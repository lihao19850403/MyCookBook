import { MethodResult } from "@ohos/flutter_ohos";
import FlutterBridgePlugin from "flutter_bridge";
import { getScreenBottomSafeZoneHeightPx, getScreenTopSafeZoneHeightPx } from "../../utils/common/ScreenUIAdapter";

/**
 * 鸿蒙平台下的Flutter桥方法处理器。
 * @param methodName 桥方法名称。
 * @param methodParams 桥方法参数。
 * @param result 运行结果，用于向Flutter页面返回参数。
 */
const flutterBridgeCallHandler: (methodName: string, methodParams: object | undefined, result: MethodResult) => void =
  (methodName, methodParams, result) => {
    if (methodName === 'getScreenSafeZoneHeightPx') {
      let top: number = getScreenTopSafeZoneHeightPx();
      let bottom: number = getScreenBottomSafeZoneHeightPx();
      let data: Record<string, number> = {};
      data['top'] = top;
      data['bottom'] = bottom;
      result.success(data);
      return;
    }
    result.notImplemented();
  };

/** 鸿蒙平台下的Flutter桥方法处理插件。 */
export function getFlutterBridgePlugin(): FlutterBridgePlugin {
  let flutterBridgePlugin: FlutterBridgePlugin = new FlutterBridgePlugin();
  flutterBridgePlugin.setBridgeCallHandler(flutterBridgeCallHandler);
  return flutterBridgePlugin;
}