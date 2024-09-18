import { getScreenBottomSafeZoneHeightPx } from '../../utils/common/ScreenUIAdapter';
import { RouterUtils } from '../../utils/common/RouterUtils';
import { LHCommonTitleBar, LHCommonTitleBarLeftBack } from '../../views/common/LHCommonTitleBar';
import { TodayNewsItem } from '../../models/TodayNewsModel';
import { NewsDetailCard, NewsDetailCardStyle } from '../../views/NewsDetailCard';
import { AppSettingsTextSizePlanModel } from '../../models/AppSettingsTextSizeModel';
import { AppSettingsTextSizePlans } from '../../models/AppSettingsTextSizePlan';
import { AppSettings } from '../../utils/AppSettings';
import { emitter } from '@kit.BasicServicesKit';
import { GLOBAL_APP_SETTINGS_CHANGED_EVENT,
  GLOBAL_APP_SETTINGS_EVENT_TYPE,
  GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN} from '../../utils/common/GlobalAppSettings';

/**
 * 新闻详情页。
 * @author li.hao85
 */
@Entry
@Component
struct NewsDetailPage {

  /** 应用文字字号方案。 */
  @State appTextSizePlan: AppSettingsTextSizePlanModel = AppSettingsTextSizePlans.SMALL;

  /** 新闻详情。 */
  private newsItem?: TodayNewsItem;

  aboutToAppear(): void {
    this.newsItem = RouterUtils.getParams();
    this.appTextSizePlan = AppSettings.textSizePlan();
    emitter.on(GLOBAL_APP_SETTINGS_CHANGED_EVENT, (dataWrap: emitter.EventData) => {
      if (dataWrap.data) {
        let eventType: string = dataWrap.data[GLOBAL_APP_SETTINGS_EVENT_TYPE] as string;
        switch (eventType) {
          case GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN: this.appTextSizePlan = AppSettings.textSizePlan(); break;
          default: break;
        }
      }
    });
  }

  build() {
    Column() {
      LHCommonTitleBar({
        centerTitleText: $r('app.string.news'),
        centerTitleTextSize: this.appTextSizePlan.unifiedTitleCenterTextSize,
        leftAction: LHCommonTitleBarLeftBack
      })
      Scroll() {
        NewsDetailCard({
          newsInfo: this.newsItem,
          style: NewsDetailCardStyle.SQUARE_BANNER,
          appTextSizePlan: this.appTextSizePlan
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