import 'package:flutter/material.dart';
import 'package:my_cook_book_flutter_plugin/utils/resources.dart';

/// 构建输入框。
class InputTextZone extends StatelessWidget {
  InputTextZone(
      {Key? key,
      this.titleContent,
      this.tipContent,
      required this.contentText,
      this.isMultiLine = false,
      this.onChangedCallback})
      : super(key: key) {
    _controller.text = contentText ?? '';
  }

  /// 前缀文字。
  final String? titleContent;

  /// 提示语。
  final String? tipContent;

  /// 初始化文本内容。
  String? contentText;

  /// 是否多行输入。
  bool isMultiLine;

  /// 文字内容改变回调。
  ValueChanged<String>? onChangedCallback;

  /// 输入框控制器。
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        prefixIcon: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text('$titleContent：',
                  style: const TextStyle(
                      color: Resources_color.main_selected_color,
                      fontSize: 14)))
        ]),
        hintText: tipContent,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
                color: Resources_color.main_selected_light_color, width: 1)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
                color: Resources_color.main_selected_color, width: 1)),
      ),
      cursorColor: Resources_color.main_selected_color,
      cursorWidth: 1,
      minLines: 1,
      maxLines: isMultiLine ? null : 1,
      keyboardType: isMultiLine ? TextInputType.multiline : null,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
      onChanged: onChangedCallback,
    );
  }
}
