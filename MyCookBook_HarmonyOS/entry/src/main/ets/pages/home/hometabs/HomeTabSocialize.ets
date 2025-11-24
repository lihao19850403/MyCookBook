import { LHCommonTitleBar } from '../../../views/common/LHCommonTitleBar';
import { LHWebView } from '../../../views/common/LHWebView';
import { webview } from '@kit.ArkWeb';
import { GlobalConfig } from '../../../utils/common/GlobalConfig';
import { GLOBAL_CONFIG_BACK_KEY_EVENT } from '../HomeMain';
import { AppSettingsTextSizePlanModel } from '../../../models/AppSettingsTextSizeModel';
import { LHWebBrowser, URL_PARAMS } from '../../common/webbrowser/LHWebBrowser';
import { HomeMainTabBarBuilder } from '../../../views/HomeMainTabBarBuilder';

/** 网页资源链接。 */
const URL_SOCIALIZE: string = 'https://www.xiangha.com/quan';

/**
 * 分屏显示链接白名单。
 * 在白名单中的链接将仅在左侧屏幕显示，不会在右侧内容区显示。
 */
const URL_WHITE_LIST: string[] = [
  URL_SOCIALIZE,
  'https://m.xiangha.com/quan',
  'https://m.xiangha.com/Index/iframe'
];

/**
 * 首页 - 美食圈。
 * @author li.hao85
 */
@Component
export struct HomeTabSocialize {

  /** 应用文字字号方案。 */
  @Prop appTextSizePlan: AppSettingsTextSizePlanModel;

  /** 当前选中的Tab序号。 */
  @Prop selectedIndex: number;

  /** 应用启动后显示的第一个Tab的序号。 */
  @Prop firstPageIndex?: number;

  /** 此Tab序号。 */
  private thisIndex: number = 2;

  /** Web组件控制器。 */
  private controller?: webview.WebviewController;

  build() {
    TabContent() {
      this.Content()
    }
    .tabBar(HomeMainTabBarBuilder({
      uiContext: this.getUIContext(),
      icon: this.selectedIndex === this.thisIndex ? $r('app.media.ic_home_tab_socialize_selected') : $r('app.media.ic_home_tab_socialize_unselected'),
      text: $r('app.string.home_tab_socialize'),
      textFontSize: this.appTextSizePlan.unifiedTabBarTextSize,
      textFontColor: this.selectedIndex === this.thisIndex ? $r('app.color.main_selected_color') : $r('app.color.main_unselected_color'),
      showFirstPagePopTips: this.firstPageIndex === this.thisIndex,
      onPopTipsShowed: () => this.firstPageIndex = undefined
    }))
  }

  @Builder
  private Content() {
    Column() {
      LHCommonTitleBar({
        centerTitleText: $r('app.string.home_tab_socialize'),
        centerTitleTextSize: this.appTextSizePlan.unifiedTitleCenterTextSize,
        rightAction: (): void => this.Reload()
      })
      LHWebView({
        src: URL_SOCIALIZE,
        mobileMode: true,
        onControllerAttachedCallback: (webViewController: webview.WebviewController): void => this.onControllerAttachedCallback(webViewController),
        onLoadInterceptCallback: this.onLoadInterceptCallback,
      })
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_bg_gray_color'))
  }

  @Builder
  private Reload() {
    Image($r("app.media.ic_reload_green"))
      .width(48)
      .height(48)
      .padding(12)
      .objectFit(ImageFit.Contain)
      .onClick((event: ClickEvent) => {
        if (this.controller !== undefined) {
          this.controller.refresh();
        }
      })
  }

  /**
   * 控制器绑定完毕回调。
   * @param webViewController WebView控制器。
   */
  private onControllerAttachedCallback(webViewController: webview.WebviewController) {
    this.controller = webViewController;
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
      // 不在白名单的链接会在在内容区打开。
      if (!URL_WHITE_LIST.includes(requestUrl)) {
        let urlParams: Record<string, string | undefined> = {};
        urlParams[URL_PARAMS] = requestUrl;
        LHWebBrowser.go(urlParams);
        return true;
      }
    }
    return false;
  }
}

