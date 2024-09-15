import { RecommendMenuItem } from '../models/RecommendMenuModel';
import { RouterUtils } from '../utils/common/RouterUtils';
import { ScreenUIType } from '../utils/common/ScreenUIAdapter';
import { FavoriteMenuChangeEventType, FavoriteMenuUtils } from '../utils/FavoriteMenuUtils';
import { LHMarkedStar } from './common/LHMarkedStar';
import { MenuTipsCard } from './MenuTipsCard';
import { componentUtils } from '@kit.ArkUI';

/**
 * 首页 - 菜谱 - 我的收藏。
 * @author li.hao85
 */
@Component
export struct HomeTabMenuFavorite {

  /** 屏幕状态。 */
  @Prop screenUIType: ScreenUIType;

  /** 已收藏的菜谱。 */
  @Prop favoriteMenu: RecommendMenuItem[] | undefined;

  /** 已收藏菜谱内容发生了怎样的改变。 */
  @Prop @Watch('onFavoriteMenuChanged') favoriteMenuChangeEventType: FavoriteMenuChangeEventType | undefined;

  /** 每个小卡片的高。 */
  @State cardHeight: number = -1;

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
                  cardHeight: this.cardHeight,
                  menuInfo: menuItem
                })
                  .id(`${menuItem.id}`)
                  .onSizeChange((_, newSize: SizeOptions) => {
                    this.cardHeight = Math.max(this.cardHeight, newSize.height as number);
                  })
                  .onClick((event: ClickEvent) => RouterUtils.go('pages/menudetail/MenuDetailPage', menuItem))
              }
            })
          }
          .columnsTemplate(this.screenUIType === ScreenUIType.FOLD_OPENED ? '1fr 1fr'
            : this.screenUIType === ScreenUIType.PAD ? '1fr 1fr 1fr'
              : '1fr')
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
            LHMarkedStar({ isSelected: false })
            Text($r('app.string.no_favorite_tips'))
              .fontSize(16)
              .fontColor($r('app.color.main_unselected_color'))
              .textAlign(TextAlign.Center)
            LHMarkedStar({ isSelected: true })
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
        .fontSize(14)
      Blank()
        .layoutWeight(1)
      Text($r('app.string.can_reorder_by_drag'))
        .fontColor($r('app.color.main_selected_color'))
        .fontSize(14)
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
    }
  }
}