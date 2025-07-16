import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bridge/flutter_bridge.dart';
import 'package:flutter_bridge/flutter_bridge_platform_interface.dart';
import 'package:flutter_bridge/flutter_bridge_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterBridgePlatform
    with MockPlatformInterfaceMixin
    implements FlutterBridgePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterBridgePlatform initialPlatform = FlutterBridgePlatform.instance;

  test('$MethodChannelFlutterBridge is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterBridge>());
  });

  test('getPlatformVersion', () async {
    FlutterBridge flutterBridgePlugin = FlutterBridge();
    MockFlutterBridgePlatform fakePlatform = MockFlutterBridgePlatform();
    FlutterBridgePlatform.instance = fakePlatform;

    expect(await flutterBridgePlugin.getPlatformVersion(), '42');
  });
}
