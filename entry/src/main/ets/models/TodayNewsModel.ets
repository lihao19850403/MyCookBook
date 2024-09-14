/**
 * 今日新闻。
 * @author li.hao85
 */
export interface TodayNewsModel {

  /** 响应码。 */
  code?: number; // 200

  /** 附加信息。 */
  msg?: string; // "success"

  /** 响应数据。 */
  result?: TodayNewsResult;
}

/** 新闻数据。 */
export interface TodayNewsResult {

  /** 当前页码。 */
  curpage?: number; // 1

  /** 本轮请求返回的新闻数量。 */
  allnum?: number; // 20

  /** 新闻摘要列表。 */
  newslist?: TodayNewsItem[];
}

/** 新闻详情。 */
export interface TodayNewsItem {

  /** 新闻ID。 */
  id?: string // "fedd916abcbe82c934b2853e984b778e"

  /** 新闻标题。 */
  title?: string // "国家卫健委：引导优质医疗资源扩容下沉"

  /** 新闻发布时间。 */
  ctime?: string // "2023-04-17 23:00"

  /** 新闻抬头图。 */
  picUrl?: string // "https://nimg.ws.126.net/?url=http%3A%2F%2Fcms-bucket.ws.126.net%2F2023%2F0404%2F17e2a159j00rsjr7500tvc000u008c0c.jpg&thumbnail=150y100&quality=100&type=jpg"

  /** 新闻简报。 */
  description?: string // "“国家区域医疗中心建设项目实施以来，有1400余项诊疗技术平移至输入省份，填补了300多项省域医疗技术空白，相关省份跨省就医人数明显下降。"

  /** 新闻原链接。 */
  url?: string // "https://jiankang.163.com/23/0417/22/I2IF0GPD0038804U.html"

  /** 新闻来源。 */
  source?: string // "网易健康"
}