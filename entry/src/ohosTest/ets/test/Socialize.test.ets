import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, TestType } from '@ohos/hypium';
import Want from '@ohos.app.ability.Want';
import { BUNDLE_NAME, DRIVER, sleep } from './utils/Utils';
import { ABILITY_NAME } from './utils/Utils';
import { DELEGATOR } from './utils/Utils';
import { UIAbility } from '@kit.AbilityKit';
import { Component, ON } from '@kit.TestKit';
import { checkTitleBarTextIs } from './utils/TitleBarTextUtils';

/** 首页 - 美食圈测试套。 */
export default function SocializeTest() {
  describe('SocializeTest', () => {
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
      let tabBarItem: Component = await DRIVER.findComponent(ON.text('美食圈'));
      expect(tabBarItem !== null).assertTrue();
      // 是否能切换至对应标签页？
      await tabBarItem.click();
      await DRIVER.delayMs(1000);
      let check: boolean = await checkTitleBarTextIs('美食圈');
      expect(check === true).assertTrue();
      finish();
    })

    /** 列表点击测试。 */
    it("webViewTest", TestType.FUNCTION, async (finish: Function) => {
      await DRIVER.delayMs(1000 * 3);
      // 是否加载出了美食圈内容？
      let webView: Component = await DRIVER.findComponent(ON.type('Web'));
      expect(webView !== null).assertTrue();
      // 返回首页。
      await DRIVER.pressBack();
      finish();
    })
  })
}