import { MethodResult } from "@ohos/flutter_ohos";
import FlutterBridgePlugin from "flutter_bridge";
import { CreatedMenuItem } from "../../models/CreatedMenuItem";
import { BLANK_OBJECT, readRawFileSync } from "../../utils/common/Utils";
import { CreatedMenuUtils } from "../../utils/CreatedMenuUtils";
import { CreatedMenuCategorySelect } from "../../views/CreatedMenuCategorySelect";
import { HashMap } from '@kit.ArkTS';
import promptAction from "@ohos.promptAction";
import { DateUtils, DATE_FORMAT } from "../../utils/common/DateUtils";
import { openAlertDialog, openCustomDialog } from "../../utils/common/DialogUtils";
import { pickPhoto } from "../../utils/common/mediapicker/PhotoPickerUtils";
import photoAccessHelper from "@ohos.file.photoAccessHelper";
import { BusinessError } from '@kit.BasicServicesKit';

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
    if (methodName === 'queryOneCreatedMenu') {
      let menuID: number = methodParams as ESObject as number;
      let menu: CreatedMenuItem | undefined = CreatedMenuUtils.queryOneCreatedMenu(menuID);
      result.success(menu);
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
    if (methodName == 'updateOneCreatedMenu') {
      let data: HashMap<string, string | number | undefined> | undefined = methodParams as HashMap<string, string | number | undefined>;
      let updateResult: boolean = updateOneCreatedMenu(data);
      result.success(updateResult);
      return;
    }
    if (methodName === 'removeCreatedMenus') {
      let markToDeletedIDs: Array<number> | undefined = methodParams as Array<number>;
      removeCreatedMenus(result, markToDeletedIDs);
      return;
    }
    if (methodName === 'pickPhoto') {
      let maxSelectNumber: number = methodParams as ESObject as number;
      pickPhoto({
        maxSelectNumber: maxSelectNumber,
        callback: (pickResult?: photoAccessHelper.PhotoSelectResult, error?: BusinessError) => {
          result.success(pickResult);
        }
      });
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
  openCustomDialog({
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
      message: $r("app.string.created_menu_exception_failure_tip"),
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
      message: $r("app.string.created_menu_exception_failure_tip"),
    })
    return false;
  }
  let categoryID: number | undefined = type_name === undefined ? undefined : CreatedMenuUtils.queryCategoryIDbyName(type_name);
  if (categoryID === undefined) {
    promptAction.showToast({
      message: $r("app.string.created_menu_exception_failure_tip"),
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
    message: $r("app.string.created_menu_add_success_tip"),
  })
  return true;
}

/**
 * 刷新一个自创菜谱。
 * @param data 原始数据。
 * @return 刷新结果。
 */
function updateOneCreatedMenu(data?: HashMap<string, string | number | undefined>): boolean {
  if (data === undefined) {
    promptAction.showToast({
      message: $r("app.string.created_menu_exception_failure_tip"),
    })
    return false;
  }
  /* 解析数据。 */
  let cp_id: number | undefined = data?.get('cp_id') as number ?? undefined;
  let cp_name: string | undefined = data.get('cp_name') as string ?? undefined;
  let author: string | undefined = data.get('author') as string ?? undefined;
  let type_name: string | undefined = data.get('type_name') as string ?? undefined;
  let texing: string | undefined = data.get('texing') as string ?? undefined;
  let yuanliao: string | undefined = data.get('yuanliao') as string ?? undefined;
  let tiaoliao: string | undefined = data.get('tiaoliao') as string ?? undefined;
  let zuofa: string | undefined = data.get('zuofa') as string ?? undefined;
  let tishi: string | undefined = data.get('tishi') as string ?? undefined;
  if (!cp_id && !cp_name && !author && !type_name && !texing && !yuanliao && !tiaoliao && !zuofa && !tishi) {
    promptAction.showToast({
      message: $r("app.string.created_menu_exception_failure_tip"),
    })
    return false;
  }
  let categoryID: number | undefined = type_name === undefined ? undefined : CreatedMenuUtils.queryCategoryIDbyName(type_name);
  if (categoryID === undefined) {
    let allCategories: Record<number, string> = CreatedMenuUtils.queryAllCategories();
    if (Object.keys(allCategories).length === 0) {
      promptAction.showToast({
        message: $r("app.string.created_menu_exception_failure_tip"),
      })
      return false;
    }
    categoryID = CreatedMenuUtils.queryCategoryIDbyName(type_name);
    if (categoryID === undefined) {
      promptAction.showToast({
        message: $r("app.string.created_menu_exception_failure_tip"),
      })
      return false;
    }
  }
  /* 刷新菜谱。 */
  let updateCreatedMenu: CreatedMenuItem = {};
  updateCreatedMenu.id = cp_id;
  updateCreatedMenu.type_id = categoryID;
  updateCreatedMenu.type_name = type_name;
  updateCreatedMenu.cp_name = cp_name;
  updateCreatedMenu.cp_thumbnail = undefined; // TODO：添加菜谱缩略图。
  updateCreatedMenu.zuofa = zuofa;
  updateCreatedMenu.texing = texing;
  updateCreatedMenu.tishi = tishi;
  updateCreatedMenu.tiaoliao = tiaoliao;
  updateCreatedMenu.yuanliao = yuanliao;
  updateCreatedMenu.author = author;
  updateCreatedMenu.createdTime = DateUtils.formatDate(new Date(), DATE_FORMAT.YYYY_MM_DD);
  CreatedMenuUtils.updateOneCreateMenu(updateCreatedMenu);
  promptAction.showToast({
    message: $r("app.string.created_menu_update_success_tip"),
  })
  return true;
}

/**
 * 批量删除菜谱。
 * @param result 运行结果，用于向Flutter页面返回参数。
 * @param markToDeletedIDs 待删除的菜谱ID列表。
 */
function removeCreatedMenus(result: MethodResult, markToDeletedIDs?: Array<number>) {
  if (markToDeletedIDs === undefined || markToDeletedIDs.length === 0) {
    promptAction.showToast({
      message: $r("app.string.created_menu_delete_empty_tip"),
    })
    result.success(false);
    return;
  }
  openAlertDialog({
    title: $r('app.string.tip'),
    content: `确定要删除所选的${markToDeletedIDs.length}条自创菜谱吗？`,
    cancelAction: () => result.success(false),
    confirmAction: () => {
      CreatedMenuUtils.removeCreatedMenus(markToDeletedIDs);
      result.success(true)
    }
  });
}