import 'package:flutter/widgets.dart';

/// 全局调试标记。
const String TAG = '[Flutter]';

/// 全局配置信息。
class Global {
  /// 全局Navigator上下文。
  static GlobalKey<NavigatorState> navigatorkey = GlobalKey();
}
