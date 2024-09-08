import axios, { AxiosError, AxiosResponse } from '@ohos/axios'
import { http } from '@kit.NetworkKit';

/** 网络请求超时时间。 */
export const DEFAULT_REQUEST_TIMEOUT_MS = 1000 * 30;

/** 网络请求参数类型。 */
export type HttpRequestParams = Record<string, Object>;

/** 网络响应类型。 */
export interface CallResult<ResultType> {

  /** 状态码。 */
  status?: number;

  /** 附加信息。 */
  message?: string;

  /** 响应结果。 */
  data?: ResultType;
}

/**
 * 网络请求工具类。
 * @author li.hao85
 */
export class HttpUtils {

  /**
   * 发送一个GET请求。
   * @param apiPath 请求路径。
   * @returns 请求结果。
   */
  static get<ResultType>(apiPath: string): Promise<CallResult<ResultType>> {
    return axios<string, AxiosResponse<ResultType>, HttpRequestParams>({
      url: apiPath,
      timeout: DEFAULT_REQUEST_TIMEOUT_MS,
      method: http.RequestMethod.GET
    })
      .then((response: AxiosResponse<ResultType>) => {
        let result: CallResult<ResultType> = {
          status: response.status,
          message: response.statusText,
          data: response.data
        };
        return result;
      })
      .catch((error: AxiosError) => {
        let result: CallResult<ResultType> = {
          status: error.status,
          message: error.message
        };
        return result;
      })
  }

  /**
   * 发送一个POST请求。
   * @param apiPath 请求路径。
   * @param params 参数。
   * @returns 请求结果。
   */
  static post<ResultType>(apiPath: string, params: HttpRequestParams): Promise<CallResult<ResultType>> {
    return axios<string, AxiosResponse<ResultType>, HttpRequestParams>({
      url: apiPath,
      timeout: DEFAULT_REQUEST_TIMEOUT_MS,
      method: http.RequestMethod.POST,
      data: params
    })
      .then((response: AxiosResponse<ResultType>) => {
        let result: CallResult<ResultType> = {
          status: response.status,
          message: response.statusText,
          data: response.data
        };
        return result;
      })
      .catch((error: AxiosError) => {
        let result: CallResult<ResultType> = {
          status: error.status,
          message: error.message
        };
        return result;
      })
  }
}
