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
    final String path = _getRouterPath(routerInfo);
    Object? params = _getRouterParams(routerInfo);
    RouterWidgetBuilder? routerWidgetBuilder = _routerMap[path];
    if (routerWidgetBuilder != null) {
      return routerWidgetBuilder(params ?? defaultParams);
    } else {
      return Container();
    }
  }

  /// 从路由信息[routerInfo]中解析出路径信息。
  ///
  /// 路由格式暂定为`path?params`，其中path是路由的路径信息，params是路由参数。路由参数是一个json字符串，路径信息与路由参数之间用问号分割。
  String _getRouterPath(String? routerInfo) {
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
  Object? _getRouterParams(String? routerInfo) {
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
}
