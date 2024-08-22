import { Context } from '@kit.AbilityKit';

/**
 * 全局上下文。
 * @author li.hao85
 */
export class GlobalContext {

  /** 全局上下文容器。 */
  private static mInstance: GlobalContext;

  /** 全局上下文。 */
  private context?: Context

  /** 构造方法。 */
  private constructor() {}

  /**
   * 初始化。
   * @param 已有的上下文，一般来自EntryAbility。
   */
  public static init(context: Context) {
    if (GlobalContext.mInstance) {
      return;
    }
    GlobalContext.mInstance = new GlobalContext();
    GlobalContext.mInstance.context = context;
  }

  /**
   * 全局上下文实例。
   * @returns 全局上下文实例，当未执行init方法时返回undefined。
   */
  public static getContext(): Context | undefined {
    if (GlobalContext.mInstance) {
      return GlobalContext.mInstance.context;
    }
    return undefined;
  }
}