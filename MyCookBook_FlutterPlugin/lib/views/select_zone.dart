import 'package:flutter/material.dart';
import 'package:my_cook_book_flutter_plugin/utils/common/global.dart';
import 'package:my_cook_book_flutter_plugin/utils/resources.dart';
import 'package:my_cook_book_flutter_plugin/views/common/safe_update.dart';

/// 选择区控件。
class SelectZone extends StatefulWidget {
  SelectZone(
      {Key? key,
      this.titleContent,
      this.tipContent,
      required this.contentText,
      this.readOnly = false,
      this.clickEvent})
      : super(key: key);

  /// 前缀文字。
  final String? titleContent;

  /// 提示语。
  final String? tipContent;

  /// 初始化文本内容。
  String? contentText;

  /// 是否只读模式？
  bool readOnly;

  /// 单击回调。
  void Function(TextEditingController)? clickEvent;

  @override
  State<StatefulWidget> createState() {
    return _SelectZone();
  }
}

class _SelectZone extends SafeState<SelectZone> {
  /// 输入框控制器。
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.contentText ?? '';
  }

  @override
  void didUpdateWidget(covariant SelectZone oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.contentText) {
      safeUpdate(() => _controller.text = (widget.contentText ?? ''));
    }
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
          suffixIcon: widget.readOnly
              ? null
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Image(
                              width: 14,
                              height: 14,
                              image: AssetImage(
                                  Resources_media.ic_right_arrow_green),
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
        style: TextStyle(
            fontSize: Global.textSizePlan.detailModifyContentTextSize,
            fontWeight: FontWeight.normal),
        onTap: () {
          if (!widget.readOnly) {
            widget.clickEvent?.call(_controller);
          }
        });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
