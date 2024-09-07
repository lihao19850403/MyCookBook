import { display, Size, window } from '@kit.ArkUI';
import { GlobalConfig, GLOBAL_CONFIG_KEY_WINDOW,
  GLOBAL_CONFIG_KEY_WINDOW_HEIGHT_PX,
  GLOBAL_CONFIG_KEY_WINDOW_WIDTH_PX } from './GlobalConfig';
import emitter from '@ohos.events.emitter';
import deviceInfo from '@ohos.deviceInfo';

/**
 * 屏幕状态相关工具方法。
 * @author li.hao85
 */

export const SCREEN_UI_CHANGE_EVENT: string = 'SCREEN_UI_CHANGE_EVENT';
export const SCREEN_UI_OLD_TYPE: string = 'SCREEN_UI_OLD_TYPE';
export const SCREEN_UI_NEW_TYPE: string = 'SCREEN_UI_NEW_TYPE';

/** 屏幕类型。 */
export const enum ScreenUIType {
  /** 直板单屏、折叠屏设备已合上、默认状态。 */ NORMAL,
  /** 折叠屏设备已打开状态。 */ FOLD_OPENED,
  /** 平板类型设备屏幕。 */ PAD
}

/**
 * 监听屏幕状态的改变。
 */
export function observeScreenUIChange() {
  let mainWindow: window.Window = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window;
  mainWindow.on('windowSizeChange', (windowSize: Size) => screenUIChangeAdapter(windowSize));
}

/**
 * 获取当前屏幕类型。
 * @returns 当前屏幕类型。
 */
export function getScreenUIType(): ScreenUIType {
  let deviceType = deviceInfo.deviceType;
  if (deviceType === 'tablet' || deviceType === 'tv' || deviceType === 'car' || deviceType === 'smartVision') {
    return ScreenUIType.PAD;
  }
  if (canIUse('SystemCapability.Window.SessionManager')) {
    if (display.isFoldable() && display.getFoldStatus().toString() !== '2') {
      return ScreenUIType.FOLD_OPENED;
    }
  } else {
    let screenWidthPx = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW_WIDTH_PX) as number;
    let screenHeightPx = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW_HEIGHT_PX) as number;
    let bigEdgeLength = Math.max(screenWidthPx, screenHeightPx);
    let smallEdgeLength = Math.min(screenWidthPx, screenHeightPx);
    let rate = bigEdgeLength / smallEdgeLength;
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
 * @param windowSize 当前屏幕尺寸数据。
 */
function screenUIChangeAdapter(windowSize: Size) {
  let oldScreenUIType = getScreenUIType();
  GlobalConfig.set(GLOBAL_CONFIG_KEY_WINDOW_WIDTH_PX, windowSize.width);
  GlobalConfig.set(GLOBAL_CONFIG_KEY_WINDOW_HEIGHT_PX, windowSize.height);
  let newScreenUIType = getScreenUIType();
  let dataWrap: emitter.EventData = {};
  dataWrap.data = {
    SCREEN_UI_OLD_TYPE: oldScreenUIType,
    SCREEN_UI_NEW_TYPE: newScreenUIType
  };
  emitter.emit(SCREEN_UI_CHANGE_EVENT, dataWrap);
}