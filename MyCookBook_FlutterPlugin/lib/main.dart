import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_router/flutter_router.dart';
import 'package:flutter_router/router_manager.dart';
import 'package:my_cook_book_flutter_plugin/models/text_size_plan_model.dart';
import 'package:my_cook_book_flutter_plugin/pages/create_menu/create_menu_detail_page.dart';
import 'package:my_cook_book_flutter_plugin/pages/create_menu/create_menu_modify_page.dart';
import 'package:my_cook_book_flutter_plugin/pages/create_menu/create_menu_list_page.dart';
import 'package:my_cook_book_flutter_plugin/utils/bridge.dart';
import 'package:my_cook_book_flutter_plugin/utils/common/global.dart';
import 'package:my_cook_book_flutter_plugin/utils/common/error_handler.dart';
import 'package:my_cook_book_flutter_plugin/views/common/safe_update.dart';

void main() {
  safeRun(() {
    // 初始化路由。
    RouterManager.instance.addRouter(CreateMenuListPage.PAGE_NAME,
        (params) => CreateMenuListPage(params: params));
    RouterManager.instance.addRouter(CreateMenuModifyPage.PAGE_NAME,
        (params) => CreateMenuModifyPage(params: params));
    RouterManager.instance.addRouter(CreateMenuDetailPage.PAGE_NAME,
        (params) => CreateMenuDetailPage(params: params));

    // 加载内容页。
    var pathInfo = PlatformDispatcher.instance.defaultRouteName;
    runApp(MyApp(pathInfo: pathInfo));
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, required this.pathInfo}) : super(key: key);
  final String pathInfo;

  @override
  State<StatefulWidget> createState() {
    return _MyApp();
  }
}

class _MyApp extends SafeState<MyApp> {
  @override
  Widget build(BuildContext context) {
    _initGlobalParams(widget.pathInfo);
    _initMethodCallHandlerWhenBuild();
    return MaterialApp(
        title: 'FlutterPlugin',
        navigatorKey: Global.navigatorkey,
        home: RouterManager.instance.getRouterWidget(widget.pathInfo),
        routes: RouterManager.instance.getRoutesMap());
  }
}

/// 初始化全局参数。
void _initGlobalParams(String pathInfo) {
  Map<Object?, Object?>? params =
      RouterManager.instance.getRouterParams(pathInfo) as Map?;
  if (params == null || params.isEmpty) {
    return;
  }
  if (params.containsKey('screenTopSafeZoneHeightVP')) {
    Global.screenTopSafeZoneHeightVP =
        params['screenTopSafeZoneHeightVP'] as double;
  }
  if (params.containsKey('screenBottomSafeZoneHeightVP')) {
    Global.screenBottomSafeZoneHeightVP =
        params['screenBottomSafeZoneHeightVP'] as double;
  }
  if (params.containsKey('screenUIType')) {
    int screenUIType = params['screenUIType'] as int;
    Global.screenUIType = screenUIType == 1
        ? ScreenUIType.FOLD_OPENED
        : screenUIType == 2
            ? ScreenUIType.PAD
            : ScreenUIType.NORMAL;
  }
  if (params.containsKey('splitScreenSetting')) {
    Global.isSplitScreen = params['splitScreenSetting'] as bool;
  }
  if (params.containsKey('textSizePlanID')) {
    int textSizePlanID = params['textSizePlanID'] as int;
    Global.textSizePlan = textSizePlanID == 1
        ? AppSettingsTextSizePlanModel.NORMAL
        : textSizePlanID == 2
            ? AppSettingsTextSizePlanModel.BIG
            : textSizePlanID == 3
                ? AppSettingsTextSizePlanModel.HUGE
                : AppSettingsTextSizePlanModel.SMALL;
  }
}

/// 在build方法中初始化Flutter方法回到监听。
void _initMethodCallHandlerWhenBuild() {
  FlutterRouter.initOnMethodCallWhenBuild(Global.navigatorkey);
  Bridge.initOnMethodCallWhenBuild(Global.navigatorkey);
}
