import { AppSettingsTextSizePlanModel } from '../../../models/AppSettingsTextSizeModel';
import { LHCommonTitleBar } from '../../../views/common/LHCommonTitleBar';
import { HomeTabNewsList } from '../../../views/HomeTabNewsList';
import { HomeMainTabBarBuilder } from '../../../views/HomeMainTabBarBuilder';

/**
 * 首页 - 头条。
 * @author li.hao85
 */
@Component
export struct HomeTabNews {

  /** 当前选中的Tab序号。 */
  @Prop selectedIndex: number;

  /** 应用启动后显示的第一个Tab的序号。 */
  @Prop firstPageIndex?: number;

  /** 应用文字字号方案。 */
  @Prop appTextSizePlan: AppSettingsTextSizePlanModel;

  /** 此Tab序号。 */
  private thisIndex: number = 0;

  build() {
    TabContent() {
      this.Content()
    }
    .tabBar(HomeMainTabBarBuilder({
      uiContext: this.getUIContext(),
      icon: this.selectedIndex === this.thisIndex ? $r('app.media.ic_home_tab_top_news_selected') : $r('app.media.ic_home_tab_top_news_unselected'),
      text: $r('app.string.home_tab_top_news'),
      textFontSize: this.appTextSizePlan.unifiedTabBarTextSize,
      textFontColor: this.selectedIndex === this.thisIndex ? $r('app.color.main_selected_color') : $r('app.color.main_unselected_color'),
      showFirstPagePopTips: this.firstPageIndex === this.thisIndex,
      onPopTipsShowed: () => this.firstPageIndex = undefined
    }))
  }

  @Builder
  private Content() {
    Column() {
      LHCommonTitleBar({
        centerTitleText: $r('app.string.home_tab_top_news'),
        centerTitleTextSize: this.appTextSizePlan.unifiedTitleCenterTextSize
      })
      HomeTabNewsList({
        appTextSizePlan: this.appTextSizePlan
      })
        .width('100%')
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_bg_gray_color'))
  }
}

