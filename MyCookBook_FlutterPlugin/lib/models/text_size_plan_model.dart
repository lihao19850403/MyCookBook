/// 应用字号方案。
class AppSettingsTextSizePlanModel {
  /* 私有构造方法。 */
  AppSettingsTextSizePlanModel._internal(
      {required this.id,
      required this.unifiedTitleCenterTextSize,
      required this.listItemMenuNameTextSize,
      required this.listItemCategoryNameTextSize,
      required this.listItemTexingTextSize,
      required this.listItemAuthorInfoTextSize,
      required this.detailModifyContentTextSize});

  /// 方案ID。
  int id;

  /// 标题栏文字字号。
  double unifiedTitleCenterTextSize;

  /// 列表页菜谱名称字号。
  double listItemMenuNameTextSize;

  /// 列表页菜谱分类名称字号。
  double listItemCategoryNameTextSize;

  /// 列表页菜谱特性字号。
  double listItemTexingTextSize;

  /// 列表页菜谱作者信息字号。
  double listItemAuthorInfoTextSize;

  /// 详情页&修改页内容文字字号。
  double detailModifyContentTextSize;

  /* ---------- 预置字号方案。 ---------- */

  static final AppSettingsTextSizePlanModel SMALL =
      AppSettingsTextSizePlanModel._internal(
          id: 0,
          unifiedTitleCenterTextSize: 18,
          listItemMenuNameTextSize: 18,
          listItemCategoryNameTextSize: 12,
          listItemTexingTextSize: 12,
          listItemAuthorInfoTextSize: 12,
          detailModifyContentTextSize: 14);

  static final AppSettingsTextSizePlanModel NORMAL =
      AppSettingsTextSizePlanModel._internal(
          id: 1,
          unifiedTitleCenterTextSize: 19,
          listItemMenuNameTextSize: 19,
          listItemCategoryNameTextSize: 13,
          listItemTexingTextSize: 13,
          listItemAuthorInfoTextSize: 13,
          detailModifyContentTextSize: 15);

  static final AppSettingsTextSizePlanModel BIG =
      AppSettingsTextSizePlanModel._internal(
          id: 2,
          unifiedTitleCenterTextSize: 20,
          listItemMenuNameTextSize: 20,
          listItemCategoryNameTextSize: 14,
          listItemTexingTextSize: 14,
          listItemAuthorInfoTextSize: 14,
          detailModifyContentTextSize: 16);

  static final AppSettingsTextSizePlanModel HUGE =
      AppSettingsTextSizePlanModel._internal(
          id: 3,
          unifiedTitleCenterTextSize: 22,
          listItemMenuNameTextSize: 22,
          listItemCategoryNameTextSize: 15,
          listItemTexingTextSize: 15,
          listItemAuthorInfoTextSize: 15,
          detailModifyContentTextSize: 18);
}
