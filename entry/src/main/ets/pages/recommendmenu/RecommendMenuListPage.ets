import {
  getScreenBottomSafeZoneHeightPx,
  getScreenUIType, ScreenUIType, SCREEN_UI_CHANGE_EVENT, SCREEN_UI_NEW_TYPE } from '../../utils/common/ScreenUIAdapter';
import { emitter } from '@kit.BasicServicesKit';
import { LHCommonTitleBar, LHCommonTitleBarLeftBack } from '../../views/common/LHCommonTitleBar';
import { RecommendMenuItem, RecommendMenuResult } from '../../models/RecommendMenuModel';
import { RouterUtils } from '../../utils/common/RouterUtils';
import { MenuDetailCard, MenuDetailCardStyle } from '../../views/MenuDetailCard';
import { res2string } from '../../utils/common/Utils';
import { LengthMetrics } from '@kit.ArkUI';
import { LHMarkedStar } from '../../views/common/LHMarkedStar';
import { FavoriteMenuUtils } from '../../utils/FavoriteMenuUtils';
import { AppSettingsTextSizePlanModel } from '../../models/AppSettingsTextSizeModel';
import { AppSettingsTextSizePlans } from '../../models/AppSettingsTextSizePlan';
import { AppSettings } from '../../utils/AppSettings';
import { GLOBAL_APP_SETTINGS_CHANGED_EVENT } from '../../utils/common/GlobalAppSettings';

/**
 * 今日推荐菜谱页。
 * @author li.hao85
 */
@Entry
@Component
struct RecommendMenuListPage {

  /** 屏幕状态。 */
  @State screenUIType: ScreenUIType = getScreenUIType();

  /** 应用文字字号方案。 */
  @State appTextSizePlan: AppSettingsTextSizePlanModel = AppSettingsTextSizePlans.SMALL;

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
    this.appTextSizePlan = AppSettings.textSizePlan();
    emitter.on(GLOBAL_APP_SETTINGS_CHANGED_EVENT, (dataWrap: emitter.EventData) => {
      this.appTextSizePlan = AppSettings.textSizePlan();
    });
  }

  build() {
    Column() {
      LHCommonTitleBar({
        centerTitleText: this.hasRecommendMenu() ? `${res2string($r('app.string.today_s_recommend'))}(${this.recommendMenu?.list?.length})` : $r('app.string.today_s_recommend'),
        centerTitleTextSize: this.appTextSizePlan.unifiedTitleCenterTextSize,
        leftAction: LHCommonTitleBarLeftBack
      })
      if (this.hasRecommendMenu()) {
        List({
          space: 4
        }) {
          ForEach(this.recommendMenu?.list, (menuItem: RecommendMenuItem, index: number) => {
            ListItem() {
              Stack({
                alignContent: Alignment.Top
              }) {
                MenuDetailCard({
                  screenUIType: this.screenUIType,
                  appTextSizePlan: this.appTextSizePlan,
                  menuInfo: menuItem,
                  style: MenuDetailCardStyle.SQUARE_BANNER
                })
                Row() {
                  Text(`${index + 1}`)
                    .width(35)
                    .height(35)
                    .textAlign(TextAlign.Start)
                    .fontColor(Color.White)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .padding({ left: 5 })
                    .backgroundColor($r('app.color.menu_index_bg_color'))
                    .borderRadius({ bottomEnd: LengthMetrics.vp(35) })
                  LHMarkedStar({
                    isSelected: menuItem.id !== undefined && FavoriteMenuUtils.isFavoriteMenu(menuItem.id),
                    onSelectedChanged: (newStatus: boolean) => {
                      if (menuItem.id !== undefined) {
                        if (newStatus) {
                          FavoriteMenuUtils.addOneFavoriteMenu(menuItem);
                        } else {
                          FavoriteMenuUtils.removeOneFavoriteMenu(menuItem.id);
                        }
                      }
                    }
                  })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(VerticalAlign.Center)
              }
            }
          })
          ListItem() {
            Text($r('app.string.reach_the_bottom'))
              .width('100%')
              .height(`${px2vp(getScreenBottomSafeZoneHeightPx()) + 100}`)
              .textAlign(TextAlign.Center)
              .fontSize(this.appTextSizePlan.homeTabMenuGrayTextSize)
              .fontColor($r('app.color.main_unselected_color'))
              .backgroundColor($r('app.color.main_bg_gray_color'))
          }
        }
        .width('100%')
        .height('100%')
        .edgeEffect(EdgeEffect.None)
        .sticky(StickyStyle.Header)
        .scrollBar(BarState.Off)
      } else {
        Text($r('app.string.no_recommend_menu_available'))
          .width('100%')
          .height('100')
          .textAlign(TextAlign.Center)
          .fontSize(this.appTextSizePlan.homeTabMenuGrayTextSize)
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