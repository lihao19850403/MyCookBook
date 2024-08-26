import { emitter } from '@kit.BasicServicesKit';
import {
  getScreenUIType,
  ScreenUIType, SCREEN_UI_CHANGE_EVENT, SCREEN_UI_NEW_TYPE } from '../utils/ScreenUIAdapter';

/**
 * 首页。
 * @author li.hao85
 */
@Entry
@Component
struct HomeMain {

  /** 屏幕状态。 */
  @State screenUIType: ScreenUIType = getScreenUIType();

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
      Text(this.screenUIType.toString())
        .id('HelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
  }
}