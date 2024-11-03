import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, TestType } from '@ohos/hypium';
import Want from '@ohos.app.ability.Want';
import { BUNDLE_NAME, sleep } from './utils/Utils';
import { ABILITY_NAME } from './utils/Utils';
import { DELEGATOR } from './utils/Utils';
import { UIAbility } from '@kit.AbilityKit';

/** Ability测试套。 */
export default function abilityTest() {
  describe('AbilityTest', () => {
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
  })
}