import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my_cook_book_flutter_plugin/views/common/render_object_animation_mixin.dart';

/// 自定义多选框，支持设置大小。
class CustomCheckBox extends LeafRenderObjectWidget {
  const CustomCheckBox(
      {Key? key,
      this.strokeWidth = 2.0,
      this.value = false,
      this.strokeColor = Colors.white,
      this.fillColor = Colors.blue,
      this.radius = 2.0,
      this.onChanged})
      : super(key: key);

  final double strokeWidth; // 对勾线宽。
  final Color strokeColor; // 对勾颜色。
  final Color? fillColor; // 填充色。
  final bool value; // 是否选中。
  final double radius; // 是否圆角。
  final ValueChanged<bool>? onChanged; // 选中状态改变监听。

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomCheckBox(strokeWidth, strokeColor,
        fillColor ?? Theme.of(context).primaryColor, value, radius, onChanged);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderCustomCheckBox renderObject) {
    if (renderObject.value != value) {
      // CheckBox状态改变，更新其动画状态。
      renderObject.animationStatus =
          value ? AnimationStatus.forward : AnimationStatus.reverse;
    }
    renderObject
      ..strokeWidth = strokeWidth
      ..strokeColor = strokeColor
      ..fillColor = fillColor ?? Theme.of(context).primaryColor
      ..radius = radius
      ..value = value
      ..onChanged = onChanged;
  }
}

class RenderCustomCheckBox extends RenderBox with RenderObjectAnimationMixin {
  RenderCustomCheckBox(this.strokeWidth, this.strokeColor, this.fillColor,
      this.value, this.radius, this.onChanged) {
    progress = value ? 1 : 0;
  }

  int pointerId = -1;
  double strokeWidth;
  Color strokeColor;
  Color fillColor;
  bool value;
  double radius;
  ValueChanged<bool>? onChanged;

  @override
  bool get isRepaintBoundary => true;

  /// 背景动画执行时长。
  final double bgAnimationInterval = .4;

  @override
  void doPaint(PaintingContext context, Offset offset) {
    Rect rect = offset & size;
    _drawBackground(context, rect);
    _drawCheckMark(context, rect);
  }

  void _drawBackground(PaintingContext context, Rect rect) {
    Color color = value ? fillColor : Colors.grey;
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..strokeWidth = strokeWidth
      ..color = color;
    final outer = RRect.fromRectXY(rect, radius, radius);
    var rects = [
      rect.inflate(-strokeWidth),
      Rect.fromCenter(center: rect.center, width: 0, height: 0)
    ];
    var rectProgress = Rect.lerp(rects[0], rects[1],
        min(progress, bgAnimationInterval) / bgAnimationInterval)!;
    final inner = RRect.fromRectXY(rectProgress, 0, 0);
    // 绘制背景。
    context.canvas.drawDRRect(outer, inner, paint);
  }

  void _drawCheckMark(PaintingContext context, Rect rect) {
    if (progress > bgAnimationInterval) {
      // 绘制完背景后绘制对勾。
      final secondOffset =
          Offset(rect.left + rect.width / 2.5, rect.bottom - rect.height / 4);
      final lastOffset =
          Offset(rect.right - rect.width / 6, rect.top + rect.height / 4);
      final lastOffsetResult = Offset.lerp(secondOffset, lastOffset,
          (progress - bgAnimationInterval) / (1 - bgAnimationInterval))!;
      final path = Path()
        ..moveTo(rect.left + rect.width / 7, rect.top + rect.height / 2)
        ..lineTo(secondOffset.dx, secondOffset.dy)
        ..lineTo(lastOffsetResult.dx, lastOffsetResult.dy);
      final paint = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..color = strokeColor
        ..strokeWidth = strokeWidth;
      context.canvas.drawPath(path, paint..style = PaintingStyle.stroke);
    }
  }

  @override
  void performLayout() {
    size = constraints
        .constrain(constraints.isTight ? Size.infinite : const Size(25, 25));
  }

  @override
  bool hitTestSelf(Offset position) => true; // 响应点击事件。

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    if (event.down) {
      pointerId = event.pointer;
    } else if (pointerId == event.pointer) {
      if (size.contains(event.localPosition)) {
        // 触摸点位于本控件范围内，触发onChanged回调。
        onChanged?.call(!value);
      }
    }
  }
}
