/// 屏幕状态信息。
class ScreenStatusInfo {
  /// 窗口类型。
  WindowStatusType? windowStatusType;
  /// 窗口宽方向断点类型。
  WidthBreakpoint? windowWidthBreakpoint;
  /// 窗口高方向断点类型。
  HeightBreakpoint? windowHeightBreakpoint;

  @override
  String toString() {
    List<String> infoStrs = <String>[];
    if (windowStatusType != null) infoStrs.add('"windowStatusType": ${windowStatusType?.name}');
    if (windowWidthBreakpoint != null) infoStrs.add('"windowWidthBreakpoint": ${windowWidthBreakpoint?.name}');
    if (windowHeightBreakpoint != null) infoStrs.add('"windowHeightBreakpoint": "${windowHeightBreakpoint?.name}"');
    String infoStr = infoStrs.join(',');
    return '{$infoStr}';
  }

  Map<String, dynamic> toJson() {
    return {
      'windowStatusType': windowStatusType?.name,
      'windowWidthBreakpoint': windowWidthBreakpoint?.name,
      'windowHeightBreakpoint': windowHeightBreakpoint?.name,
    };
  }

  /// 从原始数据中创建一个屏幕状态信息。
  static ScreenStatusInfo fromMap(Map<Object?, Object?> dataMap) {
    ScreenStatusInfo screenStatusInfo = ScreenStatusInfo();
    if (dataMap.containsKey('windowStatusType')) {
      num value = dataMap['windowStatusType'] as num;
      switch (value.toDouble()) {
        case 1: screenStatusInfo.windowStatusType = WindowStatusType.FULL_SCREEN; break;
        case 2: screenStatusInfo.windowStatusType = WindowStatusType.MAXIMIZE; break;
        case 3: screenStatusInfo.windowStatusType = WindowStatusType.MINIMIZE; break;
        case 4: screenStatusInfo.windowStatusType = WindowStatusType.FLOATING; break;
        case 5: screenStatusInfo.windowStatusType = WindowStatusType.SPLIT_SCREEN; break;
        default: screenStatusInfo.windowStatusType = WindowStatusType.UNDEFINED; break;
      }
    }
    if (dataMap.containsKey('windowWidthBreakpoint')) {
      num value = dataMap['windowWidthBreakpoint'] as num;
      switch (value.toDouble()) {
        case 1: screenStatusInfo.windowWidthBreakpoint = WidthBreakpoint.WIDTH_SM; break;
        case 2: screenStatusInfo.windowWidthBreakpoint = WidthBreakpoint.WIDTH_MD; break;
        case 3: screenStatusInfo.windowWidthBreakpoint = WidthBreakpoint.WIDTH_LG; break;
        case 4: screenStatusInfo.windowWidthBreakpoint = WidthBreakpoint.WIDTH_XL; break;
        default: screenStatusInfo.windowWidthBreakpoint = WidthBreakpoint.WIDTH_XS; break;
      }
    }
    if (dataMap.containsKey('windowHeightBreakpoint')) {
      num value = dataMap['windowHeightBreakpoint'] as num;
      switch (value.toDouble()) {
        case 1: screenStatusInfo.windowHeightBreakpoint = HeightBreakpoint.HEIGHT_MD; break;
        case 2: screenStatusInfo.windowHeightBreakpoint = HeightBreakpoint.HEIGHT_LG; break;
        default: screenStatusInfo.windowHeightBreakpoint = HeightBreakpoint.HEIGHT_SM; break;
      }
    }
    return screenStatusInfo;
  }
}

/// 窗口状态类型。
enum WindowStatusType {
  /** 未指明。 */ UNDEFINED,
  /** 全屏状态。 */ FULL_SCREEN,
  /** 窗口最大化状态。 */ MAXIMIZE,
  /** 窗口最小化状态。 */ MINIMIZE,
  /** 悬浮窗口状态。 */ FLOATING,
  /** 分屏状态，两部分APP中可通过系统分屏线调整显示比例。 */ SPLIT_SCREEN
}

/// 宽度断点信息。
enum WidthBreakpoint {
  /** Window width < 320vp type. */ WIDTH_XS,
  /** Window width >= 320vp and < 600vp type. */ WIDTH_SM,
  /** Window width >= 600vp and < 840vp type. */ WIDTH_MD,
  /** Window width >= 840vp and < 1440vp type. */ WIDTH_LG,
  /** Window width >= 1440vp type. */ WIDTH_XL
}

/// 高度断点信息。
enum HeightBreakpoint {
  /** Window aspectRatio < 0.8 type. */ HEIGHT_SM,
  /** Window aspectRatio >= 0.8 and < 1.2 type. */ HEIGHT_MD,
  /** Window aspectRatio >= 1.2 type. */ HEIGHT_LG
}