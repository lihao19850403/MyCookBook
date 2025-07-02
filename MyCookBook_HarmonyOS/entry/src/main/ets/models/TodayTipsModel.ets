/**
 * 今日养生提示。
 * @author li.hao85
 */
export interface TodayTipsModel {

  /** 响应码。 */
  code?: number; // 200

  /** 附加信息。 */
  msg?: string; // "success"

  /** 响应数据。 */
  result?: TodayTipsResult;
}

/** 今日养生提示数据。 */
export interface TodayTipsResult {

  /** 当前页码。 */
  content?: string; // "晚上少吃一口，肚里舒服一宿。"
}