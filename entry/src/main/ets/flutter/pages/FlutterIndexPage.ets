import { common } from '@kit.AbilityKit';
import { FlutterEntry, FlutterManager, FlutterPage, FlutterView } from '@ohos/flutter_ohos';
import { GlobalContext } from '../../utils/common/GlobalContext';
import { RouterUtils } from '../../utils/common/RouterUtils';
import FlutterWrapEntry from '../utils/FlutterWrapEntry';

export namespace FlutterIndexPage {
  export function go(params?: Record<string, string | undefined>) {
    RouterUtils.navPushPath('FlutterIndexPage', params);
  }
}

@Builder
export function FlutterIndexPageBuilder() {
  FlutterIndexPageComponent()
}

/**
 * Flutter模块入口页。
 * @author li.hao85
 */
@Component
struct FlutterIndexPageComponent {
  private context = GlobalContext.getContext() as common.UIAbilityContext;
  private flutterEntry?: FlutterEntry;
  private flutterView?: FlutterView;

  aboutToDisappear(): void {
    this.flutterEntry?.aboutToDisappear();
  }

  build() {
    NavDestination() {
      Stack() {
        FlutterPage({
          viewId: this.flutterView?.getId()
        })
      }
    }
    .hideTitleBar(true)
    .backButtonIcon(undefined)
    .onReady((context: NavDestinationContext) => {
      this.flutterEntry = new FlutterWrapEntry(this.context);
      this.flutterEntry.aboutToAppear();
      this.flutterView = this.flutterEntry.getFlutterView();
    })
    .onShown(() => {
      FlutterManager.getInstance().setUseFullScreen(true);
      this.flutterEntry?.onPageShow();
    })
    .onHidden(() => {
      FlutterManager.getInstance().setUseFullScreen(false);
      this.flutterEntry?.onPageHide();
    })
    // .onBackPressed(() => {
    //   this.context.eventHub.emit('EVENT_BACK_PRESS');
    //   return true;
    // })
  }
}