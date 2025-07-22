import 'package:flutter/material.dart';
import 'package:flutter_router/flutter_router.dart';
import 'package:my_cook_book_flutter_plugin/utils/resources.dart';

class CreateMenuListPage extends StatefulWidget {
  const CreateMenuListPage({Key? key, this.params}) : super(key: key);

  final Map<String, dynamic>? params;

  @override
  State<StatefulWidget> createState() {
    return _CreateMenuListPage();
  }
}

class _CreateMenuListPage extends State<CreateMenuListPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 48 - 0.3,
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
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                  height: 0.3,
                  child: Container(
                      decoration: const BoxDecoration(
                          color: Resources_color.main_bg_gray_color))),
            ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
