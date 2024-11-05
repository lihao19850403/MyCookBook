import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, TestType } from '@ohos/hypium';
import Want from '@ohos.app.ability.Want';
import { BUNDLE_NAME, DRIVER, sleep } from './utils/Utils';
import { ABILITY_NAME } from './utils/Utils';
import { DELEGATOR } from './utils/Utils';
import { UIAbility } from '@kit.AbilityKit';
import { Component, ON } from '@kit.TestKit';
import { checkTitleBarTextIncludes, checkTitleBarTextIs, getTitleBarText } from './utils/TitleBarTextUtils';
import { Rect } from '@kit.ArkUI';

/** 今日推荐菜谱Tips区域高度，用于查找控件时候的比较。 */
const RECOMMEND_MENU_HEADER_HEIGHT: number = vp2px(32);

/* 加入收藏的星星图片区域尺寸，用于查找控件时候的比较。 */
const STAR_IMAGE_WIDTH: number = vp2px(35);
const STAR_IMAGE_HEIGHT: number = vp2px(35);

/* 菜谱详情页的图片区域尺寸，用于查找控件时候的比较。 */
const MENU_DETAIL_CARD_IMAGE_WIDTH: number = vp2px(224);
const MENU_DETAIL_CARD_IMAGE_HEIGHT: number = vp2px(126);

/** 首页 - 菜谱测试套。 */
export default function MenuTest() {
  describe('MenuTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })

    /** 应用启动测试。 */
    it('BootTest', TestType.FUNCTION, async () => {
      let want: Want = {
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME
      };
      await DELEGATOR.startAbility(want);
      await sleep(1000);
      await DELEGATOR.getCurrentTopAbility().then((topAbility: UIAbility) => {
        expect(topAbility.context.abilityInfo.name).assertEqual(ABILITY_NAME);
      });
    })

    /** 标题栏切换测试。 */
    it('titleTest', TestType.FUNCTION, async (finish: Function) => {
      // TabBar是否存在？
      await DRIVER.delayMs(1000);
      let tabBarItem: Component = await DRIVER.findComponent(ON.text('菜谱'));
      expect(tabBarItem !== null).assertTrue();
      // 是否能切换至对应标签页？
      await tabBarItem.click();
      await DRIVER.delayMs(1000);
      let check: boolean = await checkTitleBarTextIs('菜谱');
      expect(check === true).assertTrue();
      finish();
    })

    /** 推荐菜谱列表点击测试。 */
    it("recommendListTest", TestType.FUNCTION, async (finish: Function) => {
      await DRIVER.delayMs(1000);
      // 是否加载出了菜谱内容？
      let grids: Array<Component> = await DRIVER.findComponents(ON.type('Grid'));
      expect(grids !== null && grids.length === 1).message('这项测试需要联网获取推荐菜谱列表后才能继续').assertTrue();
      // 是否能跳转至推荐菜谱列表？
      let recommendMenuTip: Component | undefined = await findRecommendMenuHeader();
      expect(recommendMenuTip !== undefined).assertTrue();
      await testAddFavoriteMenu(recommendMenuTip!);
      let wholeList: Component = await DRIVER.findComponent(ON.type('List'));
      expect(wholeList !== null).assertTrue();
      await wholeList.scrollToBottom();
      await DRIVER.delayMs(1000);
      grids = await DRIVER.findComponents(ON.type('Grid'));
      if (grids !== null && grids.length < 2) {
        await testAddFavoriteMenu(recommendMenuTip!); // 如果取消收藏，则再加入一次。
      }
      expect(grids !== null && grids.length === 2).assertTrue();
      finish();
    })

    /** 菜谱收藏夹列表点击测试。 */
    it("favoriteListTest", TestType.FUNCTION, async (finish: Function) => {
      await DRIVER.delayMs(1000);
      // 是否加载出了菜谱内容？
      let grids: Array<Component> = await DRIVER.findComponents(ON.type('Grid'));
      expect(grids !== null && grids.length === 2).assertTrue();
      // 是否能跳转至菜谱详情？
      let menuTips: Array<Component> = await DRIVER.findComponents(ON.type('GridItem'));
      expect(menuTips !== null && menuTips.length > 0).assertTrue();
      let lastFavoriteMenuTipsCard: Component = menuTips[menuTips.length - 1];
      await lastFavoriteMenuTipsCard.click();
      await DRIVER.delayMs(1000);
      let check: boolean = await checkTitleBarTextIncludes('家常');
      expect(check === true).assertTrue();
      // 是否能跳转至图片阅览页？
      let image: Component | undefined = await findMenuDetailCardImage();
      expect(image !== undefined).assertTrue();
      await image!.click();
      await DRIVER.delayMs(1000);
      image = await DRIVER.findComponent(ON.type('Image'));
      expect(image !== null).assertTrue();
      // 返回首页。
      await DRIVER.pressBack();
      await DRIVER.pressBack();
      finish();
    })
  })
}

/**
 * 查找今日推荐菜谱Tips区域，一般页面上第一个高是32vp的控件就是。
 * @returns 今日推荐菜谱Tips区域组件。
 */
async function findRecommendMenuHeader(): Promise<Component | undefined> {
  let comps: Array<Component> = await DRIVER.findComponents(ON.type('Row'));
  if (comps === null || comps.length === 0) {
    return undefined;
  }
  let result: Component | undefined = undefined;
  for (let index = 0; index < comps.length; index++) {
    let item: Component = comps[index];
    let bound: Rect = await item.getBounds();
    let height: number = bound.bottom - bound.top;
    if (Math.abs(height - RECOMMEND_MENU_HEADER_HEIGHT) < 3) {
      result = item;
      break;
    }
  }
  return result;
}

/**
 * 测试将菜谱加入收藏。
 * @param recommendMenuTip 推荐菜谱列表提示。
 */
async function testAddFavoriteMenu(recommendMenuTip: Component) {
  await recommendMenuTip.click();
  await DRIVER.delayMs(1000);
  let check: boolean = await checkTitleBarTextIncludes('今日推荐');
  expect(check === true).assertTrue();
  let title: string | undefined = await getTitleBarText();
  let recommendMenuCount: number = Number(title!.substring(title!.indexOf('(') + 1, title!.length - 1));
  expect(recommendMenuCount > 0).assertTrue();
  // 是否能将菜谱加入收藏？
  let star: Component | undefined = await findStarImage();
  expect(star !== undefined).assertTrue();
  await star!.click();
  await DRIVER.delayMs(1000);
  await DRIVER.pressBack(); // 返回首页检查菜谱收藏结果。
  await DRIVER.delayMs(1000);
}

/**
 * 查找加入收藏的星星图片区域，一般页面上第一个尺寸是35vp*35vp的控件就是。
 * @returns 菜谱详情页的图片区域组件。
 */
async function findStarImage(): Promise<Component | undefined> {
  let comps: Array<Component> = await DRIVER.findComponents(ON.type('Stack'));
  if (comps === null || comps.length === 0) {
    return undefined;
  }
  let result: Component | undefined = undefined;
  for (let index = 0; index < comps.length; index++) {
    let item: Component = comps[index];
    let bound: Rect = await item.getBounds();
    let width: number = bound.right - bound.left;
    let height: number = bound.bottom - bound.top;
    if (Math.abs(width - STAR_IMAGE_WIDTH) < 3 && Math.abs(height - STAR_IMAGE_HEIGHT) < 3) {
      let isItemEnabled: boolean = await item.isEnabled();
      if (isItemEnabled) {
        result = item;
        break;
      }
    }
  }
  return result;
}

/**
 * 查找菜谱详情页的图片区域，一般页面上第一个尺寸是224vp*126vp的控件就是。
 * @returns 菜谱详情页的图片区域组件。
 */
async function findMenuDetailCardImage(): Promise<Component | undefined> {
  let comps: Array<Component> = await DRIVER.findComponents(ON.type('Image'));
  if (comps === null || comps.length === 0) {
    return undefined;
  }
  let result: Component | undefined = undefined;
  for (let index = 0; index < comps.length; index++) {
    let item: Component = comps[index];
    let bound: Rect = await item.getBounds();
    let width: number = bound.right - bound.left;
    let height: number = bound.bottom - bound.top;
    if (Math.abs(width - MENU_DETAIL_CARD_IMAGE_WIDTH) < 3 && Math.abs(height - MENU_DETAIL_CARD_IMAGE_HEIGHT) < 3) {
      result = item;
      break;
    }
  }
  return result;
}