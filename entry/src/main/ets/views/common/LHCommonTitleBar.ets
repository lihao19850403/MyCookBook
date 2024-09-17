import { LHAppSettingsTextSizePlans } from '../../models/common/LHAppSettingsTextSizePlans';
import { RouterUtils } from '../../utils/common/RouterUtils';
import { firstNotVoid } from '../../utils/common/Utils';
import { LHDivider } from './LHDivider';

/** 默认属性。 */
interface DefaultAttributes {

  /** 标题栏高度，单位是vp。 */
  titleBarHeight: number;

  /** 标题栏背景。 */
  titleBarBg: ResourceColor;

  /** 是否需要底部分割线。 */
  needBottomDivider: boolean;
}

/** 默认属性。 */
const DEFAULT_ATTRIBUTES: DefaultAttributes = {
  titleBarHeight: 48,
  titleBarBg: Color.White,
  needBottomDivider: true
}

/** 一个默认的标题栏返回按钮。 */
@Builder
export function LHCommonTitleBarLeftBack() {
  Image($r('app.media.ic_main_back_arrow'))
    .width(48)
    .height(48)
    .padding(12)
    .objectFit(ImageFit.Contain)
    .onClick((event: ClickEvent) => RouterUtils.back())
}

/**
 * 自定义的标题栏。
 * @author li.hao85
 */
@Component
export struct LHCommonTitleBar {

  /** 中间标题内容字号。 */
  @Prop centerTitleTextSize: number = LHAppSettingsTextSizePlans.SMALL.unifiedTitleCenterTextSize;

  /** 中间标题内容。 */
  private centerTitleText?: ResourceStr;

  /** 标题栏高度，单位是vp。 */
  private titleBarHeight?: number;

  /** 标题栏背景。 */
  private titleBarBg?: ResourceColor;

  /** 左侧区域。 */
  @BuilderParam private leftAction?: () => void;

  /** 右侧区域。 */
  @BuilderParam private rightAction?: () => void;

  /** 是否需要底部分割线。 */
  private needBottomDivider?: boolean;

  build() {
    Stack({
      alignContent: Alignment.Bottom
    }) {
      Text(firstNotVoid(this.centerTitleText, ''))
        .height('100%')
        .fontSize(this.centerTitleTextSize)
        .fontWeight(FontWeight.Medium)
      Row() {
        Stack({
          alignContent: Alignment.Center
        }) {
          if (this.leftAction !== undefined) {
            this.leftAction()
          }
        }
        .height(firstNotVoid(this.titleBarHeight, DEFAULT_ATTRIBUTES.titleBarHeight))
        Stack({
          alignContent: Alignment.Center
        }) {
          if (this.rightAction !== undefined) {
            this.rightAction()
          }
        }
        .height(firstNotVoid(this.titleBarHeight, DEFAULT_ATTRIBUTES.titleBarHeight))
      }
      .width('100%')
      .height(firstNotVoid(this.titleBarHeight, DEFAULT_ATTRIBUTES.titleBarHeight))
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .hitTestBehavior(HitTestMode.None)
      if (firstNotVoid(this.needBottomDivider, DEFAULT_ATTRIBUTES.needBottomDivider)) {
        LHDivider()
      }
    }
    .width('100%')
    .height(firstNotVoid(this.titleBarHeight, DEFAULT_ATTRIBUTES.titleBarHeight))
    .backgroundColor(firstNotVoid(this.titleBarBg, DEFAULT_ATTRIBUTES.titleBarBg))
  }
}