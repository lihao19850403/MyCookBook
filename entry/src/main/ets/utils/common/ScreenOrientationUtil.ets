import { window, display } from '@kit.ArkUI';
import { GlobalConfig, GLOBAL_CONFIG_KEY_WINDOW } from './GlobalConfig';

/**
 * 屏幕方向相关工具方法。
 * @author li.hao85
 */

/**
 * 获取屏幕方向。
 * @returns 屏幕方向：横向、横向(反持)、纵向、纵向(反持)。
 */
export function getScreenOrientation(): window.Orientation {
  switch (display.getDefaultDisplaySync().orientation) {
    case display.Orientation.LANDSCAPE:
      return window.Orientation.LANDSCAPE;
    case display.Orientation.PORTRAIT_INVERTED:
      return window.Orientation.PORTRAIT_INVERTED;
    case display.Orientation.LANDSCAPE_INVERTED:
      return window.Orientation.LANDSCAPE_INVERTED;
    case display.Orientation.PORTRAIT:
    default:
      return window.Orientation.PORTRAIT;
  }
}

/**
 * 设置新的屏幕方向。
 * @param newOrientation 新的屏幕方向。
 */
export function setScreenOrientation(newOrientation: window.Orientation) {
  let mainWindow: window.Window = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window;
  mainWindow.setPreferredOrientation(newOrientation);
}