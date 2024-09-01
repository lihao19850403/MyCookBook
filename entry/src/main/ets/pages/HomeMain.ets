import { emitter } from '@kit.BasicServicesKit';
import {
  getScreenUIType,
  ScreenUIType, SCREEN_UI_CHANGE_EVENT, SCREEN_UI_NEW_TYPE } from '../utils/ScreenUIAdapter';
import { HomeTabMenu } from './hometabs/HomeTabMenu';
import { HomeTabMine } from './hometabs/HomeTabMine';
import { HomeTabNews } from './hometabs/HomeTabNews';
import { HomeTabSocialize } from './hometabs/HomeTabSocialize';

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

  build() {
    RelativeContainer() {
      Tabs({
        barPosition: this.screenUIType === ScreenUIType.NORMAL ? BarPosition.End : BarPosition.Start,
        index: 0,
        controller: this.tabsController
      }) {
        HomeTabNews({selectedIndex: this.curSelectedTabIndex})
        HomeTabMenu({selectedIndex: this.curSelectedTabIndex})
        HomeTabSocialize({selectedIndex: this.curSelectedTabIndex})
        HomeTabMine({selectedIndex: this.curSelectedTabIndex})
      }
      .vertical(this.screenUIType !== ScreenUIType.NORMAL)
      .edgeEffect(EdgeEffect.None)
      .onChange((newIndex: number) => this.curSelectedTabIndex = newIndex)
      .onTabBarClick((newIndex: number) => this.curSelectedTabIndex = newIndex)
    }
    .height('100%')
    .width('100%')
  }
}