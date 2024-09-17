import { ScreenUIType } from '../utils/common/ScreenUIAdapter';
import { emitter } from '@kit.BasicServicesKit';
import {
  FavoriteMenuChangeEventType,
  FavoriteMenuUtils,
  FAVORITE_MENU_CHANGE_EVENT, FAVORITE_MENU_CHANGE_EVENT_TYPE } from '../utils/FavoriteMenuUtils';
import { GlobalConfig } from '../utils/common/GlobalConfig';
import { GLOBAL_CONFIG_FOCUS_ON_FAVORITE_EVENT } from '../pages/home/hometabs/HomeTabMenu';
import { AppSettingsTextSizePlanModel } from '../models/AppSettingsTextSizeModel';

/**
 * 首页 - 我的 - 我的收藏。
 * @author li.hao85
 */
@Component
export struct HomeTabMineFavorite {

  /** 屏幕状态。 */
  @Prop screenUIType: ScreenUIType;

  /** 应用文字字号方案。 */
  @Prop appTextSizePlan: AppSettingsTextSizePlanModel;

  /** 已收藏的菜谱数量。 */
  @State favoriteMenuCount: number = 0;

  /** 首页标签控制器。 */
  private mainPageTabsController?: TabsController;

  aboutToAppear(): void {
    this.favoriteMenuCount = this.calcFavoriteMenuCount();
    emitter.on(FAVORITE_MENU_CHANGE_EVENT, (dataWrap: emitter.EventData) => {
      if (dataWrap.data === undefined) {
        return;
      }
      let eventType: FavoriteMenuChangeEventType = dataWrap.data[FAVORITE_MENU_CHANGE_EVENT_TYPE] as FavoriteMenuChangeEventType;
      if (eventType === FavoriteMenuChangeEventType.ADD_ONE_FAVORITE_MENU || FavoriteMenuChangeEventType.REMOVE_ONE_FAVORITE_MENU) {
        this.favoriteMenuCount = this.calcFavoriteMenuCount();
      }
    });
  }

  build() {
    ListItemGroup({
      header: this.FavoriteHeader()
    }) {
      ListItem() {
        Grid() {
          GridItem() { this.FavoriteMenu() }.height(84)
        }
        .columnsTemplate(this.screenUIType === ScreenUIType.FOLD_OPENED ? '1fr 1fr 1fr 1fr 1fr 1fr'
          : this.screenUIType === ScreenUIType.PAD ? '1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr'
            : '1fr 1fr 1fr')
        .columnsGap(4)
        .rowsGap(4)
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .edgeEffect(EdgeEffect.None)
        .scrollBar(BarState.Off)
      }
    }
  }

  @Builder
  private FavoriteHeader() {
    Text($r('app.string.home_tab_mine_favorite'))
      .width('100%')
      .height(40)
      .fontSize(this.appTextSizePlan.homeTabMineSubTitleTextSize)
      .textAlign(TextAlign.Start)
      .padding({ left: 12, right: 12, top: 4, bottom: 4 })
  }

  @Builder
  private FavoriteMenu() {
    RelativeContainer() {
      Stack({
        alignContent: Alignment.Center
      }) {
        Image($r('app.media.ic_home_tab_menu_selected'))
          .width(32)
          .height(32)
          .margin({ top: 4, right: 4 })
        Image($r('app.media.ic_star_gold'))
          .width(18)
          .height(18)
          .margin({ left: 18, bottom: 18 })
      }
      .width(36)
      .height(36)
      .alignRules({
        center: {
          anchor: '__container__',
          align: VerticalAlign.Center
        },
        middle: {
          anchor: '__container__',
          align: HorizontalAlign.Center
        }
      })
      Text(`${this.favoriteMenuCount >= 1000 ? '999+' : this.favoriteMenuCount}`)
        .width('100%')
        .fontSize(this.appTextSizePlan.homeTabMineSettingsTipsTextSize)
        .fontColor($r('app.color.main_selected_color'))
        .textAlign(TextAlign.End)
        .padding({ left: 24, right: 24 })
        .alignRules({
          top: {
            anchor: '__container__',
            align: VerticalAlign.Top
          }
        })
      Text($r('app.string.home_tab_mine_favorite_menu_tips'))
        .width('100%')
        .fontSize(this.appTextSizePlan.homeTabMineSettingsTitleTextSize)
        .textAlign(TextAlign.Center)
        .alignRules({
          bottom: {
            anchor: '__container__',
            align: VerticalAlign.Bottom
          }
        })
    }
    .onClick((event: ClickEvent) => {
      if (this.mainPageTabsController !== undefined) {
        GlobalConfig.set(GLOBAL_CONFIG_FOCUS_ON_FAVORITE_EVENT, true);
        this.mainPageTabsController.changeIndex(1);
      }
    })
  }

  /**
   * 计算已收藏了多少菜谱。
   * @returns 计算结果。
   */
  private calcFavoriteMenuCount(): number {
    let order: Array<number> | undefined = FavoriteMenuUtils.queryFavoriteOrder();
    return order === undefined ? 0 : order.length;
  }
}