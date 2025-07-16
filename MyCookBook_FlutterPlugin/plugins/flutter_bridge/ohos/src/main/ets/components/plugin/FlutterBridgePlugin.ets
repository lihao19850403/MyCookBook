import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';

/** Flutter桥方法处理器类型。 */
export type FlutterBridgeCallHandler = (methodName: string, methodParams: object | undefined, result: MethodResult) => void;

/** FlutterBridgePlugin **/
export default class FlutterBridgePlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;

  /** Flutter桥方法处理器，默认不处理。主工程可自行修改为有意义的工具。 */
  private bridgeCallHandler: FlutterBridgeCallHandler = (methodName, methodParams, result) =>
    console.log(`bridgeCallHandler 默认实现。方法：${methodName}，参数：${JSON.stringify(methodParams)}`);

  constructor() {
  }

  /**
   * 设置Flutter桥方法处理器。
   * @param newHandler 新的桥方法处理器。
   */
  setBridgeCallHandler(newHandler: FlutterBridgeCallHandler) {
    this.bridgeCallHandler = newHandler;
  }

  getUniqueClassName(): string {
    return "FlutterBridgePlugin"
  }

  getChannel(): MethodChannel | null {
    return this.channel;
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "flutter_bridge");
    this.channel.setMethodCallHandler(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    let methodName: string = call.method;
    let methodParams: object | undefined = call.args;
    this.bridgeCallHandler(methodName, methodParams, result);
  }
}