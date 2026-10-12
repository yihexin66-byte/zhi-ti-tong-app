/**
 * 登录/注册 ViewModel：业务逻辑与状态管理，零 UI
 *
 * 【数据来源】真实后端（LoginService → BaseService → httpClient）；
 * 校验三连保留为联网前置：挡住"不必发请求就能判死"的输入。
 */
import { BaseViewModel } from '@zhititong/common'
import { Result } from '@zhititong/common'
import { ValidationUtil } from '@zhititong/common'
import { SessionManager } from '@zhititong/common'
import { LoginResponseModel, UserInfoModel } from '../model/LoginResponseModel'
import { LoginService } from '../service/LoginService'

@ObservedV2
export class LoginViewModel extends BaseViewModel {
  // 表单输入字段（@Trace：变更自动刷新 View）
  @Trace username: string = ''
  @Trace password: string = ''
  @Trace confirmPwd: string = ''   // 注册时使用

  // 登录/注册切换：false=登录，true=注册
  @Trace isReg: boolean = false

  // 登录成功后的用户信息
  @Trace userInfo?: UserInfoModel

  // 登录服务（6-1 基础设施的第一个业务消费者）
  private loginService: LoginService = new LoginService()

  /**
   * 提交登录或注册：真实请求打到后端，返回类型与 Mock 时代一致（View 层零改动）
   */
  async submit(): Promise<Result<LoginResponseModel>> {
    // 1. 清错误
    this.clearError()

    // 2. 用户名校验
    const usernameValidation = ValidationUtil.validateUsername(this.username)
    if (!usernameValidation.isValid) {
      this.setError(usernameValidation.message ?? '用户名不合法')
      return Result.fail(-1, usernameValidation.message ?? '用户名不合法')
    }

    // 3. 密码校验
    const passwordValidation = ValidationUtil.validatePassword(this.password)
    if (!passwordValidation.isValid) {
      this.setError(passwordValidation.message ?? '密码不合法')
      return Result.fail(-1, passwordValidation.message ?? '密码不合法')
    }

    // 4. 注册需校验确认密码
    if (this.isReg) {
      const confirmValidation =
        ValidationUtil.validateConfirmPassword(this.password, this.confirmPwd)
      if (!confirmValidation.isValid) {
        this.setError(confirmValidation.message ?? '确认密码不一致')
        return Result.fail(-1, confirmValidation.message ?? '确认密码不一致')
      }
    }

    // 5. 进入加载态
    this.setLoading(true)

    try {
      // 注册流程：先注册（后端不返回 token），成功后走下面同一条登录流程
      if (this.isReg) {
        await this.loginService.register({
          username: this.username,
          password: this.password,
          confirmPassword: this.confirmPwd
        })
        this.logger.info(`注册成功，自动登录：${this.username}`)
      }

      // 登录：真实请求打到后端，拿 token + 用户信息
      const login = await this.loginService.login({
        username: this.username,
        password: this.password
      })

      // 会话落袋：token 进 Preferences（凭证），用户信息进 AppStorageV2（运行态）
      await SessionManager.save(login.token, login.userInfo)

      // 构造给 View 的业务模型（返回类型不变，View 层零改动）
      const userInfo = new UserInfoModel()
      userInfo.id = login.userInfo.id
      userInfo.username = login.userInfo.username
      this.userInfo = userInfo

      const response = new LoginResponseModel()
      response.success = true
      response.message = '登录成功'
      response.userInfo = userInfo

      this.logger.info(`${this.isReg ? '注册并登录' : '登录'}成功：${login.userInfo.username}`)
      return Result.ok<LoginResponseModel>(response)
    } catch (e) {
      // BaseService 把后端 message 原样抛上来（如"账号或密码错误""账号已存在"），直达 UI
      const errorMsg = (e as Error).message
      this.setError(errorMsg)
      this.logger.error(`提交失败：${errorMsg}`)
      return Result.fail(-1, errorMsg)
    } finally {
      // 6. 退出加载态
      this.setLoading(false)
    }
  }
}
