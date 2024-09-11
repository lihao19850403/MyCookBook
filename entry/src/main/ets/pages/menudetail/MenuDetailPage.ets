import {
  getScreenBottomSafeZoneHeightPx,
  getScreenUIType, ScreenUIType, SCREEN_UI_CHANGE_EVENT, SCREEN_UI_NEW_TYPE } from '../../utils/common/ScreenUIAdapter';
import { emitter } from '@kit.BasicServicesKit';
import { RecommendMenuItem } from '../../models/RecommendMenuModel';
import { RouterUtils } from '../../utils/common/RouterUtils';
import { LHCommonTitleBar, LHCommonTitleBarLeftBack } from '../../views/common/LHCommonTitleBar';
import { MenuDetailCard, MenuDetailCardStyle } from '../../views/MenuDetailCard';
import { LHMarkedStar } from '../../views/common/LHMarkedStar';
import { FavoriteMenuUtils } from '../../utils/FavoriteMenuUtils';

/**
 * 菜谱详情页。
 * @author li.hao85
 */
@Entry
@Component
struct MenuDetailPage {

  /** 屏幕状态。 */
  @State screenUIType: ScreenUIType = getScreenUIType();

  /** 菜谱详情。 */
  private menuItem?: RecommendMenuItem;

  aboutToAppear(): void {
    emitter.on(SCREEN_UI_CHANGE_EVENT, (dataWrap: emitter.EventData) => {
      if (dataWrap.data) {
        let newScreenUIType: ScreenUIType = dataWrap.data[SCREEN_UI_NEW_TYPE] as ScreenUIType;
        this.screenUIType = newScreenUIType;
      }
    })
    this.menuItem = RouterUtils.getParams();
  }

  build() {
    Column() {
      LHCommonTitleBar({
        centerTitleText: this.menuItem !== undefined && this.menuItem.cp_name !== undefined && this.menuItem.cp_name.length > 0 ? this.menuItem.cp_name : $r('app.string.home_tab_menu'),
        leftAction: LHCommonTitleBarLeftBack,
        rightAction: this.FavoriteStar.bind(this)
      })
      Scroll() {
        MenuDetailCard({
          screenUIType: this.screenUIType,
          menuInfo: this.menuItem,
          style: MenuDetailCardStyle.SQUARE_BANNER,
          noTitleMode: true
        })
      }
      .width('100%')
      .scrollBar(BarState.Off)
      .padding({ bottom: px2vp(getScreenBottomSafeZoneHeightPx()) })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_bg_gray_color'))
  }

  @Builder
  private FavoriteStar() {
    LHMarkedStar({
      isSelected: this.menuItem !== undefined && this.menuItem.id !== undefined && FavoriteMenuUtils.isFavoriteMenu(this.menuItem.id),
      onSelectedChanged: (newStatus: boolean) => {
        if (this.menuItem !== undefined && this.menuItem.id !== undefined) {
          if (newStatus) {
            FavoriteMenuUtils.addOneFavoriteMenu(this.menuItem);
          } else {
            FavoriteMenuUtils.removeOneFavoriteMenu(this.menuItem.id);
          }
        }
      }
    })
  }
}