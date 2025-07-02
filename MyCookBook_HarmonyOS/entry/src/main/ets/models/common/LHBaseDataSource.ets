/**
 * 懒加载通用的数据源。
 * @author li.hao85
 */
export class LHBasicDataSource<T> implements IDataSource {

  /** 数据改变监听。 */
  protected listeners: DataChangeListener[] = [];

  /** 数据源。 */
  protected dataArray: T[] = [];

  /**
   * 数据总量。
   * @returns 数据总量。
   */
  totalCount(): number {
    return this.dataArray.length;
  }

  /**
   * 获取数据。
   * @param index 序号。
   * @returns 数据。
   */
  getData(index: number): T {
    return this.dataArray[index];
  }

  /**
   * 注册一个数据改变监听器。
   * @param listener 数据改变监听器。
   */
  registerDataChangeListener(listener: DataChangeListener): void {
    if (!this.listeners.includes(listener)) {
      this.listeners.push(listener);
    }
  }

  /**
   * 取消数据改变监听的注册。
   * @param listener 数据改变监听器。
   */
  unregisterDataChangeListener(listener: DataChangeListener): void {
    let index = this.listeners.indexOf(listener);
    if (index !== -1) {
      this.listeners.splice(index, 1);
    }
  }

  /**
   * 通知所有数据重载。
   */
  protected notifyDataReloaded() {
    this.listeners.forEach((listener: DataChangeListener) => listener.onDataReloaded());
  }

  /**
   * 通知在index位置插入数据。
   * @param index 待插入数据的位置。
   */
  protected notifyDataAdded(index: number) {
    this.listeners.forEach((listener: DataChangeListener) => listener.onDataAdd(index));
  }

  /**
   * 通知连续插入了多个数据。
   * @param startIndex 首个数据插入位置。
   * @param count 新增数据数量。
   */
  protected notifyMultipleDataAdded(startIndex: number, count: number) {
    let flag: DataAddOperation = {
      type: DataOperationType.ADD,
      index: startIndex,
      count: count
    };
    this.listeners.forEach((listener: DataChangeListener) => listener.onDatasetChange([flag]));
  }

  /**
   * 通知数据从from位置移动至to位置。
   * @param from 起始位置。
   * @param to 目标位置。
   */
  protected notifyDataMoved(from: number, to: number) {
    this.listeners.forEach((listener: DataChangeListener) => listener.onDataMove(from, to));
  }

  /**
   * 通知删除index位置的数据。
   * @param index 待删除数据的位置。
   */
  protected notifyDataDeleted(index: number) {
    this.listeners.forEach((listener: DataChangeListener) => listener.onDataDelete(index));
  }

  /**
   * 通知连续删除了多个数据。
   * @param startIndex 首个数据删除位置。
   * @param count 删除数据数量。
   */
  protected notifyMultipleDataDeleted(startIndex: number, count: number) {
    let flag: DataDeleteOperation = {
      type: DataOperationType.DELETE,
      index: startIndex,
      count: count
    };
    this.listeners.forEach((listener: DataChangeListener) => listener.onDatasetChange([flag]));
  }

  /**
   * 通知index位置的数据内容发生了变化，此位置的组件要重建。
   * @param index 发生变化的数据所在位置。
   */
  protected notifyDataChanged(index: number) {
    this.listeners.forEach((listener: DataChangeListener) => listener.onDataChange(index));
  }

  /**
   * 通知多个位置的数据内容都发生了变化，这些位置的组件都要重建。
   * @param indexes 多个发生变化的数据所在位置。
   */
  protected notifyMultipleDataChanged(indexes: number[]) {
    let flags: DataChangeOperation[] = indexes.map((index: number) => {
      return {
        type: DataOperationType.CHANGE,
        index: index
      } as DataChangeOperation;
    });
    this.listeners.forEach((listener: DataChangeListener) => listener.onDatasetChange(flags));
  }
}