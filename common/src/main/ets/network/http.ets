import { HttpClient } from './HttpClient'
import { TokenInterceptor, LoggingInterceptor, TokenProvider } from './interceptors'
import { AppConfig } from '../config/AppConfig'

/**
 * Token 提供者占位：
 *   本实训阶段返回空字符串（不注入）；
 *   6-2 登录打通后一行 setTokenProvider(() => SessionManager.getToken()) 即激活。
 */
let currentTokenProvider: TokenProvider = () => ''

export function setTokenProvider(provider: TokenProvider): void {
  currentTokenProvider = provider
}

/** 全局唯一的 HttpClient 实例 */
export const httpClient: HttpClient = new HttpClient()

// 拦截器①：Token 注入——注意传入的是箭头函数而非变量本身
httpClient.use(new TokenInterceptor(() => currentTokenProvider()))

// 拦截器②：日志，受 AppConfig 开关控制
if (AppConfig.ENABLE_HTTP_LOG) {
  httpClient.use(new LoggingInterceptor())
}
