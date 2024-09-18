import { LHAppSettingsTextSizePlanModel } from '../../models/common/LHAppSettingsTextSizePlanModel';
import { LHAppSettingsTextSizePlans } from '../../models/common/LHAppSettingsTextSizePlans';
import { KVUtils } from './KVUtils';

/** 应用配置文件名。 */
export const FILE_NAME_GLOBAL_APP_SETTINGS: string = 'global_app_settings';

/** 事件：应用配置方案发生了变化。 */
export const GLOBAL_APP_SETTINGS_CHANGED_EVENT: string = 'global_app_settings_changed_event';

/** 参数：应用配置方案变化类型(哪个配置项发生了变化)。 */
export const GLOBAL_APP_SETTINGS_EVENT_TYPE: string = 'GLOBAL_APP_SETTINGS_EVENT_TYPE';

/** 配置项：文字大小设置。 */
export const GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN: string = 'global_app_settings_key_text_size_plan';

/** 配置项：应用分屏设置。 */
export const GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN: string = 'global_app_settings_key_split_screen';

/**
 * 应用细节配置。
 * @author li.hao85
 */
export class GlobalAppSettings {

  /**
   * 查询应用字号大小方案设置。
   * @returns 查询结果。
   */
  public static textSizePlan(): LHAppSettingsTextSizePlanModel {
    if (!KVUtils.hasKV(FILE_NAME_GLOBAL_APP_SETTINGS, GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN)) {
      KVUtils.setKV(FILE_NAME_GLOBAL_APP_SETTINGS, GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN, LHAppSettingsTextSizePlans.SMALL.id);
    }
    let planID: number = KVUtils.queryKV(FILE_NAME_GLOBAL_APP_SETTINGS, GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN) as number;
    switch (planID) {
      case LHAppSettingsTextSizePlans.NORMAL.id: return LHAppSettingsTextSizePlans.NORMAL;
      case LHAppSettingsTextSizePlans.BIG.id: return LHAppSettingsTextSizePlans.BIG;
      case LHAppSettingsTextSizePlans.HUGE.id: return LHAppSettingsTextSizePlans.HUGE;
      case LHAppSettingsTextSizePlans.SMALL.id:
      default: return LHAppSettingsTextSizePlans.SMALL;
    }
  }

  /**
   * 设置应用字号方案。
   * @param newSizePlan 新的字号方案。
   */
  public static setTextSizePlan(newSizePlan: LHAppSettingsTextSizePlanModel) {
    KVUtils.setKV(FILE_NAME_GLOBAL_APP_SETTINGS, GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN, newSizePlan.id);
  }

  /**
   * 设置应用字号方案。
   * @param newSizePlanID 方案的ID。
   */
  public static setTextSizePlanByID(newSizePlanID: number) {
    KVUtils.setKV(FILE_NAME_GLOBAL_APP_SETTINGS, GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN, newSizePlanID);
  }

  /**
   * 查询应用是否使用了分屏显示设置。
   * @returns 查询结果。
   */
  public static isSplitScreen(): boolean {
    if (!KVUtils.hasKV(FILE_NAME_GLOBAL_APP_SETTINGS, GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN)) {
      KVUtils.setKV(FILE_NAME_GLOBAL_APP_SETTINGS, GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN, false);
    }
    return KVUtils.queryKV(FILE_NAME_GLOBAL_APP_SETTINGS, GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN) as boolean;
  }

  /**
   * 设置应用是否使用了分屏显示功能。
   * @param flag 分屏显示设置开关。
   */
  public static setIsSplitScreen(flag: boolean) {
    KVUtils.setKV(FILE_NAME_GLOBAL_APP_SETTINGS, GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN, flag);
  }
}