import { GeneratedPluginRegistrant } from "@ohos/flutter_module";
import { FlutterEngine, FlutterEntry } from "@ohos/flutter_ohos";

/**
 * Flutter模块与原生交互工具类，在此可以注册各种插件。
 * @author li.hao85
 */
export default class FlutterWrapEntry extends FlutterEntry {
  configureFlutterEngine(flutterEngine: FlutterEngine): void {
    super.configureFlutterEngine(flutterEngine);
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    // this.delegate?.addPlugin(new BatteryPlugin());
  }
}