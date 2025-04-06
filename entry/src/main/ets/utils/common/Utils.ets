import { GlobalContext } from './GlobalContext';
import { bundleManager } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';

/**
 * 通用工具类。
 * @author li.hao85
 */

/** 一个新建的空白对象。 */
export const BLANK_OBJECT: Object = new Object();

export function firstNotVoid<T>(...objects: T[]): T {
  return firstNotVoidWithCustomRules(undefined, ...objects);
}

/**
 * 返回诸多参数中第一个不是null、undefined的参数。
 * @param customRules 自定义规则。如果设置了自定义规则，那么就按这个规则进行非空判断，否则使用默认的规则。
 * @param objects 待检测参数。
 * @returns 结果。
 */
export function firstNotVoidWithCustomRules<T>(customRules?: (object: T) => boolean, ...objects: T[]): T {
  for (let index = 0; index < objects.length; index++) {
    let object: T = objects[index];
    if (customRules !== undefined) {
      if (customRules(object)) {
        return object;
      }
    } else {
      if (object !== null && object !== undefined) {
        if (typeof object === 'string') {
          if (object !== '') {
            return object;
          }
        } else {
          return object;
        }
      }
    }
  }
  return BLANK_OBJECT as T;
}

/**
 * 将资源转成字符串。
 * @param res 待转换的资源。
 * @returns 转换结果。
 */
export function res2string(res: ResourceStr): string {
  if (typeof res === 'string') {
    return res
  }
  let context = GlobalContext.getContext();
  if (context === undefined) {
    return '';
  }
  try {
    return context.resourceManager.getStringSync(res);
  } catch (error) {
  }
  return '';
}

/**
 * 获取应用自身信息。
 * @returns 应用自身信息。
 */
export function getAppInfo(): bundleManager.BundleInfo {
  const bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION;
  const bundleInfo: bundleManager.BundleInfo = bundleManager.getBundleInfoForSelfSync(bundleFlags);
  return bundleInfo;
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

