export const GLOBAL_CONFIG_KEY_WINDOW: string = 'GLOBAL_CONFIG_KEY_WINDOW';

/**
 * 全局配置。
 * @author li.hao85
 */
export class GlobalConfig {

  /** 配置记录。 */
  private static mMap: Record<string, Object> = {};

  /**
   * 设置新键值对。
   * @param key 关键字。
   * @param value 值。
   */
  public static set<T>(key: string, value: T) {
    GlobalConfig.mMap[key] = value as object;
  }

  /**
   * 获取配置值。
   * @param key 关键字。
   * @returns 值。
   */
  public static get<T>(key: string): T {
    return GlobalConfig.mMap[key] as T;
  }
}