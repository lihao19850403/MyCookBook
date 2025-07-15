import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';

/** Flutter路由跳转类型。 */
export type FlutterRouterPushHandler = (path: string, params: Record<string, Object> | undefined, result: MethodResult) => boolean;

/** Flutter路由返回类型。 */
export type FlutterRouterBackHandler = (call: MethodCall, params: Record<string, Object> | undefined, result: MethodResult) => boolean;

/** FlutterRouterPlugin **/
export default class FlutterRouterPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;

  /** Flutter路由跳转工具，默认不处理路由，返回false。主工程可自行修改为有意义的工具。 */
  private routerPushHandler: FlutterRouterPushHandler = (path, params, result) => {
    console.log(`FlutterRouterPushHandler 默认实现。路径：${path}，参数：${JSON.stringify(params)}`);
    return false;
  };

  /** Flutter路由返回工具，默认不处理路由，返回false。主工程可自行修改为有意义的工具。 */
  private routerBackHandler: FlutterRouterBackHandler = (call, params, result) => {
    console.log(`FlutterRouterBackHandler 默认实现。调用：${JSON.stringify(call)}，参数：${JSON.stringify(params)}`);
    return false;
  }

  constructor() {
  }

  /**
   * 设置Flutter路由跳转工具。
   * @param newHandler 新的路由跳转工具。
   */
  setRouterPushHandler(newHandler: FlutterRouterPushHandler) {
    this.routerPushHandler = newHandler;
  }

  /**
   * 设置Flutter路由返回工具。
   * @param newHandler 新的路由返回工具。
   */
  setRouterBackHandler(newHandler: FlutterRouterBackHandler) {
    this.routerBackHandler = newHandler;
  }

  getUniqueClassName(): string {
    return "FlutterRouterPlugin";
  }

  getChannel(): MethodChannel | null {
    return this.channel;
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "flutter_router");
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null);
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method === 'go') {
      let path: string = call.argument('path');
      let params: Record<string, Object> | undefined = call.argument('params');
      this.routerPushHandler(path, params, result);
    } else if (call.method === 'back') {
      let params: Record<string, Object> | undefined = call.argument('params');
      this.routerBackHandler(call, params, result);
    } else {
      result.notImplemented();
    }
  }
}