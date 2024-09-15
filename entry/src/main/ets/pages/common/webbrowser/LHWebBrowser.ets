import { RouterUtils } from '../../../utils/common/RouterUtils';
import { LHCommonTitleBar, LHCommonTitleBarLeftBack } from '../../../views/common/LHCommonTitleBar';
import { LHWebView } from '../../../views/common/LHWebView';
import { webview } from '@kit.ArkWeb';

/**
 * 网页浏览器，基于原生Web组件实现。
 * @author li.hao85
 */
@Entry
@Component
struct LHWebBrowser {

  /** 地址信息。 */
  private url?: string;

  /** 浏览器控制器。 */
  private controller?: webview.WebviewController;

  aboutToAppear(): void {
    let urlParams: Record<string, string> = RouterUtils.getParams();
    this.url = urlParams['url'];
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