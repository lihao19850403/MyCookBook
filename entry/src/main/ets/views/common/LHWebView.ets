import { firstNotVoid } from '../../utils/common/Utils';
import { webview } from '@kit.ArkWeb';
import { OnLoadInterceptEvent } from '@kit.ArkUI';
import { ScreenUIType } from '../../utils/common/ScreenUIAdapter';

/** 默认属性。 */
interface DefaultAttributes {

  /** 网页资源。 */
  src: string;

  /** 支持网页缩放？ */
  supportZoom: boolean;

  /** 瘦长浏览器模式。 */
  thinMode: boolean;
}

/** 默认属性。 */
const DEFAULT_ATTRIBUTES: DefaultAttributes = {
  src: '',
  supportZoom: false,
  thinMode: false
}

/**
 * 自定义的WebView。
 * @author li.hao85
 */
@Component
export struct LHWebView {

  /** 平板设备上浏览器组件的宽度。 */
  @State padWebViewWidthVp: number | string = '100%';

  /** 当前页面加载进度。 */
  @State @Watch('onProgressChanged') curProgress: number = 0;

  /** 进度条可见性。 */
  @State progressVisible: boolean = false;

  /** 屏幕状态。 */
  @Prop screenUIType: ScreenUIType;

  /** 进度条可见性更新事件ID。 */
  private progressVisibleTask: number = -1;

  /** 控制器。 */
  private controller: webview.WebviewController = new webview.WebviewController();

  /** 网页资源。 */
  private src?: ResourceStr;

  /** 支持网页缩放？ */
  private supportZoom?: boolean;

  /** 瘦长浏览器模式。 */
  private thinMode?: boolean;

  /** 网页加载进度回调。 */
  private OnProgressChangeCallback?: (newProgress: number, webViewController: webview.WebviewController) => void;

  /** 控制器绑定完毕回调。 */
  private onControllerAttachedCallback?: (webViewController: webview.WebviewController) => void;

  /** 页面加载事件拦截回调。 */
  private onLoadInterceptCallback?: (data: WebResourceRequest, webViewController: webview.WebviewController) => boolean;

  aboutToAppear(): void {
    webview.WebviewController.setWebDebuggingAccess(true);
  }

  build() {
    RelativeContainer() {
      Web({
        src: firstNotVoid(this.src, DEFAULT_ATTRIBUTES.src),
        controller: this.controller
      })
        .width(this.screenUIType === ScreenUIType.PAD && firstNotVoid(this.thinMode, DEFAULT_ATTRIBUTES.thinMode) ? this.padWebViewWidthVp : '100%')
        .horizontalScrollBarAccess(false)
        .verticalScrollBarAccess(false)
        .fileAccess(true)
        .domStorageAccess(true)
        .javaScriptAccess(true)
        .zoomAccess(firstNotVoid(this.supportZoom, DEFAULT_ATTRIBUTES.supportZoom))
        .mixedMode(MixedMode.All)
        .nestedScroll({
          scrollForward: NestedScrollMode.SELF_FIRST,
          scrollBackward: NestedScrollMode.SELF_FIRST,
        })
        .alignRules({
          middle: {
            anchor: '__container__',
            align: HorizontalAlign.Center
          }
        })
        .onProgressChange((event: OnProgressChangeEvent) => {
          this.curProgress = event.newProgress;
          if (this.OnProgressChangeCallback !== undefined) {
            this.OnProgressChangeCallback(event.newProgress, this.controller);
          }
        })
        .onControllerAttached(() => {
          let defaultUserAgent: string = this.controller.getUserAgent();
          if (defaultUserAgent.indexOf('Mobile') === -1) {
            let customUserAgent: string = defaultUserAgent.concat('Mobile');
            this.controller.setCustomUserAgent(customUserAgent);
          }
          if (this.onControllerAttachedCallback !== undefined) {
            this.onControllerAttachedCallback(this.controller);
          }
        })
        .onLoadIntercept((event: OnLoadInterceptEvent) => {
          if (this.onLoadInterceptCallback !== undefined) {
            return this.onLoadInterceptCallback(event.data, this.controller);
          }
          return false;
        })
      Progress({
        value: this.curProgress,
        total: 100,
        type: ProgressType.Linear
      })
        .width('100%')
        .height(1.3)
        .value(this.curProgress)
        .color($r('app.color.main_selected_color'))
        .backgroundColor($r('app.color.main_bg_gray_color'))
        .visibility(this.progressVisible ? Visibility.Visible : Visibility.None)
    }
    .onSizeChange((_, newSize: SizeOptions) => {
      this.padWebViewWidthVp = this.calcPadWebViewWidthVp(newSize.width as number, newSize.height as number);
    })
  }

  /**
   * 平板设备中浏览器组件的宽度。
   * @param frameWidth 组件整体宽度。
   * @param frameHeight 组件整体高度。
   * @returns 平板设备中浏览器组件的宽度。
   */
  private calcPadWebViewWidthVp(frameWidth: number, frameHeight: number): number {
    let shortSide: number = Math.min(frameWidth, frameHeight);
    return shortSide;
  }

  /**
   * 进度条数值改变默认监听。
   * 每次进度条改变后，都设定1000ms后隐藏进度条。
   */
  private onProgressChanged() {
    clearTimeout(this.progressVisibleTask);
    this.progressVisible = true;
    this.progressVisibleTask = setTimeout(() => this.progressVisible = false, 1000);
  }
}