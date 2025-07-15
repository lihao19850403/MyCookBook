import { common } from '@kit.AbilityKit';
import { FlutterAbilityLaunchConfigs, FlutterEntry, FlutterPage, FlutterView } from '@ohos/flutter_ohos';
import { GlobalContext } from '../../utils/common/GlobalContext';
import { RouterUtils } from '../../utils/common/RouterUtils';
import FlutterWrapEntry from '../utils/FlutterWrapEntry';

/** 跳转Flutter内容页时传递的参数。 */
export interface FlutterPathInfo {
  /** Flutter页面路由名称。 */
  path: string;
  /** Flutter页面路由参数。 */
  params?: Record<string, Object | undefined>;
}

export namespace FlutterIndexPage {
  export function go(pathInfo: FlutterPathInfo) {
    let path: string = pathInfo.path;
    let params: Record<string, Object> = {};
    if (pathInfo.params !== undefined) {
      Object.keys(pathInfo.params).forEach((key: string) => {
        let value: Object | undefined = pathInfo.params?.[key];
        if (value !== undefined) {
          params[key] = value;
        }
      })
    }
    let routerParams: Record<string, Object> = {};
    routerParams[FlutterAbilityLaunchConfigs.EXTRA_INITIAL_ROUTE] = `${path}?${JSON.stringify(params)}`;
    RouterUtils.navPushPath('FlutterIndexPage', routerParams);
  }
}

@Builder
export function FlutterIndexPageBuilder() {
  FlutterIndexPageComponent()
}

/**
 * Flutter模块入口页。
 * @author li.hao85
 */
@Component
struct FlutterIndexPageComponent {
  private context = GlobalContext.getContext() as common.UIAbilityContext;
  private flutterEntry?: FlutterWrapEntry;
  private flutterView?: FlutterView;

  build() {
    NavDestination() {
      Stack() {
        FlutterPage({
          viewId: this.flutterView?.getId()
        })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backButtonIcon(undefined)
    .onReady((context: NavDestinationContext) => {
      let params: Record<string, Object> = RouterUtils.navGetParams(context) as Record<string, Object>;
      this.flutterEntry = new FlutterWrapEntry(this.context, params);
      this.flutterEntry.aboutToAppear();
      this.flutterView = this.flutterEntry.getFlutterView();
    })
    .onShown(() => {
      // FlutterManager.getInstance().setUseFullScreen(true);
      this.flutterEntry?.onPageShow();
    })
    .onHidden(() => {
      // FlutterManager.getInstance().setUseFullScreen(false);
      this.flutterEntry?.onPageHide();
    })
    .onDisAppear(() => {
      this.flutterEntry?.aboutToDisappear();
    })
    .onBackPressed(() => {
      this.flutterEntry?.callFlutterBack();
      return true;
    })
  }
}