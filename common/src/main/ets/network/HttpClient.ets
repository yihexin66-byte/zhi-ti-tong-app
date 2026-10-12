import { http } from '@kit.NetworkKit'
import { Interceptor, RequestConfig, HttpResult } from './types'
import { AppConfig } from '../config/AppConfig'

export class HttpClient {
  private interceptors: Interceptor[] = []

  /** 注册拦截器（按注册顺序依次经过） */
  use(interceptor: Interceptor): void {
    this.interceptors.push(interceptor)
  }

  async request(config: RequestConfig): Promise<HttpResult> {
    // URL 预处理：相对路径自动拼 BASE_URL
    let c: RequestConfig = {
      url: this.resolveUrl(config.url),
      method: config.method,
      headers: config.headers,
      body: config.body
    }

    // 1. 请求阶段拦截器
    for (const it of this.interceptors) {
      if (it.onRequest) {
        c = it.onRequest(c)
      }
    }

    // 2. 真正发起 HTTP 请求（每次新建会话、用完销毁）
    const httpRequest = http.createHttp()
    let result: HttpResult
    try {
      const response = await httpRequest.request(c.url, {
        method: c.method,
        header: c.headers,
        extraData: c.body,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: AppConfig.CONNECT_TIMEOUT,
        readTimeout: AppConfig.READ_TIMEOUT
      })
      result = { code: response.responseCode, raw: response.result as string }
    } finally {
      httpRequest.destroy()
    }

    // 3. 响应阶段拦截器
    for (const it of this.interceptors) {
      if (it.onResponse) {
        result = it.onResponse(result)
      }
    }
    return result
  }

  // ---------- 四个便捷方法：殊途同归，全部走 request ----------

  get(path: string, query?: Record<string, string>): Promise<HttpResult> {
    return this.request({
      url: this.appendQuery(path, query),
      method: http.RequestMethod.GET
    })
  }

  post(path: string, body?: object): Promise<HttpResult> {
    return this.request({
      url: path,
      method: http.RequestMethod.POST,
      headers: { 'Content-Type': 'application/json' },
      body: body === undefined ? undefined : JSON.stringify(body)
    })
  }

  put(path: string, body?: object): Promise<HttpResult> {
    return this.request({
      url: path,
      method: http.RequestMethod.PUT,
      headers: { 'Content-Type': 'application/json' },
      body: body === undefined ? undefined : JSON.stringify(body)
    })
  }

  delete(path: string): Promise<HttpResult> {
    return this.request({ url: path, method: http.RequestMethod.DELETE })
  }

  // ---------- 私有工具方法 ----------

  /** 相对路径自动拼 BASE_URL；已是完整 URL 则原样返回 */
  private resolveUrl(url: string): string {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url
    }
    return AppConfig.BASE_URL + url
  }

  /** 把 query 对象拼成 ?k1=v1&k2=v2，并对值做 encodeURIComponent */
  private appendQuery(path: string, query?: Record<string, string>): string {
    if (query === undefined) {
      return path
    }
    const parts: string[] = []
    for (const key of Object.keys(query)) {
      parts.push(`${encodeURIComponent(key)}=${encodeURIComponent(query[key])}`)
    }
    return parts.length === 0 ? path : `${path}?${parts.join('&')}`
  }
}
