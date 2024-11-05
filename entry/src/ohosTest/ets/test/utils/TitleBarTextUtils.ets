import { Component, ON } from '@kit.TestKit';
import { Rect } from '@kit.ArkUI';
import { DRIVER } from './Utils';

/** 标题栏文字区域高度，用于查找控件时候的比较。 */
const TITLE_BAR_TEXT_HEIGHT: number = vp2px(48);

/**
 * 查找标题栏文字组件，一般页面上第一个Text控件就是。
 * @returns 标题栏文字组件。
 */
async function findCommonTitleBarText(): Promise<Component | undefined> {
  let navBarContent: Component = await DRIVER.findComponent(ON.type("NavBarContent"));
  let navDesContent: Component = await DRIVER.findComponent(ON.type('NavDestinationContent'));
  let titleBarCount: number = (navBarContent !== null ? 1 : 0) + (navDesContent !== null ? 1 : 0)
  if (titleBarCount === 0) {
    return undefined;
  }
  let comps: Array<Component> = await DRIVER.findComponents(ON.type('Text'));
  if (comps === null || comps.length === 0) {
    return undefined;
  }
  let result: Component | undefined = undefined;
  for (let index = 0; index < comps.length; index++) {
    let item: Component = comps[index];
    let bound: Rect = await item.getBounds();
    let height: number = bound.bottom - bound.top;
    if (Math.abs(height - TITLE_BAR_TEXT_HEIGHT) < 3) {
      titleBarCount--;
      if (titleBarCount === 0) {
        result = item;
        break;
      }
    }
  }
  return result;
}

/**
 * 检查标题栏文字区是否存在，并检查标题内容是否正确。
 * @param str 待检查的标题。
 * @returns 检查结果。
 */
export async function checkTitleBarTextIs(str: string): Promise<boolean> {
  let titleBar: Component | undefined = await findCommonTitleBarText();
  if (titleBar === undefined) {
    return false;
  }
  let title: string = await titleBar.getText();
  return title === str;
}

/**
 * 检查标题栏文字区是否存在，并检查标题内容是否包含所选子字符串。
 * @param str 待检查的子字符串。
 * @returns 检查结果。
 */
export async function checkTitleBarTextIncludes(str: string): Promise<boolean> {
  let titleBar: Component | undefined = await findCommonTitleBarText();
  if (titleBar === undefined) {
    return false;
  }
  let title: string = await titleBar.getText();
  return title.includes(str);
}

/**
 * 检查标题栏文字区是否存在，并获取标题。
 * @returns 标题栏文字区内容。
 */
export async function getTitleBarText(): Promise<string | undefined> {
  let titleBar: Component | undefined = await findCommonTitleBarText();
  if (titleBar === undefined) {
    return undefined;
  }
  let title: string = await titleBar.getText();
  return title;
}