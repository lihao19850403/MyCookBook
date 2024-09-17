import { LHAppSettingsTextSizePlanModel } from './common/LHAppSettingsTextSizePlanModel';

/**
 * 应用设置 - 应用字号配置方案。
 * @author li.hao85
 */
export interface AppSettingsTextSizePlanModel extends LHAppSettingsTextSizePlanModel {

  /* ---------- 首页 - 头条 ---------- */

  /** 首页头条新闻加载提示文字字号。 */
  homeTabNewsListLoadingTextSize: number;

  /** 新闻小卡片标题文字字号。 */
  newsTipsCardTitleTextSize: number;

  /** 新闻小卡片发布时间&来源文字字号。 */
  newsTipsCardSourceTextSize: number;

  /** 新闻小卡片简要描述文字字号。 */
  newsTipsCardDescriptionTextSize: number;

  /** 新闻详情卡片标题文字字号。 */
  newsDetailCardTitleTextSize: number;

  /** 新闻详情卡片发布时间&来源文字字号。 */
  newsDetailCardSourceTextSize: number;

  /** 新闻详情卡片具体描述文字字号。 */
  newsDetailCardDescriptionTextSize: number;

  /** 新闻详情卡片原文链接文字字号。 */
  newsDetailCardLinkTextSize: number;

  /* ---------- 首页 - 菜谱 ---------- */

  /** 首页菜谱通用灰色提示文字字号。 */
  homeTabMenuGrayTextSize: number;

  /** 首页菜谱小标题文字字号。 */
  homeTabMenuSubTitleTextSize: number;

  /** 菜谱小卡片菜名文字字号。 */
  menuTipsCardNameTextSize: number;

  /** 菜谱小卡片分类文字字号。 */
  menuTipsCardTypeTextSize: number;

  /** 菜谱小卡片特性文字字号。 */
  menuTipsCardTexingTextSize: number;

  /** 菜谱小卡片做法文字字号。 */
  menuTipsCardZuofaTextSize: number;

  /** 菜谱详情菜名文字字号。 */
  menuDetailCardNameTextSize: number;

  /** 菜谱详情分类文字字号。 */
  menuDetailCardTypeTextSize: number;

  /** 菜谱详情特性文字字号。 */
  menuDetailCardTexingTextSize: number;

  /** 菜谱详情原料文字字号。 */
  menuDetailCardYuanliaoTextSize: number;

  /** 菜谱详情调料文字字号。 */
  menuDetailCardTiaoliaoTextSize: number;

  /** 菜谱详情做法文字字号。 */
  menuDetailCardZuofaTextSize: number;

  /** 菜谱详情温馨提示文字字号。 */
  menuDetailCardTipsSize: number;

  /* ---------- 首页 - 我的 ---------- */

  /** 我的页面小标题文字字号。 */
  homeTabMineSubTitleTextSize: number;

  /** 我的页面每日养生内容文字字号。 */
  homeTabMineHealthTipsTextSize: number;

  /** 我的页面设置项标题文字字号。 */
  homeTabMineSettingsTitleTextSize: number;

  /** 我的页面设置项提示文字字号。 */
  homeTabMineSettingsTipsTextSize: number;
}