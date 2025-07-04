# my_cook_book_flutter_plugin

A new Flutter module project.

## Getting Started

For help getting started with Flutter development, view the online
[documentation](https://flutter.dev/).

For instructions integrating Flutter modules to your existing applications,
see the [add-to-app documentation](https://flutter.dev/docs/development/add-to-app).

## flutter插件开发日志：

### 一、创建插件

以创建一个路由插件为例，步骤如下：

- 在flutter工程目录下创建plugins文件夹，以后各种插件都放到此文件夹下。
- cd到这个plugins文件夹中，执行命令：

```shell
hflutter create --org com.lihao.cookbook.flutter_router --template=plugin --platforms=ohos,android,ios flutter_router
```

这里创建了一个名为`flutter_router`的路由插件，支持鸿蒙、安卓、苹果平台，并且指定了插件包名是`com.lihao.cookbook.flutter_router`。

