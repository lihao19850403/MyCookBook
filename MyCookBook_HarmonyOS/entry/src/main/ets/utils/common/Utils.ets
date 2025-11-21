import { GlobalContext } from './GlobalContext';
import { bundleManager } from '@kit.AbilityKit';
import window from '@ohos.window';

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
 * 比较两个矩形是否不同。
 * @param rectA 矩形A。
 * @param rectB 矩形B。
 * @returns 比较结果，true表示二者不同。
 */
export function diffRect(rectA?: window.Rect, rectB?: window.Rect): boolean {
  return rectA?.left !== rectB?.left ||
    rectA?.top !== rectB?.top ||
    rectA?.width !== rectB?.width ||
    rectA?.height !== rectB?.height;
}