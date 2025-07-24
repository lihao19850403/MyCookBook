import { MethodResult } from "@ohos/flutter_ohos";
import FlutterBridgePlugin from "flutter_bridge";
import { CreatedMenuItem } from "../../models/CreatedMenuItem";
import { getScreenBottomSafeZoneHeightPx, getScreenTopSafeZoneHeightPx } from "../../utils/common/ScreenUIAdapter";
import { BLANK_OBJECT, readRawFileSync } from "../../utils/common/Utils";
import { CreatedMenuUtils } from "../../utils/CreatedMenuUtils";

/**
 * 鸿蒙平台下的Flutter桥方法处理器。
 * @param methodName 桥方法名称。
 * @param methodParams 桥方法参数。
 * @param result 运行结果，用于向Flutter页面返回参数。
 */
const flutterBridgeCallHandler: (methodName: string, methodParams: object | undefined, result: MethodResult) => void =
  (methodName, methodParams, result) => {
    if (methodName === 'queryScreenSafeZoneHeightVP') {
      let screenSafeZoneVP: Record<string, number> = queryScreenSafeZoneHeightVP();
      result.success(screenSafeZoneVP);
      return;
    }
    if (methodName === 'queryAllCreatedMenus') {
      let allCreatedMenus: Array<CreatedMenuItem> = queryAllCreatedMenus();
      result.success(allCreatedMenus);
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

/**
 * 查询屏幕安全区高度，单位是VP。
 * @returns 查询结果。
 */
function queryScreenSafeZoneHeightVP(): Record<string, number> {
  let screenTopSafeZoneHeightPx: number = getScreenTopSafeZoneHeightPx();
  let screenBottomSafeZoneHeightPx: number = getScreenBottomSafeZoneHeightPx();
  let result: Record<string, number> = {};
  result['screenTopSafeZoneHeightVP'] = px2vp(screenTopSafeZoneHeightPx);
  result['screenBottomSafeZoneHeightVP'] = px2vp(screenBottomSafeZoneHeightPx);
  return result;
}

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
    if (dataResult !== undefined && dataResult !== BLANK_OBJECT && dataResult.list !== undefined && dataResult.list.length > 0) {
      dataResult.list.forEach((menuItem: CreatedMenuItem): void => CreatedMenuUtils.addOneCreatedMenu(menuItem));
      menuItems = dataResult.list;
    }
  }
  return menuItems;
}