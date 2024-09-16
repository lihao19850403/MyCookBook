import { TodayNewsItem } from '../models/TodayNewsModel';
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

  /** 图片加载状态。 */
  @State imageLoadingStatus: IMAGE_LOADING_STATUS = IMAGE_LOADING_STATUS.LOADING;

  /** 新闻信息。 */
  private newsInfo?: TodayNewsItem;

  /** 新闻名片样式。 */
  private style?: NewsTipsCardStyle;

  build() {
    if (this.newsInfo !== undefined && this.newsInfo.title !== undefined && this.newsInfo.title !== '') {
      Row({
        space: 8
      }) {
        if (this.imageLoadingStatus !== IMAGE_LOADING_STATUS.FINISHED_FAILURE) {
          Stack({
            alignContent: Alignment.Center
          }) {
            Image(this.newsInfo.picUrl)
              .objectFit(ImageFit.Contain)
              .onComplete(event => this.imageLoadingStatus = IMAGE_LOADING_STATUS.FINISHED_SUCCESS)
              .onError((error: ImageError) => this.imageLoadingStatus = IMAGE_LOADING_STATUS.FINISHED_FAILURE)
            if (this.imageLoadingStatus === IMAGE_LOADING_STATUS.LOADING) {
              LoadingProgress()
                .height(24)
            }
          }
          .width(112)
          .height(63)
          .backgroundColor(this.imageLoadingStatus === IMAGE_LOADING_STATUS.LOADING ? $r("app.color.main_bg_gray_color") : undefined)
        }
        Column({
          space: 8
        }) {
          Text(this.newsInfo.title)
            .fontSize(18)
            .fontWeight(FontWeight.Regular)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .ellipsisMode(EllipsisMode.END)
          Row({
            space: 4
          }) {
            if (this.newsInfo.ctime !== undefined && this.newsInfo.ctime !== '') {
              Text(this.newsInfo.ctime)
                .fontSize(12)
                .fontWeight(FontWeight.Normal)
                .fontColor($r('app.color.main_unselected_color'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .ellipsisMode(EllipsisMode.END)
            }
            if (this.newsInfo.source !== undefined && this.newsInfo.source !== '') {
              Text(this.newsInfo.source)
                .fontSize(12)
                .fontWeight(FontWeight.Normal)
                .fontColor($r('app.color.main_unselected_color'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .ellipsisMode(EllipsisMode.END)
            }
          }
          if (this.newsInfo.description !== undefined && this.newsInfo.description !== '') {
            Text(this.newsInfo.description)
              .fontSize(13)
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