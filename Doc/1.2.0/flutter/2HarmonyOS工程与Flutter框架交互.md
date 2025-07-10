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

#### 【PART 4】Flutter框架跳转至HarmonyOS工程

从Flutter页面跳转至HarmonyOS工程页面，需要用到MethodChannel来进行跳转，具体操作步骤为：

1.  编写HarmonyOS平台特定跳转方法：

代码位置是[MyCookBook_FlutterPlugin/plugins/flutter_router/ohos/src/main/ets/components/plugin/FlutterRouterPlugin.ets](../../../MyCookBook_FlutterPlugin/plugins/flutter_router/ohos/src/main/ets/components/plugin/FlutterRouterPlugin.ets)，这里主要做了三件事：

- 定义一个HarmonyOS端的路由处理handler(`routerPushHandler`)，当有从Flutter页面跳转至HarmonyOS页面的动作时，交由此handler处理。
- 定义一个routerPushHandler的设置方法(`setRouterPushHandler()`)，HarmonyOS平台可以通过此方法手动设置一个routerPushHandler，以便跳转至不同的HarmonyOS原生页面。
- 在`onMethodCall()`方法中定义了一个`go()`方法的处理过程，以后Flutter部分跳转页面都使用这个go方法进行。

2.  在Flutter插件工程中编写go()方法的实现：

- 首先在FlutterRouterPlatform中对go()方法进行了定义。代码位置是[MyCookBook_FlutterPlugin/plugins/flutter_router/lib/flutter_router_platform_interface.dart](../../../MyCookBook_FlutterPlugin/plugins/flutter_router/lib/flutter_router_platform_interface.dart)。
- 然后在MethodChannelFlutterRouter中对go()方法进行了实现。代码位置是[MyCookBook_FlutterPlugin/plugins/flutter_router/lib/flutter_router_method_channel.dart](../../../MyCookBook_FlutterPlugin/plugins/flutter_router/lib/flutter_router_method_channel.dart)。
- 此外在RouterManager中增加了一个方法`isFlutterPage()`，用来判断要跳转的页面是否Flutter页面。代码位置是[MyCookBook_FlutterPlugin/plugins/flutter_router/lib/router_manager.dart](../../../MyCookBook_FlutterPlugin/plugins/flutter_router/lib/router_manager.dart)。
- 最后再FlutterRouter中定义了一个go()方法，供Flutter工程代码调用。这个方法会判断要跳转的目标页面类型。如果目标页面是Flutter页面，则使用Flutter的Navigator跳转；如果目标页面不在Flutter路由表中，那么就尝试跳转入原生页面。代码位置是[MyCookBook_FlutterPlugin/plugins/flutter_router/lib/flutter_router.dart](../../../MyCookBook_FlutterPlugin/plugins/flutter_router/lib/flutter_router.dart)。

3.  编译并引入go()方法：

- 首先给flutter_router添加HarmonyOS平台支持。这需要在其pubspec.yaml中添加如下配置信息：

```text
...
plugin:
    platforms:
    # This plugin project was generated without specifying any
    # platforms with the `--platform` argument. If you see the `some_platform` map below, remove it and
    # then add platforms following the instruction here:
    # https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms
    # -------------------
      some_platform:
        pluginClass: somePluginClass
    # -------------------
      ohos: # 此处添加HarmonyOS平台支持，主要填写pluginClass。
        package: com.example.my_cook_book_flutter_plugin
        pluginClass: FlutterRouterPlugin
...
```

代码位置是[MyCookBook_FlutterPlugin/plugins/flutter_router/pubspec.yaml](../../../MyCookBook_FlutterPlugin/plugins/flutter_router/pubspec.yaml)。

- 接下来编译此插件。进入MyCookBook_FlutterPlugin根目录，执行命令：

```text
hflutter pub get
hflutter build har --release
```

编译完成后会在MyCookBook_FlutterPlugin/build/ohos/har/release中生成flutter.har、flutter_module.har、flutter_router.har。最后新生成的flutter_router.har包含了上述go()方法的实现。

- 最后在HarmonyOS工程中引入此har文件。代码位置是[MyCookBook_HarmonyOS/oh-package.json5](../../../MyCookBook_HarmonyOS/oh-package.json5)。
**注意引用flutter_router.har时指定的key不是以@ohos开头的**。
引用完毕后重编译一下HarmonyOS工程。

4.  HarmonyOS平台配置routerPushHandler：

由于引用了flutter_router.har，因此HarmonyOS工程可以调用里面的方法了。此处在EntryAbility初始化时登记一个页面跳转路由handler：

```text
...
import FlutterRouterPlugin from 'flutter_router';
...
export default class EntryAbility extends UIAbility implements ExclusiveAppComponent<UIAbility> {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    ...
    // 声明平台特定的Flutter页面跳转路由handler。
    FlutterRouterPlugin.setRouterPushHandler(flutterRouterHandler);
  }
}
```

其中flutterRouterHandler定义如下：

```text
import { MethodResult } from '@ohos/flutter_ohos';
import { LHWebBrowser, URL_PARAMS } from '../../pages/common/webbrowser/LHWebBrowser';

/**
 * 鸿蒙平台下的Flutter页面跳转handler。
 * @author li.hao85
 * @param path 路由路径。
 * @param params 路由参数。
 * @param result 跳转结果，用于向Flutter页面返回参数。
 * @returns 处理是否完成。
 */
export const flutterRouterHandler: (path: string, params: Record<string, Object> | undefined, result: MethodResult) => boolean =
  (path, params, result) => {
    if (path === 'LHWebBrowser') {
      let routerParams: Record<string, string | undefined> = {};
      if (params !== undefined) {
        let urlParams: string = params instanceof Map ? params.get(URL_PARAMS) as string : params[URL_PARAMS] as string;
        routerParams[URL_PARAMS] = urlParams;
      }
      LHWebBrowser.go(routerParams);
    }
    return true;
  };

```

这个handler先对Web页的跳转进行了处理。

5.  测试跳转：

测试跳转路径是：Flutter页面打开HarmonyOS原生Web页，加载百度首页。可以编写如下Flutter代码实现：

```text
...
Padding(
  padding: const EdgeInsets.only(top: 4),
  child: ElevatedButton(
    onPressed: () {
      FlutterRouter().go(context, 'LHWebBrowser',
        params: {'url_params': 'https://www.baidu.com'});
      },
      child: const Text('跳转至百度首页',
        style: TextStyle(
          fontSize: 16, color: Color(0xFF333333)))))
...
```

#### 致谢

本文参考了以下资料，在此致谢：

1.  《鸿蒙-flutter-使用FlutterEntry的路由管理和参数传递_上》：[https://blog.csdn.net/huangyuan_xuan/article/details/148582528](https://blog.csdn.net/huangyuan_xuan/article/details/148582528)。
2.  《鸿蒙-flutter-使用FlutterEntry的路由管理和参数传递_中_flutter打开native页面传递参数》[https://blog.csdn.net/huangyuan_xuan/article/details/148606583](https://blog.csdn.net/huangyuan_xuan/article/details/148606583)。