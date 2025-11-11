import { CopyPhotoOptions, CopyPhotoResult, PickPhotoOptions } from "./models/PhotoPickerModels";
import photoAccessHelper from "@ohos.file.photoAccessHelper";
import { BusinessError } from '@kit.BasicServicesKit';
import fs from '@ohos.file.fs';

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
        isSearchSupported: true,
      })
        .then((pickResult: photoAccessHelper.PhotoSelectResult) => resolve(pickResult))
        .catch((error: BusinessError) => reject(error));
    });
  }

  /**
   * 复制图片。
   * @param options 入参。
   */
  public static copyPhoto(options: CopyPhotoOptions): Promise<CopyPhotoResult | undefined> {
    return new Promise((resolve, reject) => {
      let sourceFile: fs.File | undefined = undefined;
      let targetFile: fs.File | undefined = undefined;
      try {
        sourceFile = fs.openSync(options.sourceUri, fs.OpenMode.READ_ONLY);
        let sourceFileName: string = sourceFile.name; // 源文件名。
        let separator: string = options.targetPath.endsWith('/') ? '' : '/'; // 文件路径分隔符。
        let targetFileUri: string = `${options.targetPath}${separator}${sourceFileName}`; // 目标文件Uri。
        targetFile = fs.openSync(targetFileUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        let copyResult: CopyPhotoResult = {
          resultUri: targetFileUri
        };
        resolve(copyResult);
      } catch (error) {
        reject(error);
      } finally {
        if (sourceFile !== undefined) {
          fs.closeSync(sourceFile);
        }
        if (targetFile !== undefined) {
          fs.closeSync(targetFile);
        }
      }
    });
  }
}