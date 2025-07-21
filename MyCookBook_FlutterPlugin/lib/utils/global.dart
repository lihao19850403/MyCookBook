import 'package:flutter/widgets.dart';

/// 全局调试标记。
const String TAG = '[Flutter]';

/// 全局配置信息。
class Global {
  /// 全局Navigator上下文。
  static GlobalKey<NavigatorState> navigatorkey = GlobalKey();
}

/// 全局颜色资源。
class Resources_color {
  static const main_bg_gray_color = Color(0xFFF2F2F2);
}

/// 全局文字资源。
class Resources_string {
  static const String create_menu = '自创菜谱';
}

/// 全局文件资源。
class Resources_media {
  static const String ic_main_back_arrow =
      'assets/images/ic_main_back_arrow.webp';
  static const String ic_create_menu_green =
      'assets/images/ic_create_menu_green.webp';
}
