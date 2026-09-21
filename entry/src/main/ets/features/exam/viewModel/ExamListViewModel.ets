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
 *   Mock 数据只来自 common/mock（MOCK_PAPERS），模块内不新造业务数据；
 *   按科目过滤复用 common/utils/PaperUtils 的 filterByCategory 纯函数。
 */
import { BaseViewModel } from '../../../common/base/BaseViewModel'
import { Logger } from '../../../common/log/Logger'
import { MOCK_PAPERS } from '../../../common/mock/MockExamData'
import { PaperInfo } from '../../../common/models/QuestionModel'
import { filterByCategory } from '../../../common/utils/PaperUtils'

@ObservedV2
export class ExamListViewModel extends BaseViewModel {
  // 当前科目名（标题栏展示数据）
  @Trace categoryName: string = ''

  // 按科目过滤后的考卷列表
  @Trace papers: PaperInfo[] = []

  constructor() {
    super()
    this.logger = new Logger('[ExamListViewModel]')
  }

  /**
   * 按科目加载考卷列表（当前走 Mock，项目 6 换网络请求时 View 层零改动）
   */
  loadByCategory(categoryName: string): void {
    this.clearError()
    this.categoryName = categoryName
    this.papers = filterByCategory(MOCK_PAPERS, categoryName)
    this.logger.info(`科目「${categoryName}」加载考卷 ${this.papers.length} 套`)
  }
}
