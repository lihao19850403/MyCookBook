import {
  getScreenBottomSafeZoneHeightPx,
  getScreenTopSafeZoneHeightPx } from '../../utils/common/ScreenUIAdapter';
import { emitter } from '@kit.BasicServicesKit';
import { RecommendMenuItem } from '../../models/RecommendMenuModel';
import { RouterUtils } from '../../utils/common/RouterUtils';
import { LHCommonTitleBar, LHCommonTitleBarLeftNavBack } from '../../views/common/LHCommonTitleBar';
import { MenuDetailCard, MenuDetailCardStyle } from '../../views/MenuDetailCard';
import { LHMarkedStar } from '../../views/common/LHMarkedStar';
import { FavoriteMenuUtils } from '../../utils/FavoriteMenuUtils';
import { AppSettingsTextSizePlanModel } from '../../models/AppSettingsTextSizeModel';
import { AppSettingsTextSizePlans } from '../../models/AppSettingsTextSizePlan';
import { AppSettings } from '../../utils/AppSettings';
import { GLOBAL_APP_SETTINGS_CHANGED_EVENT,
  GLOBAL_APP_SETTINGS_EVENT_TYPE,
  GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN} from '../../utils/common/GlobalAppSettings';
import { ScreenObserver, ScreenStatusInfo } from '../../utils/common/uiobserver/ScreenObserver';
import window from '@ohos.window';

export namespace MenuDetailPage {
  export function go(params: RecommendMenuItem) {
    RouterUtils.navPushPath('MenuDetailPage', params);
  }
}

@Builder
export function MenuDetailPageBuilder() {
  MenuDetailPageComponent()
}

/**
 * 菜谱详情页。
 * @author li.hao85
 */
@Component
struct MenuDetailPageComponent {

  /** 应用文字字号方案。 */
  @State appTextSizePlan: AppSettingsTextSizePlanModel = AppSettingsTextSizePlans.SMALL;

  /** 菜谱详情。 */
  private menuItem?: RecommendMenuItem;

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
          centerTitleText: this.menuItem !== undefined && this.menuItem.cp_name !== undefined && this.menuItem.cp_name.length > 0 ? this.menuItem.cp_name : $r('app.string.home_tab_menu'),
          centerTitleTextSize: this.appTextSizePlan.unifiedTitleCenterTextSize,
          leftAction: LHCommonTitleBarLeftNavBack,
          rightAction: (): void => this.FavoriteStar()
        })
        Scroll() {
          Column() {
            MenuDetailCard({
              appTextSizePlan: this.appTextSizePlan,
              menuInfo: this.menuItem,
              style: MenuDetailCardStyle.SQUARE_BANNER,
              noTitleMode: true
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
      this.menuItem = RouterUtils.navGetParams(context) as RecommendMenuItem;
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

  @Builder
  private FavoriteStar() {
    LHMarkedStar({
      isSelected: this.menuItem !== undefined && this.menuItem.id !== undefined && FavoriteMenuUtils.isFavoriteMenu(this.menuItem.id),
      onSelectedChanged: (newStatus: boolean) => {
        if (this.menuItem !== undefined && this.menuItem.id !== undefined) {
          if (newStatus) {
            FavoriteMenuUtils.addOneFavoriteMenu(this.menuItem);
          } else {
            FavoriteMenuUtils.removeOneFavoriteMenu(this.menuItem.id);
          }
        }
      }
    })
  }
}