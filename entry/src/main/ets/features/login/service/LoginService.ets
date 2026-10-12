import { BaseService, SessionUserData } from '@zhititong/common'

/** 登录请求（契约 2.2） */
export interface LoginRequest {
  username: string
  password: string
}

/** 注册请求（契约 2.1：两次密码由后端再校验一次） */
export interface RegisterRequest {
  username: string
  password: string
  confirmPassword: string
}

/** 登录成功时 data 的形状（契约 2.2）：token + 用户信息 */
export interface LoginResult {
  token: string
  userInfo: SessionUserData
}

export class LoginService extends BaseService {
  login(req: LoginRequest): Promise<LoginResult> {
    return this.postJson<LoginResult>('/api/auth/login', req)
  }

  register(req: RegisterRequest): Promise<SessionUserData> {
    return this.postJson<SessionUserData>('/api/auth/register', req)
  }
}
