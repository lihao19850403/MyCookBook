import { MethodResult } from "@ohos/flutter_ohos";
import { AppSettingsTextSizePlanModel } from "../models/AppSettingsTextSizeModel";
import { CreatedMenuCategoryInfo } from "../models/CreatedMenuCategoryInfo";
import { AppSettings } from "../utils/AppSettings";
import { CreatedMenuUtils } from "../utils/CreatedMenuUtils";
import promptAction from "@ohos.promptAction";
import { getScreenBottomSafeZoneHeightPx, getScreenTopSafeZoneHeightPx } from "../utils/common/ScreenUIAdapter";
import { ScreenObserver, ScreenStatusInfo } from "../utils/common/uiobserver/ScreenObserver";
import window from "@ohos.window";

/**
 * 为自创菜谱设置分类。
 * @author li.hao85
 */
@Component
export struct CreatedMenuCategorySelect {
  /** 应用文字字号方案。 */
  private appTextSizePlan: AppSettingsTextSizePlanModel = AppSettings.textSizePlan();
  /** 运行结果，用于向Flutter页面返回参数。 */
  result?: MethodResult = undefined;
  /** 关闭对话框的回调。 */
  closeCallback?: Callback<void, void> = undefined;
  /** 自创菜谱分类信息列表。 */
  @State categories: Array<CreatedMenuCategoryInfo> = [];
  /** 当前选中的菜谱分类名称。 */
  @State currentSelectedCategoryName: string | undefined = undefined;
  /** 分类列表滚动装置。 */
  private categoriesListScroller: ListScroller = new ListScroller();
  /** 添加新分类输入框控制器。 */
  private addNewCategoryController: TextInputController = new TextInputController();

  /** 顶部安全区高度。 */
  @State topSafeZoneHeightVp: number = px2vp(getScreenTopSafeZoneHeightPx());

  /** 底部安全区高度。 */
  @State bottomSafeZoneHeightVp: number = px2vp(getScreenBottomSafeZoneHeightPx());

  /** 标题栏高度。 */
  private titleBarHeightVp: number = 0;

  /** 滚动区最大高度。 */
  @State contentMaxHeight: string | undefined = undefined;

  aboutToAppear(): void {
    this.initAllCategories();
    if (this.currentSelectedCategoryName != undefined && this.currentSelectedCategoryName.length > 0) {
      setTimeout(() => {
        let index: number = 0;
        for (let i: number = 0; i < this.categories.length; i++) {
          if (this.categories[i].name === this.currentSelectedCategoryName) {
            index = i;
            break;
          }
        }
        this.categoriesListScroller.scrollToIndex(index, false, ScrollAlign.CENTER);
      }, 0);
    }

    ScreenObserver.subscribe(this.getUIContext(), (screenStatus: ScreenStatusInfo) => {
      if (screenStatus.avoidArea !== undefined) {
        if (screenStatus.avoidAreaType === window.AvoidAreaType.TYPE_SYSTEM) {
          this.topSafeZoneHeightVp = px2vp(screenStatus.avoidArea.topRect.height);
        } else if (screenStatus.avoidAreaType === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          this.bottomSafeZoneHeightVp = px2vp(screenStatus.avoidArea.bottomRect.height);
        }
      }
      this.contentMaxHeight = `calc(100% - ${this.titleBarHeightVp}vp)`;
    });
  }

  aboutToDisappear(): void {
    ScreenObserver.unsubscribe(this.getUIContext());
  }

  build() {
    Column() {
      // 标题。
      Text($r('app.string.created_menu_select_category_title'))
        .width('100%')
        .fontSize(this.appTextSizePlan.createdMenuSelectCategoryTitle)
        .textAlign(TextAlign.Center)
        .padding(12)
        .onAreaChange((_, newArea: Area) => {
          this.titleBarHeightVp = Math.max(0, Math.ceil(newArea.height as number));
          this.contentMaxHeight = `calc(100% - ${this.titleBarHeightVp}vp)`;
        })
      // 内容。
      List({ scroller: this.categoriesListScroller }) {
        ForEach(this.categories, (item: CreatedMenuCategoryInfo) => {
          ListItem() {
            this.SelectItem(item)
          }
          .padding({ left: 12, right: 12 })
        })
        ListItem() {
          this.AddNewItem()
        }
        .padding({ left: 12, right: 12 })
        // 按钮区。
        ListItem() {
          Row({ space: 12 }) {
            Button($r('app.string.cancel'), {
              type: ButtonType.Normal
            })
              .layoutWeight(1)
              .fontSize(this.appTextSizePlan.createdMenuSelectCategoryButton)
              .fontColor($r('app.color.main_unselected_color'))
              .backgroundColor(Color.Transparent)
              .onClick((event: ClickEvent) => {
                this.result?.success(undefined);
                this.closeCallback?.();
              })
            Button($r('app.string.confirm'), {
              type: ButtonType.Normal
            })
              .layoutWeight(1)
              .fontSize(this.appTextSizePlan.createdMenuSelectCategoryButton)
              .fontColor($r('app.color.main_selected_color'))
              .backgroundColor(Color.Transparent)
              .onClick((event: ClickEvent) => {
                this.result?.success(this.currentSelectedCategoryName);
                this.closeCallback?.();
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .padding(12)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
      .constraintSize({ maxHeight: this.contentMaxHeight })
    }
    .width(320)
    .constraintSize({ maxHeight: 480 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.White)
    .border({ radius: 12 })
    .margin({
      top: this.topSafeZoneHeightVp,
      bottom: this.bottomSafeZoneHeightVp
    })
  }

  @Builder
  private SelectItem(item: CreatedMenuCategoryInfo) {
    Button({ type: ButtonType.Normal }) {
      Row({ space: 4 }) {
        if (this.currentSelectedCategoryName === item.name) {
          Image($r('app.media.ic_main_selected_green'))
            .width(14)
            .height(14)
            .objectFit(ImageFit.Contain)
        } else {
          Circle()
            .width(14)
            .height(14)
            .strokeWidth(1)
            .padding(1)
            .fill(Color.Transparent)
            .stroke($r('app.color.main_bg_gray_color'))
        }
        Text(item.name)
          .layoutWeight(1)
          .fontSize(this.appTextSizePlan.createdMenuSelectCategoryContent)
          .textAlign(TextAlign.Start)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.Transparent)
    .onClick((event: ClickEvent) => this.currentSelectedCategoryName = item.name)
  }

  @Builder
  private AddNewItem() {
    Row({ space: 4 }) {
      Image($r('app.media.ic_add_green'))
        .width(14)
        .height(14)
        .objectFit(ImageFit.Contain)
      TextInput({
        controller: this.addNewCategoryController,
        placeholder: $r("app.string.created_menu_select_category_new_tip")
      })
        .backgroundColor(Color.Transparent)
        .borderRadius(0)
        .padding(0)
        .layoutWeight(1)
        .fontSize(this.appTextSizePlan.createdMenuSelectCategoryContent)
        .maxLines(1)
        .placeholderFont({ size: this.appTextSizePlan.createdMenuSelectCategoryContent })
        .placeholderColor($r('app.color.main_selected_light_color'))
        .caretColor($r('app.color.main_selected_color'))
        .textAlign(TextAlign.Start)
        .enterKeyType(EnterKeyType.Done)
        .onSubmit((enterKeyType: EnterKeyType, event: SubmitEvent) => {
          if (enterKeyType === EnterKeyType.Done && event.text !== undefined && event.text.length > 0) {
            this.addNewCategory(event.text);
          }
        })
        .onBlur(() => {
          this.addNewCategoryController.deleteText();
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .padding(12)
  }

  /** 初始化所有分类列表。 */
  private initAllCategories() {
    this.categories.splice(0, this.categories.length);
    let categoryInfos: Record<number, string> = CreatedMenuUtils.queryAllCategories();
    Object.keys(categoryInfos).forEach((key: string) => {
      let id: number = Number(key);
      let name: string = categoryInfos[id];
      this.categories.push({
        id: id,
        name: name
      });
    });
  }

  /**
   * 添加一个新分类。
   * @param name 新分类名称。
   */
  private addNewCategory(name: string) {
    if (CreatedMenuUtils.queryIfCategoryNameExisted(name)) {
      promptAction.showToast({
        message: $r('app.string.created_menu_select_category_existed_tip'),
      })
    } else {
      CreatedMenuUtils.addOneCategory(name);
      this.initAllCategories();
      setTimeout(() => {
        this.categoriesListScroller.scrollToIndex(this.categories.length - 1, false);
        this.addNewCategoryController.clearPreviewText();
        this.currentSelectedCategoryName = name;
      }, 0);
    }
  }
}