import { RouterUtils } from "../../../utils/common/RouterUtils";

export namespace LHDialogContainer {
  export function open(params: DialogContainerParams) {
    RouterUtils.navPushPath('LHDialogContainer', params);
  }
}

@Builder
export function LHDialogContainerBuilder() {
  LHDialogContainerComponent()
}

/** 对话框容器需要的参数。 */
export interface DialogContainerParams {
  /**
   * 对话框视图构造器。
   * 第一个参数为对话框需要操作的数据，由DialogContainerParams.data属性提供；
   * 第二个参数为关闭对话框的回调，由框架自动填充，自定义对话框视图内仅调用即可。
   */
  builder: WrappedBuilder<[object, Callback<void, void>]>;

  /** 额外需要的参数。 */
  data?: object;

  /** 对话框被取消时候的回调，当用户点击物理返回键、从屏幕边缘向中心滑动触发返回手势、或点击蒙层关闭对话框时被调用。 */
  cancelCallback?: Callback<void, void>;

  /** 设置点击对话框外部(蒙层)是否关闭对话框，默认关闭。 */
  autoCancel?: boolean;
}

/**
 * 对话框容器，用来打开全屏对话框。
 * @author li.hao85
 */
@Component
export struct LHDialogContainerComponent {
  build() {
    NavDestination() {
    }
    .hideTitleBar(true)
    .backButtonIcon(undefined)
    .mode(NavDestinationMode.DIALOG)
    .onReady((context: NavDestinationContext) => {
      let params: DialogContainerParams = RouterUtils.navGetParams(context) as DialogContainerParams;
      let builder: WrappedBuilder<[object, Callback<void, void>]> = params.builder;
      let data: object | undefined = params.data;
      let cancelCallback: Callback<void, void> | undefined = params.cancelCallback;
      let autoCancel: boolean = params.autoCancel ?? true;
      // 打开对话框。
      let closeCallback: Callback<void, void> = () => {
        customDialogController.close();
        RouterUtils.navBack();
      };
      let customDialogController: CustomDialogController = new CustomDialogController({
        builder: LHDialogContainerWrap({
          builder: builder,
          data: data,
          closeCallback: closeCallback
        }),
        autoCancel: autoCancel,
        customStyle: true,
        onWillDismiss: (action: DismissDialogAction) => {
          cancelCallback?.();
          closeCallback();
        }
      });
      customDialogController.open();
    })
  }
}

@CustomDialog
struct LHDialogContainerWrap {
  controller?: CustomDialogController;
  /** 对话框视图构造器。 */
  builder?: WrappedBuilder<[object, Callback<void, void>]>
  /** 对话框需要的参数。 */
  data?: object = undefined
  /** 对话框关闭回调。 */
  closeCallback?: Callback<void, void> = undefined;

  build() {
    this.builder?.builder(this.data, this.closeCallback)
  }
}