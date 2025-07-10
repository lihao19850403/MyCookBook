import { MethodResult } from '@ohos/flutter_ohos';
import { LHWebBrowser, URL_PARAMS } from '../../pages/common/webbrowser/LHWebBrowser';

/**
 * 鸿蒙平台下的Flutter页面跳转handler。
 * @author li.hao85
 * @param path 路由路径。
 * @param params 路由参数。
 * @param result 跳转结果，用于向Flutter页面返回参数。
 * @returns 处理是否完成。
 */
export const flutterRouterHandler: (path: string, params: Record<string, Object> | undefined, result: MethodResult) => boolean =
  (path, params, result) => {
    if (path === 'LHWebBrowser') {
      let routerParams: Record<string, string | undefined> = {};
      if (params !== undefined) {
        let urlParams: string = params instanceof Map ? params.get(URL_PARAMS) as string : params[URL_PARAMS] as string;
        routerParams[URL_PARAMS] = urlParams;
      }
      LHWebBrowser.go(routerParams);
    }
    return true;
  };