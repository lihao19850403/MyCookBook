import { PhotoView } from '@ohos/photoview';
import { LHAppSettingsTextSizePlanModel } from '../../../models/common/LHAppSettingsTextSizePlanModel';
import { LHAppSettingsTextSizePlans } from '../../../models/common/LHAppSettingsTextSizePlans';
import { GlobalAppSettings, GLOBAL_APP_SETTINGS_CHANGED_EVENT,
  GLOBAL_APP_SETTINGS_EVENT_TYPE,
  GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN} from '../../../utils/common/GlobalAppSettings';
import { RouterUtils } from '../../../utils/common/RouterUtils';
import { firstNotVoid } from '../../../utils/common/Utils';
import { LHCommonTitleBar, LHCommonTitleBarLeftNavBack } from '../../../views/common/LHCommonTitleBar';
import { emitter } from '@kit.BasicServicesKit';
import { getScreenTopSafeZoneHeightPx } from '../../../utils/common/ScreenUIAdapter';
import { fileUri } from '@kit.CoreFileKit';
import url from '@ohos.url';
import { ScreenObserver, ScreenStatusInfo } from '../../../utils/common/uiobserver/ScreenObserver';
import window from '@ohos.window';
import { openCustomDialog } from '../../../utils/common/DialogUtils';
import { LHPhotoDownloadDialog } from './LHPhotoDownloadDialog';

export namespace LHPhotoViewer {
  export function go(params: PhotoViewerParams) {
    RouterUtils.navPushPath('LHPhotoViewer', params);
  }
}

@Builder
export function LHPhotoViewerBuilder() {
  LHPhotoViewerComponent()
}

/** 图片阅览需要的参数。 */
export interface PhotoViewerParams {

  /** 标题。 */
  title: ResourceStr;

  /** 图片路径。 */
  uri: ResourceStr;

  /** 是否允许图片缩放。默认允许。 */
  supportZoom?: boolean;

  /**
   * 图片缩放范围。格式：长为2的数字数组，表示起始范围。
   * 最小值是1.0，最大值是5.0。
   * 默认范围是[1.0, 3.0]。
   * 当数组为undefined、长度不足2、大小范围颠倒时，都会采用默认范围。
   */
  scaleRange?: Array<number>;
}

/**
 * 图片阅览器，基于PhotoView实现。
 * @author li.hao85
 */
@Component
struct LHPhotoViewerComponent {

  /** 图片阅览器。 */
  private title: ResourceStr = $r('app.string.photo_viewer');

  /** 图片数据。 */
  private data: PhotoView.Model = new PhotoView.Model();

  /** 应用文字字号方案。 */
  @State appTextSizePlan: LHAppSettingsTextSizePlanModel = LHAppSettingsTextSizePlans.SMALL;

  /** 顶部安全区高度。 */
  @State topSafeZoneHeightVp: number = px2vp(getScreenTopSafeZoneHeightPx());

  /** 是否允许下载网络图片。 */
  @State allowDownloadNetPhoto: boolean = false;

  private onGlobalAppSettingsChangedEvent: Callback<emitter.EventData> = (dataWrap: emitter.EventData) => {
    if (dataWrap.data) {
      let eventType: string = dataWrap.data[GLOBAL_APP_SETTINGS_EVENT_TYPE] as string;
      switch (eventType) {
        case GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN: this.appTextSizePlan = GlobalAppSettings.textSizePlan(); break;
        default: break;
      }
    }
  };

  build() {
    NavDestination() {
      Column() {
        LHCommonTitleBar({
          centerTitleText: this.title,
          centerTitleTextSize: this.appTextSizePlan.unifiedTitleCenterTextSize,
          leftAction: LHCommonTitleBarLeftNavBack,
          rightAction: this.allowDownloadNetPhoto ? (): void => this.downloadNetPhoto() : undefined
        })
        PhotoView({
          model: this.data
        })
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .backgroundColor($r('app.color.main_bg_gray_color'))
      .margin({ top: this.topSafeZoneHeightVp })
    }
    .hideTitleBar(true)
    .backButtonIcon(undefined)
    .onReady((context: NavDestinationContext) => {
      let params: PhotoViewerParams = RouterUtils.navGetParams(context) as PhotoViewerParams;
      this.title = params.title;
      if (typeof params.uri === 'string') {
        let uriStr: string = params.uri as string;
        let isNetUri: boolean = false;
        try {
          url.URL.parseURL(uriStr)
          isNetUri = true;
        } catch (error) {}
        if (isNetUri) {
          this.data.setImageURI(uriStr);
        } else {
          let realUri: string = fileUri.getUriFromPath(uriStr);
          this.data.setImageURI(realUri);
        }
        this.allowDownloadNetPhoto = isNetUri;
      } else {
        this.data.setImageResource(params.uri as Resource);
      }
      this.data.setZoomable(firstNotVoid(params.supportZoom, true));
      if (params.scaleRange !== undefined && params.scaleRange.length >= 2 && params.scaleRange[0] <= params.scaleRange[1]) {
        this.data.setMinimumScale(Math.max(params.scaleRange[0], 1.0));
        this.data.setMaximumScale(Math.min(params.scaleRange[1], 5.0));
      } else {
        this.data.setMinimumScale(1.0);
        this.data.setMaximumScale(3.0);
      }
      this.appTextSizePlan = GlobalAppSettings.textSizePlan();
      emitter.on(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onGlobalAppSettingsChangedEvent);
      ScreenObserver.subscribe(this.getUIContext(), (screenStatus: ScreenStatusInfo) => {
        if (screenStatus.avoidArea !== undefined) {
          if (screenStatus.avoidAreaType === window.AvoidAreaType.TYPE_SYSTEM) {
            this.topSafeZoneHeightVp = px2vp(screenStatus.avoidArea.topRect.height);
          }
        }
      });
    })
    .onDisAppear(() => {
      emitter.off(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onGlobalAppSettingsChangedEvent);
      ScreenObserver.unsubscribe(this.getUIContext());
    })
  }

  @Builder
  private downloadNetPhoto() {
    Image($r("app.media.ic_load_more_arrow_down"))
      .width(48)
      .height(48)
      .padding(12)
      .objectFit(ImageFit.Contain)
      .onClick((event: ClickEvent) => {
        if (typeof this.data.src === 'string') {
          let netPhotoUrl: string = this.data.src
          openCustomDialog({
            builder: wrapBuilder(photoDownloadDialogBuilder),
            data: [netPhotoUrl]
          });
        }
      })
  }
}

@Builder
function photoDownloadDialogBuilder(params: object, closeCallback: Callback<void, void>) {
  LHPhotoDownloadDialog({
    netPhotoUrl: (params as Array<object>)[0] as ESObject as string,
    closeCallback: closeCallback
  })
}