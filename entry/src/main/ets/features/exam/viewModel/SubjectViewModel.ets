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
 *   真实后端（PaperService → BaseService → httpClient）；
 *   科目聚合复用 common/utils/PaperUtils 的 groupByCategory 纯函数（已测，不重写）。
 *   Service 经构造器注入：日常无感知，单测可塞入假 Service。
 */
import { BaseViewModel } from '@zhititong/common'
import { Result } from '@zhititong/common'
import { Logger } from '@zhititong/common'
import { CategoryGroup, groupByCategory } from '@zhititong/common'
import { PaperService } from '../service/PaperService'

@ObservedV2
export class SubjectViewModel extends BaseViewModel {
  // 科目分组列表（@Trace：变更自动刷新科目网格）
  @Trace categories: CategoryGroup[] = []

  private paperService: PaperService

  constructor(service: PaperService = new PaperService()) {
    super()
    this.logger = new Logger('[SubjectViewModel]')
    this.paperService = service
  }

  /**
   * 加载科目分组（真实接口取全量试卷后按 categoryName 聚合计数）
   */
  async loadCategories(): Promise<Result<CategoryGroup[]>> {
    this.clearError()
    this.setLoading(true)
    try {
      const all = await this.paperService.getPapers()
      const groups = groupByCategory(all)
      this.categories = groups
      this.logger.info(`科目分组加载成功，共 ${groups.length} 个科目`)
      return Result.ok<CategoryGroup[]>(groups)
    } catch (e) {
      const errorMsg = (e as Error).message || '科目加载失败，请稍后重试'
      this.setError(errorMsg)
      this.logger.error(`科目分组加载失败：${errorMsg}`)
      return Result.fail<CategoryGroup[]>(-1, errorMsg)
    } finally {
      this.setLoading(false)
    }
  }
}
