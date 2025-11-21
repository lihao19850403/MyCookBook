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

/**
 * 首页。
 * @author li.hao85
 */
@Entry
@Component
struct HomeMain {

  /** 屏幕状态。 */
  @State screenUIType: ScreenUIType = getScreenUIType();

  /** 应用启动后显示的第一个Tab页，当在设置页进行更改后会被赋值，触发Pop提示。 */
  @State firstPageIndex?: number = undefined;

  /** 应用文字字号方案。 */
  @State appTextSizePlan: AppSettingsTextSizePlanModel = AppSettings.textSizePlan();

  /** 是否使用分屏显示。 */
  @State isSplitScreen: boolean = AppSettings.isSplitScreen();

  /** 当前选中的标签序号。 */
  @State curSelectedTabIndex: number = 0;

  /** 标签页控制器。 */
  private tabsController: TabsController = new TabsController();

  /** 页面栈控制器。 */
  private routerStack: NavPathStack = new NavPathStack();

  /** 空白视图图标位置。 */
  @State navEmptyViewPosition: Position = {};

  /** 顶部安全区高度。 */
  @State topSafeZoneHeightVp: number = px2vp(getScreenTopSafeZoneHeightPx());

  /** 底部安全区高度。 */
  @State bottomSafeZoneHeightVp: number = px2vp(getScreenBottomSafeZoneHeightPx());

  /** 屏幕状态类型。 */
  @State windowStatusType: window.WindowStatusType = (GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window).getWindowStatus();

  /** 屏幕宽度断点类型。 */
  @State windowWidthBreakpoint: WidthBreakpoint = this.getUIContext().getWindowWidthBreakpoint();

  /** 应用的Navigation框架宽度，单位是px。 */
  private navWidthPx: number | undefined = undefined;

  /** 应用的Navigation框架高度，单位是px。 */
  private navHeightPx: number | undefined = undefined;

  private onGlobalAppSettingsChangedEvent: Callback<emitter.EventData> = (dataWrap: emitter.EventData) => {
    if (dataWrap.data) {
      let eventType: string = dataWrap.data[GLOBAL_APP_SETTINGS_EVENT_TYPE] as string;
      switch (eventType) {
        case GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN:
          this.appTextSizePlan = AppSettings.textSizePlan();
          break;
        case GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN: {
          this.isSplitScreen = AppSettings.isSplitScreen();
          this.adjustNavEmptyViewPosition();
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
      this.screenUIType = screenStatus.screenUIType ?? getScreenUIType();
      this.windowStatusType = screenStatus.windowStatusType ?? (GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window).getWindowStatus();
      this.windowWidthBreakpoint = screenStatus.windowWidthBreakpoint ?? this.getUIContext().getWindowWidthBreakpoint();
      if (screenStatus.avoidArea !== undefined) {
        if (screenStatus.avoidAreaType === window.AvoidAreaType.TYPE_SYSTEM) {
          this.topSafeZoneHeightVp = px2vp(screenStatus.avoidArea.topRect.height);
        } else if (screenStatus.avoidAreaType === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          this.bottomSafeZoneHeightVp = px2vp(screenStatus.avoidArea.bottomRect.height);
        }
      }

    });
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
        barPosition: this.screenUIType === ScreenUIType.PAD ? (
          this.windowStatusType !== window.WindowStatusType.FLOATING && this.windowStatusType !== window.WindowStatusType.SPLIT_SCREEN ? BarPosition.Start :
          this.windowWidthBreakpoint >= WidthBreakpoint.WIDTH_LG ? BarPosition.Start :
          BarPosition.End
        ) :
        BarPosition.End,
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
          screenUIType: this.screenUIType,
          appTextSizePlan: this.appTextSizePlan,
          isSplitScreen: this.isSplitScreen
        })
        HomeTabSocialize({
          selectedIndex: this.curSelectedTabIndex,
          firstPageIndex: this.firstPageIndex,
          screenUIType: this.screenUIType,
          appTextSizePlan: this.appTextSizePlan,
          isSplitScreen: this.isSplitScreen
        })
        HomeTabMine({
          selectedIndex: this.curSelectedTabIndex,
          screenUIType: this.screenUIType,
          appTextSizePlan: this.appTextSizePlan,
          isSplitScreen: this.isSplitScreen,
          mainPageTabsController: this.tabsController
        })
      }
      .layoutWeight(1)
      .margin({
        top: this.topSafeZoneHeightVp,
        bottom: this.bottomSafeZoneHeightVp
      })
      .vertical(
        this.screenUIType === ScreenUIType.PAD ? (
          this.windowStatusType !== window.WindowStatusType.FLOATING && this.windowStatusType !== window.WindowStatusType.SPLIT_SCREEN ? true :
          this.windowWidthBreakpoint >= WidthBreakpoint.WIDTH_LG ? true :
          false
        ) :
        false
      )
      .edgeEffect(EdgeEffect.None)
      .scrollable(!(
        this.screenUIType === ScreenUIType.PAD ? (
          this.windowStatusType !== window.WindowStatusType.FLOATING && this.windowStatusType !== window.WindowStatusType.SPLIT_SCREEN ? true :
          this.windowWidthBreakpoint >= WidthBreakpoint.WIDTH_LG ? true :
          false
        ) :
        false
      ))
      .onChange((newIndex: number) => this.curSelectedTabIndex = newIndex)
      .onTabBarClick((newIndex: number) => this.tabsController.changeIndex(newIndex))
    }
    .height('100%')
    .width('100%')
    .hideTitleBar(true)
    .hideToolBar(true)
    .hideBackButton(true)
    .backgroundColor(Color.White)
    .backgroundImage(
      this.windowStatusType === window.WindowStatusType.FLOATING || this.windowStatusType === window.WindowStatusType.SPLIT_SCREEN ? (
        this.isSplitScreen && this.screenUIType === ScreenUIType.PAD && this.windowWidthBreakpoint >= WidthBreakpoint.WIDTH_MD ? $r('app.media.app_icon_foreground_gray') :
        undefined
      ) :
      (
        this.screenUIType === ScreenUIType.NORMAL ? undefined :
        this.isSplitScreen ? $r('app.media.app_icon_foreground_gray') : undefined
      ))
    .backgroundImageSize({ width: '512px', height: '512px' })
    .backgroundImagePosition(this.navEmptyViewPosition)
    .navBarWidth(
      this.windowStatusType === window.WindowStatusType.FLOATING || this.windowStatusType === window.WindowStatusType.SPLIT_SCREEN ? (
        this.isSplitScreen && this.screenUIType === ScreenUIType.PAD && this.windowWidthBreakpoint === WidthBreakpoint.WIDTH_MD ? '50%' :
        this.isSplitScreen && this.screenUIType === ScreenUIType.PAD && this.windowWidthBreakpoint >= WidthBreakpoint.WIDTH_LG ? '35%' :
        '100%'
      ) :
      (
        !this.isSplitScreen ? '100%' :
        this.screenUIType === ScreenUIType.PAD ? '35%' :
        this.screenUIType === ScreenUIType.FOLD_OPENED ? '50%' :
        '100%'
      ))
    .mode(
      this.windowStatusType === window.WindowStatusType.FLOATING || this.windowStatusType === window.WindowStatusType.SPLIT_SCREEN ? (
        this.isSplitScreen && this.screenUIType === ScreenUIType.PAD && this.windowWidthBreakpoint >= WidthBreakpoint.WIDTH_MD ? NavigationMode.Split :
        NavigationMode.Stack
      ) :
      (
        this.screenUIType === ScreenUIType.NORMAL ? NavigationMode.Stack :
        this.isSplitScreen ? NavigationMode.Split : NavigationMode.Stack
      ))
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
      this.adjustNavEmptyViewPosition();
    })
  }

  /**
   * 调整空白视图图标的位置。
   */
  private adjustNavEmptyViewPosition() {
    if (this.navWidthPx === undefined || this.navHeightPx === undefined) {
      return;
    }
    let x: string | undefined = undefined;
    if (this.windowStatusType === window.WindowStatusType.FLOATING || this.windowStatusType === window.WindowStatusType.SPLIT_SCREEN) {
      if (this.isSplitScreen && this.screenUIType === ScreenUIType.PAD) {
        if (this.windowWidthBreakpoint === WidthBreakpoint.WIDTH_MD) {
          x = `${this.navWidthPx - (((this.navWidthPx * 0.5) - 512) / 2) - 512}px`
        } else if (this.windowWidthBreakpoint >= WidthBreakpoint.WIDTH_LG) {
          x = `${this.navWidthPx - (((this.navWidthPx * 0.65) - 512) / 2) - 512}px`
        }
      }
    } else {
      if (this.isSplitScreen) {
        if (this.screenUIType === ScreenUIType.FOLD_OPENED) {
          x = `${this.navWidthPx - (((this.navWidthPx * 0.5) - 512) / 2) - 512}px`
        } else if (this.screenUIType === ScreenUIType.PAD) {
          x = `${this.navWidthPx - (((this.navWidthPx * 0.65) - 512) / 2) - 512}px`
        }
      }
    }
    let y: string = `${(this.navHeightPx - 512) / 2}px`;
    this.navEmptyViewPosition = { x : x, y: y };
  }
}
