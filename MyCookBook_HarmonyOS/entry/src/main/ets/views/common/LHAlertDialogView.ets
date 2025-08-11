import { LHAppSettingsTextSizePlanModel } from "../../models/common/LHAppSettingsTextSizePlanModel";
import { GlobalAppSettings } from "../../utils/common/GlobalAppSettings";

/**
 * 告警对话框视图。
 * @author li.hao85
 */
@Component
export struct LHAlertDialogView {
  /** 应用文字字号方案。 */
  private appTextSizePlan: LHAppSettingsTextSizePlanModel = GlobalAppSettings.textSizePlan();;
  /** 标题。 */
  title?: string = undefined;
  /** 内容。 */
  content?: string = undefined;
  /** 取消按钮动作。 */
  cancelAction?: Callback<void, void> = undefined;
  /** 确定按钮动作。 */
  confirmAction?: Callback<void, void> = undefined;
  /** 关闭对话框动作。 */
  closeCallback?: Callback<void, void> = undefined;

  build() {
    Column() {
      // 标题。
      if (this.title !== undefined && this.title.length > 0) {
        Text(this.title)
          .width('100%')
          .fontSize(this.appTextSizePlan.unifiedDialogTitleTextSize)
          .textAlign(TextAlign.Center)
          .padding(12)
      }
      // 内容。
      if (this.content !== undefined && this.content.length > 0) {
        Text(this.title)
          .width('100%')
          .layoutWeight(1)
          .fontSize(this.appTextSizePlan.unifiedDialogContentTextSize)
          .textAlign(TextAlign.Center)
          .padding(12)
      }

      // 按钮区。
      Row({ space: 12 }) {
        if (this.cancelAction !== undefined) {
          Button($r('app.string.cancel'), {
            type: ButtonType.Normal
          })
            .layoutWeight(1)
            .fontSize(this.appTextSizePlan.unifiedDialogButtonsTextSize)
            .fontColor($r('app.color.main_unselected_color'))
            .backgroundColor(Color.Transparent)
            .onClick((event: ClickEvent) => {
              this.cancelAction?.();
              this.closeCallback?.();
            })
        }
        if (this.confirmAction !== undefined) {
          Button($r('app.string.confirm'), {
            type: ButtonType.Normal
          })
            .layoutWeight(1)
            .fontSize(this.appTextSizePlan.unifiedDialogButtonsTextSize)
            .fontColor($r('app.color.main_selected_color'))
            .backgroundColor(Color.Transparent)
            .onClick((event: ClickEvent) => {
              this.confirmAction?.();
              this.closeCallback?.();
            })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .padding(12)
    }
    .width(320)
    .constraintSize({ minHeight: 320, maxHeight: 480 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.White)
    .border({ radius: 12 })
  }
}