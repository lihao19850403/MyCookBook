import { DialogContainerParams, LHDialogContainer } from "../../pages/common/dialogcontainer/LHDialogContainer";
import { LHAlertDialogView } from "../../views/common/LHAlertDialogView";

/**
 * 对话框相关工具类。
 * @author li.hao85
 */

/**
 * 打开一个自定义对话框。
 * @param params 参数。
 */
export function openCustomDialog(params: DialogContainerParams) {
  LHDialogContainer.open(params);
}

/** 警告对话框参数。 */
export interface LHAlertDialogParams {
  /** 标题，若不指定标题，则标题区域不会出现在对话框中。 */
  title?: ResourceStr,
  /** 内容，若不指定内容，则内容区域不会出现在对话框中。 */
  content?: ResourceStr,
  /** 取消按钮动作，若不指定取消按钮动作，则取消按钮不会出现在对话框中。 */
  cancelAction?: Callback<void, void>,
  /** 确定按钮动作，若不指定确定按钮动作，则确定按钮不会出现在对话框中。 */
  confirmAction?: Callback<void, void>
}

/**
 * 打开一个警告对话框。
 * 这个对话框含标题、内容、取消按钮、确认按钮。
 * @param params 参数。
 */
export function openAlertDialog(params: LHAlertDialogParams) {
  LHDialogContainer.open({
    builder: wrapBuilder(alertDialogBuilder),
    data: params,
    cancelCallback: params.cancelAction
  });
}

@Builder
function alertDialogBuilder(params: Object, closeCallback: Callback<void, void>) {
  LHAlertDialogView({
    title: (params as LHAlertDialogParams).title,
    content: (params as LHAlertDialogParams).content,
    cancelAction: (params as LHAlertDialogParams).cancelAction,
    confirmAction: (params as LHAlertDialogParams).confirmAction,
    closeCallback: closeCallback
  })
}