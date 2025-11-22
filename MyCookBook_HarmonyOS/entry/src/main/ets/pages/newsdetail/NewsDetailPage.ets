import { getScreenBottomSafeZoneHeightPx, getScreenTopSafeZoneHeightPx } from '../../utils/common/ScreenUIAdapter';
import { RouterUtils } from '../../utils/common/RouterUtils';
import { LHCommonTitleBar, LHCommonTitleBarLeftNavBack } from '../../views/common/LHCommonTitleBar';
import { TodayNewsItem } from '../../models/TodayNewsModel';
import { NewsDetailCard, NewsDetailCardStyle } from '../../views/NewsDetailCard';
import { AppSettingsTextSizePlanModel } from '../../models/AppSettingsTextSizeModel';
import { AppSettingsTextSizePlans } from '../../models/AppSettingsTextSizePlan';
import { AppSettings } from '../../utils/AppSettings';
import { emitter } from '@kit.BasicServicesKit';
import { GLOBAL_APP_SETTINGS_CHANGED_EVENT,
  GLOBAL_APP_SETTINGS_EVENT_TYPE,
  GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN} from '../../utils/common/GlobalAppSettings';
import { ScreenObserver, ScreenStatusInfo } from '../../utils/common/uiobserver/ScreenObserver';
import window from '@ohos.window';

export namespace NewsDetailPage {
  export function go(params: TodayNewsItem) {
    RouterUtils.navPushPath('NewsDetailPage', params);
  }
}

@Builder
export function NewsDetailPageBuilder() {
  NewsDetailPageComponent()
}

/**
 * 新闻详情页。
 * @author li.hao85
 */
@Component
struct NewsDetailPageComponent {

  /** 应用文字字号方案。 */
  @State appTextSizePlan: AppSettingsTextSizePlanModel = AppSettingsTextSizePlans.SMALL;

  /** 新闻详情。 */
  private newsItem?: TodayNewsItem;

  /** 顶部安全区高度。 */
  @State topSafeZoneHeightVp: number = px2vp(getScreenTopSafeZoneHeightPx());

  /** 底部安全区高度。 */
  @State bottomSafeZoneHeightVp: number = px2vp(getScreenBottomSafeZoneHeightPx());

  private onGlobalAppSettingsChangedEvent: Callback<emitter.EventData> = (dataWrap: emitter.EventData) => {
    if (dataWrap.data) {
      let eventType: string = dataWrap.data[GLOBAL_APP_SETTINGS_EVENT_TYPE] as string;
      switch (eventType) {
        case GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN: this.appTextSizePlan = AppSettings.textSizePlan(); break;
        default: break;
      }
    }
  };

  build() {
    NavDestination() {
      Column() {
        LHCommonTitleBar({
          centerTitleText: $r('app.string.news'),
          centerTitleTextSize: this.appTextSizePlan.unifiedTitleCenterTextSize,
          leftAction: LHCommonTitleBarLeftNavBack
        })
        Scroll() {
          Column() {
            NewsDetailCard({
              newsInfo: this.newsItem,
              style: NewsDetailCardStyle.SQUARE_BANNER,
              appTextSizePlan: this.appTextSizePlan
            })
            Blank()
              .width('100%')
              .height(this.bottomSafeZoneHeightVp)
          }
        }
        .width('100%')
        .scrollBar(BarState.Off)
        .flexShrink(1)
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .backgroundColor($r('app.color.main_bg_gray_color'))
      .margin({ top: this.topSafeZoneHeightVp })
    }
    .hideTitleBar(true)
    .backButtonIcon(undefined)
    .onReady((context: NavDestinationContext) => {
      this.newsItem = RouterUtils.navGetParams(context) as TodayNewsItem;
      this.appTextSizePlan = AppSettings.textSizePlan();
      emitter.on(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onGlobalAppSettingsChangedEvent);
      ScreenObserver.subscribe(this.getUIContext(), (screenStatus: ScreenStatusInfo) => {
        if (screenStatus.avoidArea !== undefined) {
          if (screenStatus.avoidAreaType === window.AvoidAreaType.TYPE_SYSTEM) {
            this.topSafeZoneHeightVp = px2vp(screenStatus.avoidArea.topRect.height);
          } else if (screenStatus.avoidAreaType === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
            this.bottomSafeZoneHeightVp = px2vp(screenStatus.avoidArea.bottomRect.height);
          }
        }
      });
    })
    .onDisAppear(() => {
      emitter.off(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onGlobalAppSettingsChangedEvent);
      ScreenObserver.unsubscribe(this.getUIContext());
    })
  }
}