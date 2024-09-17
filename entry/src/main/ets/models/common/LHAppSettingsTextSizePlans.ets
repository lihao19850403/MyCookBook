import { LHAppSettingsTextSizePlanModel } from './LHAppSettingsTextSizePlanModel';

/**
 * 应用设置 - 应用字号预置方案。
 * @author li.hao85
 */
export class LHAppSettingsTextSizePlans {

  public static SMALL: LHAppSettingsTextSizePlanModel = {
    id: 0,
    unifiedTitleCenterTextSize: 18,
    unifiedPullUpTipsTextSize: 16,
    unifiedTabBarTextSize: 10,
  };

  public static NORMAL: LHAppSettingsTextSizePlanModel = {
    id: 1,
    unifiedTitleCenterTextSize: 19,
    unifiedPullUpTipsTextSize: 17,
    unifiedTabBarTextSize: 11,
  };

  public static BIG: LHAppSettingsTextSizePlanModel = {
    id: 2,
    unifiedTitleCenterTextSize: 20,
    unifiedPullUpTipsTextSize: 18,
    unifiedTabBarTextSize: 12,
  };

  public static HUGE: LHAppSettingsTextSizePlanModel = {
    id: 3,
    unifiedTitleCenterTextSize: 22,
    unifiedPullUpTipsTextSize: 20,
    unifiedTabBarTextSize: 14,
  };
}