import router from '@ohos.router';
import { GlobalConfig } from './GlobalConfig';

/** 路由跳转传参类型。 */
type RouterParamsType = Record<string, Object | undefined> | Object | undefined;

/** 保存Navigation组件的页面栈控制器。 */
export const ROUTER_CONFIG_KEY_ROUTER_STACK: string = 'ROUTER_CONFIG_KEY_ROUTER_STACK';

/**
 * 路由跳转工具类。
 * @author li.hao85
 */
export class RouterUtils {

  /**
   * 获取上个页面传递过来的路由参数。
   * @returns 上个页面传递过来的路由参数。
   */
  public static getParams<T>(): T {
    return router.getParams() as T;
  }

  /**
   * 跳转至指定路由。
   * @param routerUrl 路由。
   * @param params 参数。
   * @param callback 跳转完毕后的回调。
   */
  public static go(routerUrl: string, params?: RouterParamsType, callback?: () => void) {
    router.pushUrl({
      url: routerUrl,
      params: params,
    }).then(callback);
  }

  /**
   * 返回上一页。
   */
  public static back() {
    router.back();
  }

  /**
   * 返回至某页。
   * @param routerUrl 路由。
   * @param params 参数。
   */
  public static backTo(routerUrl: string, params?: RouterParamsType) {
    router.back({
      url: routerUrl,
      params: params
    });
  }

  /* ---------- Navigation ---------- */

  /**
   * 获取Navigation组件页面栈中路由总数。
   * @returns Navigation组件页面栈中路由总数。
   */
  public static getNavPathsCount(): number {
    let routerStack: NavPathStack = GlobalConfig.get(ROUTER_CONFIG_KEY_ROUTER_STACK) as NavPathStack;
    if (routerStack === undefined) {
      return 0;
    }
    return routerStack.size();
  }

  /**
   * Navigation组件获取传递过来的路由参数。
   * @param context Navigation组件上下文。
   * @returns 传递过来的路由参数。
   */
  public static navGetParams<T>(context: NavDestinationContext): T {
    let params: T = Reflect.get(context.pathInfo.param as Record<string, T>, 'params') as T;
    return params;
  }

  /**
   * Navigation组件跳转新页。
   * @param routerName 新页路由名称。
   * @param params 新页路由参数。
   * @param isEntry 新页是否为一个Entry。
   * @param options 跳转选项。
   */
  public static navPushPath(routerName: string, params?: RouterParamsType, isEntry?: boolean, options?: NavigationOptions) {
    let routerStack: NavPathStack = GlobalConfig.get(ROUTER_CONFIG_KEY_ROUTER_STACK) as NavPathStack;
    if (routerStack === undefined) {
      return;
    }
    let paramsWrap: Record<string, RouterParamsType> = {
      'params': params
    };
    let navPathInfo: NavPathInfo = new NavPathInfo(routerName, paramsWrap, undefined, isEntry);
    routerStack.pushPath(navPathInfo, options);
  }

  /**
   * Navigation组件返回上一页。
   */
  public static navBack() {
    let routerStack: NavPathStack = GlobalConfig.get(ROUTER_CONFIG_KEY_ROUTER_STACK) as NavPathStack;
    if (routerStack === undefined) {
      return;
    }
    routerStack.pop();
  }

  /**
   * Navigation组件返回至某页。
   * @param routerName 目标页路由名称。
   */
  public static navBackTo(routerName: string) {
    let routerStack: NavPathStack = GlobalConfig.get(ROUTER_CONFIG_KEY_ROUTER_STACK) as NavPathStack;
    if (routerStack === undefined) {
      return;
    }
    routerStack.popToName(routerName);
  }
}