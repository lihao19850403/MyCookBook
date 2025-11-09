import photoAccessHelper from "@ohos.file.photoAccessHelper";
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 图片选择器工具类。
 * @author li.hao85
 */

/**
 * 图片选择器选取结果回调类型。
 * @param pickResult 已选中图片信息。
 * @param error 出错信息。
 */
export type PickPhotoCallback = (pickResult?: photoAccessHelper.PhotoSelectResult, error?: BusinessError) => void;

/** 图片选择器入参。 */
export interface PickPhotoOptions {
  /** 最多选取图片张数，默认选取一张。 */
  maxSelectNumber?: number,
  /** 图片选择器选取结果回调。 */
  callback?: PickPhotoCallback
}

/**
 * 选取图片。
 * @param options 入参。
 */
export function pickPhoto(options?: PickPhotoOptions) {
  let photoPicker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
  photoPicker.select({
    MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
    maxSelectNumber: options?.maxSelectNumber !== undefined ? Math.max(1, options.maxSelectNumber) : 1,
    isSearchSupported: true,
  })
    .then((pickResult: photoAccessHelper.PhotoSelectResult) => options?.callback?.(pickResult, undefined))
    .catch((error: BusinessError) => options?.callback?.(undefined, error));
}