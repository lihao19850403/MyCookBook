import { common } from '@kit.AbilityKit';
import { FlutterAbilityLaunchConfigs, FlutterPage, FlutterView } from '@ohos/flutter_ohos';
import { GlobalContext } from '../../utils/common/GlobalContext';
import { RouterUtils } from '../../utils/common/RouterUtils';
import { getScreenBottomSafeZoneHeightPx, getScreenTopSafeZoneHeightPx,
  getScreenUIType } from '../../utils/common/ScreenUIAdapter';
import FlutterWrapEntry from '../utils/FlutterWrapEntry';
import emitter from '@ohos.events.emitter';
import {
  GLOBAL_APP_SETTINGS_CHANGED_EVENT,
  GLOBAL_APP_SETTINGS_EVENT_TYPE,
  GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN,
  GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN} from '../../utils/common/GlobalAppSettings';
import { AppSettings } from '../../utils/AppSettings';
import { ScreenObserver, ScreenStatusInfo } from '../../utils/common/uiobserver/ScreenObserver';
import window from '@ohos.window';

/** 跳转Flutter内容页时传递的参数。 */
export interface FlutterPathInfo {
  /** Flutter页面路由名称。 */
  path: string;
  /** Flutter页面路由参数。 */
  params?: Record<string, Object | undefined>;
}

export namespace FlutterIndexPage {
  export function go(pathInfo: FlutterPathInfo) {
    // 解析页面跳转参数。
    let path: string = pathInfo.path;
    let params: Record<string, Object> = {};
    if (pathInfo.params !== undefined) {
      Object.keys(pathInfo.params).forEach((key: string) => {
        let value: Object | undefined = pathInfo.params?.[key];
        if (value !== undefined) {
          params[key] = value;
        }
      })
    }
    // 增加全局设置参数。
    params['screenTopSafeZoneHeightVP'] = px2vp(getScreenTopSafeZoneHeightPx());
    params['screenBottomSafeZoneHeightVP'] = px2vp(getScreenBottomSafeZoneHeightPx());
    params['screenUIType'] = getScreenUIType();
    params['splitScreenSetting'] = AppSettings.isSplitScreen();
    params['textSizePlanID'] = AppSettings.textSizePlan().id;
    let routerParams: Record<string, Object> = {};
    routerParams[FlutterAbilityLaunchConfigs.EXTRA_INITIAL_ROUTE] = `${path}?${JSON.stringify(params)}`;
    RouterUtils.navPushPath('FlutterIndexPage', routerParams);
  }
}

@Builder
export function FlutterIndexPageBuilder() {
  FlutterIndexPageComponent()
}

/**
 * Flutter模块入口页。
 * @author li.hao85
 */
@Component
struct FlutterIndexPageComponent {
  private context = GlobalContext.getContext() as common.UIAbilityContext;
  private flutterEntry?: FlutterWrapEntry;
  private flutterView?: FlutterView;

  private onGlobalAppSettingsChangedEvent: Callback<emitter.EventData> = (dataWrap: emitter.EventData) => {
    if (dataWrap.data) {
      let eventType: string = dataWrap.data[GLOBAL_APP_SETTINGS_EVENT_TYPE] as string;
      switch (eventType) {
        case GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN: {
          let isSplitScreen: boolean = AppSettings.isSplitScreen();
          this.flutterEntry?.callFlutterBridgeMethod('splitScreenSettingChanged', isSplitScreen);
        } break;
        case GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN: {
          let curAppTestSizePlanID: number = AppSettings.textSizePlan().id;
          this.flutterEntry?.callFlutterBridgeMethod('appTextSizePlanChanged', curAppTestSizePlanID);
        } break;
        default: break;
      }
    }
  };

  build() {
    NavDestination() {
      Stack() {
        FlutterPage({
          viewId: this.flutterView?.getId()
        })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backButtonIcon(undefined)
    .onReady((context: NavDestinationContext) => {
      let params: Record<string, Object> = RouterUtils.navGetParams(context) as Record<string, Object>;
      this.flutterEntry = new FlutterWrapEntry(this.context, params);
      this.flutterEntry.aboutToAppear();
      this.flutterView = this.flutterEntry.getFlutterView();
      emitter.on(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onGlobalAppSettingsChangedEvent);
      ScreenObserver.subscribe(this.getUIContext(), (screenStatus: ScreenStatusInfo) => {
        this.flutterEntry?.callFlutterBridgeMethod('screenUITypeChanged', screenStatus.screenUIType);
        if (screenStatus.avoidArea !== undefined) {
          let newAvoidAreaData: Record<string, Object> = {};
          if (screenStatus.avoidAreaType === window.AvoidAreaType.TYPE_SYSTEM) {
            newAvoidAreaData['screenTopSafeZoneHeightVP'] = px2vp(screenStatus.avoidArea.topRect.height);
          } else if (screenStatus.avoidAreaType === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
            newAvoidAreaData['screenBottomSafeZoneHeightVP'] = px2vp(screenStatus.avoidArea.bottomRect.height);
          }
          this.flutterEntry?.callFlutterBridgeMethod('avoidAreaChanged', newAvoidAreaData);
        }
      });
    })
    .onShown(() => this.flutterEntry?.onPageShow())
    .onHidden(() => this.flutterEntry?.onPageHide())
    .onDisAppear(() => {
      emitter.off(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onGlobalAppSettingsChangedEvent);
      ScreenObserver.unsubscribe(this.getUIContext());
      this.flutterEntry?.aboutToDisappear();
    })
    .onBackPressed(() => {
      this.flutterEntry?.callFlutterBack();
      return true;
    })
  }
}