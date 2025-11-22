import { RecommendMenuItem } from '../models/RecommendMenuModel';
import { getScreenUIType, ScreenUIType } from '../utils/common/ScreenUIAdapter';
import { FavoriteMenuChangeEventType, FavoriteMenuUtils } from '../utils/FavoriteMenuUtils';
import { LHMarkedStar } from './common/LHMarkedStar';
import { MenuTipsCard } from './MenuTipsCard';
import { componentUtils, window } from '@kit.ArkUI';
import { AppSettingsTextSizePlanModel } from '../models/AppSettingsTextSizeModel';
import { MenuDetailPage } from '../pages/menudetail/MenuDetailPage';
import { GlobalConfig, GLOBAL_CONFIG_KEY_WINDOW } from '../utils/common/GlobalConfig';
import { AppSettings } from '../utils/AppSettings';
import { ScreenObserver, ScreenStatusInfo } from '../utils/common/uiobserver/ScreenObserver';
import emitter from '@ohos.events.emitter';
import {
  GLOBAL_APP_SETTINGS_CHANGED_EVENT,
  GLOBAL_APP_SETTINGS_EVENT_TYPE,
  GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN } from '../utils/common/GlobalAppSettings';

/**
 * 首页 - 菜谱 - 我的收藏。
 * @author li.hao85
 */
@Component
export struct HomeTabMenuFavorite {

  /** 应用文字字号方案。 */
  @Prop @Watch('onAppTextSizePlanChanged') appTextSizePlan: AppSettingsTextSizePlanModel;

  /** 是否使用分屏显示。 */
  private isSplitScreen: boolean = AppSettings.isSplitScreen();

  /** 当前屏幕状态信息。 */
  private screenStatus: ScreenStatusInfo | undefined = undefined;

  /** 列数规定。 */
  @State columnsTemplate: string = '';

  /** 已收藏的菜谱。 */
  @Prop favoriteMenu: RecommendMenuItem[] | undefined;

  /** 已收藏菜谱内容发生了怎样的改变。 */
  @Link @Watch('onFavoriteMenuChanged') favoriteMenuChangeEventType: FavoriteMenuChangeEventType | undefined;

  /** 每个小卡片的高。 */
  @State cardHeight: number = -1;

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
    emitter.on(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onSplitScreenChangedEvent);
    ScreenObserver.subscribe(this.getUIContext(), (screenStatus: ScreenStatusInfo) => {
      this.screenStatus = screenStatus;
      this.calcColumnTemplate();
    });
    this.calcColumnTemplate();
  }

  aboutToDisappear(): void {
    emitter.off(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onSplitScreenChangedEvent);
    ScreenObserver.unsubscribe(this.getUIContext());
  }

  build() {
    ListItemGroup({
      header: this.MyFavoriteMenuHeader()
    }) {
      ListItem() {
        if (this.favoriteMenu !== undefined && this.favoriteMenu.length > 0) {
          Grid() {
            ForEach(this.favoriteMenu, (menuItem: RecommendMenuItem, index: number) => {
              GridItem() {
                MenuTipsCard({
                  appTextSizePlan: this.appTextSizePlan,
                  cardHeight: this.cardHeight,
                  menuInfo: menuItem
                })
                  .id(`${menuItem.id}`)
                  .onSizeChange((_, newSize: SizeOptions) => {
                    this.cardHeight = Math.max(this.cardHeight, newSize.height as number);
                  })
                  .onClick((event: ClickEvent) => MenuDetailPage.go(menuItem))
              }
            })
          }
          .columnsTemplate(this.columnsTemplate)
          .columnsGap(4)
          .rowsGap(4)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .edgeEffect(EdgeEffect.None)
          .scrollBar(BarState.Off)
          .editMode(true)
          .supportAnimation(true)
          .onItemDragStart((event: ItemDragInfo, itemIndex: number) => {
            return this.DragThumbnail(this.favoriteMenu![itemIndex]);
          })
          .onItemDrop((event: ItemDragInfo, itemIndex: number, insertIndex: number, isSuccess: boolean) => {
            if (this.favoriteMenu === undefined || !isSuccess || insertIndex >= this.favoriteMenu.length) {
              return;
            }
            // 交换菜单顺序。
            let tempMenu: RecommendMenuItem = this.favoriteMenu[itemIndex];
            if (itemIndex > insertIndex) {
              this.favoriteMenu.splice(insertIndex, 0, tempMenu);
              this.favoriteMenu.splice(itemIndex + 1, 1);
            } else {
              this.favoriteMenu.splice(insertIndex + 1, 0, tempMenu);
              this.favoriteMenu.splice(itemIndex, 1);
            }
            // 将新顺序记录到配置文件。
            let newOrder: Array<number> = [];
            this.favoriteMenu.forEach((menuItem: RecommendMenuItem) => {
              if (menuItem.id !== undefined) {
                newOrder.push(menuItem.id);
              }
            })
            FavoriteMenuUtils.updateFavoriteOrder(newOrder);
          })
        } else {
          Row() {
            LHMarkedStar({ isSelected: false, isEnabled: false })
            Text($r('app.string.no_favorite_tips'))
              .fontSize(this.appTextSizePlan.homeTabMenuGrayTextSize)
              .fontColor($r('app.color.main_unselected_color'))
              .textAlign(TextAlign.Center)
            LHMarkedStar({ isSelected: true, isEnabled: false })
          }
          .width('100%')
          .height(100)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }
      }
    }
  }

  @Builder
  private MyFavoriteMenuHeader() {
    Row() {
      Text($r('app.string.my_favorite'))
        .fontSize(this.appTextSizePlan.homeTabMenuSubTitleTextSize)
      Blank()
        .layoutWeight(1)
      Text($r('app.string.can_reorder_by_drag'))
        .fontColor($r('app.color.main_selected_color'))
        .fontSize(this.appTextSizePlan.homeTabMenuSubTitleTextSize)
        .visibility(this.favoriteMenu !== undefined && this.favoriteMenu.length > 0 ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height(32)
    .backgroundColor($r('app.color.main_bg_green_light_color'))
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 12, right: 12, top: 4, bottom: 4 })
  }

  @Builder
  private DragThumbnail(menuItem: RecommendMenuItem) {
    MenuTipsCard({
      appTextSizePlan: this.appTextSizePlan,
      cardHeight: this.cardHeight,
      menuInfo: menuItem
    })
      .width(this.calcMenuTipsCardWidth(menuItem))
  }

  /**
   * 计算小卡片宽度。用于拖拽时显示缩略图。
   * @returns 小卡片宽度。
   */
  private calcMenuTipsCardWidth(menuItem: RecommendMenuItem): number {
    let menuTipsCardInfo: componentUtils.ComponentInfo = componentUtils.getRectangleById(`${menuItem.id}`);
    return px2vp(menuTipsCardInfo.size.width);
  }

  /**
   * 当收藏的菜谱内容发生变化(增加或删除)时，触发小卡片尺寸的重新计算。
   * 如果仅收藏的菜谱顺序改变，那么不需要重新计算小卡片尺寸。
   */
  onFavoriteMenuChanged() {
    if (this.favoriteMenuChangeEventType === FavoriteMenuChangeEventType.ADD_ONE_FAVORITE_MENU
      || this.favoriteMenuChangeEventType === FavoriteMenuChangeEventType.REMOVE_ONE_FAVORITE_MENU) {
      this.cardHeight = -1;
      this.favoriteMenuChangeEventType = undefined; // 重新计算小卡片尺寸后，将此事件类型置为undefined，以便下次继续更新。
    }
  }

  /** 当字号设置方案变化时，设置cardHeight为-1，重新计算卡片的高度。 */
  onAppTextSizePlanChanged() {
    this.cardHeight = -1;
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
        this.isSplitScreen ? '1fr' :
        screenUIType === ScreenUIType.PAD && windowWidthBreakpoint === WidthBreakpoint.WIDTH_MD ? '1fr 1fr' :
        screenUIType === ScreenUIType.PAD && windowWidthBreakpoint >= WidthBreakpoint.WIDTH_LG ? '1fr 1fr 1fr' :
        '1fr'
      ) :
      (
        this.isSplitScreen ? '1fr' :
        screenUIType === ScreenUIType.FOLD_OPENED ? '1fr 1fr' :
        screenUIType === ScreenUIType.PAD ? '1fr 1fr 1fr' :
        '1fr'
      );
  }
}