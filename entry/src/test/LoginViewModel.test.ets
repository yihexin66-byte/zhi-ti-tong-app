import { describe, it, expect } from '@ohos/hypium'
import { LoginViewModel } from '../main/ets/features/login/viewModel/LoginViewModel'

export default function loginViewModelTest() {
  describe('loginViewModelSubmitTest', () => {
    // 常规：空用户名直接失败，且给出可展示的错误信息
    it('should_fail_when_username_empty', 0, async () => {
      const vm = new LoginViewModel()
      vm.username = ''
      vm.password = '123456'
      const res = await vm.submit()
      expect(res.ok).assertEqual(false)
      expect(vm.errorMessage.length > 0).assertEqual(true)
    })

    // 常规：正确账号登录成功，用户信息就位
    it('should_login_success_with_admin', 0, async () => {
      const vm = new LoginViewModel()
      vm.username = 'admin'
      vm.password = '123456'
      const res = await vm.submit()
      expect(res.ok).assertEqual(true)
      expect(vm.userInfo?.username).assertEqual('admin')
    })

    // 常规：密码错误
    it('should_fail_with_wrong_password', 0, async () => {
      const vm = new LoginViewModel()
      vm.username = 'admin'
      vm.password = '654321'
      const res = await vm.submit()
      expect(res.ok).assertEqual(false)
      expect(res.errorMessage).assertEqual('用户名或密码错误')
    })

    // 常规：注册已存在用户名
    it('should_fail_register_existing_username', 0, async () => {
      const vm = new LoginViewModel()
      vm.isReg = true
      vm.username = 'admin'
      vm.password = '123456'
      vm.confirmPwd = '123456'
      const res = await vm.submit()
      expect(res.ok).assertEqual(false)
      expect(res.errorMessage).assertEqual('用户名已存在')
    })

    // 常规：注册新用户成功并自动登录
    it('should_register_and_auto_login', 0, async () => {
      const vm = new LoginViewModel()
      vm.isReg = true
      vm.username = 'student01'
      vm.password = '123456'
      vm.confirmPwd = '123456'
      const res = await vm.submit()
      expect(res.ok).assertEqual(true)
      expect(vm.userInfo?.username).assertEqual('student01')
    })

    // 隐含约定：无论成败，loading 最终必须回到 false（finally 兜底）
    // 漏了这条约定，真实界面会在登录失败后永远转圈
    it('should_reset_loading_after_submit', 0, async () => {
      const vm = new LoginViewModel()
      vm.username = 'admin'
      vm.password = '654321'   // 故意失败
      await vm.submit()
      expect(vm.loading).assertEqual(false)
    })
  })
}