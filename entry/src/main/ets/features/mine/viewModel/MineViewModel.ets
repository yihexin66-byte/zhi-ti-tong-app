/**
 * MineViewModel — 个人中心 ViewModel（viewModel 层）
 *
 * 【分层约束】
 *   1. @ObservedV2 class，继承 common/base/BaseViewModel
 *   2. 状态一律 @Trace，变更自动驱动 View 刷新
 *   3. 异步业务方法返回 common/base/Result
 *   4. 本文件零 UI 组件、零 @Builder、零导航栈操作（导航留在 View 层）
 *
 * 【职责边界（刻意保持轻量）】
 *   mine 是最薄的模块：只管用户信息一项动态数据（Mock 占位，项目 6 接真数据）；
 *   四个设置项为纯静态展示，不为其建 Model/数据源（避免为 MVVM 而 MVVM）；
 *   退出登录的 pageStack.clear() 属导航，留在 View 层。
 */
import { BaseViewModel } from '@zhititong/common'
import { Result } from '@zhititong/common'
import { Logger } from '@zhititong/common'
import { MineUserModel } from '../model/MineUserModel'

@ObservedV2
export class MineViewModel extends BaseViewModel {
  // 用户信息（Mock 占位，项目 6 换真实接口后此字段直接更新）
  @Trace user: MineUserModel = new MineUserModel('', '')

  constructor() {
    super()
    this.logger = new Logger('[MineViewModel]')
  }

  /**
   * 加载用户信息（当前走 Mock 占位，项目 6 换网络请求时 View 层零改动）
   */
  async loadUserInfo(): Promise<Result<MineUserModel>> {
    this.clearError()
    this.setLoading(true)
    try {
      this.user = this.mockUser()
      this.logger.info(`用户信息加载完成：${this.user.nickname}`)
      return Result.ok<MineUserModel>(this.user)
    } catch (e) {
      const errorMsg = '用户信息加载失败，请稍后重试'
      this.setError(errorMsg)
      this.logger.error(errorMsg)
      return Result.fail<MineUserModel>(-1, errorMsg)
    } finally {
      this.setLoading(false)
    }
  }

  /**
   * Mock 占位用户（项目 6 移除，改调真实接口）
   */
  private mockUser(): MineUserModel {
    return new MineUserModel('用户名', '个性签名')
  }
}
