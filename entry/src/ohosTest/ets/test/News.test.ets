import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, TestType } from '@ohos/hypium';
import Want from '@ohos.app.ability.Want';
import { BUNDLE_NAME, DRIVER, sleep } from './utils/Utils';
import { ABILITY_NAME } from './utils/Utils';
import { DELEGATOR } from './utils/Utils';
import { UIAbility } from '@kit.AbilityKit';
import { Component, ON } from '@kit.TestKit';
import { checkTitleBarTextIs } from './utils/TitleBarTextUtils';

/** 首页 - 头条测试套。 */
export default function NewsTest() {
  describe('NewsTest', () => {
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
      let tabBarItem: Component = await DRIVER.findComponent(ON.text('头条'));
      expect(tabBarItem !== null).assertTrue();
      // 是否能切换至对应标签页？
      await tabBarItem.click();
      await DRIVER.delayMs(1000);
      let check: boolean = await checkTitleBarTextIs('头条');
      expect(check === true).assertTrue();
      finish();
    })

    /** 列表点击测试。 */
    it("listTest", TestType.FUNCTION, async (finish: Function) => {
      await DRIVER.delayMs(1000);
      // 是否加载出了新闻内容？
      let waterFlow: Component = await DRIVER.findComponent(ON.type('WaterFlow'));
      expect(waterFlow !== null).message('这项测试需要联网获取新闻列表后才能继续').assertTrue();
      // 是否能跳转至新闻详情？
      await waterFlow.scrollToTop();
      await DRIVER.delayMs(1000);
      let newsTipsCard: Component = await DRIVER.findComponent(ON.id('NewsTipsCard0'));
      expect(newsTipsCard !== null).assertTrue();
      await newsTipsCard.click();
      await DRIVER.delayMs(1000);
      let check: boolean = await checkTitleBarTextIs('新闻');
      expect(check === true).assertTrue();
      // 是否能跳转至浏览器页？
      let newsLink: Component = await DRIVER.findComponent(ON.id('news_link'));
      expect(newsLink !== null).assertTrue();
      await newsLink.click();
      await DRIVER.delayMs(1000);
      check = await checkTitleBarTextIs('浏览器');
      expect(check === true).assertTrue();
      // 返回首页。
      await DRIVER.pressBack();
      await DRIVER.pressBack();
      finish();
    })
  })
}