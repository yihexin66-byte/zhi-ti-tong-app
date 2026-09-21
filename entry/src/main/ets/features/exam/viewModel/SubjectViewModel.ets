/**
 * SubjectViewModel — 考试科目页 ViewModel（viewModel 层）
 *
 * 【分层约束】
 *   1. @ObservedV2 class，继承 common/base/BaseViewModel
 *   2. 状态一律 @Trace，变更自动驱动 View 刷新
 *   3. 异步业务方法返回 common/base/Result
 *   4. 本文件零 UI 组件、零 @Builder、零导航栈操作（导航留在 View 层）
 *
 * 【数据来源】
 *   Mock 数据只来自 common/mock（MOCK_PAPERS），模块内不新造业务数据；
 *   科目聚合复用 common/utils/PaperUtils 的 groupByCategory 纯函数（已测，不重写）。
 */
import { BaseViewModel } from '../../../common/base/BaseViewModel'
import { Result } from '../../../common/base/Result'
import { Logger } from '../../../common/log/Logger'
import { MOCK_PAPERS } from '../../../common/mock/MockExamData'
import { CategoryGroup, groupByCategory } from '../../../common/utils/PaperUtils'

@ObservedV2
export class SubjectViewModel extends BaseViewModel {
  // 科目分组列表（@Trace：变更自动刷新科目网格）
  @Trace categories: CategoryGroup[] = []

  constructor() {
    super()
    this.logger = new Logger('[SubjectViewModel]')
  }

  /**
   * 加载科目分组（首屏数据入口：当前走 Mock，项目 6 换网络请求时 View 层零改动）
   */
  async loadCategories(): Promise<Result<CategoryGroup[]>> {
    this.clearError()
    this.setLoading(true)
    try {
      const groups = groupByCategory(MOCK_PAPERS)
      this.categories = groups
      this.logger.info(`科目分组加载完成，共 ${groups.length} 个科目`)
      return Result.ok<CategoryGroup[]>(groups)
    } catch (e) {
      const errorMsg = '科目加载失败，请稍后重试'
      this.setError(errorMsg)
      this.logger.error(errorMsg)
      return Result.fail<CategoryGroup[]>(-1, errorMsg)
    } finally {
      this.setLoading(false)
    }
  }
}
