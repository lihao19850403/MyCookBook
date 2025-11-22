import { getScreenUIType, ScreenUIType } from '../utils/common/ScreenUIAdapter';
import { AppSettings } from '../utils/AppSettings';
import { AppSettingsTextSizePlans } from '../models/AppSettingsTextSizePlan';
import { emitter } from '@kit.BasicServicesKit';
import { GLOBAL_APP_SETTINGS_CHANGED_EVENT,
  GLOBAL_APP_SETTINGS_EVENT_TYPE,
  GLOBAL_APP_SETTINGS_KEY_FIRST_PAGE_INDEX,
  GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN,
  GLOBAL_APP_SETTINGS_KEY_TEXT_SIZE_PLAN } from '../utils/common/GlobalAppSettings';
import { AppSettingsTextSizePlanModel } from '../models/AppSettingsTextSizeModel';
import { ScreenObserver, ScreenStatusInfo } from '../utils/common/uiobserver/ScreenObserver';
import { GlobalConfig, GLOBAL_CONFIG_KEY_WINDOW } from '../utils/common/GlobalConfig';
import window from '@ohos.window';

/**
 * 首页 - 我的 - 应用设置。
 * @author li.hao85
 */
@Component
export struct HomeTabMineSettings {

  /** 应用文字字号方案。 */
  @Prop appTextSizePlan: AppSettingsTextSizePlanModel;

  /** 是否使用分屏显示。 */
  private isSplitScreen: boolean = AppSettings.isSplitScreen();

  /** 当前屏幕状态信息。 */
  private screenStatus: ScreenStatusInfo | undefined = undefined;

  /** 列数规定。 */
  @State columnsTemplate: string = '';

  /** 分屏模式图标。 */
  @State splitIcon: Resource = $r('app.media.ic_screen_ui_type_normal');

  /** 首页序号。 */
  @State firstPageIndex: number = 0;

  /** 应用字号方案ID。 */
  @State textSizePlanID: number = AppSettingsTextSizePlans.SMALL.id;

  private onSplitScreenChangedEvent: Callback<emitter.EventData> = (dataWrap: emitter.EventData) => {
    if (dataWrap.data) {
      let eventType: string = dataWrap.data[GLOBAL_APP_SETTINGS_EVENT_TYPE] as string;
      switch (eventType) {
        case GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN: {
          this.isSplitScreen = AppSettings.isSplitScreen();
          this.calcColumnTemplateAndIcon();
        }
          break;
        default:
          break;
      }
    }
  };

  aboutToAppear(): void {
    this.firstPageIndex = AppSettings.firstPageIndex();
    this.textSizePlanID = AppSettings.textSizePlan().id;
    this.isSplitScreen = AppSettings.isSplitScreen();
    emitter.on(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onSplitScreenChangedEvent);
    ScreenObserver.subscribe(this.getUIContext(), (screenStatus: ScreenStatusInfo) => {
      this.screenStatus = screenStatus;
      this.calcColumnTemplateAndIcon();
    });
    this.calcColumnTemplateAndIcon();
  }

  aboutToDisappear(): void {
    emitter.off(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onSplitScreenChangedEvent);
    ScreenObserver.unsubscribe(this.getUIContext());
  }

  build() {
    ListItemGroup({
      header: this.SettingsHeader()
    }) {
      ListItem() {
        Grid() {
          GridItem() { this.FirstPageIndex() }.height(84)
          GridItem() { this.TextSize() }.height(84)
          GridItem() { this.SplitScreen() }.height(84)
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
  private SettingsHeader() {
    Text($r('app.string.home_tab_mine_settings'))
      .width('100%')
      .height(40)
      .fontSize(this.appTextSizePlan.homeTabMineSubTitleTextSize)
      .textAlign(TextAlign.Start)
      .padding({ left: 12, right: 12, top: 4, bottom: 4 })
      .backgroundColor(Color.White)
  }

  @Builder
  private FirstPageIndex() {
    RelativeContainer() {
      Stack({
        alignContent: Alignment.Center
      }) {
        Image(this.firstPageIndex === 0 ? $r('app.media.ic_home_tab_top_news_selected') :
          this.firstPageIndex === 1 ? $r('app.media.ic_home_tab_menu_selected') :
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
      Text(this.firstPageIndex === 0 ? $r('app.string.home_tab_top_news') :
        this.firstPageIndex === 1 ? $r('app.string.home_tab_menu') :
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
      Text($r('app.string.home_tab_mine_settings_first_page_tips'))
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
      this.firstPageIndex = (this.firstPageIndex + 1) % 3;
      AppSettings.setFirstPageIndex(this.firstPageIndex);
      let dataWrap: emitter.EventData = {};
      dataWrap.data = {
        GLOBAL_APP_SETTINGS_EVENT_TYPE: GLOBAL_APP_SETTINGS_KEY_FIRST_PAGE_INDEX
      };
      emitter.emit(GLOBAL_APP_SETTINGS_CHANGED_EVENT, dataWrap);
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
      Text($r('app.string.home_tab_mine_settings_text_size_tips'))
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
        Image(this.splitIcon)
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
      Text($r('app.string.home_tab_mine_settings_split_screen_tips'))
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

  /**
   * 计算列数和分屏图标。
   */
  private calcColumnTemplateAndIcon() {
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
    // 计算分屏图标。
    this.splitIcon =
      this.isSplitScreen ?
      (screenUIType === ScreenUIType.PAD ? $r('app.media.ic_screen_ui_type_pad') : $r('app.media.ic_screen_ui_type_fold_opened')) :
      $r('app.media.ic_screen_ui_type_normal')
  }
}