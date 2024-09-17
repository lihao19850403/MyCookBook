/**
 * 应用设置 - 应用字号配置方案。
 * @author li.hao85
 */
export interface LHAppSettingsTextSizePlanModel {

  /** 方案ID。 */
  id: number;

  /** 标题栏中间文字字号。 */
  unifiedTitleCenterTextSize: number;

  /** 上拉加载更多提示文字字号。 */
  unifiedPullUpTipsTextSize: number;

  /** TabBar文字字号。 */
  unifiedTabBarTextSize: number;
}