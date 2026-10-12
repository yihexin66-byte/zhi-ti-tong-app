import { http } from '@kit.NetworkKit'

/** 请求配置：业务侧的请求最终被构造成此结构传给拦截器链 */
export interface RequestConfig {
  url: string
  method: http.RequestMethod
  headers?: Record<string, string>
  body?: string                     // 已序列化为 JSON 字符串
}

/** 响应结果：HttpClient 收到 HttpResponse 后构造，再传给响应拦截器链 */
export interface HttpResult {
  code: number                      // HTTP 状态码
  raw: string                       // 响应原始字符串
}

/** 拦截器接口：onRequest 与 onResponse 都是可选钩子 */
export interface Interceptor {
  onRequest?(config: RequestConfig): RequestConfig
  onResponse?(result: HttpResult): HttpResult
}
