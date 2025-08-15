import 'package:flutter/material.dart';
import 'package:flutter_router/flutter_router.dart';
import 'package:my_cook_book_flutter_plugin/models/created_menu_item.dart';
import 'package:my_cook_book_flutter_plugin/pages/create_menu/create_menu_detail_page.dart';
import 'package:my_cook_book_flutter_plugin/utils/bridge.dart';
import 'package:my_cook_book_flutter_plugin/utils/common/event_bus.dart';
import 'package:my_cook_book_flutter_plugin/utils/common/global.dart';
import 'package:my_cook_book_flutter_plugin/utils/resources.dart';
import 'package:my_cook_book_flutter_plugin/views/check_zone.dart';
import 'package:my_cook_book_flutter_plugin/views/common/safe_update.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../views/common/common_stateful_page.dart';
import 'create_menu_modify_page.dart';

/// 页面展示模式，有两种：列表浏览模式、删除菜谱模式。
enum _MODE { BROWSE, DELETE }

class CreateMenuListPage extends CommonStatefulPage {
  static const String PAGE_NAME = 'CreateMenu';

  CreateMenuListPage({Key? key, this.params})
      : super(key: key, path: PAGE_NAME);

  final Map<String, dynamic>? params;

  @override
  State<StatefulWidget> createState() {
    return _CreateMenuListPage();
  }
}

class _CreateMenuListPage extends SafeState<CreateMenuListPage> {
  /// 控制上拉加载/下拉刷新的controller。
  final RefreshController _refreshController = RefreshController();

  /// 瀑布流显示的列数。
  int _columnCount = 4;

  /// 自创菜谱列表。
  final List<CreatedMenuItem> _createdMenuList = <CreatedMenuItem>[];

  /// 页面展示模式，默认是列表浏览模式。
  _MODE _mode = _MODE.BROWSE;

  /// 待删除菜谱的ID列表。
  final List<num> _markToDeletedIDs = <num>[];

  EventCallback? _onRefreshCreatedMenusListEvent;
  EventCallback? _onRefreshCreatedMenusItemEvent;

  @override
  void onScreenUIInfoChanged(ScreenUIType newScreenUIType, bool isSplitScreen) {
    super.onScreenUIInfoChanged(newScreenUIType, isSplitScreen);
    safeUpdate(() => _columnCount = normalScreenMode ? 2 : 4);
  }

  @override
  void initState() {
    super.initState();
    _columnCount = normalScreenMode ? 2 : 4;
    widget.whenBackPressed = () {
      if (_mode == _MODE.BROWSE) {
        return true;
      }
      safeUpdate(() => _mode = _MODE.BROWSE);
      return false;
    };
    _onRefreshCreatedMenusListEvent =
        (Object? arguments) => _initCreatedMenusList();
    _onRefreshCreatedMenusItemEvent =
        (Object? arguments) => _initCreatedMenusList();
    eventBus.on(
        REFRESH_CREATED_MENUS_LIST_EVENT, _onRefreshCreatedMenusListEvent!);
    eventBus.on(
        REFRESH_CREATED_MENUS_ITEM_EVENT, _onRefreshCreatedMenusItemEvent!);
    _initCreatedMenusList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Resources_color.main_bg_gray_color,
        appBar: AppBar(
          toolbarHeight: 48,
          centerTitle: true,
          title: _mode == _MODE.BROWSE
              ? const Text(Resources_string.create_menu_list_page_title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal))
              : (_markToDeletedIDs.isNotEmpty
                  ? Text(
                      '${Resources_string.create_menu_list_page_delete_title}(${_markToDeletedIDs.length})',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.normal))
                  : const Text(
                      Resources_string.create_menu_list_page_delete_title,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.normal))),
          leading: Container(
              alignment: Alignment.centerLeft,
              child: InkWell(
                  child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(_mode == _MODE.BROWSE
                              ? Resources_media.ic_main_back_arrow
                              : Resources_media.ic_wrong_green))),
                  onTap: () {
                    if (_mode == _MODE.BROWSE) {
                      FlutterRouter.back(context);
                    } else {
                      safeUpdate(() => _mode = _MODE.BROWSE);
                    }
                  })),
          actions: <Widget>[
            Container(
                alignment: Alignment.centerRight,
                child: InkWell(
                  child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(_mode == _MODE.BROWSE
                              ? Resources_media.ic_add_green
                              : Resources_media.ic_right_green))),
                  onTap: () {
                    if (_mode == _MODE.BROWSE) {
                      Map<String, String> params = {'mode': 'create'};
                      FlutterRouter.go(context, CreateMenuModifyPage.PAGE_NAME,
                          params: params);
                    } else {
                      Bridge.removeCreatedMenus(_markToDeletedIDs)
                          .then((bool? result) {
                        if (result == true) {
                          safeUpdate(() {
                            _mode = _MODE.BROWSE;
                            _markToDeletedIDs.clear();
                          });
                          eventBus.emit(REFRESH_CREATED_MENUS_LIST_EVENT);
                        }
                      });
                    }
                  },
                ))
          ],
        ),
        body: SafeArea(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - // 屏幕高。
                      Global.screenTopSafeZoneHeightVP - // 顶部安全区距离。
                      48 + // 顶部标题栏高度。
                      60, // 底部加载更多视图高度，ClassicFooter目前默认高60。
                  child: _content())
            ])));
  }

  @override
  void dispose() {
    super.dispose();
    eventBus.off(
        REFRESH_CREATED_MENUS_LIST_EVENT, _onRefreshCreatedMenusListEvent!);
    eventBus.off(
        REFRESH_CREATED_MENUS_ITEM_EVENT, _onRefreshCreatedMenusItemEvent!);
  }

  /// 初始化自创菜谱列表。
  Future<void> _initCreatedMenusList() async {
    List<CreatedMenuItem>? refreshedData = await Bridge.queryAllCreatedMenus();
    safeUpdate(() {
      _createdMenuList.clear();
      if (refreshedData != null) {
        _createdMenuList.addAll(refreshedData);
      }
    });
    return Future.value();
  }

  /* ---------- 页面主体内容。 ---------- */

  /// 页面主体内容，使用瀑布流+下拉刷新组件实现。
  Widget _content() {
    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: true,
      header: const ClassicHeader(),
      footer: const ClassicFooter(),
      onRefresh: _onRefresh,
      onLoading: _onLoadMore,
      child: WaterfallFlow.builder(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columnCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            lastChildLayoutTypeBuilder: (int curCheckedIndex) {
              return curCheckedIndex == _createdMenuList.length
                  ? LastChildLayoutType.fullCrossAxisExtent
                  : LastChildLayoutType.none;
            },
          ),
          itemCount: _createdMenuList.length,
          itemBuilder: (BuildContext buildContext, int index) =>
              _oneMenuItem(buildContext, index)),
    );
  }

  /// 下拉刷新整个页面。
  void _onRefresh() async {
    await _initCreatedMenusList();
    _refreshController.refreshCompleted();
    print('下拉刷新-完成');
  }

  /// 上拉加载更多内容。
  void _onLoadMore() async {
    /// 动作待定，先延迟1秒。
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.loadComplete();
    print('上拉加载更多-完成');
  }

  /* ---------- 菜谱item内容。 ---------- */

  /// 菜谱item内容。
  Widget _oneMenuItem(BuildContext buildContext, int index) {
    CreatedMenuItem menuItem = _createdMenuList[index];
    bool isLast = index == _createdMenuList.length - 1;
    List<Widget> children = <Widget>[
      InkWell(
        child: Container(
            padding: const EdgeInsets.all(4),
            alignment: Alignment.topCenter,
            child: Column(children: <Widget>[
              const Image(
                  image: AssetImage(Resources_media.ic_menu_default_bg),
                  fit: BoxFit.contain), // [Flutter TODO] Image Picker.
              Container(
                  alignment: Alignment.topLeft,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _textContent(menuItem, index)))
            ])),
        onLongPress: () {
          // 长按删除。
          if (_mode != _MODE.DELETE) {
            safeUpdate(() {
              _markToDeletedIDs.clear();
              _mode = _MODE.DELETE;
            });
          }
        },
        onTap: () {
          // 单击查看详情。
          if (menuItem.id != null) {
            Map<String, num> params = {'menu_id': menuItem.id!};
            FlutterRouter.go(buildContext, CreateMenuDetailPage.PAGE_NAME,
                params: params);
          }
        },
      )
    ];
    if (_mode == _MODE.BROWSE) {
      if (children.length > 1) {
        children.removeLast();
      }
    } else {
      if (children.length == 1) {
        children.add(SizedBox(
            width: 24,
            height: 24,
            child: CheckZone(
              strokeWidth: 2.0,
              strokeColor: Resources_color.main_selected_color,
              fillColor: Colors.white,
              value: false,
              radius: 4.0,
              onChanged: (bool isChecked) {
                safeUpdate(() {
                  if (isChecked) {
                    if (menuItem.id != null) {
                      _markToDeletedIDs.add(menuItem.id!);
                    }
                  } else {
                    _markToDeletedIDs.remove(menuItem.id);
                  }
                });
              },
            )));
      }
    }
    return Container(
        margin: isLast
            ? EdgeInsets.only(bottom: Global.screenBottomSafeZoneHeightVP)
            : null,
        child: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(4))),
          child: Stack(alignment: Alignment.topRight, children: children),
        ));
  }

  /// 菜谱item的文字部分内容。
  List<Widget> _textContent(CreatedMenuItem menuItem, int index) {
    List<Widget> children = <Widget>[];
    if (menuItem.cp_name != null && menuItem.cp_name!.isNotEmpty) {
      children.add(Text('${index + 1}. ${menuItem.cp_name}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)));
    }
    if (menuItem.type_name != null && menuItem.type_name!.isNotEmpty) {
      children.add(Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
                color: Resources_color.menu_type_name_bg_color,
                borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Text('${menuItem.type_name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Resources_color.menu_type_name_text_color)),
          )));
    }
    if (menuItem.texing != null && menuItem.texing!.isNotEmpty) {
      children.add(Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
                color: Resources_color.menu_feature_bg_color,
                borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Text('${menuItem.texing}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Resources_color.menu_feature_text_color)),
          )));
    }
    if (menuItem.author != null &&
        menuItem.author!.isNotEmpty &&
        menuItem.createdTime != null &&
        menuItem.createdTime!.isNotEmpty) {
      children.add(Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('${menuItem.author} 创作于 ${menuItem.createdTime}',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Resources_color.main_unselected_color))));
    }
    return children;
  }
}
