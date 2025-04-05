import router from '@ohos.router';
import { GlobalConfig, GLOBAL_CONFIG_KEY_WINDOW } from '../../utils/common/GlobalConfig';
import window from '@ohos.window';
import { getScreenHeightPx } from '../../utils/common/ScreenUIAdapter';
import { getAppInfo, res2string } from '../../utils/common/Utils';

/**
 * 启动页。
 * @author li.hao85
 */
@Entry
@Component
struct SplashScreen {

  aboutToAppear(): void {
    let mainWindow: window.Window = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW);
    mainWindow.setWindowLayoutFullScreen(true).then((): void => this.changeToHomeMainPage());
  }

  build() {
    RelativeContainer() {
      Image($r('app.media.app_icon_start'))
        .width('512px')
        .height('512px')
        .objectFit(ImageFit.Contain)
        .alignRules({
          center: {
            anchor: '__container__',
            align: VerticalAlign.Center
          },
          middle: {
            anchor: '__container__',
            align: HorizontalAlign.Center
          }
        })
      Text(`${res2string($r('app.string.app_name'))}\nV${getAppInfo().versionName}`)
        .margin({ bottom: px2vp(getScreenHeightPx()) * 0.2 })
        .textAlign(TextAlign.Center)
        .alignRules({
          center: {
            anchor: '__container__',
            align: VerticalAlign.Bottom
          },
          middle: {
            anchor: '__container__',
            align: HorizontalAlign.Center
          }
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.start_window_background'))
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