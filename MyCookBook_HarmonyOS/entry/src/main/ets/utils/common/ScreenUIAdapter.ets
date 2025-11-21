import { display, Size, window } from '@kit.ArkUI';
import { GlobalConfig, GLOBAL_CONFIG_KEY_WINDOW } from './GlobalConfig';
import emitter from '@ohos.events.emitter';
import deviceInfo from '@ohos.deviceInfo';

/**
 * 屏幕状态相关工具方法。
 * @author li.hao85
 */

export const SCREEN_UI_CHANGE_EVENT: string = 'SCREEN_UI_CHANGE_EVENT';
export const SCREEN_UI_NEW_TYPE: string = 'SCREEN_UI_NEW_TYPE';

export const AVOID_AREA_CHANGE_EVENT: string = 'AVOID_AREA_CHANGE_EVENT';
export const AVOID_AREA_TYPE: string = 'AVOID_AREA_TYPE';
export const AVOID_AREA_INFO: string = 'AVOID_AREA_INFO';

export const WINDOW_STATUS_TYPE_CHANGE_EVENT: string = 'WINDOW_STATUS_TYPE_CHANGE_EVENT';
export const WINDOW_STATUS_TYPE: string = 'WINDOW_STATUS_TYPE';

export const WINDOW_SIZE_CHANGE_EVENT: string = 'WINDOW_SIZE_CHANGE_EVENT';
export const WINDOW_SIZE_INFO: string = 'WINDOW_SIZE_INFO';

/** 屏幕类型。 */
export const enum ScreenUIType {
  /** 直板单屏、折叠屏设备已合上、默认状态。 */ NORMAL = 0,
  /** 折叠屏设备已打开状态。 */ FOLD_OPENED = 1,
  /** 平板类型设备屏幕。 */ PAD = 2
}

/**
 * 监听屏幕状态的改变。
 */
export function observeScreenUIChange() {
  let mainWindow: window.Window = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window;
  mainWindow.on('windowSizeChange', (windowSize: Size) => screenUIChangeAdapter());
}

/**
 * 监听屏幕安全区的改变。
 */
export function observeAvoidAreaChange() {
  let mainWindow: window.Window = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window;
  mainWindow.on("avoidAreaChange", (options: window.AvoidAreaOptions) => avoidAreaChangeAdapter(options));
}

/**
 * 监听屏幕状态类型的改变。
 * 此处屏幕状态类型指的是“全屏”、“分屏”、“自由多窗/悬浮窗”这几种类型。
 */
export function observeWindowStatusTypeChange() {
  let mainWindow: window.Window = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window;
  mainWindow.on("windowStatusChange", (type: window.WindowStatusType) => windowStatusTypeChangeAdapter(type));
}

/**
 * 监听屏幕尺寸的改变。
 */
export function observeWindowSizeChange() {
  let mainWindow: window.Window = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window;
  mainWindow.on("windowRectChange", (options: window.RectChangeOptions) => windowSizeChangeAdapter(options));
}

/**
 * 获取当前屏幕类型。
 * @returns 当前屏幕类型。
 */
export function getScreenUIType(): ScreenUIType {
  let deviceType = deviceInfo.deviceType;
  if (deviceType === 'tablet' || deviceType === 'tv' || deviceType === 'car' || deviceType === 'smartVision' || deviceType === '2in1') {
    return ScreenUIType.PAD;
  }
  let screenWidthPx = getScreenWidthPx();
  let screenHeightPx = getScreenHeightPx();
  let bigEdgeLength = Math.max(screenWidthPx, screenHeightPx);
  let smallEdgeLength = Math.min(screenWidthPx, screenHeightPx);
  let rate = bigEdgeLength / smallEdgeLength;
  if (canIUse('SystemCapability.Window.SessionManager')) {
    if (display.isFoldable() && display.getFoldStatus() !== display.FoldStatus.FOLD_STATUS_FOLDED) {
      if (rate > 1 && rate < 1.2) {
        return ScreenUIType.FOLD_OPENED;
      } else if (screenWidthPx > screenHeightPx) {
        return ScreenUIType.PAD;
      }
    }
  } else {
    if (rate > 1 && rate < 1.2) {
      return ScreenUIType.FOLD_OPENED;
    } else if (screenWidthPx > screenHeightPx) {
      return ScreenUIType.PAD;
    }
  }
  return ScreenUIType.NORMAL;
}

/**
 * 获取屏幕宽，单位是像素。
 * @returns 屏幕像素宽。
 */
export function getScreenWidthPx(): number {
  return display.getDefaultDisplaySync().width;
}

/**
 * 获取屏幕高，单位是像素。
 * @returns 屏幕像素高。
 */
export function getScreenHeightPx(): number {
  return display.getDefaultDisplaySync().height;
}

/**
 * 获取屏幕顶端状态栏安全区域高度。
 * @returns 屏幕顶端状态栏安全区域高度。
 */
export function getScreenTopSafeZoneHeightPx(): number {
  let mainWindow: window.Window = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window;
  let type = window.AvoidAreaType.TYPE_SYSTEM;
  let avoidArea = mainWindow.getWindowAvoidArea(type);
  return avoidArea.topRect.height;
}

/**
 * 获取屏幕底部导航条安全区域高度。
 * @returns 屏幕底部导航条安全区域高度。
 */
export function getScreenBottomSafeZoneHeightPx(): number {
  let mainWindow: window.Window = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window;
  let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
  let avoidArea = mainWindow.getWindowAvoidArea(type);
  return avoidArea.bottomRect.height;
}

/**
 * 响应屏幕尺寸的变化。
 */
function screenUIChangeAdapter() {
  let newScreenUIType = getScreenUIType();
  let dataWrap: emitter.EventData = {};
  dataWrap.data = {
    SCREEN_UI_NEW_TYPE: newScreenUIType
  };
  emitter.emit(SCREEN_UI_CHANGE_EVENT, dataWrap);
}

/**
 * 响应安全区的变化。
 * @param options 新的安全区信息。
 */
function avoidAreaChangeAdapter(options: window.AvoidAreaOptions) {
  let dataWrap: emitter.EventData = {};
  dataWrap.data = {
    AVOID_AREA_TYPE: options.type,
    AVOID_AREA_INFO: options.area
  }
  emitter.emit(AVOID_AREA_CHANGE_EVENT, dataWrap);
}
/**
 * 响应屏幕状态类型的改变。
 * @param type 新的屏幕状态类型。
 */
function windowStatusTypeChangeAdapter(type: window.WindowStatusType) {
  let dataWrap: emitter.EventData = {};
  dataWrap.data = {
    WINDOW_STATUS_TYPE: type
  };
  emitter.emit(WINDOW_STATUS_TYPE_CHANGE_EVENT, dataWrap);
}

/**
 * 响应屏幕尺寸的改变。
 * @param options 新的屏幕尺寸信息。
 */
function windowSizeChangeAdapter(options: window.RectChangeOptions) {
  let dataWrap: emitter.EventData = {};
  dataWrap.data = {
    WINDOW_SIZE_INFO: options
  };
  emitter.emit(WINDOW_SIZE_CHANGE_EVENT, dataWrap);
}
