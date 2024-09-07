import { RecommendMenuItem, RecommendMenuModel, RecommendMenuResult } from '../../../models/RecommendMenuModel';
import { GlobalContext } from '../../../utils/GlobalContext';
import { CallResult, HttpUtils } from '../../../utils/HttpUtils';
import { KeysUtils } from '../../../utils/KeysUtils';
import { KVUtils } from '../../../utils/KVUtils';
import { util } from '@kit.ArkTS';
import { LHCommonTitleBar } from '../../../views/common/LHCommonTitleBar';
import { ScreenUIType } from '../../../utils/ScreenUIAdapter';
import { MenuTipsCard } from '../../../views/MenuTipsCard';
import { RouterUtils } from '../../../utils/RouterUtils';

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
        ListItemGroup({
          header: this.RecommendMenuHeader()
        }) {
          ListItem() {
            if (this.recommendMenu !== undefined && this.recommendMenu.list !== undefined && this.recommendMenu.list.length > 0) {
              Grid() {
                ForEach(this.recommendMenu.list.slice(0, 3), (menuItem: RecommendMenuItem, index: number) => {
                  GridItem() {
                    MenuTipsCard({
                      menuInfo: menuItem
                    })
                  }
                })
              }
              .columnsTemplate(this.screenUIType === ScreenUIType.FOLD_OPENED ? '1fr 1fr'
                : this.screenUIType === ScreenUIType.PAD ? '1fr 1fr 1fr'
                  : '1fr')
              .columnsGap(4)
              .rowsGap(4)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            } else {
              Text($r('app.string.no_recommend_menu_available'))
                .width('100%')
                .height('100')
                .textAlign(TextAlign.Center)
                .fontSize(16)
                .fontColor($r('app.color.main_unselected_color'))
            }
          }
        }
      }
      .edgeEffect(EdgeEffect.None)
      .sticky(StickyStyle.Header)
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

  @Builder
  RecommendMenuHeader() {
    Row() {
      Text($r('app.string.today_s_recommend'))
        .fontSize(14)
      LoadingProgress()
        .visibility(this.isLoadingRecommendMenu ? Visibility.Visible : Visibility.None)
      Blank()
        .layoutWeight(1)
      Text($r('app.string.check_all'))
        .fontColor($r('app.color.main_selected_color'))
        .fontSize(14)
        .visibility(this.recommendMenu !== undefined && this.recommendMenu.list !== undefined && this.recommendMenu.list.length > 0 ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height(32)
    .backgroundColor($r('app.color.main_bg_green_light_color'))
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 12, right: 12, top: 4, bottom: 4 })
    .onClick((event: ClickEvent) => {
      if (this.recommendMenu !== undefined && this.recommendMenu.list !== undefined && this.recommendMenu.list.length > 0) {
        RouterUtils.go('pages/recommendmenu/RecommendMenu', this.recommendMenu);
      }
    })
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
}

