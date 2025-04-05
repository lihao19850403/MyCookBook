import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { GlobalContext } from '../utils/common/GlobalContext';
import { getScreenUIType, observeScreenUIChange, ScreenUIType } from '../utils/common/ScreenUIAdapter';
import { GlobalConfig, GLOBAL_CONFIG_KEY_WINDOW } from '../utils/common/GlobalConfig';
import { setScreenOrientation } from '../utils/common/ScreenOrientationUtil';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');

    // 初始化全局上下文。
    GlobalContext.init(this.context);
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/splashscreen/SplashScreen', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');

      // 记录window对象。
      let mainWindow: window.Window = windowStage.getMainWindowSync();
      GlobalConfig.set(GLOBAL_CONFIG_KEY_WINDOW, mainWindow);
      // 设置屏幕方向。
      switch (getScreenUIType()) {
        case ScreenUIType.PAD: setScreenOrientation(window.Orientation.LANDSCAPE); break;
        default: setScreenOrientation(window.Orientation.PORTRAIT); break;
      }
      // 监控屏幕状态变化。
      observeScreenUIChange();
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
