import 'package:flutter/material.dart';
import 'package:flutter_router/flutter_router.dart';
import 'package:my_cook_book_flutter_plugin/models/created_menu_item.dart';
import 'package:my_cook_book_flutter_plugin/utils/bridge.dart';
import 'package:my_cook_book_flutter_plugin/utils/common/event_bus.dart';
import 'package:my_cook_book_flutter_plugin/utils/common/global.dart';
import 'package:my_cook_book_flutter_plugin/utils/resources.dart';
import 'package:my_cook_book_flutter_plugin/views/common/common_stateful_page.dart';
import 'package:my_cook_book_flutter_plugin/views/common/safe_update.dart';
import 'package:my_cook_book_flutter_plugin/views/input_text_zone.dart';
import 'package:my_cook_book_flutter_plugin/views/select_zone.dart';

/// 页面加载模式，有两种：未加载完成、已加载完成。
enum _MODE { IDLE, LOADED }

/// 页面功能，有两种：创建新菜谱、更新已有菜谱。
enum _FEATURE { CREATE, UPDATE }

class CreateMenuModifyPage extends CommonStatefulPage {
  static const String PAGE_NAME = 'ModifyMenu';

  CreateMenuModifyPage({Key? key, this.params})
      : super(key: key, path: PAGE_NAME);

  final Map<String, dynamic>? params;

  @override
  State<StatefulWidget> createState() {
    return _CreateMenuModifyPage();
  }
}

class _CreateMenuModifyPage extends SafeState<CreateMenuModifyPage> {
  final double _imageFrameWidth = 224;
  final double _imageFrameHeight = 126;

  /// 内容滚动视图controller。
  final ScrollController _contentScrollController = ScrollController();

  /// 菜谱ID，在更新已有菜谱模式下有效。
  num? _menuID;

  /// 菜谱标题输入框控制器。
  final TextEditingController _titleController = TextEditingController();

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

  /// 页面加载状况。
  _MODE _mode = _MODE.IDLE;

  /// 页面功能。
  _FEATURE _feature = _FEATURE.CREATE;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_mode == _MODE.IDLE) {
      Object? paramsObj = ModalRoute.of(context)?.settings.arguments;
      if (paramsObj != null) {
        safeUpdate(() {
          Map<String, Object?> params = paramsObj as Map<String, Object?>;
          String mode = params['mode'] as String;
          _feature = mode == 'create' ? _FEATURE.CREATE : _FEATURE.UPDATE;
          if (_feature == _FEATURE.UPDATE) {
            CreatedMenuItem menuItem = params['model'] as CreatedMenuItem;
            _menuID = menuItem.id;
            _menuTitle = menuItem.cp_name;
            _author = menuItem.author;
            _category = menuItem.type_name;
            _texing = menuItem.texing;
            _yuanliao = menuItem.yuanliao;
            _tiaoliao = menuItem.tiaoliao;
            _zuofa = menuItem.zuofa;
            _wenxintishi = menuItem.tishi;
            _titleController.text = _menuTitle ?? '';
          }
          _mode = _MODE.LOADED;
        });
      }
      return Container();
    }
    return Scaffold(
      backgroundColor: Resources_color.main_bg_gray_color,
      appBar: AppBar(
        toolbarHeight: 48,
        centerTitle: true,
        title: TextField(
          controller: _titleController,
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
                        child: Image.asset(Resources_media.ic_right_green))),
                onTap: () {
                  if (_feature == _FEATURE.CREATE) {
                    // 创建新菜单。
                    Bridge.addOneCreatedMenu(
                            menuTitle: _menuTitle,
                            author: _author,
                            category: _category,
                            texing: _texing,
                            yuanliao: _yuanliao,
                            tiaoliao: _tiaoliao,
                            zuofa: _zuofa,
                            wenxintishi: _wenxintishi)
                        .then((bool? result) {
                      if (result == true) {
                        eventBus.emit(REFRESH_CREATED_MENUS_LIST_EVENT);
                        if (context.mounted) {
                          FlutterRouter.back(context);
                        }
                      }
                    });
                  } else {
                    // 更新已有菜单。
                    Bridge.updateOneCreatedMenu(
                            menuID: _menuID,
                            menuTitle: _menuTitle,
                            author: _author,
                            category: _category,
                            texing: _texing,
                            yuanliao: _yuanliao,
                            tiaoliao: _tiaoliao,
                            zuofa: _zuofa,
                            wenxintishi: _wenxintishi)
                        .then((bool? result) {
                      if (result == true) {
                        Map<String, num?> params = {'menu_id': _menuID};
                        eventBus.emit(REFRESH_CREATED_MENUS_ITEM_EVENT, params);
                        if (context.mounted) {
                          FlutterRouter.back(context);
                        }
                      }
                    });
                  }
                },
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
                          top: normalScreenMode ? 0 : null,
                          left: normalScreenMode ? null : 0,
                          child: _thumbnail(context)),
                      Align(
                        alignment: normalScreenMode
                            ? Alignment.bottomCenter
                            : Alignment.centerRight,
                        child: _content(context),
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

  /* ---------- 输入区。 ---------- */

  Widget _content(BuildContext buildContext) {
    return Padding(
        padding: EdgeInsets.only(
            left: normalScreenMode ? 0 : 8 + _imageFrameWidth,
            top: normalScreenMode ? 8 + _imageFrameHeight : 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 作者。
            InputTextZone(
                titleContent: Resources_string.detail_page_author,
                tipContent: Resources_string.modify_page_author_hint,
                contentText: _author,
                isMultiLine: false,
                onChangedCallback: (String value) => _author = value),
            // 分类。
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SelectZone(
                    titleContent: Resources_string.detail_page_category,
                    tipContent: Resources_string.modify_page_category_hint,
                    contentText: _category,
                    clickEvent: (TextEditingController controller) {
                      Bridge.selectCategory(_category)
                          .then((String? newCategory) {
                        if (newCategory != null && newCategory.isNotEmpty) {
                          _category = newCategory;
                          controller.text = newCategory;
                        }
                      });
                    })),
            // 特性。
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InputTextZone(
                    titleContent: Resources_string.detail_page_texing,
                    tipContent: Resources_string.modify_page_texing_hint,
                    contentText: _texing,
                    isMultiLine: true,
                    onChangedCallback: (String value) => _texing = value)),
            // 原料。
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InputTextZone(
                    titleContent: Resources_string.detail_page_yuanliao,
                    tipContent: Resources_string.modify_page_yuanliao_hint,
                    contentText: _yuanliao,
                    isMultiLine: true,
                    onChangedCallback: (String value) => _yuanliao = value)),
            // 调料。
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InputTextZone(
                    titleContent: Resources_string.detail_page_tiaoliao,
                    tipContent: Resources_string.modify_page_tiaoliao_hint,
                    contentText: _tiaoliao,
                    isMultiLine: true,
                    onChangedCallback: (String value) => _tiaoliao = value)),
            // 做法。
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InputTextZone(
                    titleContent: Resources_string.detail_page_zuofa,
                    tipContent: Resources_string.modify_page_zuofa_hint,
                    contentText: _zuofa,
                    isMultiLine: true,
                    onChangedCallback: (String value) => _zuofa = value)),
            // 温馨提示。
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InputTextZone(
                    titleContent: Resources_string.detail_page_wenxintishi,
                    tipContent: Resources_string.modify_page_wenxintishi_hint,
                    contentText: _wenxintishi,
                    isMultiLine: true,
                    onChangedCallback: (String value) => _wenxintishi = value))
          ],
        ));
  }
}
