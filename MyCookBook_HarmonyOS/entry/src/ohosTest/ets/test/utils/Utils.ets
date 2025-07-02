import { abilityDelegatorRegistry, Driver } from '@kit.TestKit';

export const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
export const DRIVER: Driver = Driver.create();

export const BUNDLE_NAME: string = abilityDelegatorRegistry.getArguments().bundleName;
export const ABILITY_NAME: string = 'EntryAbility';

export function sleep(time: number) {
  return new Promise<void>((resolve: Function) => setTimeout(resolve, time));
}