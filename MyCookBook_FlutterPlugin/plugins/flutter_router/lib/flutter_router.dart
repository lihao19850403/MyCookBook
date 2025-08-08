// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_router/router_manager.dart';

import 'flutter_router_platform_interface.dart';

class FlutterRouter {
  /// 页面栈，存储页面名称。
  static List<String> _pageNamesStack = [];

  /// 初始化Flutter层方法回调监听。
  ///
  /// 参数[navigatorKey]可用来获取全局context。
  static void initOnMethodCallWhenBuild(GlobalKey navigatorKey) {
    FlutterRouterPlatform.instance
        .getChannel()
        .setMethodCallHandler((MethodCall call) async {
      if (call.method == 'back') {
        back(navigatorKey.currentState!.context, params: call.arguments);
        return true;
      }
      return '${call.method} is not exist.';
    });
  }

  /// 页面跳转方法。
  ///
  /// 根据给定的路由路径[path]和路由参数[params]跳转至目标页面。
  ///
  /// 注：如果目标页面是Flutter页面，则使用Flutter的Navigator跳转，需要借助布局上下文[context]；如果目标页面不在Flutter路由表中，那么就尝试跳转入原生页面。
  static Future<T> go<T extends Object?>(BuildContext context, String path,
      {Object? params}) async {
    final bool isFlutterPage = RouterManager.instance.isFlutterPage(path);
    if (isFlutterPage) {
      String routePath = path.startsWith('/') ? path : '/$path';
      return Navigator.pushNamed(context, routePath, arguments: params)
          .then((result) {
        _pageNamesStack.add(path);
        return result as T;
      });
    } else {
      return FlutterRouterPlatform.instance
          .go<T>(path, params: params)
          .then((result) => result);
    }
  }

  /// 页面返回方法。
  ///
  /// 注：如果上一个页面是Flutter页面，则使用Flutter的Navigator跳转，需要借助布局上下文[context]；如果上一个页面是原生平台页面，那么就尝试跳转入原生页面。
  static void back(BuildContext context, {Object? params}) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(params);
    } else {
      FlutterRouterPlatform.instance.back(params: params);
    }
  }
}
