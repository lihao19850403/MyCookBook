import 'package:flutter/material.dart';
import 'package:flutter_router/flutter_router.dart';
import 'package:my_cook_book_flutter_plugin/utils/bridge.dart';
import 'package:my_cook_book_flutter_plugin/utils/common/event_bus.dart';
import 'package:my_cook_book_flutter_plugin/utils/common/global.dart';
import 'package:my_cook_book_flutter_plugin/utils/resources.dart';
import 'package:my_cook_book_flutter_plugin/views/common/safe_update.dart';

class CreateMenuModifyPage extends StatefulWidget {
  const CreateMenuModifyPage({Key? key, this.params}) : super(key: key);

  final Map<String, dynamic>? params;

  @override
  State<StatefulWidget> createState() {
    return _CreateMenuModifyPage();
  }
}

class _CreateMenuModifyPage extends SafeState<CreateMenuModifyPage> {
  /// 内容滚动视图controller。
  ScrollController _contentScrollController = ScrollController();

  /// 窄屏模式。
  bool _normalScreenMode = Global.screenUIType == ScreenUIType.NORMAL ||
      (Global.isSplitScreen && Global.screenUIType == ScreenUIType.FOLD_OPENED);

  /// 菜谱标题。
  String? _menuTitle;

  /// 作者名字。
  String? _author;

  /// 菜谱分类。
  String? _category;

  /// 菜谱特性。
  String? _texing;

  /// 菜谱原料。
  String? _yuanliao;

  /// 菜谱调料。
  String? _tiaoliao;

  /// 菜谱做法。
  String? _zuofa;

  /// 菜谱温馨提示。
  String? _wenxintishi;

  @override
  void initState() {
    super.initState();
    eventBus.on(SCREEN_UI_INFO_CHANGED_EVENT, (Object? arguments) {
      safeUpdate(() {
        _normalScreenMode = Global.screenUIType == ScreenUIType.NORMAL ||
            (Global.isSplitScreen &&
                Global.screenUIType == ScreenUIType.FOLD_OPENED);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Resources_color.main_bg_gray_color,
      appBar: AppBar(
        toolbarHeight: 48,
        centerTitle: true,
        title: TextField(
          decoration: const InputDecoration(
              hintText: Resources_string.modify_page_title_hint,
              hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.normal),
              border: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Resources_color.main_selected_light_color,
                      width: 1)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Resources_color.main_selected_color, width: 1))),
          cursorColor: Resources_color.main_selected_color,
          cursorWidth: 1,
          minLines: 1,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          onChanged: (String value) => _menuTitle = value,
        ),
        leading: Container(
            alignment: Alignment.centerLeft,
            child: InkWell(
                child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(Resources_media.ic_wrong_green))),
                onTap: () => FlutterRouter().back(context))),
        actions: <Widget>[
          Container(
              alignment: Alignment.centerRight,
              child: InkWell(
                child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(Resources_media.ic_right_green))),
                onTap: () {},
              ))
        ],
      ),
      body: SingleChildScrollView(
          controller: _contentScrollController,
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: const EdgeInsets.only(
                    left: 8, right: 8, top: 24, bottom: 24),
                margin: EdgeInsets.only(
                    bottom: Global.screenBottomSafeZoneHeightVP),
                decoration: const BoxDecoration(color: Colors.white),
                child: _normalScreenMode
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _thumbnail(context),
                          _content(context)
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _thumbnail(context),
                          _content(context)
                        ],
                      ),
              ))),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  /* ---------- 缩略图。 ---------- */

  Widget _thumbnail(BuildContext buildContext) {
    return InkWell(
      child: Image(
          width: 224,
          height: 126,
          image: AssetImage(Resources_media.ic_menu_default_bg),
          fit: BoxFit.contain),
      onTap: () {},
    );
  }

  /* ---------- 输入区。 ---------- */

  Widget _content(BuildContext buildContext) {
    return Padding(
        padding: EdgeInsets.only(
            left: _normalScreenMode ? 0 : 8, top: _normalScreenMode ? 8 : 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 作者。
            _inputText(
                buildContext,
                Resources_string.detail_page_author,
                Resources_string.modify_page_author_hint,
                false,
                (String value) => _author = value),
            // 分类。
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _tip(buildContext, Resources_string.detail_page_category),
                      // TODO 分类选择。
                    ])),
            // 特性。
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _inputText(
                    buildContext,
                    Resources_string.detail_page_texing,
                    Resources_string.modify_page_texing_hint,
                    true,
                    (String value) => _texing = value)),
            // 原料。
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _inputText(
                    buildContext,
                    Resources_string.detail_page_yuanliao,
                    Resources_string.modify_page_yuanliao_hint,
                    true,
                    (String value) => _yuanliao = value)),
            // 调料。
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _inputText(
                    buildContext,
                    Resources_string.detail_page_tiaoliao,
                    Resources_string.modify_page_tiaoliao_hint,
                    true,
                    (String value) => _tiaoliao = value)),
            // 做法。
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _inputText(
                    buildContext,
                    Resources_string.detail_page_zuofa,
                    Resources_string.modify_page_zuofa_hint,
                    true,
                    (String value) => _zuofa = value)),
            // 温馨提示。
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _inputText(
                    buildContext,
                    Resources_string.detail_page_wenxintishi,
                    Resources_string.modify_page_wenxintishi_hint,
                    true,
                    (String value) => _wenxintishi = value)),
          ],
        ));
  }

  /// 提示语。
  Widget _tip(BuildContext buildContext, String tipContent) {
    return Container(
        constraints: const BoxConstraints(minHeight: 50),
        alignment: Alignment.center,
        child: Text('$tipContent：',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.normal)));
  }

  /// 构建输入框。
  Widget _inputText(
      BuildContext buildContext,
      String titleContent,
      String tipContent,
      bool isMultiLine,
      ValueChanged<String>? onChangedCallback) {
    return TextField(
      decoration: InputDecoration(
          labelText: '$titleContent：',
          labelStyle: const TextStyle(
              color: Resources_color.main_selected_color, fontSize: 14),
          hintText: tipContent,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: const OutlineInputBorder(
              borderSide: BorderSide(
                  color: Resources_color.main_selected_light_color, width: 1)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                  color: Resources_color.main_selected_color, width: 1))),
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
