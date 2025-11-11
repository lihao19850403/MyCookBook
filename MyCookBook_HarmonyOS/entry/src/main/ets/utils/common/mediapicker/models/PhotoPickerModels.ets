/** 选取图片入参。 */
export interface PickPhotoOptions {
  /** 最多选取图片张数，默认选取一张。 */
  maxSelectNumber?: number
}

/** 复制图片入参。 */
export interface CopyPhotoOptions {
  /** 源图Uri。 */
  sourceUri: string,
  /** 目标路径。 */
  targetPath: string
}

/** 复制图片结果。 */
export interface CopyPhotoResult {
  /** 复制图片结果Uri。 */
  resultUri: string
}