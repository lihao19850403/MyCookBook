import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_bridge_method_channel.dart';

abstract class FlutterBridgePlatform extends PlatformInterface {
  /// Constructs a FlutterBridgePlatform.
  FlutterBridgePlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterBridgePlatform _instance = MethodChannelFlutterBridge();

  /// The default instance of [FlutterBridgePlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterBridge].
  static FlutterBridgePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterBridgePlatform] when
  /// they register themselves.
  static set instance(FlutterBridgePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
