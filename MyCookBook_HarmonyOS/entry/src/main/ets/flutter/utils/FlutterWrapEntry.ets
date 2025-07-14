import { FlutterEngine, FlutterEntry, Log } from "@ohos/flutter_ohos";
import FlutterRouterPlugin from "flutter_router";
import { flutterRouterPlugin } from "./FlutterRouterUtils";

const TAG = "FlutterWrapEntry";

/**
 * Flutter模块与原生交互工具类，在此可以注册各种插件。
 * @author li.hao85
 */
export default class FlutterWrapEntry extends FlutterEntry {
  private flutterRouterPlugin: FlutterRouterPlugin = flutterRouterPlugin();

  configureFlutterEngine(flutterEngine: FlutterEngine): void {
    super.configureFlutterEngine(flutterEngine);
    try {
      /* 注册通用插件。 */
      flutterEngine.getPlugins()?.add(this.flutterRouterPlugin);
      /* 注册其他插件。 */

      // this.delegate?.addPlugin(new BatteryPlugin());
    } catch (error) {
      Log.e(
        TAG,
        "Tried to register plugins with FlutterEngine ("
          + flutterEngine
          + ") failed.");
      Log.e(TAG, "Received exception while registering", error);
    }
  }

  callFlutterMethod(name: string, params: Object) {
    this.flutterRouterPlugin.
  }
}