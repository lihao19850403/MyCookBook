import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:my_cook_book_flutter_plugin/models/text_size_plan_model.dart';

/// 全局调试标记。
const String TAG = '[Flutter]';

/// 屏幕类型。
enum ScreenUIType {
  /// 直板单屏、折叠屏设备已合上、默认状态。
  NORMAL,

  /// 折叠屏设备已打开状态。
  FOLD_OPENED,

  /// 平板类型设备屏幕。
  PAD;
}

/// 全局配置信息。
class Global {
  /// 全局调试开关。
  static bool debug = true;

  /// 全局Navigator上下文。
  static GlobalKey<NavigatorState> navigatorkey = GlobalKey();

  /// 屏幕顶端安全区距离。
  static double screenTopSafeZoneHeightVP =
      MediaQueryData.fromView(PlatformDispatcher.instance.views.first)
          .padding
          .top;

  /// 屏幕底部安全区距离。
  static double screenBottomSafeZoneHeightVP =
      MediaQueryData.fromView(PlatformDispatcher.instance.views.last)
          .padding
          .bottom;

  /// 屏幕类型。
  static ScreenUIType screenUIType = ScreenUIType.NORMAL;

  /// 是否使用分屏设置。
  static bool isSplitScreen = false;

  /// 字号配置方案。
  static AppSettingsTextSizePlanModel textSizePlan = AppSettingsTextSizePlanModel.SMALL;
}
