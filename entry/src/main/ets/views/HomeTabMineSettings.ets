import { ScreenUIType } from '../utils/common/ScreenUIAdapter';
import { promptAction } from '@kit.ArkUI';
import { res2string } from '../utils/common/Utils';
import { AppSettings } from '../utils/AppSettings';

/**
 * 首页 - 我的 - 应用设置。
 * @author li.hao85
 */
@Component
export struct HomeTabMineSettings {

  /** 屏幕状态。 */
  @Prop screenUIType: ScreenUIType;

  /** 首页序号。 */
  @State firstPage: number = 0;

  aboutToAppear(): void {
    this.firstPage = AppSettings.firstPageIndex();
  }

  build() {
    ListItemGroup({
      header: this.SettingsHeader()
    }) {
      ListItem() {
        Grid() {
          GridItem() { this.FirstPage() }.height(84)
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
  private SettingsHeader() {
    Text($r('app.string.home_tab_mine_settings'))
      .width('100%')
      .height(40)
      .fontSize(16)
      .textAlign(TextAlign.Start)
      .padding({ left: 12, right: 12, top: 4, bottom: 4 })
  }

  @Builder
  private FirstPage() {
    RelativeContainer() {
      Stack({
        alignContent: Alignment.Center
      }) {
        Image(this.firstPage === 0 ? $r('app.media.ic_home_tab_top_news_selected') :
          this.firstPage === 1 ? $r('app.media.ic_home_tab_menu_selected') :
          $r('app.media.ic_home_tab_socialize_selected'))
          .width(32)
          .height(32)
          .margin({ top: 4, right: 4 })
        Image($r('app.media.ic_main_selected_yellow'))
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
      Text(this.firstPage === 0 ? $r('app.string.home_tab_top_news') :
        this.firstPage === 1 ? $r('app.string.home_tab_menu') :
        $r('app.string.home_tab_socialize'))
        .width('100%')
        .fontSize(12)
        .fontColor($r('app.color.main_selected_color'))
        .textAlign(TextAlign.End)
        .padding({ left: 24, right: 24 })
        .alignRules({
          top: {
            anchor: '__container__',
            align: VerticalAlign.Top
          }
        })
      Text($r('app.string.home_tab_mine_settings_first_page'))
        .width('100%')
        .fontSize(12)
        .textAlign(TextAlign.Center)
        .alignRules({
          bottom: {
            anchor: '__container__',
            align: VerticalAlign.Bottom
          }
        })
    }
    .onClick((event: ClickEvent) => {
      this.firstPage = (this.firstPage + 1) % 3;
      AppSettings.setFirstPageIndex(this.firstPage);
      let newFirstPageName: string = res2string(
        this.firstPage === 0 ? $r('app.string.home_tab_top_news') :
          this.firstPage === 1 ? $r('app.string.home_tab_menu') :
          $r('app.string.home_tab_socialize')
      );
      promptAction.showToast({
        message: `${res2string($r('app.string.home_tab_mine_settings_first_page_tips'))}${newFirstPageName}`
      });
    })
  }
}