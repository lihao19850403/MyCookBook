import { PullToRefresh, PullToRefreshConfigurator } from '@ohos/pulltorefresh';
import { TodayNewsDataSource } from '../models/TodayNewsDataSource';
import { TodayNewsItem, TodayNewsModel } from '../models/TodayNewsModel';
import { GlobalContext } from '../utils/common/GlobalContext';
import { CallResult, HttpUtils } from '../utils/common/HttpUtils';
import { KeysUtils } from '../utils/common/KeysUtils';
import { KVUtils } from '../utils/common/KVUtils';
import { ScreenUIType } from '../utils/common/ScreenUIAdapter';
import { util } from '@kit.ArkTS';
import { NewsTipsCard } from './NewsTipsCard';
import { RouterUtils } from '../utils/common/RouterUtils';
import { AppSettingsTextSizePlanModel } from '../models/AppSettingsTextSizeModel';

/** 今日新闻请求key。 */
const KEY_HOME_TAB_TODAY_NEWS_REQUEST: string = 'home_tab_top_news_request';

/** 网络请求参数：每页请求的新闻数量。 */
const API_PARAM_NEWS_PAGE_SIZE: number = 24;

/** 今日新闻配置文件名。 */
const FILE_NAME_TODAY_NEWS: string = 'today_news';

/** 今日新闻模拟数据文件名。 */
const FILE_NAME_MOCK_DATA: string = 'home_tab_top_news_mock.json5';

/** 上拉加载更多的状态。 */
const enum LOAD_MORE_STATUS {
  /** 未开始。 */ NONE,
  /** 上拉加载更多1阶段 - 刚刚出现。 */ TIPS_STEP_1,
  /** 上拉加载更多2阶段 - 继续上拉。 */ TIPS_STEP_2,
  /** 已到达可加载更多的滑动距离 */ READY_TO_LOAD_MORE,
  /** 正在加载中。 */ LOADING,
  /** 已完成加载 - 正常结束。 */ FINISHED_SUCCESS,
  /** 已完成加载 - 未拿到更多信息(已到底部或发生了异常)。 */ FINISHED_NO_MORE
}

/**
 * 首页 - 头条 - 今日新闻列表。
 * @author li.hao85
 */
@Component
export struct HomeTabNewsList {

  /** 屏幕状态。 */
  @Prop screenUIType: ScreenUIType;

  /** 应用文字字号方案。 */
  @Prop appTextSizePlan: AppSettingsTextSizePlanModel;

  /** 是否使用分屏显示。 */
  @Prop isSplitScreen: boolean;

  /** 正在加载今日新闻。 */
  @State isLoadingTodayNews: boolean = true;

  /** 上拉加载更多的状态。 */
  @State loadingMoreStatus: LOAD_MORE_STATUS = LOAD_MORE_STATUS.NONE;

  /** 今日新闻数据。 */
  @State todayNews: TodayNewsItem[] | undefined = undefined;

  /** 今日新闻数据源。 */
  private todayNewsDataSource: TodayNewsDataSource = new TodayNewsDataSource();

  /** 今日日期(作为key)。 */
  private today: string = new Date().toLocaleDateString();

  /** 拖动拉取组件控制器。 */
  private scroller: Scroller = new Scroller();

  /** 拖动拉取组件配置工具。 */
  private refreshConfigurator: PullToRefreshConfigurator = new PullToRefreshConfigurator();

  aboutToAppear(): void {
    this.refreshConfigurator.setHasRefresh(false);
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
      Row({
        space: 4
      }) {
        LoadingProgress()
          .height(24)
        Text($r('app.string.loading'))
          .fontSize(this.appTextSizePlan.homeTabNewsListLoadingTextSize)
          .fontColor($r('app.color.main_unselected_color'))
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .layoutWeight(1)
    } else {
      PullToRefresh({
        data: this.todayNews,
        scroller: this.scroller,
        refreshConfigurator: this.refreshConfigurator,
        customList: this.NewsList.bind(this),
        onAnimPullUp: this.onAnimPullUp.bind(this),
        onAnimLoading: this.onAnimLoading.bind(this),
        customLoad: this.LoadMore.bind(this),
        onLoadMore: () => new Promise<string>((resolve, reject) => {
          this.apiLoadTodayNews()
            .then((isReachEnd: boolean) => {
              this.loadingMoreStatus = isReachEnd ? LOAD_MORE_STATUS.FINISHED_NO_MORE : LOAD_MORE_STATUS.FINISHED_SUCCESS;
              resolve(`${isReachEnd}`);
            })
            .catch((isReachEnd: boolean) => {
              this.loadingMoreStatus = isReachEnd ? LOAD_MORE_STATUS.FINISHED_NO_MORE : LOAD_MORE_STATUS.FINISHED_SUCCESS;
              reject(`${isReachEnd}`);
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
            newsInfo: newsItem,
            appTextSizePlan: this.appTextSizePlan
          })
            .onClick((event: ClickEvent) => RouterUtils.navPushPath('NewsDetailPage', newsItem))
        }
      }, (news: TodayNewsItem, index: number) => `${news.id}${index}`)
    }
    .columnsTemplate(this.isSplitScreen ? '1fr' :
      this.screenUIType === ScreenUIType.FOLD_OPENED ? '1fr 1fr' :
      this.screenUIType === ScreenUIType.PAD ? '1fr 1fr 1fr' :
      '1fr')
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

  @Builder
  private LoadMore() {
    if (this.loadingMoreStatus !== LOAD_MORE_STATUS.NONE) {
      Row({
        space: 4
      }) {
        if (this.loadingMoreStatus === LOAD_MORE_STATUS.TIPS_STEP_1 || this.loadingMoreStatus === LOAD_MORE_STATUS.TIPS_STEP_2) {
          Image($r('app.media.ic_load_more_arrow_up'))
            .width(24)
            .height(24)
        } else if (this.loadingMoreStatus === LOAD_MORE_STATUS.READY_TO_LOAD_MORE) {
          Image($r('app.media.ic_load_more_arrow_down'))
            .width(24)
            .height(24)
        } else if (this.loadingMoreStatus === LOAD_MORE_STATUS.LOADING) {
          LoadingProgress()
            .height(24)
        } else if (this.loadingMoreStatus === LOAD_MORE_STATUS.FINISHED_SUCCESS) {
          Image($r("app.media.ic_main_selected_green"))
            .width(24)
            .height(24)
        } else if (this.loadingMoreStatus === LOAD_MORE_STATUS.FINISHED_NO_MORE) {
          Image($r("app.media.ic_main_selected_yellow"))
            .width(24)
            .height(24)
        }
        Text(this.loadingMoreStatus === LOAD_MORE_STATUS.TIPS_STEP_1 ? $r('app.string.load_more_tips_step_1') :
          this.loadingMoreStatus === LOAD_MORE_STATUS.TIPS_STEP_2 ? $r('app.string.load_more_tips_step_2') :
          this.loadingMoreStatus === LOAD_MORE_STATUS.READY_TO_LOAD_MORE ? $r('app.string.load_more_ready_to_load_more') :
          this.loadingMoreStatus === LOAD_MORE_STATUS.LOADING ? $r('app.string.load_more_loading') :
          this.loadingMoreStatus === LOAD_MORE_STATUS.FINISHED_SUCCESS ? $r('app.string.load_more_finished_success') :
          this.loadingMoreStatus === LOAD_MORE_STATUS.FINISHED_NO_MORE ? $r('app.string.load_more_finished_no_more') : '')
          .fontSize(this.appTextSizePlan.unifiedPullUpTipsTextSize)
          .fontColor($r('app.color.main_unselected_color'))
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .layoutWeight(1)
    }
  }

  /**
   * 获取今日新闻。
   */
  private async apiLoadTodayNews(): Promise<boolean> {
    let apiPath: string = await KeysUtils.getServerUrlForID(KEY_HOME_TAB_TODAY_NEWS_REQUEST);
    let reqKey: string = await KeysUtils.getKeyForID(KEY_HOME_TAB_TODAY_NEWS_REQUEST);
    let page: number = this.todayNewsDataSource.totalCount() === 0 ? 1 :
      this.todayNewsDataSource.totalCount() < API_PARAM_NEWS_PAGE_SIZE ? 2 :
        Math.ceil(this.todayNewsDataSource.totalCount() / API_PARAM_NEWS_PAGE_SIZE) + 1;
    let num: number = API_PARAM_NEWS_PAGE_SIZE;
    let rand: number = 1;
    return HttpUtils.get<TodayNewsModel>(`${apiPath}?key=${reqKey}&page=${page}&num=${num}&rand=${rand}`)
      .then((response: CallResult<TodayNewsModel>) => {
        let isReachEnd: boolean = false;
        if (response !== undefined && response.data !== undefined && response.data.result !== undefined && response.data.result.newslist !== undefined) {
          if (response.data.result.newslist.length === 0) { // 已经拉取完毕，没有新数据了。
            isReachEnd = true;
          } else { // 追加新数据。
            if (!KVUtils.hasKV(FILE_NAME_TODAY_NEWS, this.today) && this.todayNewsDataSource.totalCount() > 0) {
              this.todayNewsDataSource.deleteAllNews();
            }
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

  /**
   * 上拉过程回调。
   * @param value 上拉距离与最大上拉距离的比值，一般达到0.75就可以加载了。
   * @param width loading组件的宽。
   * @param height loading组件的高。
   */
  private onAnimPullUp(value?: number, width?: number, height?: number) {
    let loadImgHeight = this.refreshConfigurator.getLoadImgHeight();
    if (value === undefined) {
      return;
    }
    if (value < 0.75) {
      if (height === undefined || height < loadImgHeight) {
        this.loadingMoreStatus = LOAD_MORE_STATUS.TIPS_STEP_1;
      } else {
        this.loadingMoreStatus = LOAD_MORE_STATUS.TIPS_STEP_2;
      }
    } else {
      this.loadingMoreStatus = LOAD_MORE_STATUS.READY_TO_LOAD_MORE;
    }
  }

  /**
   * 加载过程回调。
   * @param value 上拉距离与最大上拉距离的比值，一般达到0.75就可以加载了。
   * @param width loading组件的宽。
   * @param height loading组件的高。
   */
  private onAnimLoading(value?: number, width?: number, height?: number) {
    this.loadingMoreStatus = LOAD_MORE_STATUS.LOADING;
  }
}