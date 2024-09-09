import { RecommendMenuItem } from '../models/RecommendMenuModel';
import { firstNotVoid } from '../utils/common/Utils';

/** 菜谱名片样式。 */
export enum MenuTipsCardStyle {

  /** 圆角卡片。 */
  ROUND_CARD,

  /** 矩形卡片。 */
  SQUARE_BANNER
}

/** 默认属性。 */
interface DefaultAttributes {

  /** 菜谱名片样式。 */
  style: MenuTipsCardStyle;
}

/** 默认属性。 */
const DEFAULT_ATTRIBUTES: DefaultAttributes = {
  style: MenuTipsCardStyle.ROUND_CARD
}

/**
 * 菜谱名片。
 * @author li.hao85
 */
@Component
export struct MenuTipsCard {

  /** 动态指定小卡片的宽。 */
  @Prop cardWidth: number;

  /** 动态指定小卡片的高。 */
  @Prop cardHeight: number;

  /** 菜谱信息。 */
  private menuInfo?: RecommendMenuItem;

  /** 菜谱名片样式。 */
  private style?: MenuTipsCardStyle;

  /** 随机菜谱图片。s */
  private tempPic: ResourceStr = this.randomMenuPic();

  build() {
    if (this.menuInfo !== undefined && this.menuInfo.cp_name !== undefined && this.menuInfo.cp_name !== '') {
      Row({
        space: 8
      }) {
        Image(firstNotVoid(this.menuInfo.cp_thumbnail, this.tempPic))
          .width(112)
          .height(63)
          .objectFit(ImageFit.Contain)
        Column({
          space: 8
        }) {
          Text(this.menuInfo.cp_name)
            .fontSize(18)
            .fontWeight(FontWeight.Regular)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .ellipsisMode(EllipsisMode.END)
          if (this.menuInfo.type_name !== undefined && this.menuInfo.type_name !== '') {
            Text(this.menuInfo.type_name)
              .fontSize(12)
              .fontWeight(FontWeight.Normal)
              .fontColor($r('app.color.menu_type_name_text_color'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .ellipsisMode(EllipsisMode.END)
              .backgroundColor($r('app.color.menu_type_name_bg_color'))
              .padding(4)
              .borderRadius(4)
          }
          if (this.menuInfo.texing !== undefined && this.menuInfo.texing !== '') {
            Text(this.menuInfo.texing)
              .fontSize(12)
              .fontWeight(FontWeight.Normal)
              .fontColor($r('app.color.menu_feature_text_color'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .ellipsisMode(EllipsisMode.END)
              .backgroundColor($r('app.color.menu_feature_bg_color'))
              .padding(4)
              .borderRadius(4)
          }
          if (this.menuInfo.zuofa !== undefined && this.menuInfo.zuofa !== '') {
            Text(`做法：${this.menuInfo.zuofa}`)
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
      .width(this.cardWidth === undefined ? '100%' : this.cardWidth)
      .height(this.cardHeight)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Top)
      .padding(8)
      .backgroundColor(Color.White)
      .borderRadius(firstNotVoid(this.style, DEFAULT_ATTRIBUTES.style) === MenuTipsCardStyle.ROUND_CARD ? 4 : 0)
    }
  }

  /**
   * 随机菜谱缩略图。
   * @returns 随机菜谱缩略图。
   */
  private randomMenuPic(): ResourceStr {
    let index: number = Math.floor(Math.random() * 10) % 3;
    return $r(`app.media.pic_random_menu_${index}`);
  }
}