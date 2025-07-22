/** 日期格式。 */
export enum DATE_FORMAT {
  YYYY_MM_DD = '{y}-{m}-{d}',
  YYYY_MM_DD_hh_mm_ss = '{y}-{m}-{d} {h}:{i}:{s}',
  YYYY_MM_DD_hh_mm_ss_weekDay = '{y}-{m}-{d} {h}:{i}:{s} {a}'
}

/**
 * 时间工具类。
 * @author li.hao85
 */
export class DateUtils {

  /**
   * 格式化时间。
   * @param time 原始时间信息。
   * @param pattern 格式化字符串，有一些预设类型。
   * @returns 格式化结果。
   */
  public static formatDate(time: string | number | Date, pattern: DATE_FORMAT = DATE_FORMAT.YYYY_MM_DD_hh_mm_ss_weekDay): string {
    const date: Date = new Date(time);
    const formatObj: Record<string, number> = {
      'y': date.getFullYear(),
      'm': date.getMonth() + 1,
      'd': date.getDate(),
      'h': date.getHours(),
      'i': date.getMinutes(),
      's': date.getSeconds(),
      'a': date.getDay()
    };
    return pattern.replace(/{(y|m|d|h|i|s|a)+}/g, (match: string, key: string) => {
      let value: number = formatObj[key];
      if (key === 'a') {
        return ['周日', '周一', '周二', '周三', '周四', '周五', '周六'][value];
      }
      let maxLength: number = match === '{y}' ? 4 : 2;
      return value.toString().padStart(maxLength, '0');
    });
  }
}