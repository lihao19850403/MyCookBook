import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bridge/flutter_bridge.dart';
import 'package:flutter_router/flutter_router.dart';
import 'package:flutter_router/router_manager.dart';
import 'package:my_cook_book_flutter_plugin/create_menu.dart';
import 'package:my_cook_book_flutter_plugin/utils.dart';

void main() {
  _initRouters();
  var pathInfo = PlatformDispatcher.instance.defaultRouteName;
  runApp(MyApp(pathInfo: pathInfo));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.pathInfo}) : super(key: key);
  final String pathInfo;

  @override
  Widget build(BuildContext context) {
    _initMethodCallHandlerWhenBuild();
    return MaterialApp(
      navigatorKey: Global.navigatorkey,
      home: RouterManager.instance.getRouterWidget(pathInfo),
    );
  }
}

void _initRouters() {
  RouterManager.instance
      .addRouter('CreateMenu', (params) => CreateMenu(params: params));
}

void _initMethodCallHandlerWhenBuild() {
  FlutterRouter().initOnMethodCallWhenBuild(Global.navigatorkey);
  FlutterBridge().initOnMethodCallWhenBuild(Global.navigatorkey);
}
