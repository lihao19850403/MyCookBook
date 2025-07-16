import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bridge/flutter_bridge_platform_interface.dart';

class FlutterBridge {
  /// 初始化Flutter层方法回调监听。
  ///
  /// 参数[navigatorKey]可用来获取全局context。
  void initOnMethodCallWhenBuild(GlobalKey navigatorKey) {
    FlutterBridgePlatform.instance
        .getChannel()
        .setMethodCallHandler((MethodCall call) async {
      // if (call.method == 'xxx') {

      //   return true;
      // }
      return '${call.method} is not exist.';
    });
  }

  /// 获取平台安全区数据。
  ///
  /// 结果格式：'{top: xxx, bottom: yyy}'。其中xxx是屏幕顶端安全区距离；yyy是屏幕底端安全区距离。
  Future<Map<String, int>> getScreenSafeZoneHeightPx() async {
    final result =
        await FlutterBridgePlatform.instance.getScreenSafeZoneHeightPx();
    Map tempMap = result as Map;
    int tempTop = tempMap['top'];
    int tempBottom = tempMap['bottom'];
    Map<String, int> data = {'top': tempTop, 'bottom': tempBottom};
    return data;
  }
}
