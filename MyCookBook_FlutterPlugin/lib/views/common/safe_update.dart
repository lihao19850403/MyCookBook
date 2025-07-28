import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// 自定义抽象控件，提供安全的setState功能。
class SafeState<T extends StatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  /// 安全更新函数。由于在绘制Frame阶段不能再调用setState，因此增加此函数，以便在页面绘制状态安全的情况下更新UI。
  /// 参数fn为原本setState方法的函数参数。
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
}
