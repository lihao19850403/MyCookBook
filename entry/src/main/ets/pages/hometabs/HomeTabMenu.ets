import { RecommendMenuModel } from '../../models/RecommendMenuModel';
import { CallResult, HttpUtils } from '../../utils/HttpUtils';
import { KeysUtils } from '../../utils/KeysUtils';

/** 网络请求接口。 */
const API_PATH: string = 'https://apis.tianapi.com/caipu/index';

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
    this.apiLoadRecommendMenus();
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
    let reqKey: string = await KeysUtils.getKeyForID(KeysUtils.KEY_HOME_TAB_MENU_REQUEST);
    HttpUtils.get<RecommendMenuModel>(`${API_PATH}?key=${reqKey}&word=家常&num=3`)
      .then((response: CallResult<RecommendMenuModel>) => {
        if (response !== undefined) {

        }
      })
      .catch((error: CallResult<RecommendMenuModel>) => {

      })
  }
}

