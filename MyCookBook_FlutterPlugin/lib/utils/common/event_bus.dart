import 'package:my_cook_book_flutter_plugin/utils/common/global.dart';

typedef EventCallback = void Function(dynamic arguments);

/// 自定义简单的事件总线。
class EventBus {
  /* ---------- 单例模式。 ---------- */
  // 私有构造函数。
  EventBus._internal();

  // 保存单例。
  static final EventBus _singleton = EventBus._internal();

  // 工厂模式创建单例。
  factory EventBus() => _singleton;

  /* ---------- 自定义事件总线各方法。 ---------- */
  final _eMap = <Object, List<EventCallback>?>{};

  /// 监听事件[eventName]，当名为[eventName]的事件发生时，执行[f]回调。
  void on(String eventName, EventCallback f) {
    _eMap[eventName] ??= <EventCallback>[];
    _eMap[eventName]!.add(f);
  }

  /// 取消对事件[eventName]的监听。
  ///
  /// 注：一个事件可能对应多个回调，当提供回调对象[f]的时候，仅取消此回调；如果不提供回调对象[f]，则取消事件[eventName]对应的所有回调监听。
  void off(String eventName, [EventCallback? f]) {
    var list = _eMap[eventName];
    if (list == null) {
      return;
    }
    if (f == null) {
      _eMap.remove(eventName);
    } else {
      list.remove(f);
    }
  }

  /// 发射事件[eventName]，并提供对应参数[arguments]。
  void emit(String eventName, [arguments]) {
    var list = _eMap[eventName];
    if (list == null) {
      return;
    }
    var iterator = list.iterator;
    while (iterator.moveNext()) {
      try {
        iterator.current(arguments);
      } catch (error) {
        if (Global.debug) {
          print('执行eventBus发送的事件$eventName时出现异常：${error.toString()}。');
        }
      }
    }
  }
}

/// 生成一个事件总线对象，可直接使用。
var eventBus = EventBus();
