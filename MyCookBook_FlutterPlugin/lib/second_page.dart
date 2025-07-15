import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_router/flutter_router.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key, this.params}) : super(key: key);

  final Map<String, dynamic>? params;

  @override
  State<StatefulWidget> createState() {
    return _SecondPageState();
  }
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: const Text('第二个Flutter页面')),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              const Text('第二个Flutter页面获取到的参数', style: TextStyle(fontSize: 16)),
              Text(jsonEncode(widget.params)),
              Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: ElevatedButton(
                      onPressed: () {
                        FlutterRouter()
                            .back(context, params: {'result': '第二个Flutter页面'});
                      },
                      child: const Text('退出此页面',
                          style: TextStyle(
                              fontSize: 16, color: Color(0xFF333333)))))
            ])));
  }
}
