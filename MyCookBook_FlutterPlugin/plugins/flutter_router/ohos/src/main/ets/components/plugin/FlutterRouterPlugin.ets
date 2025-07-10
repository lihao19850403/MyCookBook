import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';

/** Flutter路由工具类型。 */
export type FlutterRouterPushHandler = (path: string, params: Record<string, Object> | undefined, result: MethodResult) => boolean;

/** FlutterRouterPlugin **/
export default class FlutterRouterPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;

  /** Flutter路由管理工具，默认不处理路由，返回false。主工程可自行修改为有意义的工具。 */
  static routerPushHandler: FlutterRouterPushHandler = (path, params, result) => {
    console.log(`FlutterRouterPushHandler 默认实现。路径：${path}，参数：${JSON.stringify(params)}`);
    return false;
  };

  constructor() {
  }

  /**
   * 设置Flutter路由管理工具。
   * @param newHandler 新的路由管理工具。
   */
  static setRouterPushHandler(newHandler: FlutterRouterPushHandler) {
    FlutterRouterPlugin.routerPushHandler = newHandler;
  }

  getUniqueClassName(): string {
    return "FlutterRouterPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "flutter_router");
    this.channel.setMethodCallHandler(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method == "getPlatformVersion") {
      result.success("OpenHarmony ^ ^ ")
    } else if (call.method === 'go') {
      let path: string = call.argument('path');
      let params: Record<string, Object> | undefined = call.argument('params');
      FlutterRouterPlugin.routerPushHandler(path, params, result);
    } else {
      result.notImplemented()
    }
  }
}