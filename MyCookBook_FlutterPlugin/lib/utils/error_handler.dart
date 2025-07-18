import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:my_cook_book_flutter_plugin/utils/utils.dart';

/// 长文本分段长度限制。
const int _PART_CONTENT_LENGTH_LIMIT = 2000;

void safeRun<R>(R Function() body) {
  var originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    originalOnError?.call(details);
    print(
        'ERROR happened: ${details.exception.toString()}\nStackTrace:\n${details.stack ?? "NONE"}');
  };
  runZoned(body,
      zoneSpecification: const ZoneSpecification(
          handleUncaughtError: _uncaughtExceptionHandler,
          print: _interceptPrint));
}

/// UncaughtExceptionHandler。
void _uncaughtExceptionHandler(Zone self, ZoneDelegate parent, Zone zone,
    Object error, StackTrace stackTrace) {
  String content =
      '$TAG UNCAUGHT EXCEPTION happened: ${error.toString()}\nStackTrace:\n$stackTrace';
  _printContent(parent, zone, content);
}

/// 全局拦截print。
void _interceptPrint(Zone self, ZoneDelegate parent, Zone zone, String line) {
  String content = '$TAG$line';
  _printContent(parent, zone, content);
}

/// 打印长文本的部分内容。
void _printContent(ZoneDelegate parent, Zone zone, String content) {
  if (content.isEmpty) {
    return;
  }
  if (content.length <= _PART_CONTENT_LENGTH_LIMIT) {
    parent.print(zone, content);
  } else {
    List<String> lines = content.split('\n');
    for (String line in lines) {
      parent.print(zone, line.startsWith(TAG) ? line : '$TAG$line');
    }
    parent.print(zone, '$TAG-----[OVER]-----');
  }
}
