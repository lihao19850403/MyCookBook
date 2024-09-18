import { ScreenUIType } from '../utils/common/ScreenUIAdapter';
import { promptAction } from '@kit.ArkUI';
import { res2string } from '../utils/common/Utils';
import { AppSettings } from '../utils/AppSettings';
import { AppSettingsTextSizePlans } from '../models/AppSettingsTextSizePlan';
import { emitter } from '@kit.BasicServicesKit';
import { GLOBAL_APP_SETTINGS_CHANGED_EVENT,
  GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN,
  GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN } from '../utils/common/GlobalAppSettings';
import { AppSettingsTextSizePlanModel } from '../models/AppSettingsTextSizeModel';

/**
 * 首页 - 我的 - 应用设置。
 * @author li.hao85
 */
@Component
export struct HomeTabMineSettings {

  /** 屏幕状态。 */
  @Prop screenUIType: ScreenUIType;

  /** 应用文字字号方案。 */
  @Prop appTextSizePlan: AppSettingsTextSizePlanModel;

  /** 首页序号。 */
  @State firstPage: number = 0;

  /** 应用字号方案ID。 */
  @State textSizePlanID: number = AppSettingsTextSizePlans.SMALL.id;

  /** 是否使用分屏显示。 */
  @State isSplitScreen: boolean = false;

  aboutToAppear(): void {
    this.firstPage = AppSettings.firstPageIndex();
    this.textSizePlanID = AppSettings.textSizePlan().id;
    this.isSplitScreen = AppSettings.isSplitScreen();
  }

  build() {
    ListItemGroup({
      header: this.SettingsHeader()
    }) {
      ListItem() {
        Grid() {
          GridItem() { this.FirstPage() }.height(84)
          GridItem() { this.TextSize() }.height(84)
          GridItem() { this.SplitScreen() }.height(84)
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
      .fontSize(this.appTextSizePlan.homeTabMineSubTitleTextSize)
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
      Text($r("app.string.home_tab_mine_settings_first_page_tips"))
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
      this.firstPage = (this.firstPage + 1) % 3;
      AppSettings.setFirstPageIndex(this.firstPage);
      let newFirstPageName: string = res2string(
        this.firstPage === 0 ? $r('app.string.home_tab_top_news') :
          this.firstPage === 1 ? $r('app.string.home_tab_menu') :
          $r('app.string.home_tab_socialize')
      );
      promptAction.showToast({
        message: `${res2string($r("app.string.home_tab_mine_settings_first_page_toast"))}${newFirstPageName}`
      });
    })
  }

  @Builder
  private TextSize() {
    RelativeContainer() {
      Stack({
        alignContent: Alignment.Center
      }) {
        Image($r('app.media.ic_magnifier_green'))
          .width(34)
          .height(34)
        Text(this.textSizePlanID === AppSettingsTextSizePlans.SMALL.id ? $r('app.string.home_tab_mine_settings_text_size_small_tips') :
          this.textSizePlanID === AppSettingsTextSizePlans.NORMAL.id ? $r('app.string.home_tab_mine_settings_text_size_normal_tips') :
          this.textSizePlanID === AppSettingsTextSizePlans.BIG.id ? $r('app.string.home_tab_mine_settings_text_size_big_tips') :
          $r('app.string.home_tab_mine_settings_text_size_huge_pic'))
          .fontSize(this.appTextSizePlan.homeTabMineSettingsTipsTextSize)
          .fontColor($r('app.color.main_selected_color'))
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
      Text(this.textSizePlanID === AppSettingsTextSizePlans.SMALL.id ? $r('app.string.home_tab_mine_settings_text_size_small_tips') :
        this.textSizePlanID === AppSettingsTextSizePlans.NORMAL.id ? $r('app.string.home_tab_mine_settings_text_size_normal_tips') :
        this.textSizePlanID === AppSettingsTextSizePlans.BIG.id ? $r('app.string.home_tab_mine_settings_text_size_big_tips') :
        $r('app.string.home_tab_mine_settings_text_size_huge_tips'))
        .width('100%')
        .fontSize(this.appTextSizePlan.homeTabMineSettingsTitleTextSize)
        .fontColor($r('app.color.main_selected_color'))
        .textAlign(TextAlign.End)
        .padding({ left: 24, right: 24 })
        .alignRules({
          top: {
            anchor: '__container__',
            align: VerticalAlign.Top
          }
        })
      Text($r("app.string.home_tab_mine_settings_text_size_tips"))
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
      this.textSizePlanID = (this.textSizePlanID + 1) % 4;
      AppSettings.setTextSizePlanByID(this.textSizePlanID);
      let dataWrap: emitter.EventData = {};
      dataWrap.data = {
        GLOBAL_APP_SETTINGS_EVENT_TYPE: GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN
      };
      emitter.emit(GLOBAL_APP_SETTINGS_CHANGED_EVENT, dataWrap);
    })
  }

  @Builder
  private SplitScreen() {
    RelativeContainer() {
      Stack({
        alignContent: Alignment.Center
      }) {
        Image(this.isSplitScreen ?
          (this.screenUIType === ScreenUIType.PAD ? $r('app.media.ic_screen_ui_type_pad') : $r('app.media.ic_screen_ui_type_fold_opened')) :
          $r('app.media.ic_screen_ui_type_normal'))
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
      Text(this.isSplitScreen ? $r('app.string.home_tab_mine_settings_split_screen_on_tips') :
          $r('app.string.home_tab_mine_settings_split_screen_off_tips'))
        .width('100%')
        .fontSize(this.appTextSizePlan.homeTabMineSettingsTitleTextSize)
        .fontColor($r('app.color.main_selected_color'))
        .textAlign(TextAlign.End)
        .padding({ left: 24, right: 24 })
        .alignRules({
          top: {
            anchor: '__container__',
            align: VerticalAlign.Top
          }
        })
      Text($r("app.string.home_tab_mine_settings_split_screen_tips"))
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
      this.isSplitScreen = !this.isSplitScreen;
      AppSettings.setIsSplitScreen(this.isSplitScreen);
      let dataWrap: emitter.EventData = {};
      dataWrap.data = {
        GLOBAL_APP_SETTINGS_EVENT_TYPE: GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN
      };
      emitter.emit(GLOBAL_APP_SETTINGS_CHANGED_EVENT, dataWrap);
    })
  }
}