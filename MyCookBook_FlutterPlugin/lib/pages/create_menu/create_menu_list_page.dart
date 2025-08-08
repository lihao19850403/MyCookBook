import 'package:flutter/material.dart';
import 'package:flutter_router/flutter_router.dart';
import 'package:my_cook_book_flutter_plugin/models/created_menu_item.dart';
import 'package:my_cook_book_flutter_plugin/utils/bridge.dart';
import 'package:my_cook_book_flutter_plugin/utils/common/event_bus.dart';
import 'package:my_cook_book_flutter_plugin/utils/common/global.dart';
import 'package:my_cook_book_flutter_plugin/utils/resources.dart';
import 'package:my_cook_book_flutter_plugin/views/common/safe_update.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class CreateMenuListPage extends StatefulWidget {
  const CreateMenuListPage({Key? key, this.params}) : super(key: key);

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
  int _columnCount = Global.screenUIType == ScreenUIType.NORMAL ||
          (Global.isSplitScreen &&
              Global.screenUIType == ScreenUIType.FOLD_OPENED)
      ? 2
      : 4;

  /// 自创菜谱列表。
  final List<CreatedMenuItem> _createdMenuList = <CreatedMenuItem>[];

  @override
  void initState() {
    super.initState();
    eventBus.on(SCREEN_UI_INFO_CHANGED_EVENT, (Object? arguments) {
      safeUpdate(() {
        _columnCount = Global.screenUIType == ScreenUIType.NORMAL ||
                (Global.isSplitScreen &&
                    Global.screenUIType == ScreenUIType.FOLD_OPENED)
            ? 2
            : 4;
      });
    });
    eventBus.on(REFRESH_CREATED_MENUS_LIST_EVENT,
        (Object? arguments) => _initCreatedMenusList());
    _initCreatedMenusList();
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
                          child: Image.asset(Resources_media.ic_add_green))),
                  onTap: () => FlutterRouter().go(context, 'ModifyMenu'),
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
  }

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
    return Container(
        margin: isLast
            ? EdgeInsets.only(bottom: Global.screenBottomSafeZoneHeightVP)
            : null,
        child: InkWell(
          child: Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(4))),
              child: Stack(
                alignment: Alignment.topRight,
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.all(4),
                      alignment: Alignment.topCenter,
                      child: Column(children: <Widget>[
                        const Image(
                            image:
                                AssetImage(Resources_media.ic_menu_default_bg),
                            fit:
                                BoxFit.contain), // [Flutter TODO] Image Picker.
                        Container(
                            alignment: Alignment.topLeft,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _textContent(menuItem, index)))
                      ])),
                ],
              )),
          onLongPress: () {
            // 长按删除。
          },
          onTap: () {
            // 单击查看详情。
          },
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
