import {
  getScreenBottomSafeZoneHeightPx,
  getScreenUIType, ScreenUIType, SCREEN_UI_CHANGE_EVENT, SCREEN_UI_NEW_TYPE } from '../../utils/ScreenUIAdapter';
import { emitter } from '@kit.BasicServicesKit';
import { LHCommonTitleBar, LHCommonTitleBarLeftBack } from '../../views/common/LHCommonTitleBar';
import { RecommendMenuItem, RecommendMenuResult } from '../../models/RecommendMenuModel';
import { RouterUtils } from '../../utils/RouterUtils';
import { MenuDetailCard, MenuDetailCardStyle } from '../../views/MenuDetailCard';
import { res2string } from '../../utils/Utils';

/**
 * 今日推荐菜谱页。
 * @author li.hao85
 */
@Entry
@Component
struct RecommendMenu {

  /** 屏幕状态。 */
  @State screenUIType: ScreenUIType = getScreenUIType();

  /** 今日推荐菜谱数据。 */
  private recommendMenu?: RecommendMenuResult;

  aboutToAppear(): void {
    emitter.on(SCREEN_UI_CHANGE_EVENT, (dataWrap: emitter.EventData) => {
      if (dataWrap.data) {
        let newScreenUIType: ScreenUIType = dataWrap.data[SCREEN_UI_NEW_TYPE] as ScreenUIType;
        this.screenUIType = newScreenUIType;
      }
    })
    this.recommendMenu = RouterUtils.getParams();
  }

  build() {
    Column() {
      LHCommonTitleBar({
        centerTitleText: this.hasRecommendMenu() ? `${res2string($r('app.string.today_s_recommend'))}(${this.recommendMenu?.list?.length})` : $r('app.string.today_s_recommend'),
        leftAction: LHCommonTitleBarLeftBack
      })
      if (this.hasRecommendMenu()) {
        List({
          space: 4
        }) {
          ForEach(this.recommendMenu?.list, (menuItem: RecommendMenuItem, index: number) => {
            ListItem() {
              MenuDetailCard({
                screenUIType: this.screenUIType,
                menuInfo: menuItem,
                style: MenuDetailCardStyle.SQUARE_BANNER
              })
            }
          })
          ListItem() {
            Text($r('app.string.reach_the_bottom'))
              .width('100%')
              .height(`${px2vp(getScreenBottomSafeZoneHeightPx()) + 100}`)
              .textAlign(TextAlign.Center)
              .fontSize(16)
              .fontColor($r('app.color.main_unselected_color'))
              .backgroundColor($r('app.color.main_bg_gray_color'))
          }
        }
        .edgeEffect(EdgeEffect.None)
        .sticky(StickyStyle.Header)
      } else {
        Text($r('app.string.no_recommend_menu_available'))
          .width('100%')
          .height('100')
          .textAlign(TextAlign.Center)
          .fontSize(16)
          .fontColor($r('app.color.main_unselected_color'))
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_bg_gray_color'))
  }

  /**
   * 判断是否有推荐菜谱。
   * @returns 判断结果。
   */
  private hasRecommendMenu(): boolean {
    return this.recommendMenu !== undefined && this.recommendMenu.list !== undefined && this.recommendMenu.list.length > 0;
  }
}