import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:my_cook_book_flutter_plugin/utils/common/global.dart';

import '../../utils/bridge.dart';
import '../../utils/common/event_bus.dart';

/// 自定义抽象控件，提供安全的setState功能。
class SafeState<T extends StatefulWidget> extends State<T> {
  /// 窄屏模式。
  @protected
  bool normalScreenMode = Global.screenUIType == ScreenUIType.NORMAL ||
      (Global.isSplitScreen && Global.screenUIType == ScreenUIType.FOLD_OPENED);

  /// 屏幕状态改变事件。
  EventCallback? _onScreenUIInfoChangedEvent;

  @override
  void initState() {
    super.initState();
    _onScreenUIInfoChangedEvent = (Object? arguments) =>
        onScreenUIInfoChanged(Global.screenUIType, Global.isSplitScreen);
    eventBus.on(SCREEN_UI_INFO_CHANGED_EVENT, _onScreenUIInfoChangedEvent!);
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  void dispose() {
    super.dispose();
    eventBus.off(SCREEN_UI_INFO_CHANGED_EVENT, _onScreenUIInfoChangedEvent!);
  }

  /// 安全更新函数。由于在绘制Frame阶段不能再调用setState，因此增加此函数，以便在页面绘制状态安全的情况下更新UI。
  /// 参数fn为原本setState方法的函数参数。
  @protected
  void safeUpdate(VoidCallback fn) {
    final schedulerPhase = SchedulerBinding.instance.schedulerPhase;
    if (schedulerPhase == SchedulerPhase.persistentCallbacks) {
      // 在这个阶段不能直接调用setState，应该安排一个刷新UI的任务，添加至帧绘制动作之后。
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(fn);
      });
    } else {
      setState(fn);
    }
  }

  /// 屏幕状态改变事件。
  /// 当屏幕状态发生变化时被触发，传递新的屏幕状态[newScreenUIType]、以及当前是否为分屏模式[isSplitScreen]。
  @protected
  void onScreenUIInfoChanged(ScreenUIType newScreenUIType, bool isSplitScreen) {
    safeUpdate(() {
      normalScreenMode = newScreenUIType == ScreenUIType.NORMAL ||
          (isSplitScreen && newScreenUIType == ScreenUIType.FOLD_OPENED);
    });
  }
}
