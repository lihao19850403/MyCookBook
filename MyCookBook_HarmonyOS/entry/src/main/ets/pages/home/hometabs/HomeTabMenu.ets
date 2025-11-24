import { RecommendMenuItem, RecommendMenuModel, RecommendMenuResult } from '../../../models/RecommendMenuModel';
import { CallResult, HttpUtils } from '../../../utils/common/HttpUtils';
import { KeysUtils } from '../../../utils/common/KeysUtils';
import { KVUtils } from '../../../utils/common/KVUtils';
import { LHCommonTitleBar } from '../../../views/common/LHCommonTitleBar';
import { HomeTabMenuRecommend } from '../../../views/HomeTabMenuRecommend';
import { HomeTabMenuFavorite } from '../../../views/HomeTabMenuFavorite';
import emitter from '@ohos.events.emitter';
import {
  FavoriteMenuChangeEventType,
  FavoriteMenuUtils, FAVORITE_MENU_CHANGE_EVENT,
  FAVORITE_MENU_CHANGE_EVENT_TYPE } from '../../../utils/FavoriteMenuUtils';
import { GlobalConfig } from '../../../utils/common/GlobalConfig';
import { AppSettingsTextSizePlanModel } from '../../../models/AppSettingsTextSizeModel';
import { HomeMainTabBarBuilder } from '../../../views/HomeMainTabBarBuilder';
import { readRawFileSync } from '../../../utils/common//filecenter/FileUtils';

/**
 * 事件：锚定至“我的收藏”。
 * 用在全局配置设置中，值设置为true表示进入菜谱Tab后马上锚定至“我的收藏”。
 * 在“我的 - 我的最爱 - 菜谱收藏夹”点击动作中会增加此事件。
 */
export const GLOBAL_CONFIG_FOCUS_ON_FAVORITE_EVENT: string = 'GlobalConfigFocusOnFavoriteEvent';

/** 菜谱页面网络请求key。 */
const KEY_HOME_TAB_MENU_REQUEST: string = 'home_tab_menu_request';

/** 推荐菜谱配置文件名。 */
const FILE_NAME_RECOMMEND_MENU: string = 'recommend_menu';

/** 菜谱模拟数据文件名。 */
const FILE_NAME_MOCK_DATA: string = 'home_tab_menu_mock.json5';

/**
 * 首页 - 菜谱。
 * @author li.hao85
 */
@Component
export struct HomeTabMenu {

  /** 当前选中的Tab序号。 */
  @Prop @Watch('onTabSelectChanged') selectedIndex: number;

  /** 应用启动后显示的第一个Tab的序号。 */
  @Prop firstPageIndex?: number;

  /** 应用文字字号方案。 */
  @Prop appTextSizePlan: AppSettingsTextSizePlanModel;

  /** 今日推荐菜谱。 */
  @State recommendMenu: RecommendMenuResult | undefined = undefined;

  /** 正在加载今日推荐菜谱。 */
  @State isLoadingRecommendMenu: boolean = true;

  /** 已收藏的菜谱。 */
  @State favoriteMenu: RecommendMenuItem[] | undefined = undefined;

  /** 已收藏菜谱内容发生了怎样的改变。 */
  @State favoriteMenuChangeEventType: FavoriteMenuChangeEventType | undefined = undefined;

  /** 此Tab序号。 */
  private thisIndex: number = 1;

  /** 今日日期(作为key)。 */
  private today: string = new Date().toLocaleDateString();

  /** 滚动视图控制器。 */
  private scroller: Scroller = new Scroller();

  private onFavoriteMenuChangedEvent: Callback<emitter.EventData> = (dataWrap: emitter.EventData) => {
    this.initFavoriteMenu();
    if (dataWrap.data) {
      this.favoriteMenuChangeEventType = dataWrap.data[FAVORITE_MENU_CHANGE_EVENT_TYPE] as FavoriteMenuChangeEventType;
    }
  };

  aboutToAppear(): void {
    if (!KVUtils.hasKV(FILE_NAME_RECOMMEND_MENU, this.today)) { // 每日拉取新推荐菜谱。
      this.apiLoadRecommendMenus();
    } else { // 今日已拉取过推荐菜谱，使用已保存的数据。
      let recommendMenuStr: string = KVUtils.queryKV(FILE_NAME_RECOMMEND_MENU, this.today) as string;
      this.recommendMenu = JSON.parse(recommendMenuStr) as RecommendMenuResult;
      this.isLoadingRecommendMenu = false;
    }
    this.initFavoriteMenu();
    emitter.on(FAVORITE_MENU_CHANGE_EVENT, this.onFavoriteMenuChangedEvent);
  }

  aboutToDisappear(): void {
    emitter.off(FAVORITE_MENU_CHANGE_EVENT, this.onFavoriteMenuChangedEvent);
  }

  build() {
    TabContent() {
      this.Content()
    }
    .tabBar(HomeMainTabBarBuilder({
      uiContext: this.getUIContext(),
      icon: this.selectedIndex === this.thisIndex ? $r('app.media.ic_home_tab_menu_selected') : $r('app.media.ic_home_tab_menu_unselected'),
      text: $r('app.string.home_tab_menu'),
      textFontSize: this.appTextSizePlan.unifiedTabBarTextSize,
      textFontColor: this.selectedIndex === this.thisIndex ? $r('app.color.main_selected_color') : $r('app.color.main_unselected_color'),
      showFirstPagePopTips: this.firstPageIndex === this.thisIndex,
      onPopTipsShowed: () => this.firstPageIndex = undefined
    }))
  }

  @Builder
  private Content() {
    Column() {
      LHCommonTitleBar({
        centerTitleText: $r('app.string.home_tab_menu'),
        centerTitleTextSize: this.appTextSizePlan.unifiedTitleCenterTextSize
      })
      List({
        scroller: this.scroller
      }) {
        HomeTabMenuRecommend({
          isLoadingRecommendMenu: this.isLoadingRecommendMenu,
          appTextSizePlan: this.appTextSizePlan,
          recommendMenu: this.recommendMenu
        })
        HomeTabMenuFavorite({
          favoriteMenu: this.favoriteMenu,
          appTextSizePlan: this.appTextSizePlan,
          favoriteMenuChangeEventType: this.favoriteMenuChangeEventType
        })
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.None)
      .sticky(StickyStyle.Header)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .nestedScroll({
        scrollForward: NestedScrollMode.SELF_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST,
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_bg_gray_color'))
  }

  onTabSelectChanged() {
    if (this.selectedIndex === this.thisIndex) {
      let focusOnFavorite: boolean | undefined = GlobalConfig.get(GLOBAL_CONFIG_FOCUS_ON_FAVORITE_EVENT);
      if (focusOnFavorite) {
        GlobalConfig.set(GLOBAL_CONFIG_FOCUS_ON_FAVORITE_EVENT, false);
        this.scroller.scrollToIndex(1, true);
      }
    }
  }

  /**
   * 获取今日推荐菜谱。
   */
  private apiLoadRecommendMenus() {
    let apiPath: string = KeysUtils.getServerUrlForID(KEY_HOME_TAB_MENU_REQUEST);
    let reqKey: string = KeysUtils.getKeyForID(KEY_HOME_TAB_MENU_REQUEST);
    let page: number = Math.floor(Math.random() * 10) % 2 + 1;
    let num: number = Math.floor(Math.random() * 10) + 3;
    HttpUtils.get<RecommendMenuModel>(`${apiPath}?key=${reqKey}&word=家常&page=${page}&num=${num}`)
      .then((response: CallResult<RecommendMenuModel>) => {
        if (response !== undefined && response.data !== undefined && response.data.result !== undefined) {
          KVUtils.setKV(FILE_NAME_RECOMMEND_MENU, this.today, JSON.stringify(response.data.result));
          this.recommendMenu = response.data.result;
        } else {
          this.recommendMenu = readRawFileSync<RecommendMenuResult>(FILE_NAME_MOCK_DATA);
        }
        this.isLoadingRecommendMenu = false;
      })
      .catch((error: CallResult<RecommendMenuModel>) => {
        this.recommendMenu = readRawFileSync<RecommendMenuResult>(FILE_NAME_MOCK_DATA);
        this.isLoadingRecommendMenu = false;
      })
  }

  /**
   * 初始化已收藏的菜谱数据。
   */
  private initFavoriteMenu() {
    let favoriteOrder = FavoriteMenuUtils.queryFavoriteOrder();
    if (favoriteOrder === undefined) {
      this.favoriteMenu = [];
      return;
    }
    try {
      if ((favoriteOrder as Array<number>).length === 0) {
        this.favoriteMenu = [];
        return;
      }
      let newFavoriteMenu: RecommendMenuItem[] = [];
      for (let index = 0; index < (favoriteOrder as Array<number>).length; index++) {
        let favoriteMenuItem = FavoriteMenuUtils.queryOneFavoriteMenu((favoriteOrder as Array<number>)[index]);
        if (favoriteMenuItem === undefined) {
          continue;
        }
        newFavoriteMenu.push(favoriteMenuItem as RecommendMenuItem);
      }
      this.favoriteMenu = newFavoriteMenu;
    } catch (error) {
    }
  }
}

