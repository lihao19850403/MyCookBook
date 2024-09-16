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

/**
 * 新闻名片。
 * @author li.hao85
 */
@Component
export struct NewsTipsCard {

  /** 图片加载失败。 */
  @State imageErrorHappened: boolean = false;

  /** 新闻信息。 */
  private newsInfo?: TodayNewsItem;

  /** 新闻名片样式。 */
  private style?: NewsTipsCardStyle;

  build() {
    if (this.newsInfo !== undefined && this.newsInfo.title !== undefined && this.newsInfo.title !== '') {
      Row({
        space: 8
      }) {
        Image(this.newsInfo.picUrl)
          .width(112)
          .height(63)
          .objectFit(ImageFit.Contain)
          .onError((error: ImageError) => this.imageErrorHappened = true)
          .visibility(this.imageErrorHappened ? Visibility.None : Visibility.Visible)
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