import { AppSettingsTextSizePlanModel } from '../models/AppSettingsTextSizeModel';
import { RecommendMenuItem, RecommendMenuResult } from '../models/RecommendMenuModel';
import { RouterUtils } from '../utils/common/RouterUtils';
import { ScreenUIType } from '../utils/common/ScreenUIAdapter';
import { MenuTipsCard } from './MenuTipsCard';

/**
 * 首页 - 菜谱 - 今日推荐。
 * @author li.hao85
 */
@Component
export struct HomeTabMenuRecommend {

  /** 屏幕状态。 */
  @Prop screenUIType: ScreenUIType;

  /** 应用文字字号方案。 */
  @Prop @Watch('onAppTextSizePlanChanged') appTextSizePlan: AppSettingsTextSizePlanModel;

  /** 是否使用分屏显示。 */
  @Prop isSplitScreen: boolean;

  /** 正在加载今日推荐菜谱。 */
  @Prop isLoadingRecommendMenu: boolean;

  /** 今日推荐菜谱。 */
  @Prop recommendMenu: RecommendMenuResult | undefined;

  /** 每个小卡片的高。 */
  @State cardHeight: number = -1;

  build() {
    ListItemGroup({
      header: this.RecommendMenuHeader()
    }) {
      ListItem() {
        if (this.recommendMenu !== undefined && this.recommendMenu.list !== undefined && this.recommendMenu.list.length > 0) {
          Grid() {
            ForEach(this.recommendMenu.list.slice(0, this.screenUIType === ScreenUIType.FOLD_OPENED ? 4 : 3), (menuItem: RecommendMenuItem, index: number) => {
              GridItem() {
                MenuTipsCard({
                  appTextSizePlan: this.appTextSizePlan,
                  cardHeight: this.cardHeight,
                  menuInfo: menuItem
                })
                  .onSizeChange((_, newSize: SizeOptions) => {
                    this.cardHeight = Math.max(this.cardHeight, newSize.height as number);
                  })
                  .onClick((event: ClickEvent) => RouterUtils.navPushPath('MenuDetailPage', menuItem))
              }
            })
          }
          .columnsTemplate(this.isSplitScreen ? '1fr' :
            this.screenUIType === ScreenUIType.FOLD_OPENED ? '1fr 1fr' :
            this.screenUIType === ScreenUIType.PAD ? '1fr 1fr 1fr' :
            '1fr')
          .columnsGap(4)
          .rowsGap(4)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .edgeEffect(EdgeEffect.None)
          .scrollBar(BarState.Off)
        } else {
          Text($r('app.string.no_recommend_menu_available'))
            .width('100%')
            .height('100')
            .textAlign(TextAlign.Center)
            .fontSize(this.appTextSizePlan.homeTabMenuGrayTextSize)
            .fontColor($r('app.color.main_unselected_color'))
        }
      }
    }
  }

  @Builder
  private RecommendMenuHeader() {
    Row() {
      Text($r('app.string.today_s_recommend'))
        .fontSize(this.appTextSizePlan.homeTabMenuSubTitleTextSize)
      LoadingProgress()
        .visibility(this.isLoadingRecommendMenu ? Visibility.Visible : Visibility.None)
      Blank()
        .layoutWeight(1)
      Text($r('app.string.check_all'))
        .fontColor($r('app.color.main_selected_color'))
        .fontSize(this.appTextSizePlan.homeTabMenuSubTitleTextSize)
        .visibility(this.recommendMenu !== undefined && this.recommendMenu.list !== undefined && this.recommendMenu.list.length > 0 ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height(32)
    .backgroundColor($r('app.color.main_bg_green_light_color'))
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 12, right: 12, top: 4, bottom: 4 })
    .onClick((event: ClickEvent) => {
      if (this.recommendMenu !== undefined && this.recommendMenu.list !== undefined && this.recommendMenu.list.length > 0) {
        RouterUtils.go('pages/recommendmenu/RecommendMenuListPage', this.recommendMenu);
      }
    })
  }

  /** 当字号设置方案变化时，设置cardHeight为-1，重新计算卡片的高度。 */
  onAppTextSizePlanChanged() {
    this.cardHeight = -1;
  }
}