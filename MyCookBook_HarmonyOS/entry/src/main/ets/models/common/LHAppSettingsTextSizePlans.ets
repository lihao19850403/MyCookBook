import { readRawFileSync } from '../../utils/common//filecenter/FileUtils';
import { LHAppSettingsTextSizePlanModel } from './LHAppSettingsTextSizePlanModel';

/**
 * 应用设置 - 应用字号预置方案。
 * @author li.hao85
 */
export class LHAppSettingsTextSizePlans {

  public static SMALL: LHAppSettingsTextSizePlanModel = readRawFileSync<LHAppSettingsTextSizePlanModel>('lh_app_settings_text_size_plan_small.json5');
  public static NORMAL: LHAppSettingsTextSizePlanModel = readRawFileSync<LHAppSettingsTextSizePlanModel>('lh_app_settings_text_size_plan_normal.json5');
  public static BIG: LHAppSettingsTextSizePlanModel = readRawFileSync<LHAppSettingsTextSizePlanModel>('lh_app_settings_text_size_plan_big.json5');
  public static HUGE: LHAppSettingsTextSizePlanModel = readRawFileSync<LHAppSettingsTextSizePlanModel>('lh_app_settings_text_size_plan_huge.json5');
}