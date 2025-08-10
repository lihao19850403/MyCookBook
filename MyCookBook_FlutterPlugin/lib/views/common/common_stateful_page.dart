import 'package:flutter/widgets.dart';
import 'package:flutter_router/router_manager.dart';

/// 通用页面，附加一些额外功能。
abstract class CommonStatefulPage extends StatefulWidget {
  CommonStatefulPage({Key? key, required this.path}) : super(key: key) {
    RouterManager.instance.addBackPressFunc(path, _whenBackPressed);
  }

  final String path;

  bool _whenBackPressed() {
    return whenBackPressed();
  }

  /// 对返回事件进行拦截。当返回true时(默认)，可以正常返回；当返回false时，停止页面的返回动作。
  Function whenBackPressed = () => true;
}
