/**
 * 登录/注册 ViewModel：业务逻辑与状态管理，零 UI
 */
import { BaseViewModel } from '../../../common/base/BaseViewModel'
import { Result } from '../../../common/base/Result'
import { ValidationUtil } from '../../../common/utils/ValidationUtil'
import { LoginResponseModel, UserInfoModel } from '../model/LoginResponseModel'

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

  /**
   * 提交登录或注册（Mock 验证，项目 6 换网络请求时 View 层零改动）
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
      // 6. 模拟网络延迟
      await this.delay(1000)

      let result: Result<LoginResponseModel>

      if (this.isReg) {
        // 注册流程：注册成功后自动登录
        result = this.mockRegisterCheck()
        if (result.ok) {
          this.logger.info(`注册成功，自动登录：${this.username}`)
          result = this.mockLoginCheck(true)
        }
      } else {
        result = this.mockLoginCheck(false)
      }

      if (result.ok) {
        this.userInfo = result.value?.userInfo
        this.logger.info(`${this.isReg ? '注册并登录' : '登录'}成功：${this.userInfo?.username}`)
      } else {
        this.setError(result.errorMessage ?? '操作失败')
      }

      return result
    } catch (e) {
      const errorMsg = '操作异常，请稍后重试'
      this.setError(errorMsg)
      this.logger.error(errorMsg)
      return Result.fail(-1, errorMsg)
    } finally {
      // 7. 退出加载态
      this.setLoading(false)
    }
  }

  /**
   * Mock 登录验证：固定账号 admin / 123456；
   * 注册后自动登录时（justRegistered）直接放行
   */
  private mockLoginCheck(justRegistered: boolean): Result<LoginResponseModel> {
    const passed = justRegistered ||
      (this.username === 'admin' && this.password === '123456')

    if (passed) {
      const userInfo = new UserInfoModel()
      userInfo.id = justRegistered ? `${Date.now()}` : '1'
      userInfo.username = this.username
      userInfo.nickname = justRegistered ? this.username : '管理员'

      const response = new LoginResponseModel()
      response.success = true
      response.message = '登录成功'
      response.userInfo = userInfo

      return Result.ok<LoginResponseModel>(response)
    }
    return Result.fail(-1, '用户名或密码错误')
  }

  /**
   * Mock 注册验证：admin 视为已存在
   */
  private mockRegisterCheck(): Result<LoginResponseModel> {
    if (this.username === 'admin') {
      return Result.fail(-1, '用户名已存在')
    }
    const response = new LoginResponseModel()
    response.success = true
    response.message = '注册成功'
    return Result.ok<LoginResponseModel>(response)
  }

  /**
   * 模拟网络延迟
   */
  private delay(ms: number): Promise<void> {
    return new Promise<void>(resolve => setTimeout(resolve, ms))
  }
}