import { getScreenBottomSafeZoneHeightPx } from '../../utils/common/ScreenUIAdapter';
import { RouterUtils } from '../../utils/common/RouterUtils';
import { LHCommonTitleBar, LHCommonTitleBarLeftBack } from '../../views/common/LHCommonTitleBar';
import { TodayNewsItem } from '../../models/TodayNewsModel';
import { NewsDetailCard, NewsDetailCardStyle } from '../../views/NewsDetailCard';

/**
 * 新闻详情页。
 * @author li.hao85
 */
@Entry
@Component
struct NewsDetailPage {
  /** 新闻详情。 */
  private newsItem?: TodayNewsItem;

  aboutToAppear(): void {
    this.newsItem = RouterUtils.getParams();
  }

  build() {
    Column() {
      LHCommonTitleBar({
        centerTitleText: $r('app.string.news'),
        leftAction: LHCommonTitleBarLeftBack
      })
      Scroll() {
        NewsDetailCard({
          newsInfo: this.newsItem,
          style: NewsDetailCardStyle.SQUARE_BANNER
        })
      }
      .width('100%')
      .scrollBar(BarState.Off)
      .padding({ bottom: px2vp(getScreenBottomSafeZoneHeightPx()) })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_bg_gray_color'))
  }
}