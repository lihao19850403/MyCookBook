import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, TestType } from '@ohos/hypium';
import Want from '@ohos.app.ability.Want';
import { BUNDLE_NAME, DRIVER, sleep } from './Utils';
import { ABILITY_NAME } from './Utils';
import { DELEGATOR } from './Utils';
import { UIAbility } from '@kit.AbilityKit';
import { Component, ON } from '@kit.TestKit';

/** 首页 - 我的测试套。 */
export default function MineTest() {
  describe('MineTest', () => {
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
      let tabBarItem: Component = await DRIVER.findComponent(ON.text('我的'));
      expect(tabBarItem !== null).assertTrue();
      // 是否能切换至对应标签页？
      await tabBarItem.click();
      await DRIVER.delayMs(1000);
      let titleBar: Component = await DRIVER.findComponent(ON.description('LHCommonTitleBar_title'));
      expect(titleBar !== null).assertTrue();
      let title: string = await titleBar.getText();
      expect(title).assertEqual('我的');
      finish();
    })

    /** 每日养生测试。 */
    it("healthyTipsTest", TestType.FUNCTION, async (finish: Function) => {
      await DRIVER.delayMs(1000);
      let title: Component = await DRIVER.findComponent(ON.text('每日养生'));
      expect(title !== null).assertTrue();
      let todayTips: Component = await DRIVER.findComponent(ON.id('todayTips'));
      expect(todayTips !== null).assertTrue();
      let tipsContent: string = await todayTips.getText();
      expect(tipsContent !== null && tipsContent.length > 0).message('这项测试需要联网获取每日养生信息才能通过').assertTrue();
      finish();
    })

    /** 应用首页点击测试。 */
    it("appFirstPageTest", TestType.FUNCTION, async (finish: Function) => {
      await DRIVER.delayMs(1000);
      let gridItems: Array<Component> = await DRIVER.findComponents(ON.type('GridItem'));
      expect(gridItems !== null && gridItems.length > 0).assertTrue();
      let firstPageGridItem: Component = gridItems[0];
      let oldConfig: number = (await DRIVER.findComponents(ON.text('头条'))).length;
      expect(oldConfig === 2).assertTrue();
      await firstPageGridItem.click();
      await DRIVER.delayMs(1000);
      let newConfig: number = (await DRIVER.findComponents(ON.text('头条'))).length;
      expect(newConfig === 1).assertTrue();
      finish();
    })

    /** 字号设置功能点击测试。 */
    it("textSizeTest", TestType.FUNCTION, async (finish: Function) => {
      await DRIVER.delayMs(1000);
      let gridItems: Array<Component> = await DRIVER.findComponents(ON.type('GridItem'));
      expect(gridItems !== null && gridItems.length > 1).assertTrue();
      let secondPageGridItem: Component = gridItems[1];
      expect(secondPageGridItem !== null).assertTrue();
      let smallConfig: Array<Component> = await DRIVER.findComponents(ON.text('小'));
      let oldConfig: number = smallConfig !== null ? smallConfig.length : 0;
      expect(oldConfig === 2).assertTrue();
      await secondPageGridItem.click();
      await DRIVER.delayMs(1000);
      smallConfig = await DRIVER.findComponents(ON.text('小'));
      let newConfig: number = smallConfig !== null ? smallConfig.length : 0
      expect(newConfig === 0).assertTrue();
      finish();
    })

    /** 分屏设置功能点击测试。 */
    it("splitScreenTest", TestType.FUNCTION, async (finish: Function) => {
      await DRIVER.delayMs(1000);
      let gridItems: Array<Component> = await DRIVER.findComponents(ON.type('GridItem'));
      expect(gridItems !== null && gridItems.length > 2).assertTrue();
      let thirdPageGridItem: Component = gridItems[2];
      expect(thirdPageGridItem !== null).assertTrue();
      let oldConfig: Component = await DRIVER.findComponent(ON.text('关闭'));
      expect(oldConfig !== null).assertTrue();
      await thirdPageGridItem.click();
      await DRIVER.delayMs(1000);
      let newConfig: Component = await DRIVER.findComponent(ON.text('打开'));
      expect(newConfig !== null).assertTrue();
      finish();
    })

    /** 跳转至菜谱收藏夹功能点击测试。 */
    it("jumpToFavoriteMenusTest", TestType.FUNCTION, async (finish: Function) => {
      await DRIVER.delayMs(1000);
      let gridItems: Array<Component> = await DRIVER.findComponents(ON.type('GridItem'));
      expect(gridItems !== null && gridItems.length > 3).assertTrue();
      let lastPageGridItem: Component = gridItems[3];
      expect(lastPageGridItem !== null).assertTrue();
      await lastPageGridItem.click();
      await DRIVER.delayMs(1000);
      let titleBar: Component = await DRIVER.findComponent(ON.description('LHCommonTitleBar_title'));
      expect(titleBar !== null).assertTrue();
      let title: string = await titleBar.getText();
      expect(title).assertEqual('菜谱');
      finish();
    })
  })
}