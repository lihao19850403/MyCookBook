// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'package:flutter/material.dart';
import 'package:flutter_router/router_manager.dart';

import 'flutter_router_platform_interface.dart';

class FlutterRouter {
  Future<String?> getPlatformVersion() {
    return FlutterRouterPlatform.instance.getPlatformVersion();
  }

  /// 页面跳转方法。
  ///
  /// 根据给定的路由路径[path]和路由参数[params]跳转至目标页面。
  ///
  /// 注：如果目标页面是Flutter页面，则使用Flutter的Navigator跳转，需要借助布局上下文[context]；如果目标页面不在Flutter路由表中，那么就尝试跳转入原生页面。
  Future<T> go<T extends Object?>(BuildContext context, String path,
      {Object? params}) async {
    final bool isFlutterPage = RouterManager.instance.isFlutterPage(path);
    if (isFlutterPage) {
      Widget widget =
          RouterManager.instance.getRouterWidget(path, defaultParams: params);
      return Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => widget))
          .then((result) => result);
    } else {
      return FlutterRouterPlatform.instance
          .go<T>(path, params: params)
          .then((result) => result);
    }
  }
}
