import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_router/flutter_router.dart';
import 'package:my_cook_book_flutter_plugin/utils/utils.dart';

class CreateMenu extends StatefulWidget {
  const CreateMenu({Key? key, this.params}) : super(key: key);

  final Map<String, dynamic>? params;

  @override
  State<StatefulWidget> createState() {
    return _CreateMenu();
  }
}

class _CreateMenu extends State<CreateMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 48 - 0.3,
          centerTitle: true,
          title: const Text(Resources_string.create_menu,
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
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Divider(
                color: Resources_color.main_bg_gray_color,
                height: 0.3,
              ),
              /*
              const Text('登录页面获取到的参数', style: TextStyle(fontSize: 16)),
              Text(jsonEncode(widget.params)),
              Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: ElevatedButton(
                      onPressed: () {
                        FlutterRouter().go(context, 'LHWebBrowser',
                            params: {'url_params': 'https://www.baidu.com'});
                      },
                      child: const Text('跳转至百度首页',
                          style: TextStyle(
                              fontSize: 16, color: Color(0xFF333333))))),
              Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: ElevatedButton(
                      onPressed: () {
                        FlutterRouter()
                            .back(context, params: {'result': 'Flutter示例页面'});
                      },
                      child: const Text('退出此页面',
                          style: TextStyle(
                              fontSize: 16, color: Color(0xFF333333)))))
               */
            ]));
  }
}
