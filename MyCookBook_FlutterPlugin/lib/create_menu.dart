import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bridge/flutter_bridge.dart';
import 'package:flutter_router/flutter_router.dart';

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
    FlutterBridge().getScreenSafeZoneHeightPx().then((result) =>
        {print('flutter 顶端：${result["top"]}，底端：${result["bottom"]}')});

    return Scaffold(
        appBar: AppBar(centerTitle: true, title: const Text('登录页面')),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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
            ])));
  }
}
