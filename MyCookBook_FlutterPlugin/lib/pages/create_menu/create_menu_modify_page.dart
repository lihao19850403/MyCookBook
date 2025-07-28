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
              border: InputBorder.none),
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
      body: SafeArea(
          child: SingleChildScrollView(
              controller: ScrollController(),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    padding: EdgeInsets.only(
                        left: 8,
                        right: 8,
                        top: 24,
                        bottom: 24 + Global.screenBottomSafeZoneHeightVP),
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
                  )))),
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
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _tip(buildContext, '${Resources_string.detail_page_author}：'),
                  _singleLineInput(
                      buildContext,
                      Resources_string.modify_page_author_hint,
                      (String value) => _author = value)
                ]),
            // 分类。
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _tip(buildContext,
                          '${Resources_string.detail_page_category}：'),
                      // TODO 分类选择。
                    ])),
            // 特性。
            _otherInfoZone(
                buildContext,
                Resources_string.detail_page_texing,
                Resources_string.modify_page_texing_hint,
                (String value) => _texing = value),
            // 原料。
            _otherInfoZone(
                buildContext,
                Resources_string.detail_page_yuanliao,
                Resources_string.modify_page_yuanliao_hint,
                (String value) => _yuanliao = value),
            // 调料。
            _otherInfoZone(
                buildContext,
                Resources_string.detail_page_tiaoliao,
                Resources_string.modify_page_tiaoliao_hint,
                (String value) => _tiaoliao = value),
            // 做法。
            _otherInfoZone(
                buildContext,
                Resources_string.detail_page_zuofa,
                Resources_string.modify_page_zuofa_hint,
                (String value) => _zuofa = value),
            // 温馨提示。
            _otherInfoZone(
                buildContext,
                Resources_string.detail_page_wenxintishi,
                Resources_string.modify_page_wenxintishi_hint,
                (String value) => _wenxintishi = value),
          ],
        ));
  }

  /// 提示语。
  Widget _tip(BuildContext buildContext, String tipContent) {
    return Text(tipContent,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal));
  }

  /// 构造一个单行输入框。
  Widget _singleLineInput(BuildContext buildContext, String tipContent,
      ValueChanged<String>? onChangedCallback) {
    return TextField(
        decoration: InputDecoration(
            hintText: tipContent,
            hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.normal)),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        onChanged: onChangedCallback);
  }

  /// 构造一个多行输入区。
  Widget _multiLinesInputZone(BuildContext buildContext, String tipContent,
      ValueChanged<String>? onChangedCallback) {
    return TextField(
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
            hintText: tipContent,
            hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.normal)),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        onChanged: onChangedCallback);
  }

  /// 作者&分类外的输入条目。
  Widget _otherInfoZone(BuildContext buildContext, String title,
      String tipContent, ValueChanged<String>? onChangedCallback) {
    return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _tip(buildContext, title),
              _multiLinesInputZone(buildContext, tipContent, onChangedCallback)
            ]));
  }
}
