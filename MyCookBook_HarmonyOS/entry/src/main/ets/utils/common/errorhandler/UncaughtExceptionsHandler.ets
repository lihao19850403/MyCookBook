import errorManager from "@ohos.app.ability.errorManager";
import hilog from "@ohos.hilog";

/**
 * 异常捕获工具类。
 * @author li.hao85
 */
export class UncaughtExceptionsHandler {

  /** 异常观察器的ID。 */
  private static observerID?: number = undefined;

  /** 异常观察器。 */
  private static observer: errorManager.ErrorObserver = {
    onUnhandledException: (errMsg: string) => {
      hilog.error(0x0000, '[UncaughtExceptionsHandler]', '异常捕获信息：\n%{public}s', errMsg);
    }
  };

  /**
   * 启动异常捕获。
   */
  public static start() {
    if (UncaughtExceptionsHandler.observerID !== undefined) {
      /* 异常观察器已经启动，无需重复启动。 */
      return;
    }
    UncaughtExceptionsHandler.observerID = errorManager.on('error', UncaughtExceptionsHandler.observer);
  }

  /**
   * 停止异常捕获。
   */
  public static stop() {
    if (UncaughtExceptionsHandler.observerID === undefined) {
      /* 没有要停止的异常观察器。 */
      return;
    }
    errorManager.off('error', UncaughtExceptionsHandler.observerID);
  }
}