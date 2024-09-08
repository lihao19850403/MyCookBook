import { RecommendMenuItem, RecommendMenuResult } from '../../../models/RecommendMenuModel';
import { RouterUtils } from '../../../utils/common/RouterUtils';
import { ScreenUIType } from '../../../utils/common/ScreenUIAdapter';
import { MenuTipsCard } from '../../../views/MenuTipsCard';

/**
 * 首页 - 菜谱 - 今日推荐。
 * @author li.hao85
 */
@Component
export struct HomeTabMenuRecommend {

  /** 屏幕状态。 */
  @Prop screenUIType: ScreenUIType;

  /** 正在加载今日推荐菜谱。 */
  @Prop isLoadingRecommendMenu: boolean;

  /** 今日推荐菜谱。 */
  @Prop recommendMenu: RecommendMenuResult | undefined;

  build() {
    this.Build()
  }

  @Builder
  private Build() {
    ListItemGroup({
      header: this.RecommendMenuHeader()
    }) {
      ListItem() {
        if (this.recommendMenu !== undefined && this.recommendMenu.list !== undefined && this.recommendMenu.list.length > 0) {
          Grid() {
            ForEach(this.recommendMenu.list.slice(0, 3), (menuItem: RecommendMenuItem, index: number) => {
              GridItem() {
                MenuTipsCard({
                  menuInfo: menuItem
                })
                  .onClick((event: ClickEvent) => RouterUtils.go('pages/menudetail/MenuDetailPage', menuItem))
              }
            })
          }
          .columnsTemplate(this.screenUIType === ScreenUIType.FOLD_OPENED ? '1fr 1fr'
            : this.screenUIType === ScreenUIType.PAD ? '1fr 1fr 1fr'
              : '1fr')
          .columnsGap(4)
          .rowsGap(4)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        } else {
          Text($r('app.string.no_recommend_menu_available'))
            .width('100%')
            .height('100')
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .fontColor($r('app.color.main_unselected_color'))
        }
      }
    }
  }

  @Builder
  RecommendMenuHeader() {
    Row() {
      Text($r('app.string.today_s_recommend'))
        .fontSize(14)
      LoadingProgress()
        .visibility(this.isLoadingRecommendMenu ? Visibility.Visible : Visibility.None)
      Blank()
        .layoutWeight(1)
      Text($r('app.string.check_all'))
        .fontColor($r('app.color.main_selected_color'))
        .fontSize(14)
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
}