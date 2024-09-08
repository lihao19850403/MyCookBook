import { RecommendMenuItem } from '../models/RecommendMenuModel';
import { KVUtils } from './common/KVUtils';
import { BLANK_OBJECT } from './common/Utils';

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
    } catch (error) {
    }
  }
}