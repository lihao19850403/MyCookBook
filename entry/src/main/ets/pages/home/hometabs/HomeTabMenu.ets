import { RecommendMenuItem, RecommendMenuModel, RecommendMenuResult } from '../../../models/RecommendMenuModel';
import { GlobalContext } from '../../../utils/common/GlobalContext';
import { CallResult, HttpUtils } from '../../../utils/common/HttpUtils';
import { KeysUtils } from '../../../utils/common/KeysUtils';
import { KVUtils } from '../../../utils/common/KVUtils';
import { util } from '@kit.ArkTS';
import { LHCommonTitleBar } from '../../../views/common/LHCommonTitleBar';
import { ScreenUIType } from '../../../utils/common/ScreenUIAdapter';
import { HomeTabMenuRecommend } from '../../../views/HomeTabMenuRecommend';
import { HomeTabMenuFavorite } from '../../../views/HomeTabMenuFavorite';
import emitter from '@ohos.events.emitter';
import {
  FavoriteMenuChangeEventType,
  FavoriteMenuUtils, FAVORITE_MENU_CHANGE_EVENT,
  FAVORITE_MENU_CHANGE_EVENT_TYPE } from '../../../utils/FavoriteMenuUtils';

/** 菜谱页面网络请求key。 */
const KEY_HOME_TAB_MENU_REQUEST: string = 'home_tab_menu_request';

/** 网络请求接口。 */
const API_PATH: string = 'https://apis.tianapi.com/caipu/index';

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
  @Prop selectedIndex: number;

  /** 屏幕状态。 */
  @Prop screenUIType: ScreenUIType;

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

  aboutToAppear(): void {
    if (!KVUtils.hasKV(FILE_NAME_RECOMMEND_MENU, this.today)) { // 每日拉取新推荐菜谱。
      this.apiLoadRecommendMenus();
    } else { // 今日已拉取过推荐菜谱，使用已保存的数据。
      let recommendMenuStr: string = KVUtils.queryKV(FILE_NAME_RECOMMEND_MENU, this.today) as string;
      this.recommendMenu = JSON.parse(recommendMenuStr) as RecommendMenuResult;
      this.isLoadingRecommendMenu = false;
    }
    this.initFavoriteMenu();
    emitter.on(FAVORITE_MENU_CHANGE_EVENT, (dataWrap: emitter.EventData) => {
      this.initFavoriteMenu();
      if (dataWrap.data) {
        this.favoriteMenuChangeEventType = dataWrap.data[FAVORITE_MENU_CHANGE_EVENT_TYPE] as FavoriteMenuChangeEventType;
      }
    });
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
        centerTitleText: $r('app.string.home_tab_menu')
      })
      List() {
        HomeTabMenuRecommend({
          screenUIType: this.screenUIType,
          isLoadingRecommendMenu: this.isLoadingRecommendMenu,
          recommendMenu: this.recommendMenu
        })
        HomeTabMenuFavorite({
          screenUIType: this.screenUIType,
          favoriteMenu: this.favoriteMenu,
          favoriteMenuChangeEventType: this.favoriteMenuChangeEventType
        })
      }
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

  @Builder
  TabBarBuilder() {
    Column() {
      Image(this.selectedIndex === this.thisIndex ? $r('app.media.ic_home_tab_menu_selected') : $r('app.media.ic_home_tab_menu_unselected'))
        .width(24)
        .height(24)
        .margin({ bottom: 4 })
      Text($r('app.string.home_tab_menu'))
        .fontSize(10)
        .fontFamily('HarmonyHeiTi-Medium')
        .fontColor(this.selectedIndex === this.thisIndex ? $r('app.color.main_selected_color') : $r('app.color.main_unselected_color'))
    }
    .padding({ top: 6, bottom: 6 })
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 获取今日推荐菜谱。
   */
  private async apiLoadRecommendMenus() {
    let reqKey: string = await KeysUtils.getKeyForID(KEY_HOME_TAB_MENU_REQUEST);
    let page: number = Math.floor(Math.random() * 10) % 2 + 1;
    let num: number = Math.floor(Math.random() * 10) + 3;
    HttpUtils.get<RecommendMenuModel>(`${API_PATH}?key=${reqKey}&word=家常&page=${page}&num=${num}`)
      .then((response: CallResult<RecommendMenuModel>) => {
        if (response !== undefined && response.data !== undefined && response.data.result !== undefined) {
          KVUtils.setKV(FILE_NAME_RECOMMEND_MENU, this.today, JSON.stringify(response.data.result));
          this.recommendMenu = response.data.result;
        } else {
          this.prepareMockRecommendMenu();
        }
        this.isLoadingRecommendMenu = false;
      })
      .catch((error: CallResult<RecommendMenuModel>) => {
        this.prepareMockRecommendMenu();
        this.isLoadingRecommendMenu = false;
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
    this.recommendMenu = JSON.parse(fileContent) as RecommendMenuResult;
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

