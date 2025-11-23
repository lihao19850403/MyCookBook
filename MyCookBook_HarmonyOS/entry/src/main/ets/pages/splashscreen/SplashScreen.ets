import router from '@ohos.router';
import { GlobalConfig, GLOBAL_CONFIG_KEY_WINDOW } from '../../utils/common/GlobalConfig';
import window from '@ohos.window';
import { getScreenBottomSafeZoneHeightPx, getScreenHeightPx } from '../../utils/common/ScreenUIAdapter';
import { getAppInfo, res2string } from '../../utils/common/Utils';

/**
 * 启动页。
 * @author li.hao85
 */
@Entry
@Component
struct SplashScreen {

  aboutToAppear(): void {
    this.changeToHomeMainPage();
  }

  build() {
    Column() {
      Blank()
        .width('100%')
        .constraintSize({
          minHeight: px2vp(getScreenBottomSafeZoneHeightPx())
        })
        .flexGrow(1)
      Image($r('app.media.app_icon_start'))
        .width('512px')
        .height('512px')
        .objectFit(ImageFit.Contain)
      Blank()
        .width('100%')
        .constraintSize({
          maxHeight: (px2vp(getScreenHeightPx()) / 2) - px2vp(256) - px2vp(getScreenBottomSafeZoneHeightPx()) - 100
        })
        .flexShrink(1)
      Text(`${res2string($r('app.string.app_name'))}\nV${getAppInfo().versionName}`)
        .textAlign(TextAlign.Center)
      Blank()
        .width('100%')
        .constraintSize({
          minHeight: px2vp(getScreenBottomSafeZoneHeightPx()),
          maxHeight: px2vp(getScreenBottomSafeZoneHeightPx()) + 100
        })
        .flexShrink(1)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
    .backgroundColor($r('app.color.start_window_background'))
    .onAppear(() => {
      let mainWindow: window.Window = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window;
      mainWindow.setWindowLayoutFullScreen(true);
    })
    .onDisAppear(() => {
      let mainWindow: window.Window = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window;
      mainWindow.setWindowLayoutFullScreen(false);
    })
  }

  private changeToHomeMainPage() {
    setTimeout(() => {
      router.replaceUrl({url: 'pages/home/HomeMain'})
        .then(() => {
          let mainWindow: window.Window = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW);
          mainWindow.setWindowLayoutFullScreen(false);
        });
    }, 2000);
  }
}