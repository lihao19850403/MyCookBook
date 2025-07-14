import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { GlobalContext } from '../utils/common/GlobalContext';
import { observeScreenUIChange } from '../utils/common/ScreenUIAdapter';
import { GlobalConfig, GLOBAL_CONFIG_KEY_WINDOW } from '../utils/common/GlobalConfig';
import { UncaughtExceptionsHandler } from '../utils/common/errorhandler/UncaughtExceptionsHandler';
import { ExclusiveAppComponent, FlutterManager } from '@ohos/flutter_ohos';

export default class EntryAbility extends UIAbility implements ExclusiveAppComponent<UIAbility> {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');

    // 启动异常捕获。
    UncaughtExceptionsHandler.start();
    // 初始化全局上下文。
    GlobalContext.init(this.context);
    // 在Flutter模块中进行登记。
    FlutterManager.getInstance().pushUIAbility(this);
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');

    // 停止异常捕获。
    UncaughtExceptionsHandler.stop();
    // 在Flutter模块中解除登记。
    FlutterManager.getInstance().popUIAbility(this);
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
      // 监控屏幕状态变化。
      observeScreenUIChange();
    });

    // 在Flutter模块中进行登记。
    FlutterManager.getInstance().pushWindowStage(this, windowStage);
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
    // 在Flutter模块中解除登记。
    FlutterManager.getInstance().popWindowStage(this);
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }

  /* ---------- Flutter插件。 ---------- */

  detachFromFlutterEngine(): void {

  }

  getAppComponent(): UIAbility {
    return this;
  }
}
