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
          image: AssetImage(Resources_media.ic_create_menu_default_bg),
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
                  const Text('${Resources_string.detail_page_author}：',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal))
                ]),
          ],
        ));
  }
}
