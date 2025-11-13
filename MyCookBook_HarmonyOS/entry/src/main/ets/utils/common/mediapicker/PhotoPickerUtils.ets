import { PickPhotoOptions } from "./models/PhotoPickerModels";
import photoAccessHelper from "@ohos.file.photoAccessHelper";
import { BusinessError } from '@kit.BasicServicesKit';
import { CopyFileOptions, CopyFileResult } from "../filecenter/models/FileCopyModel";
import image from "@ohos.multimedia.image";
import fs from '@ohos.file.fs';
import { copyFile, copyFileSync, getMimeTypeOfFile } from "../filecenter/FileUtils";

/** 带有文件mime类型的存文件方法入参。 */
interface CopyFileWithMimeTypeOptions {
  /** 源文件的mime类型。 */
  sourceFileMimeType: string;
  /** 源文件名。 */
  sourceFileName: string,
  /** 目标路径。 */
  targetPath: string
}

/** 调整图片方向，并存储图片入参。 */
interface AdjustOrientationAndSavePhotoOptions extends CopyFileWithMimeTypeOptions {
  /** 源文件Uri。 */
  sourceUri: string,
  /** 源图文件对象。 */
  sourceImg: image.ImageSource,
  /** 原始方向。 */
  sourceOrientation: string
}

/** 保存位图方法入参。 */
interface SavePixelMapOptions extends CopyFileWithMimeTypeOptions {
  /** 原始位图。 */
  sourcePixelMap: PixelMap
}

/**
 * 图片选择器工具类。
 * @author li.hao85
 */
export class PhotoPickerUtils {
  /**
   * 选取图片。
   * @param options 入参。
   */
  public static pickPhoto(options?: PickPhotoOptions): Promise<photoAccessHelper.PhotoSelectResult | undefined> {
    return new Promise((resolve, reject) => {
      let photoPicker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
      photoPicker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: options?.maxSelectNumber !== undefined ? Math.max(1, options.maxSelectNumber) : 1,
        isSearchSupported: true, // 支持按关键字搜索图片。
        isPhotoTakingSupported: true, // 支持拍照获取图片。
      })
        .then((pickResult: photoAccessHelper.PhotoSelectResult) => resolve(pickResult))
        .catch((error: BusinessError) => reject(error));
    });
  }

  /**
   * 保存一张图片。
   * @param options 入参。
   */
  public static saveOnePhoto(options: CopyFileOptions): Promise<CopyFileResult | undefined> {
    let sourceFile: fs.File | undefined = undefined;
    let sourceImg: image.ImageSource | undefined = undefined;
    try {
      sourceFile = fs.openSync(options.sourceUri, fs.OpenMode.READ_ONLY);
      sourceImg = image.createImageSource(sourceFile.fd);
      let sourceFileProperties: Record<string, string | undefined> = PhotoPickerUtils.getPhotoProperties(sourceImg);
      if (sourceFileProperties !== undefined) {
        // 处理图片方向问题。
        let sourceOrientation: string | undefined = sourceFileProperties[image.PropertyKey.ORIENTATION];
        if (sourceOrientation !== undefined && sourceOrientation !== "Top-left") {
          return PhotoPickerUtils.adjustOrientationAndSavePhoto({
            sourceFileMimeType: getMimeTypeOfFile(sourceFile.name) ?? "*/*",
            sourceFileName: sourceFile.name,
            targetPath: options.targetPath,
            sourceUri: options.sourceUri,
            sourceImg: sourceImg,
            sourceOrientation: sourceOrientation,
          });
        }
      }
      return copyFile(options);
    } catch (error) {
      return new Promise((resolve, reject) => reject(error));
    } finally {
      if (sourceImg !== undefined) {
        sourceImg.release();
      }
      if (sourceFile !== undefined) {
        fs.closeSync(sourceFile);
      }
    }
  }

  /**
   * 获取图片属性。
   * @param sourceImg 源图文件对象。
   * @return 属性集合。
   */
  private static getPhotoProperties(sourceImg: image.ImageSource): Record<string, string | undefined> {
    let result: Record<string, string | undefined> = {};
    Object.keys(image.PropertyKey).forEach((propertyKeyStr: string) => {
      let propertyKey: image.PropertyKey = image.PropertyKey[propertyKeyStr];
      try {
        let propertyValue: string = sourceImg.getImagePropertySync(propertyKey);
        result[propertyKey] = propertyValue;
      } catch (error) {
        result[propertyKey] = undefined;
      }
    });
    return result;
  }

  /**
   * 调整图片方向，并存储图片。
   * @param options 入参。
   */
  private static adjustOrientationAndSavePhoto(options: AdjustOrientationAndSavePhotoOptions): Promise<CopyFileResult | undefined> {
    return new Promise(async (resolve, reject) => {
      let pixelMap: PixelMap | undefined = undefined;
      try {
        pixelMap = options.sourceImg.createPixelMapSync();
        switch (options.sourceOrientation) {
          case "Top-right": pixelMap.flipSync(true, false); break;
          case "Bottom-right": pixelMap.rotateSync(-180); break;
          case "Bottom-left": pixelMap.flipSync(false, true); break;
          case "Left-top": pixelMap.rotateSync(-270); pixelMap.flipSync(true, false); break;
          case "Right-top": pixelMap.rotateSync(-90); break;
          case "Right-bottom": pixelMap.rotateSync(-90); pixelMap.flipSync(true, false); break;
          case "Left-bottom": pixelMap.rotateSync(-270); break;
          default:
            break;
        }
        let copyResult: CopyFileResult | undefined = await PhotoPickerUtils.savePixelMapSync({
          sourceFileMimeType: options.sourceFileMimeType,
          sourceFileName: options.sourceFileName,
          targetPath: options.targetPath,
          sourcePixelMap: pixelMap
        });
        resolve(copyResult);
      } catch (error) {
        try {
          let copyResult: CopyFileResult | undefined = copyFileSync({
            sourceUri: options.sourceUri,
            targetPath: options.targetPath
          });
          resolve(copyResult);
        } catch (error) {
          reject(error);
        }
      } finally {
        if (pixelMap !== undefined) {
          pixelMap.release();
        }
      }
    });
  }

  /**
   * 同步存储位图信息。
   * @param options 入参。
   */
  private static async savePixelMapSync(options: SavePixelMapOptions): Promise<CopyFileResult | undefined> {
    let imagePacker: image.ImagePacker | undefined = undefined;
    let targetFile: fs.File | undefined = undefined;
    try {
      imagePacker = image.createImagePacker();
      let sourceFileName: string = options.sourceFileName; // 源文件名。
      let separator: string = options.targetPath.endsWith('/') ? '' : '/'; // 文件路径分隔符。
      let targetFileUri: string = `${options.targetPath}${separator}Copy${new Date().getTime()}_${sourceFileName}`; // 目标文件Uri。
      targetFile = fs.openSync(targetFileUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      await imagePacker.packToFile(options.sourcePixelMap, targetFile.fd, {
        format: options.sourceFileMimeType,
        quality: 100
      });
      let copyResult: CopyFileResult = {
        resultUri: targetFileUri
      };
      return copyResult;
    } catch (error) {
      return undefined;
    } finally {
      if (targetFile !== undefined) {
        fs.closeSync(targetFile);
      }
      if (imagePacker !== undefined) {
        imagePacker.release();
      }
    }
  }
}