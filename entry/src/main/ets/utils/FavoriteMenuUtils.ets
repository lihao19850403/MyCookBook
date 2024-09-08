import { RecommendMenuItem } from '../models/RecommendMenuModel';
import { KVUtils } from './common/KVUtils';
import { BLANK_OBJECT } from './common/Utils';
import emitter from '@ohos.events.emitter';

/** 事件：收藏的菜谱发生了变化。 */
export const FAVORITE_MENU_CHANGE_EVENT: string = 'FAVORITE_MENU_CHANGE_EVENT';

/** 配置文件：已收藏菜谱。 */
const FILE_NAME_FAVORITE_MENU: string = 'favorite_menu';

/** 字段：菜谱顺序。 */
const KEY_FAVORITE_ORDER: string = "favorite_order";

/**
 * 菜谱收藏工具类。
 * @author li.hao85
 */
export class FavoriteMenuUtils {

  /**
   * 查询给定ID的菜谱是否在收藏夹中。
   * @param id 待查询菜谱的ID。
   * @returns 查询结果。
   */
  public static isFavoriteMenu(id: number): boolean {
    if (!KVUtils.hasKV(FILE_NAME_FAVORITE_MENU, KEY_FAVORITE_ORDER)) {
      return false;
    }
    let favoriteOrder = KVUtils.queryKV(FILE_NAME_FAVORITE_MENU, KEY_FAVORITE_ORDER);
    if (favoriteOrder === BLANK_OBJECT) {
      return false;
    }
    try {
      return (favoriteOrder as Array<number>).indexOf(id) !== -1;
    } catch (error) {
    }
    return false;
  }

  /**
   * 查询菜谱收藏夹条目顺序。
   * @returns 菜谱收藏夹条目顺序。
   */
  public static queryFavoriteOrder(): Array<number> | undefined {
    if (!KVUtils.hasKV(FILE_NAME_FAVORITE_MENU, KEY_FAVORITE_ORDER)) {
      return undefined;
    }
    let favoriteOrder = KVUtils.queryKV(FILE_NAME_FAVORITE_MENU, KEY_FAVORITE_ORDER);
    if (favoriteOrder === BLANK_OBJECT) {
      return undefined;
    }
    return favoriteOrder as Array<number>;
  }

  /**
   * 根据菜谱ID查询菜谱内容。
   * @param id 菜谱ID。
   * @returns 菜谱内容。
   */
  public static queryOneFavoriteMenu(id: number): RecommendMenuItem | undefined {
    if (!KVUtils.hasKV(FILE_NAME_FAVORITE_MENU, `${id}`)) {
      return undefined;
    }
    let menuJsonStr: string = KVUtils.queryKV(FILE_NAME_FAVORITE_MENU, `${id}`) as string;
    try {
      return JSON.parse(menuJsonStr) as RecommendMenuItem;
    } catch (error) {
    }
    return undefined;
  }

  /**
   * 更新菜谱收藏夹条目顺序。
   * @param newOrder 新的菜谱收藏夹条目顺序。
   */
  public static updateFavoriteOrder(newOrder: Array<number>) {
    KVUtils.setKV(FILE_NAME_FAVORITE_MENU, KEY_FAVORITE_ORDER, newOrder);
    emitter.emit(FAVORITE_MENU_CHANGE_EVENT);
  }

  /**
   * 添加一个喜欢的菜谱。
   * @param menu 待添加的菜谱。
   */
  public static addOneFavoriteMenu(menu: RecommendMenuItem) {
    if (menu.id === undefined) {
      return;
    }
    if (!KVUtils.hasKV(FILE_NAME_FAVORITE_MENU, KEY_FAVORITE_ORDER)) {
      KVUtils.setKV(FILE_NAME_FAVORITE_MENU, KEY_FAVORITE_ORDER, []);
    }
    let favoriteOrder = KVUtils.queryKV(FILE_NAME_FAVORITE_MENU, KEY_FAVORITE_ORDER);
    if (favoriteOrder === BLANK_OBJECT) {
      favoriteOrder = [];
    }
    try {
      if ((favoriteOrder as Array<number>).indexOf(menu.id) !== -1) {
        return;
      }
      (favoriteOrder as Array<number>).unshift(menu.id);
      KVUtils.setKV(FILE_NAME_FAVORITE_MENU, KEY_FAVORITE_ORDER, favoriteOrder);
      KVUtils.setKV(FILE_NAME_FAVORITE_MENU, `${menu.id}`, JSON.stringify(menu));
      emitter.emit(FAVORITE_MENU_CHANGE_EVENT);
    } catch (error) {
    }
  }

  /**
   * 删除一个喜欢的菜谱。
   * @param menu 待删除的菜谱。
   */
  public static removeOneFavoriteMenu(id: number) {
    if (!KVUtils.hasKV(FILE_NAME_FAVORITE_MENU, KEY_FAVORITE_ORDER)) {
      return;
    }
    let favoriteOrder = KVUtils.queryKV(FILE_NAME_FAVORITE_MENU, KEY_FAVORITE_ORDER);
    if (favoriteOrder === BLANK_OBJECT) {
      return;
    }
    try {
      let index = (favoriteOrder as Array<number>).indexOf(id);
      if (index === -1) {
        return;
      }
      (favoriteOrder as Array<number>).splice(index, 1);
      KVUtils.setKV(FILE_NAME_FAVORITE_MENU, KEY_FAVORITE_ORDER, favoriteOrder);
      KVUtils.removeKV(FILE_NAME_FAVORITE_MENU, `${id}`);
      emitter.emit(FAVORITE_MENU_CHANGE_EVENT);
    } catch (error) {
    }
  }
}