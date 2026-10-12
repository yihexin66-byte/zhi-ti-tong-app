/**
 * ExamListViewModel — 考卷列表页 ViewModel（viewModel 层）
 *
 * 【分层约束】
 *   1. @ObservedV2 class，继承 common/base/BaseViewModel
 *   2. 状态一律 @Trace，变更自动驱动 View 刷新
 *   3. 本文件零 UI 组件、零 @Builder、零导航栈操作（导航留在 View 层）
 *
 * 【职责边界】
 *   只管"按科目过滤试卷"的状态与方法；
 *   从路由参数读取科目名属于导航职责，由 View 层 onReady 取参后传入。
 *
 * 【数据来源】
 *   真实后端（PaperService → BaseService → httpClient）；
 *   按科目过滤复用 common/utils/PaperUtils 的 filterByCategory 纯函数。
 *   Service 经构造器注入：日常无感知，单测可塞入假 Service。
 */
import { BaseViewModel } from '@zhititong/common'
import { Logger } from '@zhititong/common'
import { PaperInfo } from '@zhititong/common'
import { filterByCategory } from '@zhititong/common'
import { PaperService } from '../service/PaperService'

@ObservedV2
export class ExamListViewModel extends BaseViewModel {
  // 当前科目名（标题栏展示数据）
  @Trace categoryName: string = ''

  // 按科目过滤后的考卷列表
  @Trace papers: PaperInfo[] = []

  private paperService: PaperService

  constructor(service: PaperService = new PaperService()) {
    super()
    this.logger = new Logger('[ExamListViewModel]')
    this.paperService = service
  }

  /**
   * 按科目加载考卷列表（真实接口取全量后按科目过滤）
   */
  async loadByCategory(categoryName: string): Promise<void> {
    this.clearError()
    this.categoryName = categoryName
    this.setLoading(true)
    try {
      const all = await this.paperService.getPapers()
      this.papers = filterByCategory(all, categoryName)
      this.logger.info(`科目「${categoryName}」加载考卷 ${this.papers.length} 套`)
    } catch (e) {
      const errorMsg = (e as Error).message || '考卷列表加载失败，请稍后重试'
      this.setError(errorMsg)
      this.logger.error(`考卷列表加载失败：${errorMsg}`)
    } finally {
      this.setLoading(false)
    }
  }
}
