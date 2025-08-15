import { KVUtils } from './common/KVUtils';
import { BLANK_OBJECT } from './common/Utils';
import emitter from '@ohos.events.emitter';
import { CreatedMenuItem } from '../models/CreatedMenuItem';

/** 事件：创建的菜谱发生了变化。 */
export const CREATED_MENU_CHANGE_EVENT: string = 'CREATED_MENU_CHANGE_EVENT';

/** 事件参数名：创建的菜谱发生了变化，此事件的类型。 */
export const CREATED_MENU_CHANGE_EVENT_TYPE: string = 'CREATED_MENU_CHANGE_EVENT_TYPE';

/** 创建的菜谱发生了怎样的变化。 */
export const enum CreatedMenuChangeEventType {
  /** 更新创建的菜谱条目顺序。 */
  UPDATE_CREATED_ORDER,
  /** 添加一个创建的菜谱。 */
  ADD_ONE_CREATED_MENU,
  /** 更新一个自创的菜谱。 */
  UPDATE_ONE_CREATED_MENU,
  /** 删除一个创建的菜谱。 */
  REMOVE_ONE_CREATED_MENU,
  /** 删除多个创建的菜谱。 */
  REMOVE_SOME_CREATED_MENUS
}

/** 配置文件：已创建的菜谱。 */
const FILE_NAME_CREATED_MENU: string = 'created_menu';

/** 字段：菜谱顺序。 */
const KEY_CREATED_ORDER: string = 'created_order';

/** 配置文件：所有菜谱分类。 */
const FILE_NAME_CATEGORIES = 'created_menu_categories';

/**
 * 创建菜谱工具类。
 * @author li.hao85
 */
export class CreatedMenuUtils {
  /**
   * 查询给定ID的菜谱是否在创建菜谱列表中。
   * @param id 待查询菜谱的ID。
   * @returns 查询结果。
   */
  public static isCreatedMenu(id: number): boolean {
    if (!KVUtils.hasKV(FILE_NAME_CREATED_MENU, KEY_CREATED_ORDER)) {
      return false;
    }
    let createdOrder = KVUtils.queryKV(FILE_NAME_CREATED_MENU, KEY_CREATED_ORDER);
    if (createdOrder === BLANK_OBJECT) {
      return false;
    }
    try {
      return (createdOrder as Array<number>).includes(id);
    } catch (error) {
    }
    return false;
  }

  /**
   * 查询创建的菜谱列表条目顺序。
   * @returns 创建的菜谱列表条目顺序。
   */
  public static queryCreatedOrder(): Array<number> | undefined {
    if (!KVUtils.hasKV(FILE_NAME_CREATED_MENU, KEY_CREATED_ORDER)) {
      return undefined;
    }
    let createdOrder = KVUtils.queryKV(FILE_NAME_CREATED_MENU, KEY_CREATED_ORDER);
    if (createdOrder === BLANK_OBJECT) {
      return undefined;
    }
    return createdOrder as Array<number>;
  }

  /**
   * 根据菜谱ID查询菜谱内容。
   * @param id 菜谱ID。
   * @returns 菜谱内容。
   */
  public static queryOneCreatedMenu(id: number): CreatedMenuItem | undefined {
    if (!KVUtils.hasKV(FILE_NAME_CREATED_MENU, `${id}`)) {
      return undefined;
    }
    let menuJsonStr: string = KVUtils.queryKV(FILE_NAME_CREATED_MENU, `${id}`) as string;
    try {
      return JSON.parse(menuJsonStr) as CreatedMenuItem;
    } catch (error) {
    }
    return undefined;
  }

  /**
   * 更新创建的菜谱列表条目顺序。
   * @param newOrder 新的创建的菜谱列表条目顺序。
   */
  public static updateCreatedOrder(newOrder: Array<number>) {
    KVUtils.setKV(FILE_NAME_CREATED_MENU, KEY_CREATED_ORDER, newOrder);
    let dataWrap: emitter.EventData = {};
    dataWrap.data = {
      CREATED_MENU_CHANGE_EVENT_TYPE: CreatedMenuChangeEventType.UPDATE_CREATED_ORDER
    };
    emitter.emit(CREATED_MENU_CHANGE_EVENT, dataWrap);
  }

  /**
   * 添加一个创建的菜谱。
   * @param menu 待添加的菜谱。
   */
  public static addOneCreatedMenu(menu: CreatedMenuItem) {
    if (menu.id === undefined) {
      return;
    }
    if (!KVUtils.hasKV(FILE_NAME_CREATED_MENU, KEY_CREATED_ORDER)) {
      KVUtils.setKV(FILE_NAME_CREATED_MENU, KEY_CREATED_ORDER, []);
    }
    let createdOrder = KVUtils.queryKV(FILE_NAME_CREATED_MENU, KEY_CREATED_ORDER);
    if (createdOrder === BLANK_OBJECT) {
      createdOrder = [];
    }
    try {
      if ((createdOrder as Array<number>).includes(menu.id)) {
        return;
      }
      (createdOrder as Array<number>).unshift(menu.id);
      KVUtils.setKV(FILE_NAME_CREATED_MENU, KEY_CREATED_ORDER, createdOrder);
      KVUtils.setKV(FILE_NAME_CREATED_MENU, `${menu.id}`, JSON.stringify(menu));
      let dataWrap: emitter.EventData = {};
      dataWrap.data = {
        CREATED_MENU_CHANGE_EVENT_TYPE: CreatedMenuChangeEventType.ADD_ONE_CREATED_MENU
      };
      emitter.emit(CREATED_MENU_CHANGE_EVENT, dataWrap);
    } catch (error) {
    }
  }

  /**
   * 更新一个已有的自创菜谱。
   * @param menu 待更新的新数据。
   */
  public static updateOneCreateMenu(menu: CreatedMenuItem) {
    if (menu.id === undefined) {
      return;
    }
    if (!KVUtils.hasKV(FILE_NAME_CREATED_MENU, KEY_CREATED_ORDER)) {
      return;
    }
    let createdOrder = KVUtils.queryKV(FILE_NAME_CREATED_MENU, KEY_CREATED_ORDER);
    if (createdOrder === BLANK_OBJECT) {
      return;
    }
    try {
      if (!(createdOrder as Array<number>).includes(menu.id)) {
        return;
      }
      (createdOrder as Array<number>).splice((createdOrder as Array<number>).indexOf(menu.id), 1);
      (createdOrder as Array<number>).unshift(menu.id);
      KVUtils.setKV(FILE_NAME_CREATED_MENU, KEY_CREATED_ORDER, createdOrder);
      KVUtils.setKV(FILE_NAME_CREATED_MENU, `${menu.id}`, JSON.stringify(menu));
      let dataWrap: emitter.EventData = {};
      dataWrap.data = {
        CREATED_MENU_CHANGE_EVENT_TYPE: CreatedMenuChangeEventType.UPDATE_ONE_CREATED_MENU
      };
      emitter.emit(CREATED_MENU_CHANGE_EVENT, dataWrap);
    } catch (error) {
    }
  }

  /**
   * 删除一个创建的菜谱。
   * @param menu 待删除的菜谱。
   */
  public static removeOneCreatedMenu(id: number) {
    if (!KVUtils.hasKV(FILE_NAME_CREATED_MENU, KEY_CREATED_ORDER)) {
      return;
    }
    let createdOrder = KVUtils.queryKV(FILE_NAME_CREATED_MENU, KEY_CREATED_ORDER);
    if (createdOrder === BLANK_OBJECT) {
      return;
    }
    try {
      let index = (createdOrder as Array<number>).indexOf(id);
      if (index === -1) {
        return;
      }
      (createdOrder as Array<number>).splice(index, 1);
      KVUtils.setKV(FILE_NAME_CREATED_MENU, KEY_CREATED_ORDER, createdOrder);
      KVUtils.removeKV(FILE_NAME_CREATED_MENU, `${id}`);
      let dataWrap: emitter.EventData = {};
      dataWrap.data = {
        CREATED_MENU_CHANGE_EVENT_TYPE: CreatedMenuChangeEventType.REMOVE_ONE_CREATED_MENU
      };
      emitter.emit(CREATED_MENU_CHANGE_EVENT, dataWrap);
    } catch (error) {
    }
  }

  /**
   * 批量删除多个自创菜谱。
   * @param ids 待删除的菜谱ID列表。
   */
  public static removeCreatedMenus(ids: Array<number>) {
    if (!KVUtils.hasKV(FILE_NAME_CREATED_MENU, KEY_CREATED_ORDER)) {
      return;
    }
    let createdOrder = KVUtils.queryKV(FILE_NAME_CREATED_MENU, KEY_CREATED_ORDER);
    if (createdOrder === BLANK_OBJECT) {
      return;
    }
    try {
      let deletedIDs: Array<number> = [];
      ids.forEach((id: number) => {
        let index = (createdOrder as Array<number>).indexOf(id);
        if (index !== -1) {
          (createdOrder as Array<number>).splice(index, 1);
          deletedIDs.push(id);
        }
      });
      if (deletedIDs.length == 0) { // 未删除任何菜谱。
        return;
      }
      KVUtils.setKV(FILE_NAME_CREATED_MENU, KEY_CREATED_ORDER, createdOrder);
      deletedIDs.forEach((id: number): void => KVUtils.removeKV(FILE_NAME_CREATED_MENU, `${id}`));
      let dataWrap: emitter.EventData = {};
      dataWrap.data = {
        CREATED_MENU_CHANGE_EVENT_TYPE: CreatedMenuChangeEventType.REMOVE_SOME_CREATED_MENUS
      };
      emitter.emit(CREATED_MENU_CHANGE_EVENT, dataWrap);
    } catch (error) {
    }
  }

  /**
   * 查询所有菜谱分类信息。
   * @returns 所有菜谱分类信息：key：分类ID，value：分类名称。
   */
  public static queryAllCategories(): Record<number, string> {
    let allCategoriesInfo: object = KVUtils.queryAllKVs(FILE_NAME_CATEGORIES);
    let allIDStrings: Array<string> | undefined =
      allCategoriesInfo === BLANK_OBJECT ? undefined : Object.keys(allCategoriesInfo);
    // 没有分类的情况下初始化一份分类信息文件。
    if (allIDStrings === undefined || allIDStrings.length === 0) {
      let allMenusOrder: Array<number> | undefined = CreatedMenuUtils.queryCreatedOrder();
      if (allMenusOrder === undefined || allMenusOrder.length === 0) {
        return {};
      }
      let result: Record<number, string> = {};
      allMenusOrder.forEach((id: number) => {
        let menuItem: CreatedMenuItem | undefined = CreatedMenuUtils.queryOneCreatedMenu(id);
        if (menuItem !== undefined && menuItem.type_id !== undefined && menuItem.type_name !== undefined &&
          menuItem.type_name.length > 0) {
          result[menuItem.type_id] = menuItem.type_name;
          KVUtils.setKV(FILE_NAME_CATEGORIES, `${menuItem.type_id}`, menuItem.type_name);
        }
      });
      return result;
    }
    // 有分类的情况下查询所有分类信息。
    let result: Record<number, string> = {};
    allIDStrings.forEach((idString: string) => {
      if (KVUtils.hasKV(FILE_NAME_CATEGORIES, idString)) {
        let name: string = KVUtils.queryKV(FILE_NAME_CATEGORIES, idString) as string;
        let id: number = Number(idString);
        result[id] = name;
      }
    });
    return result;
  }

  /**
   * 查询分类名称是否已存在。
   * @param name 待查询的分类名称。
   * @returns 查询结果。
   */
  public static queryIfCategoryNameExisted(name: string): boolean {
    let allCategoriesInfo: object = KVUtils.queryAllKVs(FILE_NAME_CATEGORIES);
    let allNames: Array<string> | undefined =
      allCategoriesInfo === BLANK_OBJECT ? undefined : Object.values(allCategoriesInfo);
    return allNames !== undefined && allNames.length > 0 && allNames.includes(name);
  }

  /**
   * 通过分类名称查询分类ID。
   * @param name 分类名称。
   * @returns 对应的分类ID。
   */
  public static queryCategoryIDbyName(name: string): number | undefined {
    let allCategoriesInfo: object = KVUtils.queryAllKVs(FILE_NAME_CATEGORIES);
    let allEntries: Array<[string, string]> | undefined =
      allCategoriesInfo === BLANK_OBJECT ? undefined : Object.entries(allCategoriesInfo);
    if (allEntries === undefined || allEntries.length === 0) {
      return undefined;
    }
    for (let index: number = 0; index < allEntries.length; index++) {
      let entry: [string, string] = allEntries[index];
      let entryID: number = Number(entry[0]);
      let entryName: string = entry[1];
      if (entryName === name) {
        return entryID;
      }
    }
    return undefined;
  }

  /**
   * 增加一个新的分类。
   * @param name 新分类名称。
   */
  public static addOneCategory(name: string) {
    let idString: string = `${new Date().getTime()}`;
    KVUtils.setKV(FILE_NAME_CATEGORIES, idString, name);
  }
}