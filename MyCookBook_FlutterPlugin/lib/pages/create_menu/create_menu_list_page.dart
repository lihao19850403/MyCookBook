import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_router/flutter_router.dart';
import 'package:my_cook_book_flutter_plugin/models/created_menu_item.dart';
import 'package:my_cook_book_flutter_plugin/utils/bridge.dart';
import 'package:my_cook_book_flutter_plugin/utils/resources.dart';
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

class _CreateMenuListPage extends State<CreateMenuListPage> {
  /// 控制上拉加载/下拉刷新的controller。
  final RefreshController _refreshController = RefreshController();

  /// 屏幕顶部安全区距离。
  final double _screenTopSafeZoneHeightVP =
      MediaQueryData.fromView(PlatformDispatcher.instance.views.first)
          .padding
          .top;

  /// 屏幕底部安全区距离。
  double _screenBottomSafeZoneHeightVP = 0;

  /// 瀑布流显示的列数。
  int _columnCount = 2;

  /// 自创菜谱列表。
  List<CreatedMenuItem> _createdMenuList = <CreatedMenuItem>[];

  @override
  void initState() {
    super.initState();
    Bridge.queryScreenSafeZoneHeightVP()
        .then((Map<String, double>? result) => setState(() {
              if (result != null &&
                  result.containsKey('screenBottomSafeZoneHeightVP')) {
                _screenBottomSafeZoneHeightVP =
                    result['screenBottomSafeZoneHeightVP'] as double;
              }
            }));
    Bridge.queryAllCreatedMenus()
        .then((List<CreatedMenuItem>? result) => setState(() {
              if (result == null) {
                _createdMenuList.clear();
              } else {
                _createdMenuList = result;
              }
            }));
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
                  onTap: () {
                    FlutterRouter().back(context);
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
                          child: Image.asset(
                              Resources_media.ic_create_menu_add_green))),
                  onTap: () {},
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
                      _screenTopSafeZoneHeightVP - // 顶部安全区距离。
                      48 + // 顶部标题栏高度。
                      60, // 底部加载更多视图高度，ClassicFooter目前默认高60。
                  child: _content())
            ])));
  }

  @override
  void dispose() {
    super.dispose();
  }

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
            viewportBuilder: (int preIndex, int nextIndex) {
              print('瀑布流变化：$preIndex → $nextIndex');
            },
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
    List<CreatedMenuItem>? refreshedData = await Bridge.queryAllCreatedMenus();
    setState(() {
      if (refreshedData == null) {
        _createdMenuList.clear();
      } else {
        _createdMenuList = refreshedData;
      }
    });
    _refreshController.refreshCompleted();
  }

  /// 上拉加载更多内容。
  void _onLoadMore() async {
    /// 动作待定。
    _refreshController.loadComplete();
  }

  /// 菜谱item内容。
  Widget _oneMenuItem(BuildContext buildContext, int index) {
    CreatedMenuItem menuItem = _createdMenuList[index];
    bool isLast = index == _createdMenuList.length - 1;
    return Container(
        margin: isLast
            ? EdgeInsets.only(bottom: _screenBottomSafeZoneHeightVP)
            : null,
        child: InkWell(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    color: Resources_color.main_selected_light_color,
                    width: 1.0),
                boxShadow: const [
                  BoxShadow(
                      color: Resources_color.main_bg_gray_color,
                      offset: Offset(2, 2))
                ]),
            child: Text('菜谱${index + 1}：\n$menuItem'),
          ),
          onLongPress: () {
            // 长按删除。
          },
          onTap: () {
            // 单击查看详情。
          },
        ));
  }
}
