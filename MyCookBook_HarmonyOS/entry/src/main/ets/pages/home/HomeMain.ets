import { Callback, emitter } from '@kit.BasicServicesKit';
import { AppSettingsTextSizePlanModel } from '../../models/AppSettingsTextSizeModel';
import { AppSettings } from '../../utils/AppSettings';
import {
  GLOBAL_APP_SETTINGS_CHANGED_EVENT,
  GLOBAL_APP_SETTINGS_EVENT_TYPE,
  GLOBAL_APP_SETTINGS_KEY_FIRST_PAGE_INDEX,
  GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN,
  GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN
} from '../../utils/common/GlobalAppSettings';
import { GlobalConfig, GLOBAL_CONFIG_KEY_WINDOW } from '../../utils/common/GlobalConfig';
import { RouterUtils, ROUTER_CONFIG_KEY_ROUTER_STACK } from '../../utils/common/RouterUtils';
import {
  getScreenBottomSafeZoneHeightPx,
  getScreenTopSafeZoneHeightPx,
  getScreenUIType,
  ScreenUIType } from '../../utils/common/ScreenUIAdapter';
import { HomeTabMenu } from './hometabs/HomeTabMenu';
import { HomeTabMine } from './hometabs/HomeTabMine';
import { HomeTabNews } from './hometabs/HomeTabNews';
import { HomeTabSocialize } from './hometabs/HomeTabSocialize';
import window from '@ohos.window';
import { ScreenObserver, ScreenStatusInfo } from '../../utils/common/uiobserver/ScreenObserver';

/**
 * 事件：物理返回键额外监听。
 * 用在全局配置设置中，监听函数格式为() => boolean。
 * 首页的onBackPress被触发后会拿出此监听函数的数组，并依次执行里面的函数，如果有任意一个函数执行结果为true，则onBackPress不再执行后续动作。
 */
export const GLOBAL_CONFIG_BACK_KEY_EVENT: string = 'GlobalConfigBackKeyEvent';

/** 底部导航区宽度类型。 */
enum NAV_BAR_WIDTH_TYPE {
  /** 小，占35%宽。 */ SMALL,
  /** 中，占50%宽。 */MIDDLE,
  /** 大，占100%宽。 */ FULL
}

/**
 * 首页。
 * @author li.hao85
 */
@Entry
@Component
struct HomeMain {

  /** 应用启动后显示的第一个Tab页，当在设置页进行更改后会被赋值，触发Pop提示。 */
  @State firstPageIndex?: number = undefined;

  /** 应用文字字号方案。 */
  @State appTextSizePlan: AppSettingsTextSizePlanModel = AppSettings.textSizePlan();

  /** 当前选中的标签序号。 */
  @State curSelectedTabIndex: number = 0;

  /** 标签页控制器。 */
  private tabsController: TabsController = new TabsController();

  /** 页面栈控制器。 */
  private routerStack: NavPathStack = new NavPathStack();

  /** 应用的Navigation框架宽度，单位是px。 */
  private navWidthPx: number | undefined = undefined;

  /** 应用的Navigation框架高度，单位是px。 */
  private navHeightPx: number | undefined = undefined;

  /** 是否使用分屏显示。 */
  private isSplitScreen: boolean = AppSettings.isSplitScreen();

  /** 屏幕状态信息。 */
  private screenStatusInfo: ScreenStatusInfo | undefined = undefined;

  /** 顶部安全区高度。 */
  @State topSafeZoneHeightVp: number = px2vp(getScreenTopSafeZoneHeightPx());

  /** 底部安全区高度。 */
  @State bottomSafeZoneHeightVp: number = px2vp(getScreenBottomSafeZoneHeightPx());

  /** tabs标签栏纵向排列模式。 */
  @State tabsVerticalMode: boolean = false;

  /** 底部导航栏宽度类型。 */
  @State navBarWidthType: NAV_BAR_WIDTH_TYPE = NAV_BAR_WIDTH_TYPE.FULL;

  /** 页面叠加模式。 */
  @State navMode: NavigationMode = NavigationMode.Stack;

  private onGlobalAppSettingsChangedEvent: Callback<emitter.EventData> = (dataWrap: emitter.EventData) => {
    if (dataWrap.data) {
      let eventType: string = dataWrap.data[GLOBAL_APP_SETTINGS_EVENT_TYPE] as string;
      switch (eventType) {
        case GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN:
          this.appTextSizePlan = AppSettings.textSizePlan();
          break;
        case GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN: {
          this.isSplitScreen = AppSettings.isSplitScreen();
          this.calcScreenParams();
        }
          break;
        case GLOBAL_APP_SETTINGS_KEY_FIRST_PAGE_INDEX:
          this.firstPageIndex = AppSettings.firstPageIndex();
          break;
        default:
          break;
      }
    }
  };

  aboutToAppear(): void {
    GlobalConfig.set(ROUTER_CONFIG_KEY_ROUTER_STACK, this.routerStack);
    emitter.on(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onGlobalAppSettingsChangedEvent);
    ScreenObserver.subscribe(this.getUIContext(), (screenStatus: ScreenStatusInfo) => {
      this.screenStatusInfo = screenStatus;
      this.calcScreenParams();
    });
    this.calcScreenParams();
    setTimeout(() => this.curSelectedTabIndex = AppSettings.firstPageIndex(), 0);
  }

  aboutToDisappear(): void {
    emitter.off(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onGlobalAppSettingsChangedEvent);
    ScreenObserver.unsubscribe(this.getUIContext());
  }

  onBackPress(): boolean | void {
    if (RouterUtils.navGetPathsCount() > 0) {
      RouterUtils.navBack();
      return true;
    }
    let backKeyEvents: Array<() => boolean> | undefined = GlobalConfig.get(GLOBAL_CONFIG_BACK_KEY_EVENT);
    if (backKeyEvents !== undefined && backKeyEvents.length > 0) {
      for (let index = 0; index < backKeyEvents.length; index++) {
        let func: () => boolean = backKeyEvents[index];
        if (func()) {
          return true;
        }
      }
    }
    return false;
  }

  build() {
    Navigation(this.routerStack) {
      Tabs({
        barPosition: this.tabsVerticalMode ? BarPosition.Start : BarPosition.End,
        index: this.curSelectedTabIndex,
        controller: this.tabsController
      }) {
        HomeTabNews({
          selectedIndex: this.curSelectedTabIndex,
          firstPageIndex: this.firstPageIndex,
          appTextSizePlan: this.appTextSizePlan
        })
        HomeTabMenu({
          selectedIndex: this.curSelectedTabIndex,
          firstPageIndex: this.firstPageIndex,
          appTextSizePlan: this.appTextSizePlan
        })
        HomeTabSocialize({
          selectedIndex: this.curSelectedTabIndex,
          firstPageIndex: this.firstPageIndex,
          appTextSizePlan: this.appTextSizePlan
        })
        HomeTabMine({
          selectedIndex: this.curSelectedTabIndex,
          appTextSizePlan: this.appTextSizePlan,
          mainPageTabsController: this.tabsController
        })
      }
      .layoutWeight(1)
      .margin({
        top: this.topSafeZoneHeightVp,
        bottom: this.bottomSafeZoneHeightVp
      })
      .vertical(this.tabsVerticalMode)
      .edgeEffect(EdgeEffect.None)
      .scrollable(!this.tabsVerticalMode)
      .onChange((newIndex: number) => this.curSelectedTabIndex = newIndex)
      .onTabBarClick((newIndex: number) => this.tabsController.changeIndex(newIndex))
    }
    .height('100%')
    .width('100%')
    .hideTitleBar(true)
    .hideToolBar(true)
    .hideBackButton(true)
    .backgroundColor(Color.White)
    .backgroundImage(this.navMode === NavigationMode.Split ? $r('app.media.app_icon_foreground_gray') : undefined)
    .backgroundImageSize({ width: '512px', height: '512px' })
    .backgroundImagePosition(
      this.navWidthPx === undefined || this.navHeightPx === undefined ? undefined :
      this.navBarWidthType === NAV_BAR_WIDTH_TYPE.SMALL ? { x: `${this.navWidthPx - (((this.navWidthPx * 0.65) - 512) / 2) - 512}px`, y: `${(this.navHeightPx - 512) / 2}px` } :
      this.navBarWidthType === NAV_BAR_WIDTH_TYPE.MIDDLE ? { x: `${this.navWidthPx - (((this.navWidthPx * 0.5) - 512) / 2) - 512}px`, y: `${(this.navHeightPx - 512) / 2}px` } :
      undefined
    )
    .navBarWidth(
      this.navBarWidthType === NAV_BAR_WIDTH_TYPE.SMALL ? '35%' :
      this.navBarWidthType === NAV_BAR_WIDTH_TYPE.MIDDLE ? '50%' :
      '100%'
    )
    .mode(this.navMode)
    .onAppear(() => {
      let mainWindow: window.Window = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window;
      mainWindow.setWindowLayoutFullScreen(true);
    })
    .onDisAppear(() => {
      let mainWindow: window.Window = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window;
      mainWindow.setWindowLayoutFullScreen(false);
    })
    .onAreaChange((_, newArea: Area) => {
      this.navWidthPx = vp2px(newArea.width as number);
      this.navHeightPx = vp2px(newArea.height as number);
      this.calcNavBarWidthType();
    })
  }

  /** 计算屏幕状态参数。 */
  private calcScreenParams() {
    // 计算安全区尺寸。
    if (this.screenStatusInfo?.avoidArea !== undefined) {
      if (this.screenStatusInfo.avoidAreaType === window.AvoidAreaType.TYPE_SYSTEM) {
        this.topSafeZoneHeightVp = px2vp(this.screenStatusInfo.avoidArea.topRect.height);
      } else if (this.screenStatusInfo.avoidAreaType === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        this.bottomSafeZoneHeightVp = px2vp(this.screenStatusInfo.avoidArea.bottomRect.height);
      }
    }
    // 计算tabs标签栏纵向排列模式。
    this.calcTabsVerticalMode();
    // 计算底部导航栏宽度。
    this.calcNavBarWidthType();
    // 计算页面叠加模式。
    this.calcNavMode();
  }

  /** 计算tabs标签栏纵向排列模式。 */
  private calcTabsVerticalMode() {
    let screenUIType = this.screenStatusInfo?.screenUIType ?? getScreenUIType();
    let windowStatusType = this.screenStatusInfo?.windowStatusType ?? (GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window).getWindowStatus();
    let windowWidthBreakpoint = this.screenStatusInfo?.windowWidthBreakpoint ?? this.getUIContext().getWindowWidthBreakpoint();
    this.tabsVerticalMode =
      screenUIType === ScreenUIType.PAD ? (
        windowStatusType !== window.WindowStatusType.FLOATING && windowStatusType !== window.WindowStatusType.SPLIT_SCREEN ? true :
        windowWidthBreakpoint >= WidthBreakpoint.WIDTH_LG ? true :
        false
      ) :
      false;
  }

  /** 计算底部导航栏宽度类型。 */
  private calcNavBarWidthType() {
    let screenUIType = this.screenStatusInfo?.screenUIType ?? getScreenUIType();
    let windowStatusType = this.screenStatusInfo?.windowStatusType ?? (GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window).getWindowStatus();
    let windowWidthBreakpoint = this.screenStatusInfo?.windowWidthBreakpoint ?? this.getUIContext().getWindowWidthBreakpoint();
    this.navBarWidthType =
      windowStatusType === window.WindowStatusType.FLOATING || windowStatusType === window.WindowStatusType.SPLIT_SCREEN ? (
        this.isSplitScreen && screenUIType === ScreenUIType.PAD && windowWidthBreakpoint === WidthBreakpoint.WIDTH_MD ? NAV_BAR_WIDTH_TYPE.MIDDLE :
        this.isSplitScreen && screenUIType === ScreenUIType.PAD && windowWidthBreakpoint >= WidthBreakpoint.WIDTH_LG ? NAV_BAR_WIDTH_TYPE.SMALL :
        NAV_BAR_WIDTH_TYPE.FULL
      ) :
      (
        !this.isSplitScreen ? NAV_BAR_WIDTH_TYPE.FULL :
        screenUIType === ScreenUIType.PAD ? NAV_BAR_WIDTH_TYPE.SMALL :
        screenUIType === ScreenUIType.FOLD_OPENED ? NAV_BAR_WIDTH_TYPE.MIDDLE :
        NAV_BAR_WIDTH_TYPE.FULL
      );
  }

  /** 计算页面叠加模式。 */
  private calcNavMode() {
    let screenUIType = this.screenStatusInfo?.screenUIType ?? getScreenUIType();
    let windowStatusType = this.screenStatusInfo?.windowStatusType ?? (GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window).getWindowStatus();
    let windowWidthBreakpoint = this.screenStatusInfo?.windowWidthBreakpoint ?? this.getUIContext().getWindowWidthBreakpoint();
    this.navMode =
      windowStatusType === window.WindowStatusType.FLOATING || windowStatusType === window.WindowStatusType.SPLIT_SCREEN ? (
        this.isSplitScreen && screenUIType === ScreenUIType.PAD && windowWidthBreakpoint >= WidthBreakpoint.WIDTH_MD ? NavigationMode.Split :
        NavigationMode.Stack
      ) :
      (
        screenUIType === ScreenUIType.NORMAL ? NavigationMode.Stack :
        this.isSplitScreen ? NavigationMode.Split : NavigationMode.Stack
      );
  }
}