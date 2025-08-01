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
  /** 对话框视图构造器。 */
  builder: WrappedBuilder<[object]>;

  /** 额外需要的参数。 */
  data?: object
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
      let builder: WrappedBuilder<[object]> = params.builder;
      let data: object | undefined = params.data;
      // 打开对话框。
      let customDialogController: CustomDialogController = new CustomDialogController({
        builder: LHDialogContainerWrap({
          builder: builder,
          data: data
        }),

      });
      customDialogController.open();
    })
  }
}

@CustomDialog
struct LHDialogContainerWrap {
  controller: CustomDialogController;
  /** 对话框视图构造器。 */
  builder?: WrappedBuilder<[object]>
  /** 对话框需要的参数。 */
  data?: object = undefined

  build() {
    this.builder?.builder(this.data)
  }
}

