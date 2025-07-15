import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_router/flutter_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, this.params}) : super(key: key);

  final Map<String, dynamic>? params;

  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
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
                        FlutterRouter().go(context, 'second_page');
                      },
                      child: const Text('跳转至第二个Flutter页面',
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
