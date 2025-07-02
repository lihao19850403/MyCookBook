import { LHAppSettingsTextSizePlans } from '../../models/common/LHAppSettingsTextSizePlans';
import { RouterUtils } from '../../utils/common/RouterUtils';
import { firstNotVoid, res2string } from '../../utils/common/Utils';
import { LHDivider } from './LHDivider';
import emitter from '@ohos.events.emitter';
import { SCREEN_UI_CHANGE_EVENT } from '../../utils/common/ScreenUIAdapter';
import MeasureText from '@ohos.measure';

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

/** 一个默认的Navigation组件标题栏返回按钮。 */
@Builder
export function LHCommonTitleBarLeftNavBack() {
  Image($r('app.media.ic_main_back_arrow'))
    .width(48)
    .height(48)
    .padding(12)
    .objectFit(ImageFit.Contain)
    .onClick((event: ClickEvent) => RouterUtils.navBack())
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

  /** 标题栏整体宽度。 */
  private titleBarWidth: number = 0;

  /** 左侧区域宽度。 */
  private leftZoneWidth: number = 0;

  /** 右侧区域宽度。 */
  private rightZoneWidth: number = 0;

  /** 中间标题内容左右边距描述。 */
  @State centerTitleMargin?: Margin = undefined;

  /** 中间标题是否使用跑马灯。 */
  @State useMarquee: boolean = false;

  /** 是否需要底部分割线。 */
  private needBottomDivider?: boolean;

  aboutToAppear(): void {
    emitter.on(SCREEN_UI_CHANGE_EVENT, (dataWrap: emitter.EventData) => {
      if (dataWrap.data) {
        this.calcCenterTitleMargin();
        this.calcUseMarquee();
      }
    })
  }

  build() {
    Stack({
      alignContent: Alignment.Bottom
    }) {
      if (this.useMarquee) {
        Marquee({
          start: true,
          src: this.centerTitleText !== undefined ? res2string(this.centerTitleText) : ''
        })
          .height('100%')
          .margin(this.centerTitleMargin)
          .fontSize(this.centerTitleTextSize)
          .fontWeight(FontWeight.Medium)
      } else {
        Text(firstNotVoid(this.centerTitleText, ''))
          .height('100%')
          .margin(this.centerTitleMargin)
          .fontSize(this.centerTitleTextSize)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
      }
      Row() {
        Stack({
          alignContent: Alignment.Center
        }) {
          if (this.leftAction !== undefined) {
            this.leftAction()
          }
        }
        .height(firstNotVoid(this.titleBarHeight, DEFAULT_ATTRIBUTES.titleBarHeight))
        .onSizeChange((_, newSize: SizeOptions) => {
          this.leftZoneWidth = newSize.width as number;
          this.calcCenterTitleMargin();
          this.calcUseMarquee();
        })
        Stack({
          alignContent: Alignment.Center
        }) {
          if (this.rightAction !== undefined) {
            this.rightAction()
          }
        }
        .height(firstNotVoid(this.titleBarHeight, DEFAULT_ATTRIBUTES.titleBarHeight))
        .onSizeChange((_, newSize: SizeOptions) => {
          this.rightZoneWidth = newSize.width as number;
          this.calcCenterTitleMargin();
          this.calcUseMarquee();
        })
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
    .onSizeChange((_, newSize: SizeOptions) => {
      this.titleBarWidth = newSize.width as number;
      this.calcCenterTitleMargin();
      this.calcUseMarquee();
    })
  }

  /**
   * 计算中间内容的宽。
   * @returns 中间内容的宽。
   */
  private calcCenterTitleTextWidth(): number {
    let textSizeOptionPX: SizeOptions = MeasureText.measureTextSize({
      textContent: firstNotVoid(this.centerTitleText, ''),
      fontSize: this.centerTitleTextSize,
      fontWeight: FontWeight.Medium
    });
    return px2vp(textSizeOptionPX.width as number);
  }

  /** 计算中间内容区域的左右边距。 */
  private calcCenterTitleMargin() {
    if (this.titleBarWidth - Math.max(this.leftZoneWidth, this.rightZoneWidth) * 2 > this.calcCenterTitleTextWidth()) {
      this.centerTitleMargin = undefined;
    } else {
      this.centerTitleMargin = {
        left: this.leftZoneWidth,
        right: this.rightZoneWidth
      }
    }
  }

  /** 决定中间内容区域是否使用跑马灯。 */
  private calcUseMarquee() {
    let centerTitleTextWidth = this.calcCenterTitleTextWidth();
    let centerTitleWidth = this.titleBarWidth - this.leftZoneWidth - this.rightZoneWidth;
    this.useMarquee = centerTitleTextWidth > centerTitleWidth;
  }
}