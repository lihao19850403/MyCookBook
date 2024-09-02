import { GlobalContext } from './GlobalContext'
import { util } from '@kit.ArkTS';

/** 密钥信息。 */
export interface KeyInfo {

  /** 密钥ID。 */
  id: string;

  /** 密钥名称。 */
  name: string;

  /** 密钥描述。 */
  description: string;

  /** 密钥值。 */
  value: string;
}

/**
 * 读取密钥工具类。
 * @author li.hao85
 */
export class KeysUtils {

  /** 菜谱页面网络请求key。 */
  public static KEY_HOME_TAB_MENU_REQUEST: string = 'home_tab_menu_request';

  /** 记录密钥的文件名。 */
  private static KEYS_FILE_NAME: string = 'keys.json5';

  /** 配置记录。 */
  private static mMap: Record<string, KeyInfo> = {};

  /**
   * 获取密钥值。
   * @param id 密钥ID。
   * @returns 密钥值。
   */
  public static async getKeyForID(id: string): Promise<string> {
    let ids: string[] = Object.keys(KeysUtils.mMap);
    if (ids.length === 0) {
      await KeysUtils.initKeyInfos();
    }
    let keyInfo: KeyInfo = KeysUtils.mMap[id];
    return keyInfo ? keyInfo.value : '';
  }

  private static async initKeyInfos() {
    let context = GlobalContext.getContext();
    if (context === undefined) {
      return;
    }
    try {
      let rawFile = await context.resourceManager.getRawFileContent(KeysUtils.KEYS_FILE_NAME);
      let textDecoder = util.TextDecoder.create('UTF-8', { ignoreBOM: true });
      let fileContent: string = textDecoder.decodeToString(rawFile, { stream: false });
      let keyInfos: KeyInfo[] = JSON.parse(fileContent) as KeyInfo[];
      keyInfos.forEach((keyInfo: KeyInfo) => {
        KeysUtils.mMap[keyInfo.id] = keyInfo;
      })
    } catch (error) {
    }
  }
}