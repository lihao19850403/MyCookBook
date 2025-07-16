
import 'flutter_bridge_platform_interface.dart';

class FlutterBridge {
  Future<String?> getPlatformVersion() {
    return FlutterBridgePlatform.instance.getPlatformVersion();
  }
}
