import { HttpResult, Interceptor, RequestConfig } from './types'
import { Logger } from '../log/Logger'

// 工程日志口径：文件顶层 const，标签取文件主体名
const logger: Logger = new Logger('Interceptor')

/** Token 提供者：返回当前要使用的 Token；空字符串表示"未登录/不注入" */
export type TokenProvider = () => string

/** 拦截器①：自动注入 Authorization: Bearer <token> */
export class TokenInterceptor implements Interceptor {
  private tokenProvider: TokenProvider

  constructor(tokenProvider: TokenProvider) {
    this.tokenProvider = tokenProvider
  }

  onRequest(config: RequestConfig): RequestConfig {
    const token: string = this.tokenProvider()
    if (token !== '') {
      config.headers = config.headers ?? {}
      config.headers['Authorization'] = `Bearer ${token}`
    }
    return config
  }
}

/** 拦截器②：请求/响应日志 */
export class LoggingInterceptor implements Interceptor {
  onRequest(config: RequestConfig): RequestConfig {
    logger.info(`→ ${config.method} ${config.url}`)
    return config
  }

  onResponse(result: HttpResult): HttpResult {
    logger.info(`← HTTP ${result.code} (body ${result.raw.length} bytes)`)
    return result
  }
}
