import { getScreenUIType, ScreenUIType } from '../utils/common/ScreenUIAdapter';
import { emitter } from '@kit.BasicServicesKit';
import {
  FavoriteMenuChangeEventType,
  FavoriteMenuUtils,
  FAVORITE_MENU_CHANGE_EVENT, FAVORITE_MENU_CHANGE_EVENT_TYPE } from '../utils/FavoriteMenuUtils';
import { GlobalConfig, GLOBAL_CONFIG_KEY_WINDOW } from '../utils/common/GlobalConfig';
import { GLOBAL_CONFIG_FOCUS_ON_FAVORITE_EVENT } from '../pages/home/hometabs/HomeTabMenu';
import { AppSettingsTextSizePlanModel } from '../models/AppSettingsTextSizeModel';
import { CreatedMenuChangeEventType, CreatedMenuUtils, CREATED_MENU_CHANGE_EVENT,
  CREATED_MENU_CHANGE_EVENT_TYPE } from '../utils/CreatedMenuUtils';
import { FlutterIndexPage } from '../flutter/pages/FlutterIndexPage';
import { AppSettings } from '../utils/AppSettings';
import { ScreenObserver, ScreenStatusInfo } from '../utils/common/uiobserver/ScreenObserver';
import {
  GLOBAL_APP_SETTINGS_CHANGED_EVENT,
  GLOBAL_APP_SETTINGS_EVENT_TYPE,
  GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN } from '../utils/common/GlobalAppSettings';
import window from '@ohos.window';

/**
 * 首页 - 我的 - 我的收藏。
 * @author li.hao85
 */
@Component
export struct HomeTabMineFavorite {

  /** 应用文字字号方案。 */
  @Prop appTextSizePlan: AppSettingsTextSizePlanModel;

  /** 是否使用分屏显示。 */
  private isSplitScreen: boolean = AppSettings.isSplitScreen();

  /** 当前屏幕状态信息。 */
  private screenStatus: ScreenStatusInfo | undefined = undefined;

  /** 列数规定。 */
  @State columnsTemplate: string = '';

  /** 已收藏的菜谱数量。 */
  @State favoriteMenuCount: number = 0;

  /** 已创建的菜谱数量。 */
  @State createdMenuCount: number = 0;

  /** 首页标签控制器。 */
  private mainPageTabsController?: TabsController;

  private onFavoriteMenuChangedEvent: Callback<emitter.EventData> = (dataWrap: emitter.EventData) => {
    if (dataWrap.data === undefined) {
      return;
    }
    let eventType: FavoriteMenuChangeEventType = dataWrap.data[FAVORITE_MENU_CHANGE_EVENT_TYPE] as FavoriteMenuChangeEventType;
    if (eventType === FavoriteMenuChangeEventType.ADD_ONE_FAVORITE_MENU || FavoriteMenuChangeEventType.REMOVE_ONE_FAVORITE_MENU) {
      this.favoriteMenuCount = this.calcFavoriteMenuCount();
    }
  };

  private onCreatedMenuChangedEvent: Callback<emitter.EventData> = (dataWrap: emitter.EventData) => {
    if (dataWrap.data === undefined) {
      return;
    }
    let eventType: CreatedMenuChangeEventType = dataWrap.data[CREATED_MENU_CHANGE_EVENT_TYPE] as CreatedMenuChangeEventType;
    if (eventType === CreatedMenuChangeEventType.ADD_ONE_CREATED_MENU || CreatedMenuChangeEventType.REMOVE_ONE_CREATED_MENU || CreatedMenuChangeEventType.REMOVE_SOME_CREATED_MENUS) {
      this.createdMenuCount = this.calcCreatedMenuCount();
    }
  };

  private onSplitScreenChangedEvent: Callback<emitter.EventData> = (dataWrap: emitter.EventData) => {
    if (dataWrap.data) {
      let eventType: string = dataWrap.data[GLOBAL_APP_SETTINGS_EVENT_TYPE] as string;
      switch (eventType) {
        case GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN: {
          this.isSplitScreen = AppSettings.isSplitScreen();
          this.calcColumnTemplate();
        }
          break;
        default:
          break;
      }
    }
  };

  aboutToAppear(): void {
    // 处理已收藏的菜谱数量。
    this.favoriteMenuCount = this.calcFavoriteMenuCount();
    emitter.on(FAVORITE_MENU_CHANGE_EVENT, this.onFavoriteMenuChangedEvent);
    // 处理已创建的菜谱数量。
    this.createdMenuCount = this.calcCreatedMenuCount();
    emitter.on(CREATED_MENU_CHANGE_EVENT, this.onCreatedMenuChangedEvent);

    emitter.on(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onSplitScreenChangedEvent);
    ScreenObserver.subscribe(this.getUIContext(), (screenStatus: ScreenStatusInfo) => {
      this.screenStatus = screenStatus;
      this.calcColumnTemplate();
    });
    this.calcColumnTemplate();
  }

  aboutToDisappear(): void {
    emitter.off(FAVORITE_MENU_CHANGE_EVENT, this.onFavoriteMenuChangedEvent);
    emitter.off(CREATED_MENU_CHANGE_EVENT, this.onCreatedMenuChangedEvent);
    emitter.off(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onSplitScreenChangedEvent);
    ScreenObserver.unsubscribe(this.getUIContext());
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
        .columnsTemplate(this.columnsTemplate)
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
      .backgroundColor(Color.White)
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
        Image($r('app.media.ic_flutter_logo'))
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

  /**
   * 计算列数。
   */
  private calcColumnTemplate() {
    let screenUIType = this.screenStatus?.screenUIType ?? getScreenUIType();
    let windowStatusType = this.screenStatus?.windowStatusType ?? (GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window).getWindowStatus();
    let windowWidthBreakpoint = this.screenStatus?.windowWidthBreakpoint ?? this.getUIContext().getWindowWidthBreakpoint();
    // 计算列数。
    this.columnsTemplate =
      windowStatusType === window.WindowStatusType.FLOATING || windowStatusType === window.WindowStatusType.SPLIT_SCREEN ? (
        this.isSplitScreen ? '1fr 1fr 1fr' :
        screenUIType === ScreenUIType.PAD && windowWidthBreakpoint === WidthBreakpoint.WIDTH_MD ? '1fr 1fr 1fr 1fr 1fr 1fr' :
        screenUIType === ScreenUIType.PAD && windowWidthBreakpoint >= WidthBreakpoint.WIDTH_LG ? '1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr' :
        '1fr 1fr 1fr'
      ) :
      (
        this.isSplitScreen ? '1fr 1fr 1fr' :
        screenUIType === ScreenUIType.FOLD_OPENED ? '1fr 1fr 1fr 1fr 1fr 1fr' :
        screenUIType === ScreenUIType.PAD ? '1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr' :
        '1fr 1fr 1fr'
      );
  }
}