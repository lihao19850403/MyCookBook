import 'package:flutter/material.dart';
import 'package:my_cook_book_flutter_plugin/views/common/custom_check_box.dart';
import 'package:my_cook_book_flutter_plugin/views/common/safe_update.dart';

/// Checkbox控件。
class CheckZone extends StatefulWidget {
  CheckZone(
      {Key? key,
      this.strokeWidth = 2.0,
      this.value = false,
      this.strokeColor = Colors.white,
      this.fillColor = Colors.blue,
      this.radius = 2.0,
      this.onChanged})
      : super(key: key);

  /// 对勾线宽。
  final double strokeWidth;

  /// 对勾颜色。
  final Color strokeColor;

  /// 填充色。
  final Color? fillColor;

  /// 是否选中。
  final bool value;

  /// 是否圆角。
  final double radius;

  /// 选中状态改变监听。
  final ValueChanged<bool>? onChanged;

  @override
  State<StatefulWidget> createState() {
    return _CheckZone();
  }
}

class _CheckZone extends SafeState<CheckZone> {
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return CustomCheckBox(
      strokeWidth: widget.strokeWidth,
      strokeColor: widget.strokeColor,
      fillColor: widget.fillColor,
      value: _isChecked,
      radius: widget.radius,
      onChanged: (bool isChecked) {
        safeUpdate(() {
          _isChecked = isChecked;
        });
        widget.onChanged?.call(isChecked);
      },
    );
  }
}
