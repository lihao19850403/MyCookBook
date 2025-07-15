import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_router/flutter_router.dart';
import 'package:flutter_router/router_manager.dart';
import 'package:my_cook_book_flutter_plugin/login_page.dart';
import 'package:my_cook_book_flutter_plugin/second_page.dart';
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
    FlutterRouter().initOnMethodCallWhenBuild(Global.navigatorkey);
    return MaterialApp(
      navigatorKey: Global.navigatorkey,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RouterManager.instance.getRouterWidget(pathInfo),
    );
  }
}

void _initRouters() {
  RouterManager.instance
      .addRouter('login_page', (params) => LoginPage(params: params));
  RouterManager.instance
      .addRouter('second_page', (params) => const SecondPage());
}
