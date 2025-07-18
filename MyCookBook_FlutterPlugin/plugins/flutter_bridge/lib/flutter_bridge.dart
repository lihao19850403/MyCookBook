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
}
