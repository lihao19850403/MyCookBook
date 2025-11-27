# MyCookBook

#### 介绍

本CodeLab基于ArkUI实现了一个菜谱应用，主要展示应用如何适配多种尺寸的屏幕。

此外本项目还进行了如下测试工作：

1.  使用ArkXTest框架进行项目测试，详情可查阅[应用测试](./Doc/1.1.0/测试/应用测试.md)
2.  使用Hypium进行UI测试，测试工程见[https://gitee.com/greatleghair/MyCookBookTest](https://gitee.com/greatleghair/MyCookBookTest)。

#### 软件特点

《香辣菜谱》是一款运行于HarmonyOS NEXT平台的移动端应用，具有新闻查看、菜谱推荐与收藏、美食圈探索等功能，同时应用也为用户提供了个性化设置。

应用的特点如下：

1.  屏幕适配：应用适配普通直板设备、折叠屏(2折叠、3折叠、扩折叠)、Pad屏幕、PC屏幕、TV屏幕(操作方式暂未适配)。应用在折叠屏上运行时，会对设备展开与合盖状态进行响应，并自动调整页面布局。关于屏幕状态响应的实现方法可查阅[动态监听屏幕尺寸及状态改变](https://developer.huawei.com/consumer/cn/blog/topic/03162326904748004)。 此外应用还适配了各种屏幕下的悬浮窗模式、双应用分屏模式。
2.  分页分屏：应用使用Tab组件进行多标签页展现，支持滑动切换页面或点击标签切换页面；应用使用Navigation实现分屏显示功能，并支持动态切换分屏状态。应用中各页面之间的跳转使用NavPathStack实现。关于分屏展示功能的实现方法可查阅[迁移旧项目至Navigation，使用NavPathStack进行页面跳转，并实现分屏显示](https://developer.huawei.com/consumer/cn/blog/topic/03162334632054323)。
3.  列表吸顶：应用对List组件，使用ListItemGroup及sticky来展现小标题吸顶效果。 
4.  网格拖拽：应用对Grid组件设置了用户可长按元素进行拖拽排序的功能。 
5.  瀑布流UI：应用在首页新闻页面使用WaterFlow组件展现瀑布流排版效果，并使用LazyForEach实现懒加载。
6.  资源浏览：应用还使用了开源的图片浏览库，用户可以查看菜谱大图。
7.  网络请求：应用使用axios进行网络请求开发，并对响应数据进行解析。注：本应用使用了免费测试api，不需要搭建服务端。 
8.  事件传递：应用使用emitter进行事件传递、接收与处理。 
9.  持久化：应用使用preferences对需要保存的信息进行持久化。
10. 自定义组件：应用对使用频次高的组件进行了封装，比如标题栏、分割线、Web组件等。
11. 跨平台开发：应用集成了Flutter开发框架，并进行了Flutter与原生平台之间的双向通信。关于如何在鸿蒙平台集成Flutter、如何进行双向通信，可参考如下笔记：[鸿蒙平台集成Flutter框架开发笔记](./Doc/1.2.0/flutter)。此外Flutter页面也适配了各种类型的屏幕、悬浮窗模式、双应用分屏模式。

#### 安装教程

##### 开发环境配置

开发工具下载地址：[https://developer.huawei.com/consumer/cn/download/deveco-studio](https://developer.huawei.com/consumer/cn/download/deveco-studio)。

选择合适的DevEco Studio下载安装即可。

##### 获取代码

执行以下命令将工程代码下载到本地：

```text
git clone https://gitee.com/greatleghair/MyCookBook.git
```

并在DevEco Studio中打开。

应用用到了第三方库，可以使用以下命令安装：

```text
ohpm install @ohos/photoview
ohpm install @ohos/pulltorefresh
```

##### 配置模拟器

在DevEco Studio中创建模拟器(应用适配了除手表外的其余各种设备，可以创建对应模拟器来查看运行效果)。

##### 启动项目

选择刚才配置好的模拟器，点击绿色的播放按钮，即可启动项目。

或使用菜单栏的```Run → Run 'entry'```来启动项目，或使用默认快捷键：```Shift+Command+F11```也可以启动项目。

#### 使用说明

应用在不同尺寸屏幕上的表现可查看：[应用图集](./Doc/1.2.1/图集/应用图集.md)

##### 头条

<img src=./Doc/1.0.0/图集/1普通/01.头条.webp width="33%" />

1.  应用首页默认显示头条Tab页。在头条Tab页中应用向服务端分页请求新闻数据，并采用LazyForEach进行懒加载。
2.  每页默认获取24条新闻，上拉可以加载更多。
3.  如果图片未加载完成，会显示reload图标，点击可以重试加载图片；当图片已加载完毕，点击图片会进入图片浏览页进行单独查看。
4.  点击新闻横幅会进入新闻详情页。新闻详情页的图片也有reload功能，点击加载完毕的图片也可以进入图片浏览页进行单独查看。
5.  新闻详情页最后会显示本条新闻的原文链接，点击后会跳转至内置浏览器进行查看。

##### 菜谱

<img src=./Doc/1.0.0/图集/1普通/04.菜谱.webp width="33%" />

1.  菜谱Tab页每天向服务端请求随机数量的推荐菜谱并展示成列表，在本Tab页中默认展示前3条(折叠屏展开状态下会展示前4条)，点击“查看全部”会列出所有今日推荐的菜谱。
2.  点击菜谱Tab页中的菜谱横幅会进入菜谱详情页，在详情页中会展示菜谱的详细信息，并可以点击右上角的星标来将菜谱加入收藏。
3.  点击菜谱Tab页右上的“查看全部”会进入一个由菜谱详情构成的列表，列表中的每一条菜谱都可以通过点击星标来加入收藏。
4.  菜谱收藏页的“我的收藏”初始内容为空，当用户收藏了菜谱后会按收藏顺序进行展示，用户还可以长按菜谱横幅来进行排序。
5.  点击菜谱详情页中的图片可以查看菜谱大图。

##### 美食圈

<img src=./Doc/1.0.0/图集/1普通/08.美食圈.webp width="33%" />

1.  美食圈采用内嵌Web容器的方式实现。
2.  美食圈内嵌的Web容器重写了onLoadIntercept回调，在这个回调中对请求的url进行了筛选，某些url会在当前Web容器中展示，其余url会单独打开新的内置浏览器来展示。在折叠屏展开时或平板设备上，如果设置了分屏显示模式，就会看到具体的效果。
3.  美食圈Tab页右上角的reload图标用来重新加载当前页面。

##### 我的

<img src=./Doc/1.2.1/图集/1普通/09.我的.webp width="33%" />

1.  “我的”Tab页每天向服务端请求一条养生小秘诀。
2.  “应用首页”用于设置应用启动时首先显示的Tab页，点击图标会在“头条”、“菜谱”、“美食圈”三个选项中进行切换。这项设置在下次启动应用时有效。
3.  “调整字号”用于设置应用全局文字字号，点击图标会在“小”、“中”、“大”、“特大”四个选项中进行切换。这项设置会马上起效，不论在普通显示模式还是分屏显示模式中，都会马上看到效果。
4.  “分屏设置”用于开启或关闭应用的分屏显示模式。这项设置会马上起效，页面会根据此设置动态调整自身的显示模式。
5.  点击“菜谱收藏夹”将自动切换至“菜谱”Tab页，并锚点定位至“我的收藏”区域。
6.  点击“自创菜谱”将进入自创菜谱模块，此模块基于Flutter实现，完成了对自创菜谱的列表查看、详情查看、增加、批量删除、内容修改功能。

##### 数据来源说明

1.  免费测试api的使用：应用的头条新闻、今日推荐菜谱、每日养生小秘诀使用了免费测试api，相关配置可查看[entry/src/main/resources/rawfile/keys.json5](./MyCookBook_HarmonyOS/entry/src/main/resources/rawfile/keys.json5)。这些接口对于同一个账户有每日请求次数限制，因此当访问人数较多时将不会返回有效信息。您可以到对应的网页注册账户申请自己的免费key来使用，只需把新的key写到配置文件中的value字段处即可。
2.  关于模拟数据：为了能够演示应用内容，我准备了一些模拟数据，以便在服务端接口出现异常的时候仍然能展示一些内容。这些模拟数据位于[entry/src/main/resources/rawfile/](./MyCookBook_HarmonyOS/entry/src/main/resources/rawfile)文件夹，您可以根据自己的需求进行修改调试。
注：测试文件是
[home_tab_menu_mock.json5](MyCookBook_HarmonyOS/entry/src/main/resources/rawfile/home_tab_menu_mock.json5)、
[home_tab_mine_create_menu_mock.json5](MyCookBook_HarmonyOS/entry/src/main/resources/rawfile/home_tab_mine_create_menu_mock.json5)、
[home_tab_mine_tips_mock.json5](MyCookBook_HarmonyOS/entry/src/main/resources/rawfile/home_tab_mine_tips_mock.json5)和
[home_tab_top_news_mock.json5](MyCookBook_HarmonyOS/entry/src/main/resources/rawfile/home_tab_top_news_mock.json5)。

#### 相关权限

应用用到了以下权限(1个)：

1.  网络访问权限：ohos.permission.INTERNET。

请确保在测试设备上正确授予权限。

#### 更新日志

| 版本号   | 内容                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|-------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1.0.0 | 初版                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| 1.1.0 | 改进ArkXTest测试代码，去除冗余id属性设置，解耦测试代码与产品代码，并适配折叠屏与Pad屏幕的测试                                                                                                                                                                                                                                                                                                                                                                                                         |
| 1.2.0 | 一、跨平台开发：<br />1.1&emsp;集成Flutter开发框架。<br /><br />二、功能更新：<br />2.1&emsp;屏幕适配：适配三折叠设备。<br />2.2&emsp;异常捕获：增加异常捕获模块。<br />2.3&emsp;实现优化Ⅰ：“上拉加载更多”优化实现效果。<br />2.4&emsp;实现优化Ⅱ：使用配置文件的方式实现文字字号调整功能。<br />2.5&emsp;实现优化Ⅲ：使用更好的方式代替.bind(this)方式。<br />2.6&emsp;实现优化Ⅳ：精简代码，不再存储旧的屏幕宽高数据、不再存储旧的屏幕状态。<br /><br />三、细节调整：<br />3.1&emsp;默认启动页：增加一个默认启动页。<br />3.2&emsp;标题栏优化：标题栏文字避让图标。<br />3.3&emsp;分屏兜底：分屏模式下内容区增加一个兜底页面。<br />3.4&emsp;气泡提示：“我的”页面中使用气泡提示代替Toast提示。 |
| 1.2.1 | Flutter部分增加图片选取功能：可以从图库中选择一张图片作为菜谱大图。                                                                                                                                                                                                                                                                                                                                                                                                                         |
| 1.3.0 | 适配更多类型设备(除手表外)，并适配悬浮窗模式、双应用分屏模式。                                                                                                                                                                                                                                                                                                                                                                                                                              |

#### 致谢

应用开发过程中使用到了以下开源库，在此致谢：

1.  axios：易于使用的网络请求库。
2.  PhotoView：图片浏览库，项目地址：[https://gitee.com/openharmony-sig/PhotoView](https://gitee.com/openharmony-sig/PhotoView)。
3.  PullToRefresh：数据获取组件，支持下拉刷新、上拉加载更多，项目地址：[https://gitee.com/openharmony-sig/PullToRefresh](https://gitee.com/openharmony-sig/PullToRefresh)。
4.  Flutter for HarmonyOS：鸿蒙平台可用的第三方FlutterSDK，项目地址：[https://gitcode.com/openharmony-tpc/flutter_flutter.git](https://gitcode.com/openharmony-tpc/flutter_flutter.git)。
5.  path_provider：支持Flutter组件访问鸿蒙原生文件路径系统，项目地址：[https://gitcode.com/openharmony-tpc/flutter_packages.git](https://gitcode.com/openharmony-tpc/flutter_packages.git)。

应用使用了天聚数行免费api，仅做技术演示，在此致谢。

应用内嵌了香哈网的美食圈栏目，仅做技术演示，在此致谢。