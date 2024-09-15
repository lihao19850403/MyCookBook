import { ScreenUIType } from '../../../utils/common/ScreenUIAdapter';
import { LHCommonTitleBar } from '../../../views/common/LHCommonTitleBar';
import { LHWebView } from '../../../views/common/LHWebView';
import { webview } from '@kit.ArkWeb';
import { GlobalConfig } from '../../../utils/common/GlobalConfig';
import { GLOBAL_CONFIG_BACK_KEY_EVENT } from '../HomeMain';

/** 网页资源链接。 */
const URL_SOCIALIZE: string = 'https://www.xiangha.com/quan';

/**
 * 首页 - 美食圈。
 * @author li.hao85
 */
@Component
export struct HomeTabSocialize {

  /** 当前选中的Tab序号。 */
  @Prop selectedIndex: number;

  /** 屏幕状态。 */
  @Prop screenUIType: ScreenUIType;

  /** 此Tab序号。 */
  private thisIndex: number = 2;

  build() {
    TabContent() {
      this.Content()
    }
    .tabBar(this.TabBarBuilder())
  }

  @Builder
  private Content() {
    Column() {
      LHCommonTitleBar({
        centerTitleText: $r('app.string.home_tab_socialize')
      })
      LHWebView({
        src: URL_SOCIALIZE,
        mobileMode: true,
        onControllerAttachedCallback: this.onControllerAttachedCallback.bind(this),
        onLoadInterceptCallback: this.onLoadInterceptCallback,
      })
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_bg_gray_color'))
  }

  @Builder
  private TabBarBuilder() {
    Column() {
      Image(this.selectedIndex === this.thisIndex ? $r('app.media.ic_home_tab_socialize_selected') : $r('app.media.ic_home_tab_socialize_unselected'))
        .width(24)
        .height(24)
        .margin({ bottom: 4 })
      Text($r('app.string.home_tab_socialize'))
        .fontSize(10)
        .fontFamily('HarmonyHeiTi-Medium')
        .fontColor(this.selectedIndex === this.thisIndex ? $r('app.color.main_selected_color') : $r('app.color.main_unselected_color'))
    }
    .padding({ top: 6, bottom: 6 })
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 控制器绑定完毕回调。
   * @param webViewController WebView控制器。
   */
  private onControllerAttachedCallback(webViewController: webview.WebviewController) {
    let callbacks: Array<() => boolean> | undefined = GlobalConfig.get(GLOBAL_CONFIG_BACK_KEY_EVENT);
    if (callbacks === undefined) {
      callbacks = [];
    }
    callbacks.push(() => {
      if (this.selectedIndex === this.thisIndex && webViewController.accessBackward()) {
        webViewController.backward();
        return true;
      }
      return false;
    });
    GlobalConfig.set(GLOBAL_CONFIG_BACK_KEY_EVENT, callbacks);
  }

  /**
   * 页面加载事件拦截回调。
   * @param data 页面加载事件数据。
   * @param webViewController WebView控制器。
   * @returns 是否停止WebView进行页面加载。
   */
  private onLoadInterceptCallback(data: WebResourceRequest, webViewController: webview.WebviewController): boolean {
    let requestUrl: string = data.getRequestUrl();
    if (requestUrl !== undefined) {
      if (requestUrl.includes('xiangha.com/download')) {

        return true;
      }
      if (requestUrl.includes('xiangha.com/entry')) {

        return true;
      }
    }
    return false;
  }
}

