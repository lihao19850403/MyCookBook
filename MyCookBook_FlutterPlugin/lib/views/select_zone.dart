import 'package:flutter/material.dart';
import 'package:my_cook_book_flutter_plugin/utils/resources.dart';

/// 选择区控件。
class SelectZone extends StatelessWidget {
  SelectZone(
      {Key? key,
      this.titleContent,
      this.tipContent,
      required this.contentText,
      this.clickEvent})
      : super(key: key) {
    _controller.text = contentText ?? '';
  }

  /// 前缀文字。
  final String? titleContent;

  /// 提示语。
  final String? tipContent;

  /// 初始化文本内容。
  String? contentText;

  /// 单击回调。
  GestureTapCallback? clickEvent;

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
          suffixIcon: const Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Image(
                        width: 14,
                        height: 14,
                        image: AssetImage(Resources_media.ic_right_arrow_green),
                        fit: BoxFit.contain))
              ]),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                  color: Resources_color.main_selected_light_color, width: 1)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                  color: Resources_color.main_selected_color, width: 1)),
        ),
        cursorColor: Colors.transparent,
        cursorWidth: 0,
        keyboardType: TextInputType.none,
        readOnly: true,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        onTap: clickEvent);
  }
}
