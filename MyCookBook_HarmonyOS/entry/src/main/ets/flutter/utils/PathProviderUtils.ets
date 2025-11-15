import PathProviderPlugin from 'path_provider_ohos';

/**
 * 鸿蒙平台下的PathProvider插件实例。
 * @author li.hao85
 */
class PathProviderUtils {

  private static instance: PathProviderUtils;

  pathProviderPlugin: PathProviderPlugin;

  private constructor() {
    this.pathProviderPlugin = new PathProviderPlugin();
  }

  public static getInstance(): PathProviderUtils {
    if (PathProviderUtils.instance === undefined) {
      PathProviderUtils.instance = new PathProviderUtils();
    }
    return PathProviderUtils.instance;
  }
}

export function getPathProviderPlugin(): PathProviderPlugin {
  return PathProviderUtils.getInstance().pathProviderPlugin;
}