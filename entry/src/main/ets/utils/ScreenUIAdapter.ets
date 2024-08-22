import { Size, window } from '@kit.ArkUI';
import { GlobalConfig, GLOBAL_CONFIG_KEY_WINDOW,
  GLOBAL_CONFIG_KEY_WINDOW_HEIGHT_PX,
  GLOBAL_CONFIG_KEY_WINDOW_WIDTH_PX } from './GlobalConfig';
import emitter from '@ohos.events.emitter';

/**
 * 屏幕状态相关工具方法。
 * @author li.hao85
 */

export const SCREEN_UI_CHANGE_EVENT: string = 'SCREEN_UI_CHANGE_EVENT';
export const SCREEN_UI_OLD_TYPE: string = 'SCREEN_UI_OLD_TYPE';
export const SCREEN_UI_NEW_TYPE: string = 'SCREEN_UI_NEW_TYPE';

/** 屏幕类型。 */
export const enum ScreenUIType {
  /** 直板单屏状态。 */ NORMAL,
  /** 折叠屏设备已打开状态。 */ FOLD_OPENED,
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
  let screenWidthPx = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW_WIDTH_PX) as number;
  let screenHeightPx = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW_HEIGHT_PX) as number;
  let bigEdgeLength = Math.max(screenWidthPx, screenHeightPx);
  let smallEdgeLength = Math.min(screenWidthPx, screenHeightPx);
  let rate = bigEdgeLength / smallEdgeLength;
  if (rate > 1 && rate < 1.2) {
    return ScreenUIType.FOLD_OPENED;
  }
  return ScreenUIType.NORMAL;
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