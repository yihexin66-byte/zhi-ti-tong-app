import { describe, it, expect } from '@ohos/hypium'
import { MineViewModel } from '../main/ets/features/mine/viewModel/MineViewModel'

export default function mineViewModelTest() {
  describe('mineViewModelTest', () => {
    // 常规：加载成功，用户信息就位（Mock 占位）
    it('should_load_user_info_success', 0, async () => {
      const vm = new MineViewModel()
      const res = await vm.loadUserInfo()
      expect(res.ok).assertEqual(true)
      expect(vm.user.nickname).assertEqual('用户名')
      expect(vm.user.signature).assertEqual('个性签名')
    })

    // 隐含约定：加载完成后 loading 归 false（finally 兜底）、无错误信息
    it('should_reset_loading_after_load', 0, async () => {
      const vm = new MineViewModel()
      await vm.loadUserInfo()
      expect(vm.loading).assertEqual(false)
      expect(vm.errorMessage).assertEqual('')
    })

    // 边界：重复加载得到同一份占位数据（幂等，不产生脏状态）
    it('should_be_idempotent_on_reload', 0, async () => {
      const vm = new MineViewModel()
      await vm.loadUserInfo()
      const first = vm.user.nickname
      await vm.loadUserInfo()
      expect(vm.user.nickname).assertEqual(first)
    })
  })
}
