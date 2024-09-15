import { ScreenUIType } from '../../../utils/common/ScreenUIAdapter';
import { LHCommonTitleBar } from '../../../views/common/LHCommonTitleBar';
import { HomeTabNewsList } from '../../../views/HomeTabNewsList';

/**
 * 首页 - 头条。
 * @author li.hao85
 */
@Component
export struct HomeTabNews {

  /** 当前选中的Tab序号。 */
  @Prop selectedIndex: number;

  /** 屏幕状态。 */
  @Prop screenUIType: ScreenUIType;

  /** 此Tab序号。 */
  private thisIndex: number = 0;

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
        centerTitleText: $r('app.string.home_tab_news')
      })
      HomeTabNewsList({
        screenUIType: this.screenUIType
      })
        .width('100%')
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_bg_gray_color'))
  }

  @Builder
  private TabBarBuilder() {
    Column() {
      Image(this.selectedIndex === this.thisIndex ? $r('app.media.ic_home_tab_news_selected') : $r('app.media.ic_home_tab_news_unselected'))
        .width(24)
        .height(24)
        .margin({ bottom: 4 })
      Text($r('app.string.home_tab_news'))
        .fontSize(10)
        .fontFamily('HarmonyHeiTi-Medium')
        .fontColor(this.selectedIndex === this.thisIndex ? $r('app.color.main_selected_color') : $r('app.color.main_unselected_color'))
    }
    .padding({ top: 6, bottom: 6 })
    .alignItems(HorizontalAlign.Center)
  }
}

