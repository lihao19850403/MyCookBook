import { KVUtils } from './common/KVUtils';

/** 应用配置文件名。 */
const FILE_NAME_APP_SETTINGS: string = 'app_settings';

/** 配置项：选择首页。 */
const APP_SETTINGS_KEY_FIRST_PAGE: string = 'app_settings_key_first_page';

/**
 * 应用设置工具类。
 * @author li.hao85
 */
export class AppSettings {

  /**
   * 查询启动应用将首先显示的Tab序号。
   * @returns 查询结果。
   */
  public static firstPageIndex(): number {
    if (!KVUtils.hasKV(FILE_NAME_APP_SETTINGS, APP_SETTINGS_KEY_FIRST_PAGE)) {
      KVUtils.setKV(FILE_NAME_APP_SETTINGS, APP_SETTINGS_KEY_FIRST_PAGE, 0);
    }
    return KVUtils.queryKV(FILE_NAME_APP_SETTINGS, APP_SETTINGS_KEY_FIRST_PAGE) as number;
  }

  /**
   * 设置启动应用将首先显示的Tab序号。
   * @param newIndex 启动应用将首先显示的Tab序号。
   */
  public static setFirstPageIndex(newIndex: number) {
    KVUtils.setKV(FILE_NAME_APP_SETTINGS, APP_SETTINGS_KEY_FIRST_PAGE, newIndex);
  }
}