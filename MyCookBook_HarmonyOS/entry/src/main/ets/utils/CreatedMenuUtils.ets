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
  /** 更新创建的菜谱条目顺序。 */ UPDATE_CREATED_ORDER,
  /** 添加一个创建的菜谱。 */ ADD_ONE_CREATED_MENU,
  /** 更新一个自创的菜谱。 */ UPDATE_ONE_CREATED_MENU,
  /** 删除一个创建的菜谱。 */ REMOVE_ONE_CREATED_MENU
}

/** 配置文件：已创建的菜谱。 */
const FILE_NAME_CREATED_MENU: string = 'created_menu';

/** 字段：菜谱顺序。 */
const KEY_CREATED_ORDER: string = 'created_order';

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
}