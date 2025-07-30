import 'package:flutter/material.dart';

/// 通用弹窗。
class CommonDialog extends Dialog {
  CommonDialog({Key? key, required this.childWidget}) : super(key: key);

  /// 弹窗布局。
  Widget childWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(12),
        child: Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[childWidget],
            )));
  }
}

/// 显示一个自定义弹窗。
///
/// 此弹窗需要上下文参数[context]，且需要自定义弹窗内容[childWidget]。
void showCustomDialog(BuildContext context, Widget childWidget) {
  showDialog(
      context: context,
      builder: (context) {
        return CommonDialog(childWidget: childWidget);
      });
}
