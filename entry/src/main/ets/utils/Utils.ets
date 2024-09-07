/**
 * 通用工具类。
 * @author li.hao85
 */

/** 一个新建的空白对象。 */
export const BLANK_OBJECT: Object = new Object();

/**
 * 返回诸多参数中第一个不是null、undefined的参数。
 * @param objects 待检测参数。
 * @returns 结果。Record<K extends keyof any, T>
 */
export function firstNotVoid<T>(...objects: T[]): T {
  for (let index = 0; index < objects.length; index++) {
    let object: T = objects[index];
    if (object !== null && object !== undefined) {
      return object;
    }
  }
  return BLANK_OBJECT as T;
}