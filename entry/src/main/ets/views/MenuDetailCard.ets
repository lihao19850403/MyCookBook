import { RecommendMenuItem } from '../models/RecommendMenuModel';
import { ScreenUIType } from '../utils/common/ScreenUIAdapter';
import { firstNotVoid } from '../utils/common/Utils';
import { LengthMetrics } from '@ohos.arkui.node';
import { RouterUtils } from '../utils/common/RouterUtils';
import { PhotoViewerParams } from '../pages/common/photoviewer/LHPhotoViewer';
import { AppSettingsTextSizePlanModel } from '../models/AppSettingsTextSizeModel';

/** 菜谱详情样式。 */
export enum MenuDetailCardStyle {
  /** 圆角卡片。 */ ROUND_CARD,
  /** 矩形卡片。 */ SQUARE_BANNER
}

/** 默认属性。 */
interface DefaultAttributes {

  /** 菜谱详情样式。 */
  style: MenuDetailCardStyle;

  /** 无标题模式，适合嵌入单页显示。 */
  noTitleMode: boolean;
}

/** 默认属性。 */
const DEFAULT_ATTRIBUTES: DefaultAttributes = {
  style: MenuDetailCardStyle.ROUND_CARD,
  noTitleMode: false
}

/**
 * 菜谱详情。
 * @author li.hao85
 */
@Component
export struct MenuDetailCard {

  /** 图片加载失败。 */
  @State imageErrorHappened: boolean = false;

  /** 屏幕状态。 */
  @Prop screenUIType: ScreenUIType;

  /** 应用文字字号方案。 */
  @Prop appTextSizePlan: AppSettingsTextSizePlanModel;

  /** 是否使用分屏显示。 */
  @Prop isSplitScreen: boolean;

  /** 菜谱信息。 */
  private menuInfo?: RecommendMenuItem;

  /** 菜谱详情样式。 */
  private style?: MenuDetailCardStyle;

  /** 无标题模式，适合嵌入单页显示。 */
  private noTitleMode?: boolean;

  /** 随机菜谱图片。 */
  private tempPic: ResourceStr = this.randomMenuPic();

  build() {
    if (this.menuInfo !== undefined && this.menuInfo.cp_name !== undefined && this.menuInfo.cp_name !== '') {
      if (this.screenUIType === ScreenUIType.NORMAL || (this.isSplitScreen && this.screenUIType === ScreenUIType.FOLD_OPENED)) {
        Column() {
          this.Image(firstNotVoid(this.menuInfo.cp_thumbnail, this.tempPic)!)
          this.Detail(this.menuInfo.cp_name)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .padding({ left: 8, right: 8, top: 24, bottom: 24 })
        .backgroundColor(Color.White)
        .borderRadius(firstNotVoid(this.style, DEFAULT_ATTRIBUTES.style) === MenuDetailCardStyle.ROUND_CARD ? 4 : 0)
      } else {
        Row() {
          this.Image(firstNotVoid(this.menuInfo.cp_thumbnail, this.tempPic)!)
          this.Detail(this.menuInfo.cp_name)
        }
        .width('100%')
        .padding({ left: 8, right: 8, top: 24, bottom: 24 })
        .backgroundColor(Color.White)
        .borderRadius(firstNotVoid(this.style, DEFAULT_ATTRIBUTES.style) === MenuDetailCardStyle.ROUND_CARD ? 4 : 0)
      }
    }
  }

  @Builder
  private Image(src: ResourceStr) {
    Image(this.imageErrorHappened ? this.tempPic : src)
      .width(224)
      .height(126)
      .objectFit(ImageFit.Contain)
      .onError((error: ImageError) => this.imageErrorHappened = true)
      .onClick((event: ClickEvent) => {
        let params: PhotoViewerParams = {
          title: this.menuInfo !== undefined && this.menuInfo.cp_name !== undefined ? this.menuInfo.cp_name : $r('app.string.photo_viewer'),
          uri: firstNotVoid(this.menuInfo?.cp_thumbnail, this.tempPic)!
        };
        RouterUtils.go('pages/common/photoviewer/LHPhotoViewer', params);
      })
  }

  @Builder
  private Detail(menuName: string) {
    Column({
      space: 8
    }) {
      if (!firstNotVoid(this.noTitleMode, DEFAULT_ATTRIBUTES.noTitleMode)) {
        Text(menuName)
          .width('100%')
          .fontSize(this.appTextSizePlan.menuDetailCardNameTextSize)
          .fontWeight(FontWeight.Medium)
          .textAlign((this.screenUIType === ScreenUIType.NORMAL || (this.isSplitScreen && this.screenUIType === ScreenUIType.FOLD_OPENED)) ?
            TextAlign.Center : TextAlign.Start)
      }
      if (this.menuInfo!.type_name !== undefined && this.menuInfo!.type_name !== '') {
        Text(this.menuInfo!.type_name)
          .fontSize(this.appTextSizePlan.menuDetailCardTypeTextSize)
          .fontWeight(FontWeight.Normal)
          .fontColor($r('app.color.menu_type_name_text_color'))
          .backgroundColor($r('app.color.menu_type_name_bg_color'))
          .padding(4)
          .borderRadius(4)
      }
      if (this.menuInfo!.texing !== undefined && this.menuInfo!.texing !== '') {
        Text(this.menuInfo!.texing)
          .fontSize(this.appTextSizePlan.menuDetailCardTexingTextSize)
          .fontWeight(FontWeight.Normal)
          .fontColor($r('app.color.menu_feature_text_color'))
          .backgroundColor($r('app.color.menu_feature_bg_color'))
          .padding(4)
          .borderRadius(4)
      }
      if (this.menuInfo!.yuanliao !== undefined && this.menuInfo!.yuanliao !== '') {
        Row({
          space: 8
        }) {
          Text($r('app.string.material'))
            .fontSize(this.appTextSizePlan.menuDetailCardYuanliaoTextSize)
            .fontWeight(FontWeight.Medium)
          Text(this.menuInfo!.yuanliao)
            .fontSize(this.appTextSizePlan.menuDetailCardYuanliaoTextSize)
            .fontWeight(FontWeight.Normal)
            .lineSpacing(LengthMetrics.vp(4))
            .layoutWeight(1)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Top)
      }
      if (this.menuInfo!.tiaoliao !== undefined && this.menuInfo!.tiaoliao !== '') {
        Row({
          space: 8
        }) {
          Text($r('app.string.seasoning'))
            .fontSize(this.appTextSizePlan.menuDetailCardTiaoliaoTextSize)
            .fontWeight(FontWeight.Medium)
          Text(this.menuInfo!.tiaoliao)
            .fontSize(this.appTextSizePlan.menuDetailCardTiaoliaoTextSize)
            .fontWeight(FontWeight.Normal)
            .lineSpacing(LengthMetrics.vp(4))
            .layoutWeight(1)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Top)
      }
      if (this.menuInfo!.zuofa !== undefined && this.menuInfo!.zuofa !== '') {
        Row({
          space: 8
        }) {
          Text($r('app.string.practice'))
            .fontSize(this.appTextSizePlan.menuDetailCardZuofaTextSize)
            .fontWeight(FontWeight.Medium)
          Text(this.menuInfo!.zuofa)
            .fontSize(this.appTextSizePlan.menuDetailCardZuofaTextSize)
            .fontWeight(FontWeight.Normal)
            .lineSpacing(LengthMetrics.vp(4))
            .layoutWeight(1)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Top)
      }
      if (this.menuInfo!.tishi !== undefined && this.menuInfo!.tishi !== '') {
        Row() {
          Text($r('app.string.tips'))
            .fontSize(this.appTextSizePlan.menuDetailCardTipsSize)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.menu_tips_title_color'))
            .padding(4)
          Text(this.menuInfo!.tishi)
            .fontSize(this.appTextSizePlan.menuDetailCardTipsSize)
            .fontWeight(FontWeight.Normal)
            .fontColor($r('app.color.menu_tips_content_color'))
            .padding(4)
            .lineSpacing(LengthMetrics.vp(4))
            .layoutWeight(1)
            .borderWidth({ left: 0.3 })
            .borderColor($r('app.color.main_bg_gray_color'))
        }
        .width('100%')
        .backgroundColor($r('app.color.menu_tips_bg_color'))
        .borderRadius(4)
      }
    }
    .width('100%')
    .flexGrow(1)
    .flexShrink(1)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .margin((this.screenUIType === ScreenUIType.NORMAL || (this.isSplitScreen && this.screenUIType === ScreenUIType.FOLD_OPENED)) ?
      { top: 8 } : { left: 8 })
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