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

@Builder
export function LHPhotoViewerBuilder() {
  LHPhotoViewer()
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
struct LHPhotoViewer {

  /** 图片阅览器。 */
  private title: ResourceStr = $r('app.string.photo_viewer');

  /** 图片数据。 */
  @State data: PhotoView.Model = new PhotoView.Model();

  /** 应用文字字号方案。 */
  @State appTextSizePlan: LHAppSettingsTextSizePlanModel = LHAppSettingsTextSizePlans.SMALL;

  build() {
    NavDestination() {
      Column() {
        LHCommonTitleBar({
          centerTitleText: this.title,
          centerTitleTextSize: this.appTextSizePlan.unifiedTitleCenterTextSize,
          leftAction: LHCommonTitleBarLeftNavBack,
        })
        PhotoView({
          model: this.data
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.main_bg_gray_color'))
    }
    .hideTitleBar(true)
    .backButtonIcon(undefined)
    .onReady((context: NavDestinationContext) => {
      let params: PhotoViewerParams = RouterUtils.navGetParams(context) as PhotoViewerParams;
      this.title = params.title;
      if (params.uri instanceof String) {
        this.data.setImageURI(params.uri as string);
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
      emitter.on(GLOBAL_APP_SETTINGS_CHANGED_EVENT, (dataWrap: emitter.EventData) => {
        if (dataWrap.data) {
          let eventType: string = dataWrap.data[GLOBAL_APP_SETTINGS_EVENT_TYPE] as string;
          switch (eventType) {
            case GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN: this.appTextSizePlan = GlobalAppSettings.textSizePlan(); break;
            default: break;
          }
        }
      });
    })
  }
}