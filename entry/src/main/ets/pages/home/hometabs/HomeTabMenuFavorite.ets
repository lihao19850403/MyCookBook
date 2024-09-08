import { RecommendMenuItem } from '../../../models/RecommendMenuModel';
import { RouterUtils } from '../../../utils/common/RouterUtils';
import { ScreenUIType } from '../../../utils/common/ScreenUIAdapter';
import { FavoriteMenuUtils } from '../../../utils/FavoriteMenuUtils';
import { LHMarkedStar } from '../../../views/common/LHMarkedStar';
import { MenuTipsCard } from '../../../views/MenuTipsCard';

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

  build() {
    this.Build()
  }

  @Builder
  private Build() {
    ListItemGroup({
      header: this.MyFavoriteMenuHeader()
    }) {
      ListItem() {
        if (this.favoriteMenu !== undefined && this.favoriteMenu.length > 0) {
          Grid() {
            ForEach(this.favoriteMenu, (menuItem: RecommendMenuItem, index: number) => {
              GridItem() {
                MenuTipsCard({
                  menuInfo: menuItem
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
  MyFavoriteMenuHeader() {
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
    MenuTipsCard({ menuInfo: menuItem })
  }
}