import preferences from '@ohos.data.preferences';
import { GlobalContext } from './GlobalContext';

/** 空的preferences配置项。 */
export const EMPTY_KV: Object = new Object();

/**
 * 读取密钥工具类。
 * @author li.hao85
 */
export class KVUtils {

  /**
   * 查询键值对。
   * @param fileName 配置文件名。
   * @param key 待查询的关键字。
   * @returns 对应的值。
   */
  public static queryKV(fileName: string, key: string): preferences.ValueType {
    let context = GlobalContext.getContext();
    if (context === undefined) {
      return EMPTY_KV;
    }
    try {
      let handler = preferences.getPreferencesSync(context, { name: fileName });
      return handler.getSync(fileName, key);
    } catch (error) {
    }
    return EMPTY_KV;
  }

  /**
   * 查询所有键值对。
   * @param fileName 配置文件名。
   * @returns 所有键值对结果。
   */
  public static queryAllKVs(fileName: string): Object {
    let context = GlobalContext.getContext();
    if (context === undefined) {
      return EMPTY_KV;
    }
    try {
      let handler = preferences.getPreferencesSync(context, { name: fileName });
      return handler.getAllSync();
    } catch (error) {
    }
    return EMPTY_KV;
  }

  /**
   * 检查指定的键值对是否存在。
   * @param fileName 配置文件名。
   * @param key 待查询的关键字。
   * @returns 查询结果。
   */
  public static hasKV(fileName: string, key: string): boolean {
    let context = GlobalContext.getContext();
    if (context === undefined) {
      return false;
    }
    try {
      let handler = preferences.getPreferencesSync(context, { name: fileName });
      return handler.hasSync(key);
    } catch (error) {
    }
    return false;
  }

  /**
   * 将键值对存入配置文件中。
   * @param fileName 配置文件名。
   * @param key 关键字。
   * @param value 值。
   */
  public static setKV(fileName: string, key: string, value: preferences.ValueType) {
    let context = GlobalContext.getContext();
    if (context === undefined) {
      return;
    }
    try {
      let handler = preferences.getPreferencesSync(context, { name: fileName });
      handler.putSync(key, value);
    } catch (error) {
    }
  }

  /**
   * 删除某个键值对。
   * @param fileName 配置文件名。
   * @param key 待删除的键。
   */
  public static removeKV(fileName: string, key: string) {
    let context = GlobalContext.getContext();
    if (context === undefined) {
      return;
    }
    try {
      let handler = preferences.getPreferencesSync(context, { name: fileName });
      handler.deleteSync(key);
    } catch (error) {
    }
  }

  /**
   * 删光键值对。
   * @param fileName 配置文件名。
   */
  public static removeAllKVs(fileName: string) {
    let context = GlobalContext.getContext();
    if (context === undefined) {
      return;
    }
    try {
      let handler = preferences.getPreferencesSync(context, { name: fileName });
      handler.clearSync();
    } catch (error) {
    }
  }

  /**
   * 刷新一遍配置文件内容。
   * @param fileName 配置文件名。
   */
  public static refresh(fileName: string) {
    let context = GlobalContext.getContext();
    if (context === undefined) {
      return;
    }
    try {
      let handler = preferences.getPreferencesSync(context, { name: fileName });
      handler.flush();
    } catch (error) {
    }
  }
}