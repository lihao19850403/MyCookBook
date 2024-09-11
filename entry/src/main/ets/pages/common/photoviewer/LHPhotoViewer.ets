import { PhotoView } from '@ohos/photoview';
import { RouterUtils } from '../../../utils/common/RouterUtils';
import { firstNotVoid } from '../../../utils/common/Utils';
import { LHCommonTitleBar, LHCommonTitleBarLeftBack } from '../../../views/common/LHCommonTitleBar';

/** 图片阅览需要的参数。 */
export interface PhotoViewerParams {

  /** 标题。 */
  title: ResourceStr;

  /** 图片路径。 */
  uri: ResourceStr;

  /** 是否允许图片缩放。默认允许。 */
  zoomable?: boolean;

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
@Entry
@Component
export struct LHPhotoViewer {

  /** 图片阅览器。 */
  private title: ResourceStr = $r('app.string.photo_viewer');

  /** 图片数据。 */
  @State data: PhotoView.Model = new PhotoView.Model();

  aboutToAppear(): void {
    let params: PhotoViewerParams = RouterUtils.getParams();
    this.title = params.title;
    if (params.uri instanceof String) {
      this.data.setImageURI(params.uri as string);
    } else {
      this.data.setImageResource(params.uri as Resource);
    }
    this.data.setZoomable(firstNotVoid(params.zoomable, true));
    if (params.scaleRange !== undefined && params.scaleRange.length >= 2 && params.scaleRange[0] <= params.scaleRange[1]) {
      this.data.setMinimumScale(Math.max(params.scaleRange[0], 1.0));
      this.data.setMaximumScale(Math.min(params.scaleRange[1], 5.0));
    } else {
      this.data.setMinimumScale(1.0);
      this.data.setMaximumScale(3.0);
    }
  }

  build() {
    Column() {
      LHCommonTitleBar({
        centerTitleText: this.title,
        leftAction: LHCommonTitleBarLeftBack,
      })
      PhotoView({
        model: this.data
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_bg_gray_color'))
  }
}