import {
  getScreenBottomSafeZoneHeightPx,
  getScreenUIType, ScreenUIType, SCREEN_UI_CHANGE_EVENT, SCREEN_UI_NEW_TYPE } from '../../utils/common/ScreenUIAdapter';
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
  GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN,
  GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN} from '../../utils/common/GlobalAppSettings';

@Builder
export function MenuDetailPageBuilder() {
  MenuDetailPage()
}

/**
 * 菜谱详情页。
 * @author li.hao85
 */
@Component
struct MenuDetailPage {

  /** 屏幕状态。 */
  @State screenUIType: ScreenUIType = getScreenUIType();

  /** 应用文字字号方案。 */
  @State appTextSizePlan: AppSettingsTextSizePlanModel = AppSettingsTextSizePlans.SMALL;

  /** 是否使用分屏显示。 */
  @State isSplitScreen: boolean = false;

  /** 菜谱详情。 */
  private menuItem?: RecommendMenuItem;

  build() {
    NavDestination() {
      Column() {
        LHCommonTitleBar({
          centerTitleText: this.menuItem !== undefined && this.menuItem.cp_name !== undefined && this.menuItem.cp_name.length > 0 ? this.menuItem.cp_name : $r('app.string.home_tab_menu'),
          centerTitleTextSize: this.appTextSizePlan.unifiedTitleCenterTextSize,
          leftAction: LHCommonTitleBarLeftNavBack,
          rightAction: this.FavoriteStar.bind(this)
        })
        Scroll() {
          MenuDetailCard({
            screenUIType: this.screenUIType,
            appTextSizePlan: this.appTextSizePlan,
            isSplitScreen: this.isSplitScreen,
            menuInfo: this.menuItem,
            style: MenuDetailCardStyle.SQUARE_BANNER,
            noTitleMode: true
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
    .hideTitleBar(true)
    .backButtonIcon(undefined)
    .onReady((context: NavDestinationContext) => {
      emitter.on(SCREEN_UI_CHANGE_EVENT, (dataWrap: emitter.EventData) => {
        if (dataWrap.data) {
          let newScreenUIType: ScreenUIType = dataWrap.data[SCREEN_UI_NEW_TYPE] as ScreenUIType;
          this.screenUIType = newScreenUIType;
        }
      })
      this.menuItem = RouterUtils.navGetParams(context) as RecommendMenuItem;
      this.appTextSizePlan = AppSettings.textSizePlan();
      this.isSplitScreen = AppSettings.isSplitScreen();
      emitter.on(GLOBAL_APP_SETTINGS_CHANGED_EVENT, (dataWrap: emitter.EventData) => {
        if (dataWrap.data) {
          let eventType: string = dataWrap.data[GLOBAL_APP_SETTINGS_EVENT_TYPE] as string;
          switch (eventType) {
            case GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN: this.appTextSizePlan = AppSettings.textSizePlan(); break;
            case GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN: this.isSplitScreen = AppSettings.isSplitScreen(); break;
            default: break;
          }
        }
      });
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