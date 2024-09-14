import { emitter } from '@kit.BasicServicesKit';
import { GlobalConfig } from '../../utils/common/GlobalConfig';
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

  /** 当前选中的标签序号。 */
  @State curSelectedTabIndex: number = 0;

  private tabsController: TabsController = new TabsController();

  aboutToAppear(): void {
    emitter.on(SCREEN_UI_CHANGE_EVENT, (dataWrap: emitter.EventData) => {
      if (dataWrap.data) {
        let newScreenUIType: ScreenUIType = dataWrap.data[SCREEN_UI_NEW_TYPE] as ScreenUIType;
        this.screenUIType = newScreenUIType;
      }
    })
  }

  onBackPress(): boolean | void {
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
    RelativeContainer() {
      Tabs({
        barPosition: this.screenUIType !== ScreenUIType.PAD ? BarPosition.End : BarPosition.Start,
        index: 0,
        controller: this.tabsController
      }) {
        HomeTabNews({ selectedIndex: this.curSelectedTabIndex, screenUIType: this.screenUIType })
        HomeTabMenu({ selectedIndex: this.curSelectedTabIndex, screenUIType: this.screenUIType })
        HomeTabSocialize({ selectedIndex: this.curSelectedTabIndex, screenUIType: this.screenUIType })
        HomeTabMine({ selectedIndex: this.curSelectedTabIndex, screenUIType: this.screenUIType })
      }
      .vertical(this.screenUIType === ScreenUIType.PAD)
      .edgeEffect(EdgeEffect.None)
      .onChange((newIndex: number) => this.curSelectedTabIndex = newIndex)
      .onTabBarClick((newIndex: number) => this.curSelectedTabIndex = newIndex)
    }
    .height('100%')
    .width('100%')
  }
}