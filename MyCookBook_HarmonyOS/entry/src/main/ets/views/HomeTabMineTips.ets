import { CallResult, HttpUtils } from '../utils/common/HttpUtils';
import { KeysUtils } from '../utils/common/KeysUtils';
import { getScreenUIType, ScreenUIType } from '../utils/common/ScreenUIAdapter';
import { TodayTipsModel, TodayTipsResult } from '../models/TodayTipsModel';
import { KVUtils } from '../utils/common/KVUtils';
import { LengthMetrics } from '@ohos.arkui.node';
import { AppSettingsTextSizePlanModel } from '../models/AppSettingsTextSizeModel';
import { readRawFileSync } from '../utils/common//filecenter/FileUtils';
import { AppSettings } from '../utils/AppSettings';
import { ScreenObserver, ScreenStatusInfo } from '../utils/common/uiobserver/ScreenObserver';
import emitter from '@ohos.events.emitter';
import {
  GLOBAL_APP_SETTINGS_CHANGED_EVENT,
  GLOBAL_APP_SETTINGS_EVENT_TYPE,
  GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN } from '../utils/common/GlobalAppSettings';
import { GlobalConfig, GLOBAL_CONFIG_KEY_WINDOW } from '../utils/common/GlobalConfig';
import window from '@ohos.window';

/** 每日养生请求key。 */
const KEY_HOME_TAB_MINE_TIPS_REQUEST: string = 'home_tab_mine_tips_request';

/** 每日养生配置文件名。 */
const FILE_NAME_MINE_TIPS: string = 'mine_tips';

/** 每日养生模拟数据文件名。 */
const FILE_NAME_MOCK_DATA: string = 'home_tab_mine_tips_mock.json5';

/**
 * 首页 - 我的 - 每日养生。
 * @author li.hao85
 */
@Component
export struct HomeTabMineTips {

  /** 应用文字字号方案。 */
  @Prop appTextSizePlan: AppSettingsTextSizePlanModel;

  /** 是否使用分屏显示。 */
  private isSplitScreen: boolean = AppSettings.isSplitScreen();

  /** 当前屏幕状态信息。 */
  private screenStatus: ScreenStatusInfo | undefined = undefined;

  /** 内容宽度。 */
  @State contentWidth: string | number | undefined = undefined;

  /** 是否正在加载每日养生。 */
  @State isLoadingTips: boolean = true;

  /** 今日养生提示。 */
  @State todayTips: string | undefined = undefined;

  /** 今日日期(作为key)。 */
  private today: string = new Date().toLocaleDateString();

  private onSplitScreenChangedEvent: Callback<emitter.EventData> = (dataWrap: emitter.EventData) => {
    if (dataWrap.data) {
      let eventType: string = dataWrap.data[GLOBAL_APP_SETTINGS_EVENT_TYPE] as string;
      switch (eventType) {
        case GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN: {
          this.isSplitScreen = AppSettings.isSplitScreen();
          this.calcContentWidth();
        }
          break;
        default:
          break;
      }
    }
  };

  aboutToAppear(): void {
    if (!KVUtils.hasKV(FILE_NAME_MINE_TIPS, this.today)) { // 每日养生提示。
      this.apiLoadTodayTips();
    } else { // 今日已有养生提示，使用已保存的数据。
      let todayTipsStr: string = KVUtils.queryKV(FILE_NAME_MINE_TIPS, this.today) as string;
      let todayTipsObject: TodayTipsResult = JSON.parse(todayTipsStr) as TodayTipsResult;
      this.todayTips = todayTipsObject.content;
      this.isLoadingTips = false;
    }
    emitter.on(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onSplitScreenChangedEvent);
    ScreenObserver.subscribe(this.getUIContext(), (screenStatus: ScreenStatusInfo) => {
      this.screenStatus = screenStatus;
      this.calcContentWidth();
    });
    this.calcContentWidth();
  }

  aboutToDisappear(): void {
    emitter.off(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onSplitScreenChangedEvent);
    ScreenObserver.unsubscribe(this.getUIContext());
  }

  build() {
    ListItemGroup({
      header: this.TipsHeader()
    }) {
      ListItem() {
        Stack({
          alignContent: Alignment.Center
        }) {
          Text(this.todayTips)
            .width(this.contentWidth)
            .constraintSize({
              minHeight: 100
            })
            .textAlign(TextAlign.Start)
            .fontSize(this.appTextSizePlan.homeTabMineHealthTipsTextSize)
            .lineSpacing(LengthMetrics.vp(4))
            .fontWeight(FontWeight.Medium)
            .padding(12)
            .backgroundColor($r('app.color.main_bg_green_light_color'))
            .border({
              width: 0.3,
              radius: 4,
              color: $r('app.color.main_selected_color')
            })
          if (this.isLoadingTips) {
            LoadingProgress()
              .height(24)
          }
        }
        .width('100%')
      }
    }
  }

  @Builder
  private TipsHeader() {
    Text($r('app.string.home_tab_mine_tips'))
      .width('100%')
      .height(40)
      .fontSize(this.appTextSizePlan.homeTabMineSubTitleTextSize)
      .textAlign(TextAlign.Start)
      .padding({ left: 12, right: 12, top: 4, bottom: 4 })
      .backgroundColor(Color.White)
  }

  /**
   * 获取今日养生提示。
   */
  private apiLoadTodayTips() {
    let apiPath: string = KeysUtils.getServerUrlForID(KEY_HOME_TAB_MINE_TIPS_REQUEST);
    let reqKey: string = KeysUtils.getKeyForID(KEY_HOME_TAB_MINE_TIPS_REQUEST);
    return HttpUtils.get<TodayTipsModel>(`${apiPath}?key=${reqKey}`)
      .then((response: CallResult<TodayTipsModel>) => {
        if (response !== undefined &&
          response.data !== undefined &&
          response.data.result !== undefined &&
          response.data.result.content !== undefined &&
          response.data.result.content.length > 0) {
          KVUtils.setKV(FILE_NAME_MINE_TIPS, this.today, JSON.stringify(response.data.result));
          this.todayTips = response.data.result.content;
        } else { // 出现了异常。
          this.prepareMockTodayTips();
        }
        this.isLoadingTips = false;
      })
      .catch((error: CallResult<TodayTipsModel>) => {
        this.prepareMockTodayTips();
        this.isLoadingTips = false;
      })
  }

  /**
   * 准备模拟数据。
   */
  private prepareMockTodayTips() {
    let todayTipsObjectArray: TodayTipsResult[] = readRawFileSync<TodayTipsResult[]>(FILE_NAME_MOCK_DATA);
    let index: number = Math.floor(Math.random() * todayTipsObjectArray.length);
    this.todayTips = todayTipsObjectArray[index].content;
  }

  /**
   * 计算内容宽度。
   */
  private calcContentWidth() {
    let screenUIType = this.screenStatus?.screenUIType ?? getScreenUIType();
    let windowStatusType = this.screenStatus?.windowStatusType ?? (GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window).getWindowStatus();
    let windowWidthBreakpoint = this.screenStatus?.windowWidthBreakpoint ?? this.getUIContext().getWindowWidthBreakpoint();
    // 计算内容宽度。
    this.contentWidth =
      windowStatusType === window.WindowStatusType.FLOATING || windowStatusType === window.WindowStatusType.SPLIT_SCREEN ? (
        this.isSplitScreen ? '95%' :
        screenUIType === ScreenUIType.PAD && windowWidthBreakpoint === WidthBreakpoint.WIDTH_MD ? '47.5%' :
        screenUIType === ScreenUIType.PAD && windowWidthBreakpoint >= WidthBreakpoint.WIDTH_LG ? '31.67%' :
        '95%'
      ) :
      (
        this.isSplitScreen ? '95%' :
        screenUIType === ScreenUIType.FOLD_OPENED ? '47.5%' :
        screenUIType === ScreenUIType.PAD ? '31.67%' :
        '95%'
      );
  }
}