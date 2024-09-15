import { PullToRefresh } from '@ohos/pulltorefresh';
import { TodayNewsDataSource } from '../models/TodayNewsDataSource';
import { TodayNewsItem, TodayNewsModel } from '../models/TodayNewsModel';
import { GlobalContext } from '../utils/common/GlobalContext';
import { CallResult, HttpUtils } from '../utils/common/HttpUtils';
import { KeysUtils } from '../utils/common/KeysUtils';
import { KVUtils } from '../utils/common/KVUtils';
import { ScreenUIType } from '../utils/common/ScreenUIAdapter';
import { util } from '@kit.ArkTS';
import { NewsTipsCard } from './NewsTipsCard';

/** 今日新闻请求key。 */
const KEY_HOME_TAB_TODAY_NEWS_REQUEST: string = 'home_tab_news_request';

/** 网络请求接口。 */
const API_PATH: string = 'https://apis.tianapi.com/health/index';

/** 网络请求参数：每页请求的新闻数量。 */
const API_PARAM_NEWS_PAGE_SIZE: number = 20;

/** 今日新闻配置文件名。 */
const FILE_NAME_TODAY_NEWS: string = 'today_news';

/** 今日新闻拟数据文件名。 */
const FILE_NAME_MOCK_DATA: string = 'home_tab_news_mock.json5';

/**
 * 首页 - 头条 - 今日新闻列表。
 * @author li.hao85
 */
@Component
export struct HomeTabNewsList {

  /** 屏幕状态。 */
  @Prop screenUIType: ScreenUIType;

  /** 正在加载今日新闻。 */
  @State isLoadingTodayNews: boolean = true;

  /** 今日新闻数据。 */
  @State todayNews: TodayNewsItem[] | undefined = undefined;

  /** 今日新闻数据源。 */
  private todayNewsDataSource: TodayNewsDataSource = new TodayNewsDataSource();

  /** 今日日期(作为key)。 */
  private today: string = new Date().toLocaleDateString();

  /** 拖动拉取组件控制器。 */
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    if (!KVUtils.hasKV(FILE_NAME_TODAY_NEWS, this.today)) { // 每日新闻。
      this.apiLoadTodayNews();
    } else { // 今日已有新闻，使用已保存的数据。
      let todayNewsStr: string = KVUtils.queryKV(FILE_NAME_TODAY_NEWS, this.today) as string;
      let todayNewsArray = JSON.parse(todayNewsStr) as TodayNewsItem[];
      this.todayNewsDataSource.deleteAllNews();
      this.todayNewsDataSource.appendNewsArray(todayNewsArray);
      this.isLoadingTodayNews = false;
    }
  }

  build() {
    if (this.isLoadingTodayNews) {
      Row() {
        LoadingProgress()
          .height(24)
        Text($r('app.string.loading'))
          .fontSize(16)
          .fontColor($r('app.color.main_unselected_color'))
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .layoutWeight(1)
    } else {
      PullToRefresh({
        data: this.todayNews,
        scroller: this.scroller,
        customList: this.NewsList.bind(this),
        onLoadMore: () => new Promise<string>((resolve, reject) => {
          this.apiLoadTodayNews()
            .then((isReachEnd: boolean) => {
              resolve(`state ${isReachEnd}`)
            })
            .catch((isReachEnd: boolean) => {
              reject(`state ${isReachEnd}`)
            })
        })
      })
    }
  }

  @Builder
  private NewsList() {
    WaterFlow({
      scroller: this.scroller
    }) {
      LazyForEach(this.todayNewsDataSource, (newsItem: TodayNewsItem, index: number) => {
        FlowItem() {
          NewsTipsCard({
            newsInfo: newsItem
          })
            // .onClick((event: ClickEvent) => RouterUtils.go('pages/menudetail/MenuDetailPage', menuItem))
        }
      }, (news: TodayNewsItem, index: number) => `${news.id}${index}`)
    }
    .columnsTemplate(this.screenUIType === ScreenUIType.FOLD_OPENED ? '1fr 1fr'
      : this.screenUIType === ScreenUIType.PAD ? '1fr 1fr 1fr'
        : '1fr')
    .columnsGap(4)
    .rowsGap(4)
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .edgeEffect(EdgeEffect.None)
    .scrollBar(BarState.Off)
    .nestedScroll({
      scrollForward: NestedScrollMode.SELF_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST,
    })
    .cachedCount(4)
  }

  /**
   * 获取今日新闻。
   */
  private async apiLoadTodayNews(): Promise<boolean> {
    let reqKey: string = await KeysUtils.getKeyForID(KEY_HOME_TAB_TODAY_NEWS_REQUEST);
    let page: number = this.todayNewsDataSource.totalCount() === 0 ? 1 :
      this.todayNewsDataSource.totalCount() < API_PARAM_NEWS_PAGE_SIZE ? 2 :
        Math.ceil(this.todayNewsDataSource.totalCount() / API_PARAM_NEWS_PAGE_SIZE) + 1;
    let num: number = API_PARAM_NEWS_PAGE_SIZE;
    let rand: number = 1;
    return HttpUtils.get<TodayNewsModel>(`${API_PATH}?key=${reqKey}&page=${page}&num=${num}&rand=${rand}`)
      .then((response: CallResult<TodayNewsModel>) => {
        let isReachEnd: boolean = false;
        if (response !== undefined && response.data !== undefined && response.data.result !== undefined && response.data.result.newslist !== undefined) {
          if (response.data.result.newslist.length === 0) { // 已经拉取完毕，没有新数据了。
            isReachEnd = true;
          } else { // 追加新数据。
            this.todayNewsDataSource.appendNewsArray(response.data.result.newslist);
            KVUtils.setKV(FILE_NAME_TODAY_NEWS, this.today, JSON.stringify(this.todayNewsDataSource.getAllData()));
            isReachEnd = false;
          }
        } else { // 出现了异常。
          if (this.todayNewsDataSource.totalCount() === 0) {
            this.prepareMockRecommendMenu();
            isReachEnd = true;
          }
        }
        this.isLoadingTodayNews = false;
        return isReachEnd;
      })
      .catch((error: CallResult<TodayNewsModel>) => {
        let isReachEnd: boolean = false;
        if (this.todayNewsDataSource.totalCount() === 0) {
          this.prepareMockRecommendMenu();
          isReachEnd = true;
        }
        this.isLoadingTodayNews = false;
        return isReachEnd;
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
    let todayNewsArray = JSON.parse(fileContent) as TodayNewsItem[];
    this.todayNewsDataSource.deleteAllNews();
    this.todayNewsDataSource.appendNewsArray(todayNewsArray);
  }
}