import { firstNotVoid } from '../../utils/Utils';
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

/**
 * 自定义的标题栏。
 * @author li.hao85
 */
@Component
export struct LHCommonTitleBar {

  /** 中间标题内容。 */
  private centerTitleText?: ResourceStr;

  /** 标题栏高度，单位是vp。 */
  private titleBarHeight?: number;

  /** 标题栏背景。 */
  private titleBarBg?: ResourceColor;

  /** 是否需要底部分割线。 */
  private needBottomDivider?: boolean;

  build() {
    Stack({
      alignContent: Alignment.Bottom
    }) {
      Text(firstNotVoid(this.centerTitleText, ''))
        .height('100%')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
      if (firstNotVoid(this.needBottomDivider, DEFAULT_ATTRIBUTES.needBottomDivider)) {
        LHDivider()
      }
    }
    .width('100%')
    .height(firstNotVoid(this.titleBarHeight, DEFAULT_ATTRIBUTES.titleBarHeight))
    .backgroundColor(firstNotVoid(this.titleBarBg, DEFAULT_ATTRIBUTES.titleBarBg))
  }
}