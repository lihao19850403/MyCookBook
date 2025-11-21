import { GlobalConfig, GLOBAL_CONFIG_KEY_WINDOW } from "../GlobalConfig";
import window from "@ohos.window";
import { getScreenUIType, ScreenUIType } from "../ScreenUIAdapter";
import HashMap from "@ohos.util.HashMap";
import { diffRect } from "../Utils";

/** 屏幕状态信息。 */
export interface ScreenStatusInfo {
  /** 设备类型。 */ screenUIType?: ScreenUIType;
  /** 安全区类型。 */ avoidAreaType?: window.AvoidAreaType;
  /** 安全区域信息。 */ avoidArea?: window.AvoidArea;
  /** 窗口类型。 */ windowStatusType?: window.WindowStatusType;
  /** 窗口宽方向断点类型。 */ windowWidthBreakpoint?: WidthBreakpoint;
  /** 窗口高方向断点类型。 */ windowHeightBreakpoint?: HeightBreakpoint;
}

/**
 * 监控屏幕状态改变的工具类。
 * @author li.hao85
 */
export class ScreenObserver {

  private static mInstance: ScreenObserver;

  /** 当前屏幕状态信息。 */
  private currentScreenStatusInfo: ScreenStatusInfo;

  /** 订阅者集合。 */
  private subscribers: HashMap<UIContext, Callback<ScreenStatusInfo, void>> = new HashMap();

  private constructor() {
    this.currentScreenStatusInfo = {};
    let mainWindow: window.Window = GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window;
    mainWindow.on('windowSizeChange', (windowSize: Size) => this.screenUIChangeAdapter());
    mainWindow.on("avoidAreaChange", (options: window.AvoidAreaOptions) => this.avoidAreaChangeAdapter(options));
    mainWindow.on("windowStatusChange", (type: window.WindowStatusType) => this.windowStatusTypeChangeAdapter(type));
    mainWindow.on("windowRectChange", (options: window.RectChangeOptions) => this.windowSizeChangeAdapter(options));
  }

  /** 初始化，一般在EntryAbility获取到当前window对象后调用 */
  public static init() {
    if (ScreenObserver.mInstance) {
      return;
    }
    ScreenObserver.mInstance = new ScreenObserver();
  }

  /**
   * 在当前UI上下文中订阅屏幕状态改变事件。
   * @param uiContext 当前UI上下文。
   * @param subscriber 屏幕状态改变事件，与当前UI上下文相关。
   */
  public static subscribe(uiContext: UIContext, subscriber: Callback<ScreenStatusInfo, void>) {
    ScreenObserver.init();
    ScreenObserver.mInstance.subscribers.set(uiContext, subscriber);
  }

  /**
   * 取消当前UI上下文中屏幕状态改变事件的订阅。。
   * @param uiContext 当前UI上下文。
   */
  public static unsubscribe(uiContext: UIContext) {
    ScreenObserver.init();
    ScreenObserver.mInstance.subscribers.remove(uiContext);
  }

  /* ---------- 子项监听。 ---------- */

  /** 响应设备类型的变化。 */
  private screenUIChangeAdapter() {
    let newScreenUIType = getScreenUIType();
    let changed: boolean = this.currentScreenStatusInfo.screenUIType !== newScreenUIType;
    if (changed) {
      this.currentScreenStatusInfo.screenUIType = newScreenUIType;
      this.subscribers.forEach((callback: Callback<ScreenStatusInfo, void>, uiContext: UIContext) => {
        try {
          callback(this.currentScreenStatusInfo);
        } catch (error) {}
      });
    }
  }

  /**
   * 响应安全区的变化。
   * @param options 新的安全区信息。
   */
  private avoidAreaChangeAdapter(options: window.AvoidAreaOptions) {
    let newAvoidAreaType = options.type;
    let newAvoidArea = options.area;
    let changed: boolean = this.currentScreenStatusInfo.avoidAreaType !== newAvoidAreaType ||
      this.currentScreenStatusInfo.avoidArea?.visible !== newAvoidArea.visible ||
      diffRect(this.currentScreenStatusInfo.avoidArea.leftRect, newAvoidArea.leftRect) ||
      diffRect(this.currentScreenStatusInfo.avoidArea.topRect, newAvoidArea.topRect) ||
      diffRect(this.currentScreenStatusInfo.avoidArea.rightRect, newAvoidArea.rightRect) ||
      diffRect(this.currentScreenStatusInfo.avoidArea.bottomRect, newAvoidArea.bottomRect);
    if (changed) {
      this.currentScreenStatusInfo.avoidAreaType = newAvoidAreaType;
      this.currentScreenStatusInfo.avoidArea = newAvoidArea;
      this.subscribers.forEach((callback: Callback<ScreenStatusInfo, void>, uiContext: UIContext) => {
        try {
          callback(this.currentScreenStatusInfo);
        } catch (error) {}
      });
    }
  }
  /**
   * 响应屏幕状态类型的改变。
   * @param type 新的屏幕状态类型。
   */
  private windowStatusTypeChangeAdapter(type: window.WindowStatusType) {
    let newType = type;
    let changed: boolean = this.currentScreenStatusInfo.windowStatusType !== newType;
    if (changed) {
      this.currentScreenStatusInfo.windowStatusType = newType;
      this.subscribers.forEach((callback: Callback<ScreenStatusInfo, void>, uiContext: UIContext) => {
        try {
          callback(this.currentScreenStatusInfo);
        } catch (error) {}
      });
    }
  }

  /**
   * 响应屏幕断点的改变。
   * @param options 新的屏幕尺寸信息。
   */
  private windowSizeChangeAdapter(options: window.RectChangeOptions) {
    let oldWindowWidthBreakpoint = this.currentScreenStatusInfo.windowWidthBreakpoint;
    let oldWindowHeightBreakpoint = this.currentScreenStatusInfo.windowHeightBreakpoint;
    this.subscribers.forEach((callback: Callback<ScreenStatusInfo, void>, uiContext: UIContext) => {
      let newWindowWidthBreakpoint = uiContext.getWindowWidthBreakpoint();
      let newWindowHeightBreakpoint = uiContext.getWindowHeightBreakpoint();
      let changed: boolean = oldWindowWidthBreakpoint !== newWindowWidthBreakpoint || oldWindowHeightBreakpoint !== newWindowHeightBreakpoint;
      if (changed) {
        this.currentScreenStatusInfo.windowWidthBreakpoint = newWindowWidthBreakpoint;
        this.currentScreenStatusInfo.windowHeightBreakpoint = newWindowHeightBreakpoint;
        try {
          callback(this.currentScreenStatusInfo);
        } catch (error) {}
      }
    });
  }
}