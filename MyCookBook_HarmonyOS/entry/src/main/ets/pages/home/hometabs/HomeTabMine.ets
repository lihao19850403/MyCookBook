import { AppSettingsTextSizePlanModel } from '../../../models/AppSettingsTextSizeModel';
import { LHCommonTitleBar } from '../../../views/common/LHCommonTitleBar';
import { LHDivider } from '../../../views/common/LHDivider';
import { HomeTabMineFavorite } from '../../../views/HomeTabMineFavorite';
import { HomeTabMineSettings } from '../../../views/HomeTabMineSettings';
import { HomeTabMineTips } from '../../../views/HomeTabMineTips';
import { HomeMainTabBarBuilder } from '../../../views/HomeMainTabBarBuilder';

/**
 * 首页 - 个人主页。
 * @author li.hao85
 */
@Component
export struct HomeTabMine {

  /** 当前选中的Tab序号。 */
  @Prop selectedIndex: number;

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
    .tabBar(HomeMainTabBarBuilder({
      icon: this.selectedIndex === this.thisIndex ? $r('app.media.ic_home_tab_mine_selected') : $r('app.media.ic_home_tab_mine_unselected'),
      text: $r('app.string.home_tab_mine'),
      textFontSize: this.appTextSizePlan.unifiedTabBarTextSize,
      textFontColor: this.selectedIndex === this.thisIndex ? $r('app.color.main_selected_color') : $r('app.color.main_unselected_color')
    }))
  }

  @Builder
  private Content() {
    Column() {
      LHCommonTitleBar({
        centerTitleText: $r('app.string.home_tab_mine'),
        centerTitleTextSize: this.appTextSizePlan.unifiedTitleCenterTextSize
      })
      List({
        space: 24
      }) {
        HomeTabMineTips({
          appTextSizePlan: this.appTextSizePlan
        })
        HomeTabMineSettings({
          appTextSizePlan: this.appTextSizePlan
        })
        HomeTabMineFavorite({
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
}

