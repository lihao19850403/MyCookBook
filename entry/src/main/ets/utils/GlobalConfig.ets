export const GLOBAL_CONFIG_KEY_WINDOW: string = 'GLOBAL_CONFIG_KEY_WINDOW';
export const GLOBAL_CONFIG_KEY_WINDOW_WIDTH_PX: string = 'GLOBAL_CONFIG_KEY_WINDOW_WIDTH_PX';
export const GLOBAL_CONFIG_KEY_WINDOW_HEIGHT_PX: string = 'GLOBAL_CONFIG_KEY_WINDOW_HEIGHT_PX';

/**
 * 全局配置。
 * @author li.hao85
 */
export class GlobalConfig {

  /** 配制记录。 */
  private static mMap: Record<string, Object> = {};

  /**
   * 设置新键值对。
   * @param key 关键字。
   * @param value 值。
   */
  public static set(key: string, value: Object) {
    GlobalConfig.mMap[key] = value;
  }

  /**
   * 获取配置值。
   * @param key 关键字。
   * @returns 值。
   */
  public static get(key: string): Object {
    return GlobalConfig.mMap[key];
  }
}