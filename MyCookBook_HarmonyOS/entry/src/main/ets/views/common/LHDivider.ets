import { firstNotVoid } from '../../utils/common/Utils';

/** 默认属性。 */
interface DefaultAttributes {

  /** 是否纵向分割线。 */
  isVertical: boolean;
}

/** 默认属性。 */
const DEFAULT_ATTRIBUTES: DefaultAttributes = {
  isVertical: false
}

/**
 * 自定义的分割线。
 * @author li.hao85
 */
@Component
export struct LHDivider {

  /** 是否纵向分割线。 */
  private isVertical?: boolean;

  build() {
    Divider()
      .vertical(firstNotVoid(this.isVertical, DEFAULT_ATTRIBUTES.isVertical))
      .backgroundColor($r('app.color.main_bg_gray_color'))
      .width(firstNotVoid(this.isVertical, DEFAULT_ATTRIBUTES.isVertical) ? 0.3 : '100%')
      .height(firstNotVoid(this.isVertical, DEFAULT_ATTRIBUTES.isVertical) ? '100%' : 0.3)
  }
}