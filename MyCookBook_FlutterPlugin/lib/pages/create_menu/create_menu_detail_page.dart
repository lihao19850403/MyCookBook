import 'package:flutter/material.dart';
import 'package:flutter_router/flutter_router.dart';
import 'package:my_cook_book_flutter_plugin/views/common/common_stateful_page.dart';
import '../../utils/bridge.dart';
import '../../utils/common/event_bus.dart';
import '../../utils/common/global.dart';
import '../../utils/resources.dart';
import '../../views/common/safe_update.dart';

class CreateMenuDetailPage extends CommonStatefulPage {
  static const String PAGE_NAME = 'DetailMenu';

  CreateMenuDetailPage({Key? key, this.params})
      : super(key: key, path: PAGE_NAME);

  final Map<String, dynamic>? params;

  @override
  State<StatefulWidget> createState() {
    return _CreateMenuDetailPage();
  }
}

class _CreateMenuDetailPage extends SafeState<CreateMenuDetailPage> {
  final double _imageFrameWidth = 224;
  final double _imageFrameHeight = 126;

  /// 内容滚动视图controller。
  final ScrollController _contentScrollController = ScrollController();

  /// 窄屏模式。
  bool _normalScreenMode = Global.screenUIType == ScreenUIType.NORMAL ||
      (Global.isSplitScreen && Global.screenUIType == ScreenUIType.FOLD_OPENED);

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
        title: const Text(Resources_string.create_menu_list_page_title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
        leading: Container(
            alignment: Alignment.centerLeft,
            child: InkWell(
                child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Padding(
                        padding: const EdgeInsets.all(12),
                        child:
                            Image.asset(Resources_media.ic_main_back_arrow))),
                onTap: () => FlutterRouter.back(context))),
        actions: <Widget>[
          Container(
              alignment: Alignment.centerRight,
              child: InkWell(
                child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(Resources_media.ic_edit_green))),
                onTap: () => FlutterRouter.go(context, 'ModifyMenu'),
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Positioned(
                          top: _normalScreenMode ? 0 : null,
                          left: _normalScreenMode ? null : 0,
                          child: Image(
                              image:
                                  AssetImage(Resources_media.ic_edit_green))),
                      Align(
                        alignment: _normalScreenMode
                            ? Alignment.bottomCenter
                            : Alignment.centerRight,
                        // child: _content(context), TODO
                      )
                    ],
                  )))),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
