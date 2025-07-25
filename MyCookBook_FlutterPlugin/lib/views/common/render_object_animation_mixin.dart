import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 动画调度抽象类，用于混入。
mixin RenderObjectAnimationMixin on RenderObject {
  double _progress = 0;
  int? _lastTimeStamp;

  /// 动画执行时长。
  Duration get duration => const Duration(milliseconds: 200);

  /// 动画状态。
  AnimationStatus _animationStatus = AnimationStatus.completed;

  /// 设置动画状态。
  set animationStatus(AnimationStatus v) {
    if (_animationStatus != v) {
      markNeedsPaint(); // 动画状态改变导致重绘。
    }
    _animationStatus = v;
  }

  /// 动画执行进度。
  double get progress => _progress;

  /// 设置动画执行进度，取值[0, 1]。
  set progress(double v) {
    _progress = v.clamp(0, 1);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    doPaint(context, offset);
    _scheduleAnimation();
  }

  void _scheduleAnimation() {
    if (_animationStatus != AnimationStatus.completed) {
      SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
        if (_lastTimeStamp != null) {
          double delta = (timeStamp.inMilliseconds - _lastTimeStamp!) /
              duration.inMilliseconds;
          // 一帧中添加了多个FrameCallback，直接标记控件需要重绘，这样只最后一次FrameCallback会被执行。
          if (delta == 0) {
            markNeedsPaint();
            return;
          }
          if (_animationStatus == AnimationStatus.reverse) {
            delta = -delta;
          }
          _progress = _progress + delta; // 更新进度。
          if (_progress >= 1 || _progress <= 0) {
            _animationStatus = AnimationStatus.completed;
            _progress = _progress.clamp(0, 1);
          }
        }
        markNeedsPaint();
        _lastTimeStamp = timeStamp.inMilliseconds;
      });
    } else {
      _lastTimeStamp = null;
    }
  }

  /// 子类进行绘制。
  void doPaint(PaintingContext context, Offset offset);
}
