import { KVUtils } from './common/KVUtils';
import { AppSettingsTextSizePlanModel } from '../models/AppSettingsTextSizeModel';
import { AppSettingsTextSizePlans } from '../models/AppSettingsTextSizePlan';
import { FILE_NAME_GLOBAL_APP_SETTINGS, GlobalAppSettings } from './common/GlobalAppSettings';

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
    if (!KVUtils.hasKV(FILE_NAME_GLOBAL_APP_SETTINGS, APP_SETTINGS_KEY_FIRST_PAGE)) {
      KVUtils.setKV(FILE_NAME_GLOBAL_APP_SETTINGS, APP_SETTINGS_KEY_FIRST_PAGE, 0);
    }
    return KVUtils.queryKV(FILE_NAME_GLOBAL_APP_SETTINGS, APP_SETTINGS_KEY_FIRST_PAGE) as number;
  }

  /**
   * 设置启动应用将首先显示的Tab序号。
   * @param newIndex 启动应用将首先显示的Tab序号。
   */
  public static setFirstPageIndex(newIndex: number) {
    KVUtils.setKV(FILE_NAME_GLOBAL_APP_SETTINGS, APP_SETTINGS_KEY_FIRST_PAGE, newIndex);
  }

  /**
   * 查询应用字号大小方案设置。
   * @returns 查询结果。
   */
  public static textSizePlan(): AppSettingsTextSizePlanModel {
    let planID: number = GlobalAppSettings.textSizePlan().id;
    switch (planID) {
      case AppSettingsTextSizePlans.NORMAL.id: return AppSettingsTextSizePlans.NORMAL;
      case AppSettingsTextSizePlans.BIG.id: return AppSettingsTextSizePlans.BIG;
      case AppSettingsTextSizePlans.HUGE.id: return AppSettingsTextSizePlans.HUGE;
      case AppSettingsTextSizePlans.SMALL.id:
      default: return AppSettingsTextSizePlans.SMALL;
    }
  }

  /**
   * 设置应用字号方案。
   * @param newSizePlan 新的字号方案。
   */
  public static setTextSizePlan(newSizePlan: AppSettingsTextSizePlanModel) {
    GlobalAppSettings.setTextSizePlan(newSizePlan);
  }

  /**
   * 设置应用字号方案。
   * @param newSizePlanID 方案的ID。
   */
  public static setTextSizePlanByID(newSizePlanID: number) {
    GlobalAppSettings.setTextSizePlanByID(newSizePlanID);
  }
}