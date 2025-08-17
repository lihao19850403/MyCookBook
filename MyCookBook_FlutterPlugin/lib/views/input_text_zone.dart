import 'package:flutter/material.dart';
import 'package:my_cook_book_flutter_plugin/utils/common/global.dart';
import 'package:my_cook_book_flutter_plugin/utils/resources.dart';
import 'package:my_cook_book_flutter_plugin/views/common/safe_update.dart';

/// 构建输入框。
class InputTextZone extends StatefulWidget {
  InputTextZone(
      {Key? key,
      this.titleContent,
      this.tipContent,
      required this.contentText,
      this.isMultiLine = false,
      this.readOnly = false,
      this.onChangedCallback})
      : super(key: key);

  /// 前缀文字。
  final String? titleContent;

  /// 提示语。
  final String? tipContent;

  /// 初始化文本内容。
  String? contentText;

  /// 是否多行输入。
  bool isMultiLine;

  /// 是否只读模式？
  bool readOnly;

  /// 文字内容改变回调。
  ValueChanged<String>? onChangedCallback;

  @override
  State<StatefulWidget> createState() {
    return _InputTextZone();
  }
}

class _InputTextZone extends SafeState<InputTextZone> {
  /// 输入框控制器。
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.contentText ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        prefixIcon: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text('${widget.titleContent}：',
                  style: TextStyle(
                      color: Resources_color.main_selected_color,
                      fontSize:
                          Global.textSizePlan.detailModifyContentTextSize)))
        ]),
        hintText: widget.tipContent,
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
      maxLines: widget.isMultiLine ? null : 1,
      keyboardType: widget.isMultiLine ? TextInputType.multiline : null,
      style: TextStyle(
          fontSize: Global.textSizePlan.detailModifyContentTextSize,
          fontWeight: FontWeight.normal),
      readOnly: widget.readOnly,
      onChanged: widget.onChangedCallback,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
