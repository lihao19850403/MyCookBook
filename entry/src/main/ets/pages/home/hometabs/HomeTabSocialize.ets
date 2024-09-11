import { ScreenUIType } from '../../../utils/common/ScreenUIAdapter';
import { LHCommonTitleBar } from '../../../views/common/LHCommonTitleBar';
import { LHWebView } from '../../../views/common/LHWebView';
import { webview } from '@kit.ArkWeb';

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
  Content() {
    Column() {
      LHCommonTitleBar({
        centerTitleText: $r('app.string.home_tab_socialize')
      })
      LHWebView({
        src: URL_SOCIALIZE,
        onLoadInterceptCallback: this.onLoadInterceptCallback
      })
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_bg_gray_color'))
  }

  @Builder
  TabBarBuilder() {
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
   * 页面加载事件拦截回调。
   * @param data 页面加载事件数据。
   * @param webViewController WebView控制器。
   * @returns 是否停止WebView进行页面加载。
   */
  private onLoadInterceptCallback(data: WebResourceRequest, webViewController: webview.WebviewController): boolean {
    let requestUrl: string = data.getRequestUrl();
    if (requestUrl !== undefined && requestUrl.indexOf('https://m.xiangha.com/download') != -1) {

      return true;
    }
    return false;
  }
}

