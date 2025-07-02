/**
 * 今日推荐菜谱。
 * @author li.hao85
 */
export interface RecommendMenuModel {

  /** 响应码。 */
  code?: number; // 200

  /** 附加信息。 */
  msg?: string; // "success"

  /** 响应数据。 */
  result?: RecommendMenuResult;
}

/** 菜谱数据。 */
export interface RecommendMenuResult {

  /** 当前页码。 */
  curpage?: number; // 1

  /** 本轮请求返回的菜谱数量。 */
  allnum?: number; // 3

  /** 菜谱详情列表。 */
  list?: RecommendMenuItem[];
}

/** 菜谱详情。 */
export interface RecommendMenuItem {

  /** 菜谱ID。 */
  id?: number; // 5012

  /** 分类ID。 */
  type_id?: number; // 443

  /** 分类名称。 */
  type_name?: string; // "禽肉及其他肉类"

  /** 菜谱名称。 */
  cp_name?: string; // "家常鹅肉"

  /** 菜谱缩略图。 */
  cp_thumbnail?: string; // 缩略图链接。

  /** 菜谱做法。 */
  zuofa?: string; // "1.将鹅肉洗净切块；青笋切滚刀块；葱、姜切片；2.将油烧热，把豆瓣酱、葱片、姜片下锅煸炒，待出香味后，把鹅肉放入稍炒，烹入料酒、酱油，放入精盐、味精后继续煸炒；3.待肉上色时，加入适量开水，烧开后，转小火慢烧，待肉将熟时放入辣椒、青笋，青笋烧熟后即可。"

  /** 菜谱特性。 */
  texing?: string; // "咸鲜适口，鹅肉香浓。"

  /** 菜谱提示。 */
  tishi?: string; // "鹅肉的肉质较粗，烹制时要多炖一会，烧至鹅肉完全酥烂后口感更佳。"

  /** 菜谱调料。 */
  tiaoliao?: string; // "食用油50克；酱油3小匙(9克)；料酒3小匙(9克)；豆瓣酱1大匙(30克)；精盐1小匙(3克)；味精1/2小匙(1.5克)"

  /** 菜谱原料。 */
  yuanliao?: string; // "鹅肉300克；青笋100克；红辣椒2个；大葱1根；生姜1小块"
}