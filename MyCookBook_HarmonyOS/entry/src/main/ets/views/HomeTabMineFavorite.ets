import { ScreenUIType } from '../utils/common/ScreenUIAdapter';
import { emitter } from '@kit.BasicServicesKit';
import {
  FavoriteMenuChangeEventType,
  FavoriteMenuUtils,
  FAVORITE_MENU_CHANGE_EVENT, FAVORITE_MENU_CHANGE_EVENT_TYPE } from '../utils/FavoriteMenuUtils';
import { GlobalConfig } from '../utils/common/GlobalConfig';
import { GLOBAL_CONFIG_FOCUS_ON_FAVORITE_EVENT } from '../pages/home/hometabs/HomeTabMenu';
import { AppSettingsTextSizePlanModel } from '../models/AppSettingsTextSizeModel';
import { CreatedMenuChangeEventType, CreatedMenuUtils, CREATED_MENU_CHANGE_EVENT,
  CREATED_MENU_CHANGE_EVENT_TYPE } from '../utils/CreatedMenuUtils';
import { FlutterIndexPage } from '../flutter/pages/FlutterIndexPage';

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

  /** 是否使用分屏显示。 */
  @Prop isSplitScreen: boolean;

  /** 已收藏的菜谱数量。 */
  @State favoriteMenuCount: number = 0;

  /** 已创建的菜谱数量。 */
  @State createdMenuCount: number = 0;

  /** 首页标签控制器。 */
  private mainPageTabsController?: TabsController;

  aboutToAppear(): void {
    // 处理已收藏的菜谱数量。
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
    // 处理已创建的菜谱数量。
    this.createdMenuCount = this.calcCreatedMenuCount();
    emitter.on(CREATED_MENU_CHANGE_EVENT, (dataWrap: emitter.EventData) => {
      if (dataWrap.data === undefined) {
        return;
      }
      let eventType: CreatedMenuChangeEventType = dataWrap.data[CREATED_MENU_CHANGE_EVENT_TYPE] as CreatedMenuChangeEventType;
      if (eventType === CreatedMenuChangeEventType.ADD_ONE_CREATED_MENU || CreatedMenuChangeEventType.REMOVE_ONE_CREATED_MENU) {
        this.createdMenuCount = this.calcCreatedMenuCount();
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
          GridItem() { this.CreateMenu() }.height(84)
        }
        .columnsTemplate(this.isSplitScreen ? '1fr 1fr 1fr' :
          this.screenUIType === ScreenUIType.FOLD_OPENED ? '1fr 1fr 1fr 1fr 1fr 1fr' :
          this.screenUIType === ScreenUIType.PAD ? '1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr' :
          '1fr 1fr 1fr')
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
    .border({
      width: { right: 0.3 },
      color: $r('app.color.main_selected_color')
    })
    .onClick((event: ClickEvent) => {
      if (this.mainPageTabsController !== undefined) {
        GlobalConfig.set(GLOBAL_CONFIG_FOCUS_ON_FAVORITE_EVENT, true);
        this.mainPageTabsController.changeIndex(1);
      }
    })
  }

  @Builder
  private CreateMenu() {
    RelativeContainer() {
      Stack({
        alignContent: Alignment.Center
      }) {
        Image($r('app.media.ic_create_menu'))
          .width(34)
          .height(34)
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
      Text(`${this.createdMenuCount >= 1000 ? '999+' : this.createdMenuCount}`)
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
      Text($r('app.string.home_tab_mine_create_menu_tips'))
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
    .onClick((event: ClickEvent) => FlutterIndexPage.go({path: 'CreateMenu'}))
  }

  /**
   * 计算已收藏了多少菜谱。
   * @returns 计算结果。
   */
  private calcFavoriteMenuCount(): number {
    let order: Array<number> | undefined = FavoriteMenuUtils.queryFavoriteOrder();
    return order === undefined ? 0 : order.length;
  }

  /**
   * 计算已创建了多少菜谱。
   * @returns 计算结果。
   */
  private calcCreatedMenuCount(): number {
    let order: Array<number> | undefined = CreatedMenuUtils.queryCreatedOrder();
    return order === undefined ? 0 : order.length;
  }
}