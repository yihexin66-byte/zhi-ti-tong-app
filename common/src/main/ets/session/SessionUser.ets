/**
 * 当前登录用户（运行态）：AppStorageV2 全局单例
 *   - UI 侧 connect 后，字段变化（登录/登出）自动刷新
 *   - 不持久化：冷启动时由 SessionManager.loadFromDisk 从 Preferences 回填
 */
@ObservedV2
export class SessionUser {
  @Trace id: string = ''
  @Trace username: string = ''
  @Trace role: string = ''
  @Trace loggedIn: boolean = false
}

/** 会话数据的持久化形状（写进 Preferences 的 JSON） */
export interface SessionUserData {
  id: string
  username: string
  role: string
}
