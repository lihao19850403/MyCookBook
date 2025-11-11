import PathProviderPlugin from 'path_provider_ohos';

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