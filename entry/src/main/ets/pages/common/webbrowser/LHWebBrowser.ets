import { RouterUtils } from '../../../utils/common/RouterUtils';
import { LHCommonTitleBar, LHCommonTitleBarLeftBack } from '../../../views/common/LHCommonTitleBar';
import { LHWebView } from '../../../views/common/LHWebView';
import { webview } from '@kit.ArkWeb';
import { LHAppSettingsTextSizePlanModel } from '../../../models/common/LHAppSettingsTextSizePlanModel';
import { LHAppSettingsTextSizePlans } from '../../../models/common/LHAppSettingsTextSizePlans';
import { GlobalAppSettings, GLOBAL_APP_SETTINGS_EVENT_TYPE,
  GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN } from '../../../utils/common/GlobalAppSettings';
import { emitter } from '@kit.BasicServicesKit';
import { GLOBAL_APP_SETTINGS_CHANGED_EVENT } from '../../../utils/common/GlobalAppSettings';

/**
 * 网页浏览器，基于原生Web组件实现。
 * @author li.hao85
 */
@Entry
@Component
struct LHWebBrowser {

  /** 应用文字字号方案。 */
  @State appTextSizePlan: LHAppSettingsTextSizePlanModel = LHAppSettingsTextSizePlans.SMALL;

  /** 地址信息。 */
  private url?: string;

  /** 浏览器控制器。 */
  private controller?: webview.WebviewController;

  aboutToAppear(): void {
    let urlParams: Record<string, string> = RouterUtils.getParams();
    this.url = urlParams['url'];
    this.appTextSizePlan = GlobalAppSettings.textSizePlan();
    emitter.on(GLOBAL_APP_SETTINGS_CHANGED_EVENT, (dataWrap: emitter.EventData) => {
      if (dataWrap.data) {
        let eventType: string = dataWrap.data[GLOBAL_APP_SETTINGS_EVENT_TYPE] as string;
        switch (eventType) {
          case GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN: this.appTextSizePlan = GlobalAppSettings.textSizePlan(); break;
          default: break;
        }
      }
    });
  }

  onBackPress(): boolean | void {
    if (this.controller !== undefined && this.controller.accessBackward()) {
      this.controller.backward();
      return true;
    }
    return false;
  }

  build() {
    Column() {
      LHCommonTitleBar({
        centerTitleText: $r('app.string.browser'),
        centerTitleTextSize: this.appTextSizePlan.unifiedTitleCenterTextSize,
        leftAction: LHCommonTitleBarLeftBack,
      })
      LHWebView({
        src: this.url,
        mobileMode: true,
        onControllerAttachedCallback: this.onControllerAttachedCallback.bind(this),
      })
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_bg_gray_color'))
  }

  /**
   * 控制器绑定完毕回调。
   * @param webViewController WebView控制器。
   */
  private onControllerAttachedCallback(webViewController: webview.WebviewController) {
    this.controller = webViewController;
  }
}