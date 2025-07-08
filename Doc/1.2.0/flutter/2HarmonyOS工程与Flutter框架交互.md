# HarmonyOS工程与Flutter框架交互

#### 概述

在上一篇文章[《HarmonyOS工程集成Flutter的过程》](1HarmonyOS工程集成Flutter的过程.md)中，我为已有的HarmonyOS工程添加了Flutter开发框架。添加完毕后，HarmonyOS工程可以跳转至一个容器页（FlutterIndexPage），在这个容器页中通过加载FlutterPage控件来展示Flutter内容。

本文在此基础上，以创建一个路由插件的方式，进一步讨论HarmonyOS工程与Flutter代码的交互流程。

#### 【PART 1】准备插件开发环境

##### 一、创建插件工程

以创建一个路由插件为例，步骤如下：

- 在Flutter工程目录（MyCookBook_FlutterPlugin）下创建plugins文件夹，以后各种插件都放到此文件夹下。
- cd到这个plugins文件夹中，执行命令：

```text
hflutter create --org com.lihao.cookbook.flutter_router --template=plugin --platforms=ohos,android,ios flutter_router
```

注：此处依然是使用定制版Flutter SDK中的`hflutter`来操作。

这里创建了一个名为`flutter_router`的路由插件，支持鸿蒙、安卓、苹果平台，并且指定了插件包名是`com.lihao.cookbook.flutter_router`。

由此可见如果要支持多个平台，在命令的`--platforms`参数中以逗号分割指定即可。

##### 二、补充插件支持的平台

上一节指定了插件支持的平台是鸿蒙、安卓、苹果三个，当然也可以仅指定一个平台，或者先不指定任何平台：

```text
hflutter create --org com.lihao.cookbook.flutter_router --template=plugin flutter_router
```

如果不指定任何平台，那么会收到系统的提示：

```text
Creating project flutter_router...
Resolving dependencies in `flutter_router`... (2.0s)
Downloading packages... 
Got dependencies in `flutter_router`.
Resolving dependencies in `flutter_router/example`... 
Downloading packages... 
Got dependencies in `flutter_router/example`.
Wrote 26 files.

All done!

Your plugin code is in flutter_router/lib/flutter_router.dart.

Your example app code is in flutter_router/example/lib/main.dart.


You've created a plugin project that doesn't yet support any platforms.


To add platforms, run `flutter create -t plugin --platforms <platforms> .` under flutter_router.
For more information, see https://flutter.dev/go/plugin-platforms.
```

接下来可以补充对HarmonyOS平台的支持（仍然在plugins文件夹中执行命令）：

```text
hflutter create -t plugin --platforms=ohos flutter_router 
```

##### 三、删除插件支持的平台

如果想删除对某个平台的支持，到对应插件文件夹中，删除平台文件夹即可。此外example文件夹中对应平台的示例文件夹也需要被删除。

##### 四、集成插件

插件创建完毕后记得在MyCookBook_FlutterPlugin工程的pubspec.yaml中添加引用：

```text
...
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.6

  flutter_router: 
    path: plugins/flutter_router
...
```

#### 【PART 2】开发Flutter路由插件

1.  在刚创建的flutter_router插件工程中，可以创建一个路由管理器，用来记录路由路径、参数与Flutter页面的对应关系。示例代码见[MyCookBook_FlutterPlugin/plugins/flutter_router/lib/router_manager.dart](../../../MyCookBook_FlutterPlugin/plugins/flutter_router/lib/router_manager.dart)。

2.  增加一个Flutter测试页面，用来展示接收到的参数：

```text
import 'dart:convert';

import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, this.params}) : super(key: key);

  final Map<String, dynamic>? params; // 前一页传递过来的参数。

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
              Text(jsonEncode(widget.params))
            ])));
  }
}
```

3.  对Flutter工程根目录lib文件夹下的main.dart进行修改，使之能够接收HarmonyOS工程传递过来的路由路径、参数，并跳转至上一小节的测试页面：

```text
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_router/router_manager.dart';
import 'package:my_cook_book_flutter_plugin/login_page.dart';

void main() {
  _initRouters();
  var pathInfo = PlatformDispatcher.instance.defaultRouteName; // 从具体平台处接收传递过来的参数。
  runApp(MyApp(pathInfo: pathInfo));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.pathInfo}) : super(key: key);
  final String pathInfo;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RouterManager.instance.getRouterWidget(pathInfo),
    );
  }
}

void _initRouters() {
  RouterManager.instance
      .addRouter('login_page', (params) => LoginPage(params: params));
}
```

4.  至此一个Flutter路由插件就创建好了，使用`hflutter build har --release`命令编译一下。

#### 【PART 3】HarmonyOS工程跳转至Flutter框架

1.  对HarmonyOS工程中用来展示Flutter内容的容器页面FlutterIndexPage进行修改：

- 创建FlutterWrapEntry时，传递页面参数：

```text
...
.onReady((context: NavDestinationContext) => {
  let params: Record<string, Object> = RouterUtils.navGetParams(context) as Record<string, Object>;
  this.flutterEntry = new FlutterWrapEntry(this.context, params); // 新增第二个参数，用来向Flutter页面传递信息。
  this.flutterEntry.aboutToAppear();
  this.flutterView = this.flutterEntry.getFlutterView();
})
...
```

- 控制路由跳转的go方法中对路由参数进行构造：

```text
...
export namespace FlutterIndexPage {
  export function go(pathInfo: FlutterPathInfo) {
    let path: string = pathInfo.path;
    let params: Record<string, Object> = {};
    params['ScreenTopSafeZoneHeightPx'] = getScreenTopSafeZoneHeightPx();
    params['ScreenBottomSafeZoneHeightPx'] = getScreenBottomSafeZoneHeightPx();
    if (pathInfo.params !== undefined) {
      Object.keys(pathInfo.params).forEach((key: string) => {
        let value: Object | undefined = pathInfo.params?.[key];
        if (value !== undefined) {
          params[key] = value;
        }
      })
    }
    let routerParams: Record<string, Object> = {};
    // 使用此特定key来向Flutter页面传参。
    routerParams[FlutterAbilityLaunchConfigs.EXTRA_INITIAL_ROUTE] = `${path}?${JSON.stringify(params)}`;
    RouterUtils.navPushPath('FlutterIndexPage', routerParams);
  }
}
...
```

完整的FlutterIndexPage见[MyCookBook_HarmonyOS/entry/src/main/ets/flutter/pages/FlutterIndexPage.ets](../../../MyCookBook_HarmonyOS/entry/src/main/ets/flutter/pages/FlutterIndexPage.ets)。

2.  携带参数跳转至FlutterIndexPage页面即可：

```text
.onClick((event: ClickEvent) => {
  FlutterIndexPage.go({
    path: 'login_page', // 此路径名字要提前在Flutter侧中注册好。
    params: {
      'name': '李浩',
      'year': '1985-4-3'
    }
  });
})
```

#### 致谢

本文参考了以下资料，在此致谢：

1.  《鸿蒙-flutter-使用FlutterEntry的路由管理和参数传递_上》：[https://blog.csdn.net/huangyuan_xuan/article/details/148582528](https://blog.csdn.net/huangyuan_xuan/article/details/148582528)。