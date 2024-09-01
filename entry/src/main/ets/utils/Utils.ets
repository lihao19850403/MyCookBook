import { GlobalContext } from './GlobalContext'
import { util } from '@kit.ArkTS';

/**
 * 通用工具类。
 * @author li.hao85
 */

/**
 * 解析rawfile下的json5文件。
 * @param fileName 文件名。
 * @returns 文件内容，字符串。
 */
export async function parseRawFileJson5(fileName: string): Promise<string> {
  let context = GlobalContext.getContext();
  if (context === undefined) {
    return '';
  }
  try {
    let rawFile = await context.resourceManager.getRawFileContent(fileName);
    let textDecoder = util.TextDecoder.create('UTF-8', { ignoreBOM: true });
    return textDecoder.decodeToString(rawFile, { stream: false });
  } catch (error) {

  }
  return '';
}

/**
 * 获取网络请求的key。
 * @returns 网络请求的key。
 */
export async function getHttpKey(): Promise<string> {
  let result: string = await parseRawFileJson5('key.json5');
  let info: Record<string, string> = JSON.parse(result) as Record<string, string>;
  return info['value'];
}