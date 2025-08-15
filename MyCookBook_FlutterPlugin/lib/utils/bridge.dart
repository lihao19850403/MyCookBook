import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bridge/flutter_bridge_platform_interface.dart';
import 'package:my_cook_book_flutter_plugin/models/created_menu_item.dart';
import 'package:my_cook_book_flutter_plugin/utils/common/event_bus.dart';
import 'package:my_cook_book_flutter_plugin/utils/common/global.dart';

/// 屏幕类型、分屏配置项变化事件。
const String SCREEN_UI_INFO_CHANGED_EVENT = 'screenUIInfoChangedEvent';

/// 重刷自创菜谱列表事件。
const String REFRESH_CREATED_MENUS_LIST_EVENT = 'refreshCreatedMenusListEvent';

/// 重刷单个自创菜谱事件。
const String REFRESH_CREATED_MENUS_ITEM_EVENT = 'refreshCreatedMenusItemEvent';

/// Flutter与原生交互的桥方法集。
class Bridge {
  /// 初始化Flutter层方法回调监听。
  ///
  /// 参数[navigatorKey]可用来获取全局context。
  static void initOnMethodCallWhenBuild(GlobalKey navigatorKey) {
    FlutterBridgePlatform.instance
        .getChannel()
        .setMethodCallHandler((MethodCall call) async {
      if (call.method == 'screenUITypeChanged') {
        int newScreenUIType = call.arguments as int;
        Global.screenUIType = newScreenUIType == 1
            ? ScreenUIType.FOLD_OPENED
            : newScreenUIType == 2
                ? ScreenUIType.PAD
                : ScreenUIType.NORMAL;
        eventBus.emit(SCREEN_UI_INFO_CHANGED_EVENT);
        return true;
      }
      if (call.method == 'splitScreenSettingChanged') {
        bool newSplitScreenSetting = call.arguments as bool;
        Global.isSplitScreen = newSplitScreenSetting;
        eventBus.emit(SCREEN_UI_INFO_CHANGED_EVENT);
        return true;
      }
      return '${call.method} is not exist.';
    });
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

  /// 根据菜谱ID[menuID]查询对应菜谱信息。
  static Future<CreatedMenuItem?> queryOneCreatedMenu(num menuID) async {
    final Object? result = await FlutterBridgePlatform.instance
        .callNativeMethod('queryOneCreatedMenu', methodParams: menuID);
    if (result == null) {
      return Future.value(null);
    }
    Map<Object?, Object?> dataMap = result as Map<Object?, Object?>;
    CreatedMenuItem data = CreatedMenuItem.fromMap(dataMap);
    return Future.value(data);
  }

  /// 选择一个分类。
  static Future<String?> selectCategory(String? curCategoryName) async {
    final String? result = await FlutterBridgePlatform.instance
        .callNativeMethod('selectCategory', methodParams: curCategoryName);
    if (result == null || result.isEmpty) {
      return Future.value(null);
    }
    return Future.value(result);
  }

  /// 添加一个自创菜谱。
  static Future<bool?> addOneCreatedMenu(
      {String? menuTitle,
      String? author,
      String? category,
      String? texing,
      String? yuanliao,
      String? tiaoliao,
      String? zuofa,
      String? wenxintishi}) async {
    Map<String, String?> data = HashMap();
    data['cp_name'] = menuTitle;
    data['author'] = author;
    data['type_name'] = category;
    data['texing'] = texing;
    data['yuanliao'] = yuanliao;
    data['tiaoliao'] = tiaoliao;
    data['zuofa'] = zuofa;
    data['tishi'] = wenxintishi;
    final bool? result = await FlutterBridgePlatform.instance
        .callNativeMethod('addOneCreatedMenu', methodParams: data);
    return Future.value(result);
  }

  /// 更新一个自创菜谱。
  static Future<bool?> updateOneCreatedMenu(
      {num? menuID,
      String? menuTitle,
      String? author,
      String? category,
      String? texing,
      String? yuanliao,
      String? tiaoliao,
      String? zuofa,
      String? wenxintishi}) async {
    Map<String, Object?> data = HashMap();
    data['cp_id'] = menuID;
    data['cp_name'] = menuTitle;
    data['author'] = author;
    data['type_name'] = category;
    data['texing'] = texing;
    data['yuanliao'] = yuanliao;
    data['tiaoliao'] = tiaoliao;
    data['zuofa'] = zuofa;
    data['tishi'] = wenxintishi;
    final bool? result = await FlutterBridgePlatform.instance
        .callNativeMethod('updateOneCreatedMenu', methodParams: data);
    return Future.value(result);
  }

  /// 批量删除菜谱。
  static Future<bool?> removeCreatedMenus(List<num> ids) async {
    final bool? result = await FlutterBridgePlatform.instance
        .callNativeMethod('removeCreatedMenus', methodParams: ids);
    return Future.value(result);
  }
}
