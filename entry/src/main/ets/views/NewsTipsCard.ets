import { AppSettingsTextSizePlanModel } from '../models/AppSettingsTextSizeModel';
import { TodayNewsItem } from '../models/TodayNewsModel';
import { PhotoViewerParams } from '../pages/common/photoviewer/LHPhotoViewer';
import { RouterUtils } from '../utils/common/RouterUtils';
import { firstNotVoid } from '../utils/common/Utils';

/** 新闻名片样式。 */
export enum NewsTipsCardStyle {
  /** 圆角卡片。 */ ROUND_CARD,
  /** 矩形卡片。 */ SQUARE_BANNER
}

/** 默认属性。 */
interface DefaultAttributes {

  /** 新闻名片样式。 */
  style: NewsTipsCardStyle;
}

/** 默认属性。 */
const DEFAULT_ATTRIBUTES: DefaultAttributes = {
  style: NewsTipsCardStyle.ROUND_CARD
}

/** 图片加载状态。 */
const enum IMAGE_LOADING_STATUS {
  /** 加载中。 */ LOADING,
  /** 成功加载。 */ FINISHED_SUCCESS,
  /** 加载失败。 */ FINISHED_FAILURE
}

/**
 * 新闻名片。
 * @author li.hao85
 */
@Component
export struct NewsTipsCard {

  /** 应用文字字号方案。 */
  @Prop appTextSizePlan: AppSettingsTextSizePlanModel;

  /** 图片加载状态。 */
  @State imageLoadingStatus: IMAGE_LOADING_STATUS = IMAGE_LOADING_STATUS.LOADING;

  /** 要加载的图片资源。 */
  @State imageSrc: ResourceStr | undefined = undefined;

  /** 新闻信息。 */
  private newsInfo?: TodayNewsItem;

  /** 新闻名片样式。 */
  private style?: NewsTipsCardStyle;

  aboutToAppear(): void {
    this.imageSrc = this.newsInfo?.picUrl;
  }

  build() {
    if (this.newsInfo !== undefined && this.newsInfo.title !== undefined && this.newsInfo.title !== '') {
      Row({
        space: 8
      }) {
        if (this.newsInfo.picUrl !== undefined && this.newsInfo.picUrl.length > 0) {
          Stack({
            alignContent: Alignment.Center
          }) {
            Image(this.imageSrc)
              .objectFit(ImageFit.Contain)
              .onComplete(event => this.imageLoadingStatus = IMAGE_LOADING_STATUS.FINISHED_SUCCESS)
              .onError((error: ImageError) => this.imageLoadingStatus = IMAGE_LOADING_STATUS.FINISHED_FAILURE)
            if (this.imageLoadingStatus === IMAGE_LOADING_STATUS.LOADING) {
              LoadingProgress()
                .height(24)
            } else if (this.imageLoadingStatus === IMAGE_LOADING_STATUS.FINISHED_FAILURE) {
              Image($r('app.media.ic_reload_heavy_gray'))
                .width(24)
                .height(24)
            }
          }
          .width(112)
          .height(63)
          .backgroundColor(this.imageLoadingStatus === IMAGE_LOADING_STATUS.FINISHED_SUCCESS ? undefined : $r("app.color.main_bg_gray_color"))
          .onClick((event: ClickEvent) => {
            if (this.imageLoadingStatus === IMAGE_LOADING_STATUS.FINISHED_FAILURE) {
              this.imageLoadingStatus = IMAGE_LOADING_STATUS.LOADING;
              this.imageSrc = this.newsInfo?.picUrl?.concat(`&lh_retry_time=${new Date().getTime()}`);
            } else if (this.imageLoadingStatus === IMAGE_LOADING_STATUS.FINISHED_SUCCESS) {
              let params: PhotoViewerParams = {
                title: $r('app.string.photo_viewer'),
                uri: this.newsInfo?.picUrl!
              };
              RouterUtils.navPushPath('LHPhotoViewer', params);
            }
          })
        }
        Column({
          space: 8
        }) {
          Text(this.newsInfo.title)
            .fontSize(this.appTextSizePlan.newsTipsCardTitleTextSize)
            .fontWeight(FontWeight.Regular)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .ellipsisMode(EllipsisMode.END)
          Row({
            space: 4
          }) {
            if (this.newsInfo.ctime !== undefined && this.newsInfo.ctime !== '') {
              Text(this.newsInfo.ctime)
                .fontSize(this.appTextSizePlan.newsTipsCardSourceTextSize)
                .fontWeight(FontWeight.Normal)
                .fontColor($r('app.color.main_unselected_color'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .ellipsisMode(EllipsisMode.END)
            }
            if (this.newsInfo.source !== undefined && this.newsInfo.source !== '') {
              Text(this.newsInfo.source)
                .fontSize(this.appTextSizePlan.newsTipsCardSourceTextSize)
                .fontWeight(FontWeight.Normal)
                .fontColor($r('app.color.main_unselected_color'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .ellipsisMode(EllipsisMode.END)
            }
          }
          if (this.newsInfo.description !== undefined && this.newsInfo.description !== '') {
            Text(this.newsInfo.description)
              .fontSize(this.appTextSizePlan.newsTipsCardDescriptionTextSize)
              .fontWeight(FontWeight.Normal)
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .ellipsisMode(EllipsisMode.END)
          }
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Top)
      .padding(8)
      .backgroundColor(Color.White)
      .borderRadius(firstNotVoid(this.style, DEFAULT_ATTRIBUTES.style) === NewsTipsCardStyle.ROUND_CARD ? 4 : 0)
    }
  }
}