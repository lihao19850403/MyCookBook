import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bridge/flutter_bridge_platform_interface.dart';
import 'package:my_cook_book_flutter_plugin/models/created_menu_item.dart';

/// Flutter与原生交互的桥方法集。
class Bridge {
  /// 初始化Flutter层方法回调监听。
  ///
  /// 参数[navigatorKey]可用来获取全局context。
  static void initOnMethodCallWhenBuild(GlobalKey navigatorKey) {
    FlutterBridgePlatform.instance
        .getChannel()
        .setMethodCallHandler((MethodCall call) async {
      // if (call.method == 'xxx') {

      //   return true;
      // }
      return '${call.method} is not exist.';
    });
  }

  /// 查询屏幕顶部和底部安全区距离，单位是VP。
  static Future<Map<String, double>?> queryScreenSafeZoneHeightVP() async {
    final Map<Object?, Object?>? result = await FlutterBridgePlatform.instance
        .callNativeMethod('queryScreenSafeZoneHeightVP');
    if (result == null) {
      return Future.value(null);
    }
    Map<String, double> data = <String, double>{};
    if (result.containsKey('screenTopSafeZoneHeightVP') &&
        result['screenTopSafeZoneHeightVP'] != null) {
      data['screenTopSafeZoneHeightVP'] =
          result['screenTopSafeZoneHeightVP'] as double;
    }
    if (result.containsKey('screenBottomSafeZoneHeightVP') &&
        result['screenBottomSafeZoneHeightVP'] != null) {
      data['screenBottomSafeZoneHeightVP'] =
          result['screenBottomSafeZoneHeightVP'] as double;
    }
    return Future.value(data);
  }

  /// 查询所有自创菜谱。
  static Future<List<CreatedMenuItem>?> queryAllCreatedMenus() async {
    final List<Object?>? result = await FlutterBridgePlatform.instance
        .callNativeMethod('queryAllCreatedMenus');
    if (result == null) {
      return Future.value(null);
    }
    List<CreatedMenuItem> data = <CreatedMenuItem>[];
    for (Object? resultItem in result) {
      if (resultItem != null) {
        Map<Object?, Object?> dataItemMap = resultItem as Map<Object?, Object?>;
        CreatedMenuItem dataItem = CreatedMenuItem.fromMap(dataItemMap);
        data.add(dataItem);
      }
    }
    return Future.value(data);
  }
}
