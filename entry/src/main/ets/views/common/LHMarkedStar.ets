import { firstNotVoid } from '../../utils/common/Utils';

/** 默认属性。 */
interface DefaultAttributes {

  /** 星尺寸。 */
  starSize: number;
}

/** 默认属性。 */
const DEFAULT_ATTRIBUTES: DefaultAttributes = {
  starSize: 35
}

/**
 * 星型单选钮。
 * @author li.hao85
 */
@Component
export struct LHMarkedStar {

  /** 是否选中。 */
  @State isSelected?: boolean = false;

  /** 星尺寸。 */
  private starSize?: number;

  /** 选中状态改变监听。 */
  private onSelectedChanged?: (isSelected: boolean) => void

  build() {
    Stack({
      alignContent: Alignment.Center
    }) {
      Image(this.isSelected ? $r('app.media.ic_star_gold') : $r('app.media.ic_star_gray'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)
    }
    .width(firstNotVoid(this.starSize, DEFAULT_ATTRIBUTES.starSize))
    .height(firstNotVoid(this.starSize, DEFAULT_ATTRIBUTES.starSize))
    .padding(`${firstNotVoid(this.starSize, DEFAULT_ATTRIBUTES.starSize)! * 0.2}vp`)
    .onClick((event: ClickEvent) => {
      this.isSelected = !this.isSelected;
      if (this.onSelectedChanged !== undefined) {
        this.onSelectedChanged(this.isSelected);
      }
    })
  }
}