import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_router_platform_interface.dart';

/// An implementation of [FlutterRouterPlatform] that uses method channels.
class MethodChannelFlutterRouter extends FlutterRouterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_router');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<T> go<T extends Object?>(String path, {dynamic params}) async {
    var routerParams = {};
    routerParams['path'] = path;
    if (params != null) {
      routerParams['params'] = params;
    }
    final result = await methodChannel.invokeMethod('go', routerParams);
    return result;
  }

  @override
  void back({dynamic params}) async {
    var routerParams = {};
    if (params != null) {
      routerParams = params;
    }
    await methodChannel.invokeMethod('back', routerParams);
  }
}
