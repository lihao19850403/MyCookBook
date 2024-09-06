import { RecommendMenuModel } from '../../models/RecommendMenuModel';
import { CallResult, HttpUtils } from '../../utils/HttpUtils';
import { KeysUtils } from '../../utils/KeysUtils';
import { KVUtils } from '../../utils/KVUtils';

/** 菜谱页面网络请求key。 */
const KEY_HOME_TAB_MENU_REQUEST: string = 'home_tab_menu_request';

/** 网络请求接口。 */
const API_PATH: string = 'https://apis.tianapi.com/caipu/index';

/** 推荐菜谱配置文件名。 */
const FILE_NAME_RECOMMEND_MENU: string = 'recommend_menu';

/**
 * 首页 - 菜谱。
 * @author li.hao85
 */
@Component
export struct HomeTabMenu {

  /** 当前选中的Tab序号。 */
  @Prop selectedIndex: number;

  /** 此Tab序号。 */
  private thisIndex: number = 1;

  aboutToAppear(): void {
    let today: string = new Date().toLocaleDateString();
    if (!KVUtils.hasKV(FILE_NAME_RECOMMEND_MENU, today)) { // 每日拉取新推荐菜谱。
      this.apiLoadRecommendMenus();
    } else { // 今日已拉取过推荐菜谱，使用已保存的数据。
      this.prepareRecommendMenu();
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

    }
    .width('100%')
    .height('100%')
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
        if (response !== undefined && response.data !== undefined && response.data.result != undefined) {
          let today: string = new Date().toLocaleDateString();
          KVUtils.setKV(FILE_NAME_RECOMMEND_MENU, today, JSON.stringify(response.data.result));
          this.prepareRecommendMenu();
        } else {
          this.prepareMockRecommendMenu();
        }
      })
      .catch((error: CallResult<RecommendMenuModel>) => {
        this.prepareMockRecommendMenu();
      })
  }

  /**
   * 根据今日推荐菜谱信息准备数据。
   */
  private prepareRecommendMenu() {

  }

  /**
   * 准备模拟数据。
   */
  private prepareMockRecommendMenu() {

  }
}

