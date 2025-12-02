import { getScreenBottomSafeZoneHeightPx, getScreenTopSafeZoneHeightPx } from "../../../utils/common/ScreenUIAdapter";
import { ScreenObserver, ScreenStatusInfo } from "../../../utils/common/uiobserver/ScreenObserver";
import window from "@ohos.window";
import { LHAppSettingsTextSizePlanModel } from "../../../models/common/LHAppSettingsTextSizePlanModel";
import { GlobalAppSettings } from "../../../utils/common/GlobalAppSettings";
import http from "@ohos.net.http";
import { PhotoPickerUtils } from "../../../utils/common/mediapicker/PhotoPickerUtils";
import { CopyFileResult } from "../../../utils/common/filecenter/models/FileCopyModel";
import { promptAction } from "@kit.ArkUI";
import { res2string } from "../../../utils/common/Utils";

/** 页面显示状态。 */
enum PAGE_STATUS {
  /** 准备中。 */ PREPARING,
  /** 准备成功。 */ PREPARE_SUCCESS,
  /** 准备失败。 */ PREPARE_FAILURE,
  /** 保存中。 */ SAVING
}

/**
 * 网络图片下载对话框。
 * @author li.hao85
 */
@Component
export struct LHPhotoDownloadDialog {
  /** 应用文字字号方案。 */
  private appTextSizePlan: LHAppSettingsTextSizePlanModel = GlobalAppSettings.textSizePlan();

  /** 网络图片地址。 */
  netPhotoUrl: string = ''

  /** 关闭对话框的回调。 */
  closeCallback?: Callback<void, void> = undefined;

  /** 网络图片数据。 */
  private photoData: ArrayBuffer | undefined = undefined;

  /** 页面加载状态。 */
  @State pageStatus: PAGE_STATUS = PAGE_STATUS.PREPARING;

  /** 顶部安全区高度。 */
  @State topSafeZoneHeightVp: number = px2vp(getScreenTopSafeZoneHeightPx());

  /** 底部安全区高度。 */
  @State bottomSafeZoneHeightVp: number = px2vp(getScreenBottomSafeZoneHeightPx());

  aboutToAppear(): void {
    ScreenObserver.subscribe(this.getUIContext(), (screenStatus: ScreenStatusInfo) => {
      if (screenStatus.avoidArea !== undefined) {
        if (screenStatus.avoidAreaType === window.AvoidAreaType.TYPE_SYSTEM) {
          this.topSafeZoneHeightVp = px2vp(screenStatus.avoidArea.topRect.height);
        } else if (screenStatus.avoidAreaType === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          this.bottomSafeZoneHeightVp = px2vp(screenStatus.avoidArea.bottomRect.height);
        }
      }
    });
    this.preparing();
  }

  aboutToDisappear(): void {
    ScreenObserver.unsubscribe(this.getUIContext());
  }

  build() {
    Column() {
      Text(
        this.pageStatus === PAGE_STATUS.PREPARING ? $r('app.string.preparing') :
        this.pageStatus === PAGE_STATUS.PREPARE_SUCCESS ? $r('app.string.prepare_success') :
        this.pageStatus === PAGE_STATUS.PREPARE_FAILURE ? $r('app.string.prepare_failure') :
        $r('app.string.saving')
      )
        .width('100%')
        .fontSize(this.appTextSizePlan.unifiedDialogTitleTextSize)
        .textAlign(TextAlign.Center)
        .padding(12)
      if (this.pageStatus === PAGE_STATUS.PREPARE_SUCCESS) {
        Row() {
          SaveButton()
            .fontSize(this.appTextSizePlan.unifiedDialogButtonsTextSize)
            .onClick((event: ClickEvent, result: SaveButtonOnClickResult, error?: BusinessError<void>) => {
              this.pageStatus = PAGE_STATUS.SAVING;
              if (this.photoData !== undefined) {
                PhotoPickerUtils.saveOnePhotoToGallery(this.photoData)
                  .then((result?: CopyFileResult) => {
                    if (result && result.resultUri !== undefined && result.resultUri.length > 0) {
                      promptAction.showToast({
                        message: res2string($r('app.string.save_success')) + result.resultUri
                      });
                    } else {
                      promptAction.showToast({
                        message: $r('app.string.save_failure')
                      });
                    }
                  })
                  .catch(() => promptAction.showToast({
                    message: $r('app.string.save_failure')
                  }))
              } else {
                promptAction.showToast({
                  message: $r('app.string.save_failure')
                });
              }
              this.closeCallback?.();
            })
        }
        .margin({ bottom: 12 })
      } else if (this.pageStatus === PAGE_STATUS.PREPARE_FAILURE) {
        Image($r("app.media.ic_reload_green"))
          .width(48)
          .height(48)
          .padding(12)
          .objectFit(ImageFit.Contain)
          .onClick((event: ClickEvent) => this.preparing())
      }
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

  /** 准备图片数据。 */
  private preparing() {
    this.pageStatus = PAGE_STATUS.PREPARING;
    http.createHttp().request(this.netPhotoUrl)
      .then((response: http.HttpResponse) => {
        if (response.result instanceof ArrayBuffer) {
          this.photoData = response.result;
          this.pageStatus = PAGE_STATUS.PREPARE_SUCCESS;
        } else {
          this.pageStatus = PAGE_STATUS.PREPARE_FAILURE;
        }
      })
      .catch(() => this.pageStatus = PAGE_STATUS.PREPARE_FAILURE)
  }
}