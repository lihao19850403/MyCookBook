import 'package:flutter/material.dart';
import 'package:my_cook_book_flutter_plugin/views/common/safe_update.dart';

class SelectMenuCategoriesDialogContent extends StatefulWidget {
  const SelectMenuCategoriesDialogContent({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SelectMenuCategoriesDialogContent();
  }
}

class _SelectMenuCategoriesDialogContent
    extends SafeState<SelectMenuCategoriesDialogContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text('测试弹窗');
  }

  @override
  void dispose() {
    super.dispose();
  }
}
