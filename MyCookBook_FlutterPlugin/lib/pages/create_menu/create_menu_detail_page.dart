import 'package:flutter/material.dart';
import 'package:flutter_router/flutter_router.dart';
import 'package:my_cook_book_flutter_plugin/models/created_menu_item.dart';
import 'package:my_cook_book_flutter_plugin/pages/create_menu/create_menu_modify_page.dart';
import 'package:my_cook_book_flutter_plugin/views/common/common_stateful_page.dart';
import '../../utils/bridge.dart';
import '../../utils/common/event_bus.dart';
import '../../utils/common/global.dart';
import '../../utils/resources.dart';
import '../../views/common/safe_update.dart';

/// 页面加载模式，有两种：未加载完成、已加载完成。
enum _MODE { IDLE, LOADED }

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

  /// 本页菜谱信息。
  CreatedMenuItem? _menuItem;

  /// 页面加载状况。
  _MODE _mode = _MODE.IDLE;

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
    if (_mode == _MODE.IDLE) {
      _initMenuInfo(context).then((_) => _mode = _MODE.LOADED);
      return Container();
    }
    return Scaffold(
      backgroundColor: Resources_color.main_bg_gray_color,
      appBar: AppBar(
        toolbarHeight: 48,
        centerTitle: true,
        title: Text(
            _menuItem?.cp_name ??
                Resources_string.create_menu_detail_page_title,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
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
                onTap: () =>
                    FlutterRouter.go(context, CreateMenuModifyPage.PAGE_NAME),
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
                          child: _thumbnail(context)),
                      Align(
                        alignment: _normalScreenMode
                            ? Alignment.bottomCenter
                            : Alignment.centerRight,
                        // child: _content(context),
                      )
                    ],
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
          width: _imageFrameWidth,
          height: _imageFrameHeight,
          image: const AssetImage(Resources_media
              .ic_menu_default_bg), // [Flutter TODO] Image Picker.
          fit: BoxFit.contain),
      onTap: () {},
    );
  }

  /* ---------- 内容区。 ---------- */

  /// 初始化本页菜谱信息。
  Future<void> _initMenuInfo(BuildContext context) async {
    Object? paramsObj = ModalRoute.of(context)?.settings.arguments;
    if (paramsObj != null) {
      Map<String, num> params = paramsObj as Map<String, num>;
      num menuID = params['menu_id'] as num;
      CreatedMenuItem? refreshedData = await Bridge.queryOneCreatedMenu(menuID);
      safeUpdate(() => _menuItem = refreshedData);
    }
    return Future.value();
  }
}
