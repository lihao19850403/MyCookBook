import { emitter } from '@kit.BasicServicesKit';
import { AppSettingsTextSizePlanModel } from '../../models/AppSettingsTextSizeModel';
import { AppSettingsTextSizePlans } from '../../models/AppSettingsTextSizePlan';
import { AppSettings } from '../../utils/AppSettings';
import { GLOBAL_APP_SETTINGS_CHANGED_EVENT,
  GLOBAL_APP_SETTINGS_EVENT_TYPE,
  GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN,
  GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN} from '../../utils/common/GlobalAppSettings';
import { GlobalConfig } from '../../utils/common/GlobalConfig';
import { RouterUtils, ROUTER_CONFIG_KEY_ROUTER_STACK } from '../../utils/common/RouterUtils';
import {
  getScreenUIType,
  ScreenUIType, SCREEN_UI_CHANGE_EVENT, SCREEN_UI_NEW_TYPE } from '../../utils/common/ScreenUIAdapter';
import { HomeTabMenu } from './hometabs/HomeTabMenu';
import { HomeTabMine } from './hometabs/HomeTabMine';
import { HomeTabNews } from './hometabs/HomeTabNews';
import { HomeTabSocialize } from './hometabs/HomeTabSocialize';

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

  /** 应用文字字号方案。 */
  @State appTextSizePlan: AppSettingsTextSizePlanModel = AppSettingsTextSizePlans.SMALL;

  /** 是否使用分屏显示。 */
  @State isSplitScreen: boolean = false;

  /** 当前选中的标签序号。 */
  @State curSelectedTabIndex: number = 0;

  /** 标签页控制器。 */
  private tabsController: TabsController = new TabsController();

  /** 页面栈控制器。 */
  private routerStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    GlobalConfig.set(ROUTER_CONFIG_KEY_ROUTER_STACK, this.routerStack);
    emitter.on(SCREEN_UI_CHANGE_EVENT, (dataWrap: emitter.EventData) => {
      if (dataWrap.data) {
        let newScreenUIType: ScreenUIType = dataWrap.data[SCREEN_UI_NEW_TYPE] as ScreenUIType;
        this.screenUIType = newScreenUIType;
      }
    })
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
    setTimeout(() => this.curSelectedTabIndex = AppSettings.firstPageIndex(), 0);
  }

  onBackPress(): boolean | void {
    if (RouterUtils.getNavPathsCount() > 0) {
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
        barPosition: this.screenUIType !== ScreenUIType.PAD ? BarPosition.End : BarPosition.Start,
        index: this.curSelectedTabIndex,
        controller: this.tabsController
      }) {
        HomeTabNews({
          selectedIndex: this.curSelectedTabIndex,
          screenUIType: this.screenUIType,
          appTextSizePlan: this.appTextSizePlan,
          isSplitScreen: this.isSplitScreen
        })
        HomeTabMenu({
          selectedIndex: this.curSelectedTabIndex,
          screenUIType: this.screenUIType,
          appTextSizePlan: this.appTextSizePlan,
          isSplitScreen: this.isSplitScreen
        })
        HomeTabSocialize({
          selectedIndex: this.curSelectedTabIndex,
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
      .vertical(this.screenUIType === ScreenUIType.PAD)
      .edgeEffect(EdgeEffect.None)
      .scrollable(this.screenUIType !== ScreenUIType.PAD)
      .onChange((newIndex: number) => this.curSelectedTabIndex = newIndex)
      .onTabBarClick((newIndex: number) => this.tabsController.changeIndex(newIndex))
    }
    .height('100%')
    .width('100%')
    .hideTitleBar(true)
    .hideToolBar(true)
    .hideBackButton(true)
    .navBarWidth(!this.isSplitScreen ? '100%' :
      this.screenUIType === ScreenUIType.PAD ? '35%' :
      this.screenUIType === ScreenUIType.FOLD_OPENED ? '50%' :
      '100%')
    .mode(this.screenUIType === ScreenUIType.NORMAL ? NavigationMode.Stack :
      this.isSplitScreen ? NavigationMode.Split : NavigationMode.Stack)
  }
}