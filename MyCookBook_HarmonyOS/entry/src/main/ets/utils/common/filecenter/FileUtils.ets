import fs from '@ohos.file.fs';
import { CopyFileOptions, CopyFileResult } from './models/FileCopyModel';
import uniformTypeDescriptor from '@ohos.data.uniformTypeDescriptor';
import { GlobalContext } from '../GlobalContext';
import { BLANK_OBJECT } from '../Utils';
import util from '@ohos.util';

/**
 * 文件处理通用工具类。
 * @author li.hao85
 */

/**
 * 判断文件是否存在。
 * @param fileUri 文件路径信息。
 * @returns 判断结果。
 */
export function isFileExist(fileUri?: string): boolean {
  if (fileUri === undefined) {
    return false;
  }
  try {
    return fs.accessSync(fileUri);
  } catch (error) {
    return false;
  }
}

/**
 * 复制文件。
 * @param options 入参。
 */
export function copyFile(options: CopyFileOptions): Promise<CopyFileResult | undefined> {
  return new Promise((resolve, reject) => {
    try {
      let copyResult: CopyFileResult | undefined = copyFileSync(options);
      resolve(copyResult);
    } catch (error) {
      reject(error);
    }
  });
}

/**
 * 复制文件(同步方法)。
 * @param options 入参。
 * @returns 复制结果。
 * @throws 复制过程中会出现异常，须捕获。
 */
export function copyFileSync(options: CopyFileOptions): CopyFileResult | undefined {
  let sourceFile: fs.File | undefined = undefined;
  let targetFile: fs.File | undefined = undefined;
  try {
    sourceFile = fs.openSync(options.sourceUri, fs.OpenMode.READ_ONLY);
    let sourceFileName: string = sourceFile.name; // 源文件名。
    let separator: string = options.targetPath.endsWith('/') ? '' : '/'; // 文件路径分隔符。
    let targetFileUri: string =
      `${options.targetPath}${separator}Copy${new Date().getTime()}_${sourceFileName}`; // 目标文件Uri。
    targetFile = fs.openSync(targetFileUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    fs.copyFileSync(sourceFile.fd, targetFile.fd);
    let copyResult: CopyFileResult = {
      resultUri: targetFileUri
    };
    return copyResult;
  } catch (error) {
    throw new Error(error);
  } finally {
    if (sourceFile !== undefined) {
      fs.closeSync(sourceFile);
    }
    if (targetFile !== undefined) {
      fs.closeSync(targetFile);
    }
  }
}

/**
 * 根据文件名查询文件的mime类型。
 * @param fileName 文件名。
 * @returns 文件类型。
 */
export function getMimeTypeOfFile(fileName: string): string | undefined {
  let fileExtention: string | undefined = fileName.substring(fileName.lastIndexOf('.'));
  if (fileExtention === undefined) {
    return undefined;
  }
  try {
    let typeId: string = uniformTypeDescriptor.getUniformDataTypeByFilenameExtension(fileExtention);
    let typeObj: uniformTypeDescriptor.TypeDescriptor = uniformTypeDescriptor.getTypeDescriptor(typeId);
    let mimeTypes: string[] = typeObj.mimeTypes;
    return mimeTypes[0];
  } catch (error) {
    return undefined;
  }
}

/**
 * 获取rawfile文件夹中的文件内容，并解析成需要的格式。
 * @param fileName 文件名，含扩展名。
 * @returns 指定的对象，解析失败会返回一个空对象。
 */
export function readRawFileSync<T>(fileName: string): T {
  let context = GlobalContext.getContext();
  if (context === undefined) {
    return BLANK_OBJECT as T;
  }
  try {
    let rawFile = context.resourceManager.getRawFileContentSync(fileName);
    let textDecoder = util.TextDecoder.create('UTF-8', { ignoreBOM: true });
    let fileContent: string = textDecoder.decodeToString(rawFile, { stream: false });
    return JSON.parse(fileContent) as T;
  } catch (error) {
  }
  return BLANK_OBJECT as T;
}