import { firstNotVoid } from '../utils/common/Utils';
import { TodayNewsItem } from '../models/TodayNewsModel';
import { LengthMetrics } from '@kit.ArkUI';
import { RouterUtils } from '../utils/common/RouterUtils';

/** 新闻详情样式。 */
export enum NewsDetailCardStyle {
  /** 圆角卡片。 */ ROUND_CARD,
  /** 矩形卡片。 */ SQUARE_BANNER
}

/** 默认属性。 */
interface DefaultAttributes {

  /** 新闻详情样式。 */
  style: NewsDetailCardStyle;
}

/** 默认属性。 */
const DEFAULT_ATTRIBUTES: DefaultAttributes = {
  style: NewsDetailCardStyle.ROUND_CARD,
}

/** 图片加载状态。 */
const enum IMAGE_LOADING_STATUS {
  /** 加载中。 */ LOADING,
/** 成功加载。 */ FINISHED_SUCCESS,
/** 加载失败。 */ FINISHED_FAILURE
}

/**
 * 新闻详情。
 * @author li.hao85
 */
@Component
export struct NewsDetailCard {

  /** 图片加载状态。 */
  @State imageLoadingStatus: IMAGE_LOADING_STATUS = IMAGE_LOADING_STATUS.LOADING;

  /** 动态记录新闻详情卡片的宽度。 */
  @State cardWidth: number = -1;

  /** 信息。 */
  private newsInfo?: TodayNewsItem;

  /** 新闻详情样式。 */
  private style?: NewsDetailCardStyle;

  build() {
    if (this.newsInfo !== undefined && this.newsInfo.title !== undefined && this.newsInfo.title !== '') {
      Column({
        space: 8
      }) {
        Text(this.newsInfo.title)
          .width('100%')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
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
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        if (this.imageLoadingStatus !== IMAGE_LOADING_STATUS.FINISHED_FAILURE) {
          Stack({
            alignContent: Alignment.Center
          }) {
            Image(this.newsInfo.picUrl)
              .width(this.cardWidth * 0.95)
              .constraintSize({
                minWidth: 224,
                minHeight: 126
              })
              .objectFit(ImageFit.Contain)
              .onComplete(event => this.imageLoadingStatus = IMAGE_LOADING_STATUS.FINISHED_SUCCESS)
              .onError((error: ImageError) => this.imageLoadingStatus = IMAGE_LOADING_STATUS.FINISHED_FAILURE)
            if (this.imageLoadingStatus === IMAGE_LOADING_STATUS.LOADING) {
              LoadingProgress()
                .height(24)
            }
          }
          .width('100%')
          .backgroundColor(this.imageLoadingStatus === IMAGE_LOADING_STATUS.LOADING ? $r("app.color.main_bg_gray_color") : undefined)
        }
        if (this.newsInfo.description !== undefined && this.newsInfo!.description !== '') {
          Text(this.newsInfo.description)
            .width('100%')
            .fontSize(14)
            .fontWeight(FontWeight.Normal)
            .lineSpacing(LengthMetrics.vp(4))
        }
        if (this.newsInfo.url !== undefined && this.newsInfo.url !== '') {
          Column({
            space: 8
          }) {
            Text($r('app.string.original_link'))
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.main_link_text_heavy_color'))
            Text(this.newsInfo.url)
              .fontSize(14)
              .fontWeight(FontWeight.Normal)
              .fontColor($r('app.color.main_link_text_color'))
              .lineSpacing(LengthMetrics.vp(4))
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start)
          .margin({ top: 24 })
          .onClick((event: ClickEvent) => RouterUtils.go('pages/common/webbrowser/LHWebBrowser', { "url": this.newsInfo?.url }))
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 8, right: 8, top: 24, bottom: 24 })
      .backgroundColor(Color.White)
      .borderRadius(firstNotVoid(this.style, DEFAULT_ATTRIBUTES.style) === NewsDetailCardStyle.ROUND_CARD ? 4 : 0)
      .onSizeChange((_, newSize: SizeOptions) => {
        this.cardWidth = newSize.width as number;
      })
    }
  }
}