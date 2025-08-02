import { MethodResult } from "@ohos/flutter_ohos";
import { AppSettingsTextSizePlanModel } from "../models/AppSettingsTextSizeModel";
import { AppSettings } from "../utils/AppSettings";

/**
 * 为自创菜谱设置分类。
 * @author li.hao85
 */
@Component
export struct CreatedMenuCategorySelect {
  /** 应用文字字号方案。 */
  private appTextSizePlan: AppSettingsTextSizePlanModel = AppSettings.textSizePlan();
  /** 运行结果，用于向Flutter页面返回参数。 */
  result?: MethodResult = undefined;
  /** 关闭对话框的回调。 */
  closeCallback?: Callback<void, void> = undefined;

  build() {
    Column() {
      // 标题。
      Text($r('app.string.created_menu_select_category_title'))
        .width('100%')
        .fontSize(this.appTextSizePlan.createdMenuSelectCategoryTitle)
        .textAlign(TextAlign.Center)
        .padding(12)
      // 内容。
      Stack() {
      }
      .layoutWeight(1)

      // 按钮区。
      Row({ space: 12 }) {
        Button($r('app.string.cancel'), {
          type: ButtonType.Normal
        })
          .fontSize(this.appTextSizePlan.createdMenuSelectCategoryButton)
          .fontColor($r('app.color.main_unselected_color'))
          .backgroundColor(Color.Transparent)
          .onClick((event: ClickEvent) => {
            this.result?.success(undefined);
            this.closeCallback?.();
          })
        Button($r('app.string.confirm'), {
          type: ButtonType.Normal
        })
          .fontSize(this.appTextSizePlan.createdMenuSelectCategoryButton)
          .fontColor($r('app.color.main_selected_color'))
          .backgroundColor(Color.Transparent)
          .onClick((event: ClickEvent) => {
            this.result?.success('测试分类');
            this.closeCallback?.();
          })
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