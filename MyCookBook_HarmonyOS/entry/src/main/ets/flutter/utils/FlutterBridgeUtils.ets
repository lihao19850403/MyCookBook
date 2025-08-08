import { MethodResult } from "@ohos/flutter_ohos";
import FlutterBridgePlugin from "flutter_bridge";
import { CreatedMenuItem } from "../../models/CreatedMenuItem";
import { LHDialogContainer } from "../../pages/common/dialogcontainer/LHDialogContainer";
import { BLANK_OBJECT, readRawFileSync } from "../../utils/common/Utils";
import { CreatedMenuUtils } from "../../utils/CreatedMenuUtils";
import { CreatedMenuCategorySelect } from "../../views/CreatedMenuCategorySelect";
import { HashMap } from '@kit.ArkTS';
import promptAction from "@ohos.promptAction";
import { DateUtils, DATE_FORMAT } from "../../utils/common/DateUtils";

/**
 * 鸿蒙平台下的Flutter桥方法处理器。
 * @param methodName 桥方法名称。
 * @param methodParams 桥方法参数。
 * @param result 运行结果，用于向Flutter页面返回参数。
 */
const flutterBridgeCallHandler: (methodName: string, methodParams: object | undefined, result: MethodResult) => void =
  (methodName, methodParams, result) => {
    if (methodName === 'queryAllCreatedMenus') {
      let allCreatedMenus: Array<CreatedMenuItem> = queryAllCreatedMenus();
      result.success(allCreatedMenus);
      return;
    }
    if (methodName === 'selectCategory') {
      let curCategory: string | undefined = methodParams ? (methodParams as ESObject as string) : undefined;
      selectCategory(result, curCategory);
      return;
    }
    if (methodName === 'addOneCreatedMenu') {
      let data: HashMap<string, string | undefined> | undefined = methodParams as HashMap<string, string | undefined>;
      let addResult: boolean = addOneCreatedMenu(data);
      result.success(addResult);
      return;
    }
    result.notImplemented();
  };

/** 鸿蒙平台下的Flutter桥方法处理插件。 */
export function getFlutterBridgePlugin(): FlutterBridgePlugin {
  let flutterBridgePlugin: FlutterBridgePlugin = new FlutterBridgePlugin();
  flutterBridgePlugin.setBridgeCallHandler(flutterBridgeCallHandler);
  return flutterBridgePlugin;
}

/* ---------- 桥方法。 ---------- */

/** 自创菜谱模拟数据文件。 */
const CREATE_MENU_MOCK_DATA: string = 'home_tab_mine_create_menu_mock.json5';

/** 自创菜谱模拟数据结构。 */
interface CreateMenuMockResult {
  curpage?: number,
  allnum?: number,
  list?: CreatedMenuItem[]
}

/**
 * 查询所有自创菜谱。
 * @returns 查询结果。
 */
function queryAllCreatedMenus(): Array<CreatedMenuItem> {
  let order: Array<number> = CreatedMenuUtils.queryCreatedOrder() ?? [];
  let menuItems: Array<CreatedMenuItem> = [];
  order.forEach((menuId: number) => {
    let menuItem: CreatedMenuItem | undefined = CreatedMenuUtils.queryOneCreatedMenu(menuId);
    if (menuItem !== undefined) {
      menuItems.push(menuItem);
    }
  });
  if (menuItems.length === 0) { // 无自创菜谱数据时，使用mock数据。
    let dataResult: CreateMenuMockResult = readRawFileSync<CreateMenuMockResult>(CREATE_MENU_MOCK_DATA);
    if (dataResult !== undefined && dataResult !== BLANK_OBJECT && dataResult.list !== undefined &&
      dataResult.list.length > 0) {
      dataResult.list.forEach((menuItem: CreatedMenuItem): void => CreatedMenuUtils.addOneCreatedMenu(menuItem));
      menuItems = dataResult.list;
    }
  }
  return menuItems;
}

/**
 * 为自创菜谱选择分类。
 * @param result 运行结果，用于向Flutter页面返回参数。
 * @param curCategory 当前选中的分类名称。
 */
function selectCategory(result: MethodResult, curCategory?: string) {
  LHDialogContainer.open({
    builder: wrapBuilder(selectCategoryDialogBuilder),
    data: [result, curCategory],
    cancelCallback: () => result.success(undefined) // 用户取消了对话框，返回空结果。
  });
}

@Builder
function selectCategoryDialogBuilder(params: object, closeCallback: Callback<void, void>) {
  CreatedMenuCategorySelect({
    result: (params as Array<object>)[0] as MethodResult,
    currentSelectedCategoryName: (params as Array<object>)[1] as ESObject as string,
    closeCallback: closeCallback
  })
}


/**
 * 添加一个自创菜谱。
 * @param data 原始数据。
 * @return 添加结果。
 */
function addOneCreatedMenu(data?: HashMap<string, string | undefined>): boolean {
  if (data === undefined) {
    promptAction.showToast({
      message: $r("app.string.created_menu_add_category_failure_tip"),
    })
    return false;
  }
  /* 解析数据。 */
  let cp_name: string | undefined = data.get('cp_name') ?? undefined;
  let author: string | undefined = data.get('author') ?? undefined;
  let type_name: string | undefined = data.get('type_name') ?? undefined;
  let texing: string | undefined = data.get('texing') ?? undefined;
  let yuanliao: string | undefined = data.get('yuanliao') ?? undefined;
  let tiaoliao: string | undefined = data.get('tiaoliao') ?? undefined;
  let zuofa: string | undefined = data.get('zuofa') ?? undefined;
  let tishi: string | undefined = data.get('tishi') ?? undefined;
  if (!cp_name && !author && !type_name && !texing && !yuanliao && !tiaoliao && !zuofa && !tishi) {
    promptAction.showToast({
      message: $r("app.string.created_menu_add_category_failure_tip"),
    })
    return false;
  }
  let categoryID: number | undefined = type_name === undefined ? undefined : CreatedMenuUtils.queryCategoryIDbyName(type_name);
  if (categoryID === undefined) {
    promptAction.showToast({
      message: $r("app.string.created_menu_add_category_failure_tip"),
    })
    return false;
  }
  /* 增加新菜谱。 */
  let newCreatedMenu: CreatedMenuItem = {};
  newCreatedMenu.id = new Date().getTime();
  newCreatedMenu.type_id = categoryID;
  newCreatedMenu.type_name = type_name;
  newCreatedMenu.cp_name = cp_name;
  newCreatedMenu.cp_thumbnail = undefined; // TODO：添加菜谱缩略图。
  newCreatedMenu.zuofa = zuofa;
  newCreatedMenu.texing = texing;
  newCreatedMenu.tishi = tishi;
  newCreatedMenu.tiaoliao = tiaoliao;
  newCreatedMenu.yuanliao = yuanliao;
  newCreatedMenu.author = author;
  newCreatedMenu.createdTime = DateUtils.formatDate(new Date(), DATE_FORMAT.YYYY_MM_DD);
  CreatedMenuUtils.addOneCreatedMenu(newCreatedMenu);
  promptAction.showToast({
    message: $r("app.string.created_menu_add_category_success_tip"),
  })
  return true;
}