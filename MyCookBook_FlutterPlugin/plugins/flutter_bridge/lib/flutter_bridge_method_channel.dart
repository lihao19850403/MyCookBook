import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_bridge_platform_interface.dart';

/// An implementation of [FlutterBridgePlatform] that uses method channels.
class MethodChannelFlutterBridge extends FlutterBridgePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_bridge');

  @override
  MethodChannel getChannel() {
    return methodChannel;
  }

  @override
  Future<T> getScreenSafeZoneHeightPx<T extends Object?>() async {
    final result =
        await methodChannel.invokeMethod('getScreenSafeZoneHeightPx');
    return result;
  }
}
