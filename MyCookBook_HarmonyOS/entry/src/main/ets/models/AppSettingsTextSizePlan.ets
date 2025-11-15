import { readRawFileSync } from '../utils/common//filecenter/FileUtils';
import { AppSettingsTextSizePlanModel } from './AppSettingsTextSizeModel'

/**
 * 应用设置 - 应用字号预置方案。
 * @author li.hao85
 */
export class AppSettingsTextSizePlans {

  public static SMALL: AppSettingsTextSizePlanModel = readRawFileSync<AppSettingsTextSizePlanModel>('lh_app_settings_text_size_plan_small.json5');
  public static NORMAL: AppSettingsTextSizePlanModel = readRawFileSync<AppSettingsTextSizePlanModel>('lh_app_settings_text_size_plan_normal.json5');
  public static BIG: AppSettingsTextSizePlanModel = readRawFileSync<AppSettingsTextSizePlanModel>('lh_app_settings_text_size_plan_big.json5');
  public static HUGE: AppSettingsTextSizePlanModel = readRawFileSync<AppSettingsTextSizePlanModel>('lh_app_settings_text_size_plan_huge.json5');
}