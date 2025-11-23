import { display, window } from '@kit.ArkUI';
import { GlobalConfig, GLOBAL_CONFIG_KEY_WINDOW } from './GlobalConfig';
import deviceInfo from '@ohos.deviceInfo';

/**
 * 屏幕状态相关工具方法。
 * @author li.hao85
 */

/** 屏幕类型。 */
export const enum ScreenUIType {
  /** 直板单屏、折叠屏设备已合上、默认状态。 */ NORMAL = 0,
  /** 折叠屏设备已打开状态。 */ FOLD_OPENED = 1,
  /** 平板类型设备屏幕。 */ PAD = 2
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