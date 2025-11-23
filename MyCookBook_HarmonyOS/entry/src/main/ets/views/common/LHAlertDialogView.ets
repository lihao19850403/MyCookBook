import { LHAppSettingsTextSizePlanModel } from "../../models/common/LHAppSettingsTextSizePlanModel";
import { GlobalAppSettings } from "../../utils/common/GlobalAppSettings";
import { getScreenBottomSafeZoneHeightPx, getScreenTopSafeZoneHeightPx } from "../../utils/common/ScreenUIAdapter";
import { ScreenObserver, ScreenStatusInfo } from "../../utils/common/uiobserver/ScreenObserver";
import window from "@ohos.window";

/**
 * 告警对话框视图。
 * @author li.hao85
 */
@Component
export struct LHAlertDialogView {
  /** 应用文字字号方案。 */
  private appTextSizePlan: LHAppSettingsTextSizePlanModel = GlobalAppSettings.textSizePlan();
  /** 标题。 */
  title?: ResourceStr = undefined;
  /** 内容。 */
  content?: ResourceStr = undefined;
  /** 取消按钮动作。 */
  cancelAction?: Callback<void, void> = undefined;
  /** 确定按钮动作。 */
  confirmAction?: Callback<void, void> = undefined;
  /** 关闭对话框动作。 */
  closeCallback?: Callback<void, void> = undefined;

  /** 顶部安全区高度。 */
  @State topSafeZoneHeightVp: number = px2vp(getScreenTopSafeZoneHeightPx());

  /** 底部安全区高度。 */
  @State bottomSafeZoneHeightVp: number = px2vp(getScreenBottomSafeZoneHeightPx());

  /** 标题栏高度。 */
  private titleBarHeightVp: number = 0;

  /** 滚动区最大高度。 */
  @State contentMaxHeight: string | undefined = undefined;

  aboutToAppear(): void {
    ScreenObserver.subscribe(this.getUIContext(), (screenStatus: ScreenStatusInfo) => {
      if (screenStatus.avoidArea !== undefined) {
        if (screenStatus.avoidAreaType === window.AvoidAreaType.TYPE_SYSTEM) {
          this.topSafeZoneHeightVp = px2vp(screenStatus.avoidArea.topRect.height);
        } else if (screenStatus.avoidAreaType === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          this.bottomSafeZoneHeightVp = px2vp(screenStatus.avoidArea.bottomRect.height);
        }
      }
      this.contentMaxHeight = `calc(100% - ${this.titleBarHeightVp}vp)`;
    });
  }

  aboutToDisappear(): void {
    ScreenObserver.unsubscribe(this.getUIContext());
  }

  build() {
    Column() {
      // 标题。
      if (this.title !== undefined) {
        Text(this.title)
          .width('100%')
          .fontSize(this.appTextSizePlan.unifiedDialogTitleTextSize)
          .textAlign(TextAlign.Center)
          .padding(12)
          .onAreaChange((_, newArea: Area) => {
            this.titleBarHeightVp = Math.max(0, Math.ceil(newArea.height as number));
            this.contentMaxHeight = `calc(100% - ${this.titleBarHeightVp}vp)`;
          })
      }
      Scroll() {
        Column() {
          // 内容。
          if (this.content !== undefined) {
            Text(this.content)
              .width('100%')
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
      }
      .width('100%')
      .scrollBar(BarState.Off)
      .constraintSize({ maxHeight: this.contentMaxHeight })
    }
    .width(320)
    .constraintSize({ maxHeight: 480 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.White)
    .border({ radius: 12 })
    .margin({
      top: this.topSafeZoneHeightVp,
      bottom: this.bottomSafeZoneHeightVp
    })
  }
}