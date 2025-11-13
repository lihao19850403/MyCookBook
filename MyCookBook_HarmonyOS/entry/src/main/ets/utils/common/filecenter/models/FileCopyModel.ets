/**
 * 文件复制Model。
 * @author li.hao85
 */

/** 复制图片入参。 */
export interface CopyFileOptions {
  /** 源文件Uri。 */
  sourceUri: string,
  /** 目标路径。 */
  targetPath: string
}

/** 复制文件结果。 */
export interface CopyFileResult {
  /** 复制文件结果Uri。 */
  resultUri: string
}