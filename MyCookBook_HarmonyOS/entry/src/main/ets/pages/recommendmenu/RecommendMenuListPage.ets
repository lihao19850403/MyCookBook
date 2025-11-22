import {
  getScreenBottomSafeZoneHeightPx,
  getScreenTopSafeZoneHeightPx } from '../../utils/common/ScreenUIAdapter';
import { Callback, emitter } from '@kit.BasicServicesKit';
import { LHCommonTitleBar, LHCommonTitleBarLeftNavBack } from '../../views/common/LHCommonTitleBar';
import { RecommendMenuItem, RecommendMenuResult } from '../../models/RecommendMenuModel';
import { RouterUtils } from '../../utils/common/RouterUtils';
import { MenuDetailCard, MenuDetailCardStyle } from '../../views/MenuDetailCard';
import { res2string } from '../../utils/common/Utils';
import { LengthMetrics, window } from '@kit.ArkUI';
import { LHMarkedStar } from '../../views/common/LHMarkedStar';
import { FavoriteMenuUtils } from '../../utils/FavoriteMenuUtils';
import { AppSettingsTextSizePlanModel } from '../../models/AppSettingsTextSizeModel';
import { AppSettingsTextSizePlans } from '../../models/AppSettingsTextSizePlan';
import { AppSettings } from '../../utils/AppSettings';
import { GLOBAL_APP_SETTINGS_CHANGED_EVENT,
  GLOBAL_APP_SETTINGS_EVENT_TYPE,
  GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN} from '../../utils/common/GlobalAppSettings';
import { ScreenObserver, ScreenStatusInfo } from '../../utils/common/uiobserver/ScreenObserver';

export namespace RecommendMenuListPage {
  export function go(params: RecommendMenuResult) {
    RouterUtils.navPushPath('RecommendMenuListPage', params);
  }
}

@Builder
export function RecommendMenuListPageBuilder() {
  RecommendMenuListPageComponent()
}

/**
 * 今日推荐菜谱页。
 * @author li.hao85
 */
@Component
struct RecommendMenuListPageComponent {

  /** 应用文字字号方案。 */
  @State appTextSizePlan: AppSettingsTextSizePlanModel = AppSettingsTextSizePlans.SMALL;

  /** 今日推荐菜谱数据。 */
  private recommendMenu?: RecommendMenuResult;

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
          centerTitleText: this.hasRecommendMenu() ? `${res2string($r('app.string.today_s_recommend'))}(${this.recommendMenu?.list?.length})` : $r('app.string.today_s_recommend'),
          centerTitleTextSize: this.appTextSizePlan.unifiedTitleCenterTextSize,
          leftAction: LHCommonTitleBarLeftNavBack
        })
        if (this.hasRecommendMenu()) {
          List({
            space: 4
          }) {
            ForEach(this.recommendMenu?.list, (menuItem: RecommendMenuItem, index: number) => {
              ListItem() {
                Stack({
                  alignContent: Alignment.Top
                }) {
                  MenuDetailCard({
                    appTextSizePlan: this.appTextSizePlan,
                    menuInfo: menuItem,
                    style: MenuDetailCardStyle.SQUARE_BANNER
                  })
                  Row() {
                    Text(`${index + 1}`)
                      .width(35)
                      .height(35)
                      .textAlign(TextAlign.Start)
                      .fontColor(Color.White)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .padding({ left: 5 })
                      .backgroundColor($r('app.color.menu_index_bg_color'))
                      .borderRadius({ bottomEnd: LengthMetrics.vp(35) })
                    LHMarkedStar({
                      isSelected: menuItem.id !== undefined && FavoriteMenuUtils.isFavoriteMenu(menuItem.id),
                      onSelectedChanged: (newStatus: boolean) => {
                        if (menuItem.id !== undefined) {
                          if (newStatus) {
                            FavoriteMenuUtils.addOneFavoriteMenu(menuItem);
                          } else {
                            FavoriteMenuUtils.removeOneFavoriteMenu(menuItem.id);
                          }
                        }
                      }
                    })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                  .alignItems(VerticalAlign.Center)
                }
              }
            })
            ListItem() {
              Text($r('app.string.reach_the_bottom'))
                .width('100%')
                .height(this.bottomSafeZoneHeightVp + 100)
                .textAlign(TextAlign.Center)
                .fontSize(this.appTextSizePlan.homeTabMenuGrayTextSize)
                .fontColor($r('app.color.main_unselected_color'))
                .backgroundColor($r('app.color.main_bg_gray_color'))
            }
          }
          .width('100%')
          .edgeEffect(EdgeEffect.None)
          .sticky(StickyStyle.Header)
          .scrollBar(BarState.Off)
          .flexShrink(1)
        } else {
          Text($r('app.string.no_recommend_menu_available'))
            .width('100%')
            .height('100')
            .textAlign(TextAlign.Center)
            .fontSize(this.appTextSizePlan.homeTabMenuGrayTextSize)
            .fontColor($r('app.color.main_unselected_color'))
        }
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
      this.recommendMenu = RouterUtils.navGetParams(context) as RecommendMenuResult;
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

  /**
   * 判断是否有推荐菜谱。
   * @returns 判断结果。
   */
  private hasRecommendMenu(): boolean {
    return this.recommendMenu !== undefined && this.recommendMenu.list !== undefined && this.recommendMenu.list.length > 0;
  }
}