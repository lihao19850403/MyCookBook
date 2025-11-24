import { AppSettings } from "../utils/AppSettings"
import { GlobalConfig, GLOBAL_CONFIG_KEY_WINDOW } from "../utils/common/GlobalConfig"
import { getScreenUIType, ScreenUIType } from "../utils/common/ScreenUIAdapter"
import { res2string } from "../utils/common/Utils"
import window from "@ohos.window"

/**
 * 首页 - 底部Tab构造器。
 * @author li.hao85
 */

/** 首页 - 底部Tab信息。 */
export interface HomeMainTabBarInfo {
  uiContext: UIContext,
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
    placement: getScreenUIType() === ScreenUIType.PAD ? (
        (GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window).getWindowStatus() !== window.WindowStatusType.FLOATING &&
        (GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window).getWindowStatus() !== window.WindowStatusType.SPLIT_SCREEN ? Placement.Right :
        info.uiContext.getWindowWidthBreakpoint() >= WidthBreakpoint.WIDTH_LG ? Placement.Right :
        undefined
      ) :
      undefined,
    backgroundBlurStyle: BlurStyle.NONE,
    mask: { color: '#33000000' },
    popupColor: Color.White,
    onStateChange: (event) => {
      if (event.isVisible === true && info.onPopTipsShowed !== undefined) {
        setTimeout(() => info.onPopTipsShowed?.(), 2000);
      }
    }
  })
}