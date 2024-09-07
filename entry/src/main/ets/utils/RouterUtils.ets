import router from '@ohos.router';

/** 路由跳转传参类型。 */
type RouterParamsType = Record<string, Object | undefined> | Object | undefined;

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
}