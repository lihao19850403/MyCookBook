import { GlobalContext } from '../utils/common/GlobalContext';
import { CallResult, HttpUtils } from '../utils/common/HttpUtils';
import { KeysUtils } from '../utils/common/KeysUtils';
import { getScreenWidthPx, ScreenUIType } from '../utils/common/ScreenUIAdapter';
import { util } from '@kit.ArkTS';
import { TodayTipsModel, TodayTipsResult } from '../models/TodayTipsModel';
import { KVUtils } from '../utils/common/KVUtils';
import { LengthMetrics } from '@ohos.arkui.node';
import { AppSettingsTextSizePlanModel } from '../models/AppSettingsTextSizeModel';

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

  /** 屏幕状态。 */
  @Prop screenUIType: ScreenUIType;

  /** 应用文字字号方案。 */
  @Prop appTextSizePlan: AppSettingsTextSizePlanModel;

  /** 是否正在加载每日养生。 */
  @State isLoadingTips: boolean = true;

  /** 今日养生提示。 */
  @State todayTips: string | undefined = undefined;

  /** 今日日期(作为key)。 */
  private today: string = new Date().toLocaleDateString();

  aboutToAppear(): void {
    if (!KVUtils.hasKV(FILE_NAME_MINE_TIPS, this.today)) { // 每日养生提示。
      this.apiLoadTodayTips();
    } else { // 今日已有养生提示，使用已保存的数据。
      let todayTipsStr: string = KVUtils.queryKV(FILE_NAME_MINE_TIPS, this.today) as string;
      let todayTipsObject: TodayTipsResult = JSON.parse(todayTipsStr) as TodayTipsResult;
      this.todayTips = todayTipsObject.content;
      this.isLoadingTips = false;
    }
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
            .width(this.screenUIType === ScreenUIType.FOLD_OPENED ? px2vp(getScreenWidthPx()) / 2 * 0.95 :
              this.screenUIType === ScreenUIType.PAD ? px2vp(getScreenWidthPx()) / 3 * 0.95 :
                '95%')
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
  private async apiLoadTodayTips() {
    let apiPath: string = await KeysUtils.getServerUrlForID(KEY_HOME_TAB_MINE_TIPS_REQUEST);
    let reqKey: string = await KeysUtils.getKeyForID(KEY_HOME_TAB_MINE_TIPS_REQUEST);
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
  private async prepareMockTodayTips() {
    let context = GlobalContext.getContext();
    if (context === undefined) {
      return;
    }
    let rawFile = await context.resourceManager.getRawFileContent(FILE_NAME_MOCK_DATA);
    let textDecoder = util.TextDecoder.create('UTF-8', { ignoreBOM: true });
    let fileContent: string = textDecoder.decodeToString(rawFile, { stream: false });
    let todayTipsObjectArray: TodayTipsResult[] = JSON.parse(fileContent) as TodayTipsResult[];
    let index: number = Math.floor(Math.random() * todayTipsObjectArray.length);
    this.todayTips = todayTipsObjectArray[index].content;
  }
}