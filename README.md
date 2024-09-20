# MyCookBook

#### 介绍
本Codelab基于ArkUI实现了一个菜谱应用，主要展示应用如何适配多种尺寸的屏幕。

#### 软件特点
《香辣菜谱》是一款运行于HarmonyOS NEXT平台的移动端应用，具有新闻查看、菜谱推荐与收藏、美食圈探索的功能，同时应用也为用户提供了个性化设置。

应用的主要特点如下：

1.  屏幕适配：应用适配普通直板设备、折叠屏、Pad屏幕。应用在折叠屏上运行时，会对设备展开与合盖状态进行响应，并调整页面布局。 
2.  分页分屏：应用使用Tab组件进行多标签页开发，支持滑动切换页面或点击标签切换；应用使用Navigation实现分屏显示功能，并支持动态切换分屏状态。应用中各页面之间的跳转使用NavPathStack实现。

[应用图集](./Doc/1.0.0/应用图集.md)

应用还有以下特点：

3.  列表吸顶：应用对List组件，使用ListItemGroup及sticky来展现小标题吸顶效果。 
4.  网格拖拽：应用对Grid组件设置了用户可长按元素进行拖拽排序的功能。 
5.  瀑布流UI：应用在首页新闻页面使用WaterFlow组件展现瀑布流排版效果，并使用LazyForEach实现懒加载。
6.  资源浏览：应用还使用了开源的图片浏览库，使用户可以查看菜谱大图。
7.  网络请求：应用使用axios进行网络请求开发，并对响应数据进行解析。注：本应用使用了免费测试api，不需要搭建服务端。 
8.  事件传递：应用内部使用emitter进行事件传递、接收与处理。 
9.  持久化：应用内部使用preferences对需要保存的信息进行持久化。
10. 自定义组件：应用对使用频次高的组件进行了封装，比如标题栏、分割线、Web组件等。

#### 相关权限

应用用到了以下权限(1个)：

1.  网络访问权限："ohos.permission.INTERNET"。

请确保在测试设备上正确授予权限。

#### 安装教程

1.  xxxx
2.  xxxx
3.  xxxx

#### 使用说明

1.  xxxx
2.  xxxx
3.  xxxx

#### 致谢
应用开发过程中使用到了以下开源库，在此致谢：

1.  axios：易于使用的网络请求库。
2.  PhotoView：图片浏览库，项目地址：[https://gitee.com/openharmony-sig/PhotoView](https://gitee.com/openharmony-sig/PhotoView)。
3.  PullToRefresh：数据获取组件，支持下拉刷新、上拉加载更多，项目地址：[https://gitee.com/openharmony-sig/PullToRefresh](https://gitee.com/openharmony-sig/PullToRefresh)。

应用使用了天聚数行免费api，仅做技术演示，在此致谢。

应用内嵌了香哈网的美食圈栏目，仅做技术演示，在此致谢。