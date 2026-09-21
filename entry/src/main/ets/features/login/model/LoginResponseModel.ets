/**
 * 登录响应数据模型
 */
export class LoginResponseModel {
  success: boolean = false      // 登录是否成功
  message: string = ''          // 响应消息
  userInfo?: UserInfoModel      // 用户信息（登录成功时携带）
}

/**
 * 用户信息模型
 */
export class UserInfoModel {
  id: string = ''               // 用户ID（对齐契约：string 雪花ID）
  username: string = ''         // 用户名
  nickname?: string             // 昵称（可选）
}