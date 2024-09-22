import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, TestType } from '@ohos/hypium';
import Want from '@ohos.app.ability.Want';
import { BUNDLE_NAME, DRIVER, sleep } from './Utils';
import { ABILITY_NAME } from './Utils';
import { DELEGATOR } from './Utils';
import { UIAbility } from '@kit.AbilityKit';
import { Component, ON } from '@kit.TestKit';

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
      let titleBar: Component = await DRIVER.findComponent(ON.id('LHCommonTitleBar_title'));
      expect(titleBar !== null).assertTrue();
      let title: string = await titleBar.getText();
      expect(title).assertEqual('菜谱');
      finish();
    })

    /** 推荐菜谱列表点击测试。 */
    it("recommendListTest", TestType.FUNCTION, async (finish: Function) => {
      await DRIVER.delayMs(1000);
      // 是否加载出了菜谱内容？
      let grids: Array<Component> = await DRIVER.findComponents(ON.type('Grid'));
      expect(grids !== null && grids.length === 1).message('这项测试需要联网获取推荐菜谱列表后才能继续').assertTrue();
      // 是否能跳转至推荐菜谱列表？
      let recommendMenuTips: Component = await DRIVER.findComponent(ON.id('RecommendMenuHeader'));
      expect(recommendMenuTips !== null).assertTrue();
      await testAddFavoriteMenu(recommendMenuTips);
      grids = await DRIVER.findComponents(ON.type('Grid'));
      if (grids !== null && grids.length < 2) {
        await testAddFavoriteMenu(recommendMenuTips); // 如果取消收藏，则再加入一次。
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
      let titleBar: Component = await DRIVER.findComponent(ON.id('LHCommonTitleBar_title'));
      expect(titleBar !== null).assertTrue();
      let title: string = await titleBar.getText();
      expect(title.startsWith('家常')).assertTrue();
      // 是否能跳转至图片阅览页？
      let image: Component = await DRIVER.findComponent(ON.id('MenuDetailCard_image'));
      expect(image !== null).assertTrue();
      await image.click();
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
 * 测试将菜谱加入收藏。
 * @param recommendMenuTips 推荐菜谱列表提示。
 */
async function testAddFavoriteMenu(recommendMenuTips: Component) {
  await recommendMenuTips.click();
  await DRIVER.delayMs(1000);
  let titleBar: Component = await DRIVER.findComponent(ON.id('LHCommonTitleBar_title'));
  expect(titleBar !== null).assertTrue();
  let title: string = await titleBar.getText();
  expect(title.includes('今日推荐')).assertTrue();
  let recommendMenuCount: number = Number(title.substring(title.indexOf('(') + 1, title.length - 1));
  expect(recommendMenuCount > 0).assertTrue();
  // 是否能将菜谱加入收藏？
  let stars: Array<Component> = await DRIVER.findComponents(ON.id('LHMarkedStar'));
  expect(stars !== null && stars.length > 0).assertTrue();
  let star = stars[0];
  await star.click();
  await DRIVER.delayMs(1000);
  await DRIVER.pressBack(); // 返回首页检查菜谱收藏结果。
  await DRIVER.delayMs(1000);
}