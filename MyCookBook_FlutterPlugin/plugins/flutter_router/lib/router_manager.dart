import 'dart:convert';
import 'package:flutter/widgets.dart';

/// Widget构造方法，接收任意类型参数[params]。
typedef RouterWidgetBuilder = Widget Function(dynamic params);

/// flutter路由管理器。
/// @author li.hao85
class RouterManager {
  RouterManager._();

  static final RouterManager _instance = RouterManager._();

  static RouterManager get instance => _instance;

  /// 路由路径与Widget构造方法的对应Map。
  final Map<String, RouterWidgetBuilder> _routerMap = {};

  /// 路由路径与页面返回方法的对应Map。
  final Map<String, Function> _backPressMap = {};

  /// 添加新的路由路径[path]与对应的Widget构造方法[routerWidgetBuilder]。
  bool addRouter(String path, RouterWidgetBuilder routerWidgetBuilder) {
    _routerMap[path] = routerWidgetBuilder;
    return true;
  }

  /// 根据路由信息[routerInfo]查询对应的Widget构造方法并返回。
  ///
  /// 当路由信息[routerInfo]不带参数时，尝试给对应的Widget构造方法传递默认参数[defaultParams]。
  ///
  /// 注：如果路由信息不对应任何Widget构造方法，那么会返回一个Container空容器。
  Widget getRouterWidget(String routerInfo, {Object? defaultParams}) {
    final String path = getRouterPath(routerInfo);
    Object? params = getRouterParams(routerInfo);
    RouterWidgetBuilder? routerWidgetBuilder = _routerMap[path];
    if (routerWidgetBuilder != null) {
      return routerWidgetBuilder(params ?? defaultParams);
    } else {
      return Container();
    }
  }

  /// 判断给定的路由信息[routerInfo]是否指向Flutter页面。
  bool isFlutterPage(String routerInfo) {
    final String path = getRouterPath(routerInfo);
    return _routerMap.containsKey(path);
  }

  /// 从路由信息[routerInfo]中解析出路径信息。
  ///
  /// 路由格式暂定为`path?params`，其中path是路由的路径信息，params是路由参数。路由参数是一个json字符串，路径信息与路由参数之间用问号分割。
  String getRouterPath(String? routerInfo) {
    if (routerInfo == null) {
      return '/';
    }
    if (routerInfo.contains('?')) {
      Uri uri = Uri.parse(routerInfo);
      return uri.path;
    } else {
      return routerInfo;
    }
  }

  /// 从路由信息[routerInfo]中解析出路由参数。
  ///
  /// 路由格式暂定为`path?params`，其中path是路由的路径信息，params是路由参数。路由参数是一个json字符串，路径信息与路由参数之间用问号分割。
  Object? getRouterParams(String? routerInfo) {
    if (routerInfo == null) {
      return null;
    }
    if (routerInfo.contains('?')) {
      Uri uri = Uri.parse(routerInfo);
      String query = uri.query;
      try {
        query = Uri.decodeFull(query);
        return json.decode(query);
      } catch (error) {
        return Uri.splitQueryString(query);
      }
    } else {
      return null;
    }
  }

  /// 将已登记的路由信息转换为MaterialApp可用的routes属性。
  Map<String, WidgetBuilder> getRoutesMap() {
    Map<String, WidgetBuilder> routesMap = {};
    _routerMap.forEach((String path, RouterWidgetBuilder builder) {
      String routePath = path.startsWith('/') ? path : '/$path';
      routesMap[routePath] = (context, {arguments}) {
        return builder(arguments);
      };
    });
    return routesMap;
  }

  /// 添加新的路由路径[path]与对应页面的返回方法[backPressFunc]。
  bool addBackPressFunc(String path, Function backPressFunc) {
    _backPressMap[path] = backPressFunc;
    return true;
  }

  /// 获取指定路由路径[path]对应页面的返回方法。
  Function? getBackPressFunc(String? path) {
    return _backPressMap[path];
  }

  /// 清除路由路径[path]对应页面的返回方法。
  bool removeBackPressFunc(String? path) {
    _backPressMap.remove(path);
    return true;
  }

  /// 获取所有返回方法的列表。
  List<Function> getAllBackPressFuncs() {
    List<Function> allFunctions = [];
    _backPressMap
        .forEach((String key, Function value) => allFunctions.add(value));
    return allFunctions;
  }
}
