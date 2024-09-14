import { TodayNewsModel, TodayNewsResult } from '../../../models/TodayNewsModel';
import { GlobalContext } from '../../../utils/common/GlobalContext';
import { CallResult, HttpUtils } from '../../../utils/common/HttpUtils';
import { KeysUtils } from '../../../utils/common/KeysUtils';
import { KVUtils } from '../../../utils/common/KVUtils';
import { ScreenUIType } from '../../../utils/common/ScreenUIAdapter';
import { LHCommonTitleBar } from '../../../views/common/LHCommonTitleBar';
import { util } from '@kit.ArkTS';

/** 今日新闻请求key。 */
const KEY_HOME_TAB_TODAY_NEWS_REQUEST: string = 'home_tab_news_request';

/** 网络请求接口。 */
const API_PATH: string = 'https://apis.tianapi.com/health/index';

/** 今日新闻配置文件名。 */
const FILE_NAME_TODAY_NEWS: string = 'today_news';

/** 今日新闻拟数据文件名。 */
const FILE_NAME_MOCK_DATA: string = 'home_tab_news_mock.json5';

/**
 * 首页 - 头条。
 * @author li.hao85
 */
@Component
export struct HomeTabNews {

  /** 当前选中的Tab序号。 */
  @Prop selectedIndex: number;

  /** 屏幕状态。 */
  @Prop screenUIType: ScreenUIType;

  /** 今日新闻。 */
  @State todayNews: TodayNewsResult | undefined = undefined;

  /** 正在加载今日新闻。 */
  @State isLoadingTodayNews: boolean = true;

  /** 此Tab序号。 */
  private thisIndex: number = 0;

  /** 今日日期(作为key)。 */
  private today: string = new Date().toLocaleDateString();

  aboutToAppear(): void {
    if (!KVUtils.hasKV(FILE_NAME_TODAY_NEWS, this.today)) { // 每日新闻。
      this.apiLoadTodayNews();
    } else { // 今日已有新闻，使用已保存的数据。
      let todayNewsStr: string = KVUtils.queryKV(FILE_NAME_TODAY_NEWS, this.today) as string;
      this.todayNews = JSON.parse(todayNewsStr) as TodayNewsResult;
      this.isLoadingTodayNews = false;
    }
  }

  build() {
    TabContent() {
      this.Content()
    }
    .tabBar(this.TabBarBuilder())
  }

  @Builder
  Content() {
    Column() {
      LHCommonTitleBar({
        centerTitleText: $r('app.string.home_tab_news')
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_bg_gray_color'))
  }

  @Builder
  TabBarBuilder() {
    Column() {
      Image(this.selectedIndex === this.thisIndex ? $r('app.media.ic_home_tab_news_selected') : $r('app.media.ic_home_tab_news_unselected'))
        .width(24)
        .height(24)
        .margin({ bottom: 4 })
      Text($r('app.string.home_tab_news'))
        .fontSize(10)
        .fontFamily('HarmonyHeiTi-Medium')
        .fontColor(this.selectedIndex === this.thisIndex ? $r('app.color.main_selected_color') : $r('app.color.main_unselected_color'))
    }
    .padding({ top: 6, bottom: 6 })
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 获取今日新闻。
   */
  private async apiLoadTodayNews() {
    let reqKey: string = await KeysUtils.getKeyForID(KEY_HOME_TAB_TODAY_NEWS_REQUEST);
    let page: number = 1;
    let num: number = 20;
    let rand: number = 1;
    HttpUtils.get<TodayNewsModel>(`${API_PATH}?key=${reqKey}&page=${page}&num=${num}&rand=${rand}`)
      .then((response: CallResult<TodayNewsModel>) => {
        if (response !== undefined && response.data !== undefined && response.data.result !== undefined) {
          KVUtils.setKV(FILE_NAME_TODAY_NEWS, this.today, JSON.stringify(response.data.result));
          this.todayNews = response.data.result;
        } else {
          this.prepareMockRecommendMenu();
        }
        this.isLoadingTodayNews = false;
      })
      .catch((error: CallResult<TodayNewsModel>) => {
        this.prepareMockRecommendMenu();
        this.isLoadingTodayNews = false;
      })
  }

  /**
   * 准备模拟数据。
   */
  private async prepareMockRecommendMenu() {
    let context = GlobalContext.getContext();
    if (context === undefined) {
      return;
    }
    let rawFile = await context.resourceManager.getRawFileContent(FILE_NAME_MOCK_DATA);
    let textDecoder = util.TextDecoder.create('UTF-8', { ignoreBOM: true });
    let fileContent: string = textDecoder.decodeToString(rawFile, { stream: false });
    this.todayNews = JSON.parse(fileContent) as TodayNewsResult;
  }
}

