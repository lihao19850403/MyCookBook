import { AppSettingsTextSizePlanModel } from '../../../models/AppSettingsTextSizeModel';
import { ScreenUIType } from '../../../utils/common/ScreenUIAdapter';
import { LHCommonTitleBar } from '../../../views/common/LHCommonTitleBar';
import { LHDivider } from '../../../views/common/LHDivider';
import { HomeTabMineFavorite } from '../../../views/HomeTabMineFavorite';
import { HomeTabMineSettings } from '../../../views/HomeTabMineSettings';
import { HomeTabMineTips } from '../../../views/HomeTabMineTips';

/**
 * 首页 - 个人主页。
 * @author li.hao85
 */
@Component
export struct HomeTabMine {

  /** 当前选中的Tab序号。 */
  @Prop selectedIndex: number;

  /** 屏幕状态。 */
  @Prop screenUIType: ScreenUIType;

  /** 应用文字字号方案。 */
  @Prop appTextSizePlan: AppSettingsTextSizePlanModel;

  /** 此Tab序号。 */
  private thisIndex: number = 3;

  /** 首页标签控制器。 */
  private mainPageTabsController?: TabsController;

  build() {
    TabContent() {
      this.Content()
    }
    .tabBar(this.TabBarBuilder())
  }

  @Builder
  private Content() {
    Column() {
      LHCommonTitleBar({
        centerTitleText: $r("app.string.home_tab_mine"),
        centerTitleTextSize: this.appTextSizePlan.unifiedTitleCenterTextSize
      })
      List({
        space: 24
      }) {
        HomeTabMineTips({
          screenUIType: this.screenUIType,
          appTextSizePlan: this.appTextSizePlan
        })
        HomeTabMineSettings({
          screenUIType: this.screenUIType,
          appTextSizePlan: this.appTextSizePlan
        })
        HomeTabMineFavorite({
          screenUIType: this.screenUIType,
          appTextSizePlan: this.appTextSizePlan,
          mainPageTabsController: this.mainPageTabsController
        })
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.None)
      .sticky(StickyStyle.Header)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .nestedScroll({
        scrollForward: NestedScrollMode.SELF_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST,
      })
      LHDivider()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  @Builder
  private TabBarBuilder() {
    Column() {
      Image(this.selectedIndex === this.thisIndex ? $r('app.media.ic_home_tab_mine_selected') : $r('app.media.ic_home_tab_mine_unselected'))
        .width(24)
        .height(24)
        .margin({ bottom: 4 })
      Text($r('app.string.home_tab_mine'))
        .fontSize(this.appTextSizePlan.unifiedTabBarTextSize)
        .fontFamily('HarmonyHeiTi-Medium')
        .fontColor(this.selectedIndex === this.thisIndex ? $r('app.color.main_selected_color') : $r('app.color.main_unselected_color'))
    }
    .padding({ top: 6, bottom: 6 })
    .alignItems(HorizontalAlign.Center)
  }
}

