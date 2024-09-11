import { firstNotVoid } from '../../utils/common/Utils';
import { webview } from '@kit.ArkWeb';
import { OnLoadInterceptEvent } from '@kit.ArkUI';

/** 默认属性。 */
interface DefaultAttributes {

  /** 网页资源。 */
  src: string;
}

/** 默认属性。 */
const DEFAULT_ATTRIBUTES: DefaultAttributes = {
  src: ''
}

/**
 * 自定义的WebView。
 * @author li.hao85
 */
@Component
export struct LHWebView {

  /** 控制器。 */
  private controller: webview.WebviewController = new webview.WebviewController();

  /** 网页资源。 */
  private src?: ResourceStr;

  /** 页面加载事件拦截回调。 */
  private onLoadInterceptCallback?: (data: WebResourceRequest, webViewController: webview.WebviewController) => boolean;

  aboutToAppear(): void {
    webview.WebviewController.setWebDebuggingAccess(true);
  }

  build() {
    Web({
      src: firstNotVoid(this.src, DEFAULT_ATTRIBUTES.src),
      controller: this.controller
    })
      .fileAccess(true)
      .domStorageAccess(true)
      .javaScriptAccess(true)
      .mixedMode(MixedMode.All)
      .onControllerAttached(() => {})
      .onProgressChange((event: OnProgressChangeEvent) => {})
      .onLoadIntercept((event: OnLoadInterceptEvent) => {
        if (this.onLoadInterceptCallback !== undefined) {
          return this.onLoadInterceptCallback(event.data, this.controller);
        }
        return false;
      })
  }
}