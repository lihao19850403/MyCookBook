import { GlobalConfig } from './GlobalConfig';

/** 保存Navigation组件的页面栈控制器。 */
export const ROUTER_CONFIG_KEY_ROUTER_STACK: string = 'ROUTER_CONFIG_KEY_ROUTER_STACK';

/**
 * 路由跳转工具类。
 * @author li.hao85
 */
export class RouterUtils {

  /**
   * 获取Navigation组件页面栈中路由总数。
   * @returns Navigation组件页面栈中路由总数。
   */
  public static navGetPathsCount(): number {
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
    let params: T = context.pathInfo.param as T;
    return params;
  }

  /**
   * Navigation组件跳转新页。
   * @param routerName 新页路由名称。
   * @param params 新页路由参数。
   * @param isEntry 新页是否为一个Entry。
   * @param options 跳转选项。
   */
  public static navPushPath<T>(routerName: string, params?: T, isEntry?: boolean, options?: NavigationOptions) {
    let routerStack: NavPathStack = GlobalConfig.get(ROUTER_CONFIG_KEY_ROUTER_STACK) as NavPathStack;
    if (routerStack === undefined) {
      return;
    }
    let navPathInfo: NavPathInfo = new NavPathInfo(routerName, params, undefined, isEntry);
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