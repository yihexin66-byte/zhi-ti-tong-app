import { AppStorageV2 } from '@kit.ArkUI'
import { PreferencesUtil } from '../utils/PreferencesUtil'
import { StateKeys } from '../constants/StateKeys'
import { SessionUser, SessionUserData } from './SessionUser'
import { Logger } from '../log/Logger'

const logger: Logger = new Logger('SessionManager')

/**
 * 登录态生命周期管理者：一个类同时驾驭两种状态工具
 *   - token 走 Preferences（凭证，重启还在）+ 内存缓存（拦截器零 IO 高频读）
 *   - "当前用户是谁"走 AppStorageV2（运行态 UI 状态，页面响应式消费）
 */
export class SessionManager {
  private static readonly PREF_NAME: string = 'user_session'
  private static readonly KEY_TOKEN: string = 'token'
  private static readonly KEY_USER: string = 'user_info'

  /** token 内存缓存：TokenInterceptor 每次请求都读，必须零 IO */
  private static cachedToken: string = ''

  /** 运行态用户（AppStorageV2 全局单例；UI 侧也用同一行 connect 消费） */
  static getUser(): SessionUser {
    return AppStorageV2.connect(SessionUser, StateKeys.SESSION_USER, () => new SessionUser())!
  }

  /** 同步取 token（供 TokenInterceptor 高频调用） */
  static getToken(): string {
    return SessionManager.cachedToken
  }

  /** 是否处于已登录态（内存缓存判定，零 IO） */
  static isLoggedIn(): boolean {
    return SessionManager.cachedToken !== ''
  }

  /** 应用启动时调用一次：把上次会话从磁盘恢复到内存与运行态 */
  static loadFromDisk(): void {
    SessionManager.cachedToken = PreferencesUtil.getString(
      SessionManager.PREF_NAME, SessionManager.KEY_TOKEN, '')
    const userJson: string = PreferencesUtil.getString(
      SessionManager.PREF_NAME, SessionManager.KEY_USER, '')
    if (SessionManager.cachedToken === '' || userJson === '') {
      return
    }
    try {
      const saved = JSON.parse(userJson) as SessionUserData
      const user = SessionManager.getUser()
      user.id = saved.id
      user.username = saved.username
      user.role = saved.role
      user.loggedIn = true
      logger.info(`已恢复上次会话：${saved.username}`)
    } catch (e) {
      logger.warn('本地会话数据解析失败，按未登录处理')
    }
  }

  /** 登录成功时调用：token 入 Preferences（凭证），用户信息进运行态并落盘 */
  static async save(token: string, data: SessionUserData): Promise<void> {
    SessionManager.cachedToken = token
    const user = SessionManager.getUser()
    user.id = data.id
    user.username = data.username
    user.role = data.role
    user.loggedIn = true
    await PreferencesUtil.putString(
      SessionManager.PREF_NAME, SessionManager.KEY_TOKEN, token)
    await PreferencesUtil.putString(
      SessionManager.PREF_NAME, SessionManager.KEY_USER, JSON.stringify(data))
  }

  /** 登出：内存与运行态立即清空，磁盘异步清理（失败仅记日志，不阻塞 UI） */
  static logout(): void {
    SessionManager.cachedToken = ''
    const user = SessionManager.getUser()
    user.id = ''
    user.username = ''
    user.role = ''
    user.loggedIn = false
    PreferencesUtil.clear(SessionManager.PREF_NAME)
      .catch((e: Error) => logger.warn(`登出清盘失败：${e.message}`))
  }
}
