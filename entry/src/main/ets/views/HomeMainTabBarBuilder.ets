import { AppSettings } from "../utils/AppSettings"
import { res2string } from "../utils/common/Utils"

/**
 * 首页 - 底部Tab构造器。
 * @author li.hao85
 */

/** 首页 - 底部Tab信息。 */
export interface HomeMainTabBarInfo {
  icon: ResourceStr,
  text: ResourceStr,
  textFontSize: ResourceColor,
  textFontColor: ResourceColor,
  showFirstPagePopTips?: boolean,
  onPopTipsShowed?: Callback<void, void>
}

@Builder
export function HomeMainTabBarBuilder(info: HomeMainTabBarInfo) {
  Column() {
    Image(info.icon)
      .width(24)
      .height(24)
      .margin({ bottom: 4 })
    Text(info.text)
      .fontSize(info.textFontSize)
      .fontFamily('HarmonyHeiTi-Medium')
      .fontColor(info.textFontColor)
  }
  .padding({ top: 6, bottom: 6 })
  .alignItems(HorizontalAlign.Center)
  .bindPopup(info.showFirstPagePopTips, {
    message: res2string($r('app.string.home_tab_mine_settings_first_page_pop')),
    messageOptions: {
      font: { size: AppSettings.textSizePlan().homeTabMinePopupTipsTextSize }
    },
    backgroundBlurStyle: BlurStyle.NONE,
    onStateChange: (event) => {
      if (event.isVisible === true && info.onPopTipsShowed !== undefined) {
        setTimeout(() => info.onPopTipsShowed?.(), 2000);
      }
    }
  })
}