import { describe, it, expect } from '@ohos/hypium'
import { MockKit, when, ArgumentMatchers } from '@ohos/hamock'
import { SessionUserData } from '@zhititong/common'
import { LoginViewModel } from '../main/ets/features/login/viewModel/LoginViewModel'
import { LoginResult, LoginService } from '../main/ets/features/login/service/LoginService'
import {
  FIXTURE_ERROR_USER_EXISTS,
  FIXTURE_ERROR_WRONG_PASSWORD,
  FIXTURE_LOGIN_ADMIN,
  FIXTURE_LOGIN_OK,
  FIXTURE_REGISTER_OK
} from './Fixtures'

/**
 * 造一个被 hamock 接管的假 LoginService。
 * when(...)(ArgumentMatchers.any).afterReturn(...) 读作"这个方法被以任意参数调用时，返回这份夹具"。
 */
function createMockedService(loginResult: LoginResult, registerResult: SessionUserData): LoginService {
  const service = new LoginService()
  const mockKit = new MockKit()
  when(mockKit.mockFunc(service, service.login))(ArgumentMatchers.any)
    .afterReturn(Promise.resolve(loginResult))
  when(mockKit.mockFunc(service, service.register))(ArgumentMatchers.any)
    .afterReturn(Promise.resolve(registerResult))
  return service
}

/** 造一个按后端语义失败的假 LoginService（错误文案来自后端 message） */
function createFailingService(message: string): LoginService {
  const service = new LoginService()
  const mockKit = new MockKit()
  when(mockKit.mockFunc(service, service.login))(ArgumentMatchers.any)
    .afterAction(() => Promise.reject(new Error(message)))
  when(mockKit.mockFunc(service, service.register))(ArgumentMatchers.any)
    .afterAction(() => Promise.reject(new Error(message)))
  return service
}

export default function loginViewModelTest() {
  describe('loginViewModelSubmitTest', () => {
    // 隐含约定：前置校验挡住空用户名，压根不发网络请求
    it('should_fail_when_username_empty', 0, async () => {
      const vm = new LoginViewModel(createMockedService(FIXTURE_LOGIN_OK, FIXTURE_REGISTER_OK))
      vm.username = ''
      vm.password = '123456'
      const res = await vm.submit()
      expect(res.ok).assertEqual(false)
      expect(vm.errorMessage).assertEqual('用户名不能为空')
    })

    // 常规：账号存在、密码正确 → 登录成功，用户信息就位，无错误文案
    it('should_login_success_with_admin', 0, async () => {
      const vm = new LoginViewModel(createMockedService(FIXTURE_LOGIN_ADMIN, FIXTURE_REGISTER_OK))
      vm.username = 'admin'
      vm.password = 'admin123'
      const res = await vm.submit()
      expect(res.ok).assertEqual(true)
      expect(vm.errorMessage).assertEqual('')
      expect(vm.userInfo?.username).assertEqual('admin')
      expect(vm.errorMessage).assertEqual('')
    })

    // 常规：密码错误 → 后端 message 原样直达 UI
    it('should_fail_with_wrong_password', 0, async () => {
      const vm = new LoginViewModel(createFailingService(FIXTURE_ERROR_WRONG_PASSWORD))
      vm.username = 'student'
      vm.password = 'student123'
      const res = await vm.submit()
      expect(res.ok).assertEqual(false)
      expect(vm.errorMessage).assertEqual(FIXTURE_ERROR_WRONG_PASSWORD)
    })

    // 常规：注册已存在用户名 → 断言"调用参数"，不关心数据库效果
    it('should_fail_register_existing_username', 0, async () => {
      const vm = new LoginViewModel(createFailingService(FIXTURE_ERROR_USER_EXISTS))
      vm.isReg = true
      vm.username = 'admin'
      vm.password = 'admin123'
      vm.confirmPwd = 'admin123'
      const res = await vm.submit()
      expect(res.ok).assertEqual(false)
      expect(vm.errorMessage).assertEqual(FIXTURE_ERROR_USER_EXISTS)
    })

    // 常规：注册新用户成功并自动登录（注册 → 登录 → 会话落袋一条龙）
    it('should_register_and_auto_login', 0, async () => {
      const vm = new LoginViewModel(createMockedService(FIXTURE_LOGIN_OK, FIXTURE_REGISTER_OK))
      vm.isReg = true
      vm.username = 'student'
      vm.password = 'student123'
      vm.confirmPwd = 'student123'
      const res = await vm.submit()
      expect(res.ok).assertEqual(true)
      expect(vm.userInfo?.username).assertEqual('student')
    })

    // 隐含约定：无论成败，loading 最终必须回到 false（finally 兜底）
    // 漏了这条约定，真实界面会在登录失败后永远转圈
    it('should_reset_loading_after_submit', 0, async () => {
      const vm = new LoginViewModel(createFailingService(FIXTURE_ERROR_WRONG_PASSWORD))
      vm.username = 'student'
      vm.password = 'student123'
      await vm.submit()
      expect(vm.loading).assertEqual(false)
    })
  })
}
