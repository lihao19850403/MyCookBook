import { MethodCall, MethodResult } from '@ohos/flutter_ohos';
import FlutterRouterPlugin from 'flutter_router';
import { LHWebBrowser, URL_PARAMS } from '../../pages/common/webbrowser/LHWebBrowser';
import { RouterUtils } from '../../utils/common/RouterUtils';

/**
 * 鸿蒙平台下的Flutter页面跳转handler。
 * @param path 路由路径。
 * @param params 路由参数。
 * @param result 跳转结果，用于向Flutter页面返回参数。
 * @returns 处理是否完成。
 */
const flutterRouterPushHandler: (path: string, params: Record<string, Object> | undefined, result: MethodResult) => boolean =
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

/**
 * 鸿蒙平台下的Flutter页面返回handler。
 * @param call 函数调用。
 * @param params 路由参数。
 * @param result 跳转结果，用于向Flutter页面返回参数。
 * @returns 处理是否完成。
 */
const flutterRouterBackHandler: (call: MethodCall, params: Record<string, Object> | undefined, result: MethodResult) => boolean =
  (call, params, result) => {
    if (call.method === 'back') {
      let routerName: string | undefined = undefined;
      if (params !== undefined) {
        routerName = params instanceof Map ? params.get('router_name') as string : params['router_name'] as string;
      }
      if (routerName !== undefined) {
        RouterUtils.navBackTo(routerName);
      } else {
        RouterUtils.navBack();
      }
    }
    return true;
  };

/** 鸿蒙平台下的Flutter路由管理handler。 */
export function flutterRouterPlugin(): FlutterRouterPlugin {
  let flutterRouterPlugin: FlutterRouterPlugin = new FlutterRouterPlugin();
  flutterRouterPlugin.setRouterPushHandler(flutterRouterPushHandler);
  flutterRouterPlugin.setRouterBackHandler(flutterRouterBackHandler);
  return flutterRouterPlugin;
}