import { FlutterEngine, FlutterEntry, Log, MethodResult } from "@ohos/flutter_ohos";
import FlutterBridgePlugin from "flutter_bridge";
import FlutterRouterPlugin from "flutter_router";
import { getFlutterBridgePlugin } from "./FlutterBridgeUtils";
import { getFlutterRouterPlugin } from "./FlutterRouterUtils";

const TAG = "FlutterWrapEntry";

/**
 * Flutter模块与原生交互工具类，在此可以注册各种插件。
 * @author li.hao85
 */
export default class FlutterWrapEntry extends FlutterEntry {
  private flutterRouterPlugin: FlutterRouterPlugin = getFlutterRouterPlugin();
  private flutterBridgePlugin: FlutterBridgePlugin = getFlutterBridgePlugin();

  configureFlutterEngine(flutterEngine: FlutterEngine): void {
    super.configureFlutterEngine(flutterEngine);
    try {
      /* 注册通用插件。 */
      flutterEngine.getPlugins()?.add(this.flutterRouterPlugin);
      /* 注册其他插件。 */
      this.delegate?.addPlugin(this.flutterBridgePlugin);
    } catch (error) {
      Log.e(
        TAG,
        "Tried to register plugins with FlutterEngine ("
          + flutterEngine
          + ") failed.");
      Log.e(TAG, "Received exception while registering", error);
    }
  }

  /**
   * 调用Flutter的back()方法。
   * @param params 方法参数。
   * @param callback 执行结果回调。
   */
  callFlutterBack(params?: Object, callback?: MethodResult) {
    this.flutterRouterPlugin.getChannel()?.invokeMethod('back', params, callback);
  }
}