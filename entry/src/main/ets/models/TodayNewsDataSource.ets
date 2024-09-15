import { LHBasicDataSource } from './common/LHBaseDataSource';
import { TodayNewsItem } from './TodayNewsModel';

/**
 * 今日新闻数据源。
 * @author li.hao85
 */
export class TodayNewsDataSource extends LHBasicDataSource<TodayNewsItem> {

  /**
   * 获取全部新闻。
   * @returns 全部新闻。
   */
  public getAllData(): TodayNewsItem[] {
    return this.dataArray;
  }

  /**
   * 增加多条新闻。
   * @param newsArray 多条新闻内容。
   */
  public appendNewsArray(newsArray: TodayNewsItem[]) {
    if (newsArray === undefined || newsArray.length === 0) {
      return;
    }
    this.dataArray = this.dataArray.concat(newsArray);
    this.notifyMultipleDataAdded(this.dataArray.length - newsArray.length, newsArray.length);
  }

  /**
   * 删除多条新闻。
   */
  public deleteAllNews() {
    if (this.dataArray === undefined || this.dataArray.length === 0) {
      return;
    }
    this.dataArray.splice(0, this.dataArray.length);
    this.notifyMultipleDataDeleted(0, this.dataArray.length);
  }
}