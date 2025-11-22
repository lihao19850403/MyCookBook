import { AppSettingsTextSizePlanModel } from '../models/AppSettingsTextSizeModel';
import { RecommendMenuItem, RecommendMenuResult } from '../models/RecommendMenuModel';
import { MenuDetailPage } from '../pages/menudetail/MenuDetailPage';
import { RecommendMenuListPage } from '../pages/recommendmenu/RecommendMenuListPage';
import { AppSettings } from '../utils/AppSettings';
import { getScreenUIType, ScreenUIType } from '../utils/common/ScreenUIAdapter';
import { ScreenObserver, ScreenStatusInfo } from '../utils/common/uiobserver/ScreenObserver';
import { MenuTipsCard } from './MenuTipsCard';
import emitter from '@ohos.events.emitter';
import {
  GLOBAL_APP_SETTINGS_CHANGED_EVENT,
  GLOBAL_APP_SETTINGS_EVENT_TYPE,
  GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN } from '../utils/common/GlobalAppSettings';
import { GlobalConfig, GLOBAL_CONFIG_KEY_WINDOW } from '../utils/common/GlobalConfig';
import window from '@ohos.window';

/**
 * 首页 - 菜谱 - 今日推荐。
 * @author li.hao85
 */
@Component
export struct HomeTabMenuRecommend {

  /** 应用文字字号方案。 */
  @Prop @Watch('onAppTextSizePlanChanged') appTextSizePlan: AppSettingsTextSizePlanModel;

  /** 是否使用分屏显示。 */
  private isSplitScreen: boolean = AppSettings.isSplitScreen();

  /** 当前屏幕状态信息。 */
  private screenStatus: ScreenStatusInfo | undefined = undefined;

  /** 列数规定。 */
  @State columnsTemplate: string = '';

  /** 正在加载今日推荐菜谱。 */
  @Prop isLoadingRecommendMenu: boolean;

  /** 今日推荐菜谱。 */
  @Prop recommendMenu: RecommendMenuResult | undefined;

  /** 每个小卡片的高。 */
  @State cardHeight: number = -1;

  private onSplitScreenChangedEvent: Callback<emitter.EventData> = (dataWrap: emitter.EventData) => {
    if (dataWrap.data) {
      let eventType: string = dataWrap.data[GLOBAL_APP_SETTINGS_EVENT_TYPE] as string;
      switch (eventType) {
        case GLOBAL_APP_SETTINGS_KEY_SPLIT_SCREEN: {
          this.isSplitScreen = AppSettings.isSplitScreen();
          this.calcColumnTemplate();
        }
          break;
        default:
          break;
      }
    }
  };

  aboutToAppear(): void {
    emitter.on(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onSplitScreenChangedEvent);
    ScreenObserver.subscribe(this.getUIContext(), (screenStatus: ScreenStatusInfo) => {
      this.screenStatus = screenStatus;
      this.calcColumnTemplate();
    });
    this.calcColumnTemplate();
  }

  aboutToDisappear(): void {
    emitter.off(GLOBAL_APP_SETTINGS_CHANGED_EVENT, this.onSplitScreenChangedEvent);
    ScreenObserver.unsubscribe(this.getUIContext());
  }

  build() {
    ListItemGroup({
      header: this.RecommendMenuHeader()
    }) {
      ListItem() {
        if (this.recommendMenu !== undefined && this.recommendMenu.list !== undefined && this.recommendMenu.list.length > 0) {
          Grid() {
            ForEach(this.recommendMenu.list.slice(0, this.columnsTemplate === '1fr 1fr' ? 4 : 3), (menuItem: RecommendMenuItem, index: number) => {
              GridItem() {
                MenuTipsCard({
                  appTextSizePlan: this.appTextSizePlan,
                  cardHeight: this.cardHeight,
                  menuInfo: menuItem
                })
                  .onSizeChange((_, newSize: SizeOptions) => {
                    this.cardHeight = Math.max(this.cardHeight, newSize.height as number);
                  })
                  .onClick((event: ClickEvent) => MenuDetailPage.go(menuItem))
              }
            })
          }
          .columnsTemplate(this.columnsTemplate)
          .columnsGap(4)
          .rowsGap(4)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .edgeEffect(EdgeEffect.None)
          .scrollBar(BarState.Off)
        } else {
          Text($r('app.string.no_recommend_menu_available'))
            .width('100%')
            .height('100')
            .textAlign(TextAlign.Center)
            .fontSize(this.appTextSizePlan.homeTabMenuGrayTextSize)
            .fontColor($r('app.color.main_unselected_color'))
        }
      }
    }
  }

  @Builder
  private RecommendMenuHeader() {
    Row() {
      Text($r('app.string.today_s_recommend'))
        .fontSize(this.appTextSizePlan.homeTabMenuSubTitleTextSize)
      LoadingProgress()
        .visibility(this.isLoadingRecommendMenu ? Visibility.Visible : Visibility.None)
      Blank()
        .layoutWeight(1)
      Text($r('app.string.check_all'))
        .fontColor($r('app.color.main_selected_color'))
        .fontSize(this.appTextSizePlan.homeTabMenuSubTitleTextSize)
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
        RecommendMenuListPage.go(this.recommendMenu);
      }
    })
  }

  /** 当字号设置方案变化时，设置cardHeight为-1，重新计算卡片的高度。 */
  onAppTextSizePlanChanged() {
    this.cardHeight = -1;
  }

  /**
   * 计算列数。
   */
  private calcColumnTemplate() {
    let screenUIType = this.screenStatus?.screenUIType ?? getScreenUIType();
    let windowStatusType = this.screenStatus?.windowStatusType ?? (GlobalConfig.get(GLOBAL_CONFIG_KEY_WINDOW) as window.Window).getWindowStatus();
    let windowWidthBreakpoint = this.screenStatus?.windowWidthBreakpoint ?? this.getUIContext().getWindowWidthBreakpoint();
    // 计算列数。
    this.columnsTemplate =
      windowStatusType === window.WindowStatusType.FLOATING || windowStatusType === window.WindowStatusType.SPLIT_SCREEN ? (
        this.isSplitScreen ? '1fr' :
        screenUIType === ScreenUIType.PAD && windowWidthBreakpoint === WidthBreakpoint.WIDTH_MD ? '1fr 1fr' :
        screenUIType === ScreenUIType.PAD && windowWidthBreakpoint >= WidthBreakpoint.WIDTH_LG ? '1fr 1fr 1fr' :
        '1fr'
      ) :
      (
        this.isSplitScreen ? '1fr' :
        screenUIType === ScreenUIType.FOLD_OPENED ? '1fr 1fr' :
        screenUIType === ScreenUIType.PAD ? '1fr 1fr 1fr' :
        '1fr'
      );
  }
}