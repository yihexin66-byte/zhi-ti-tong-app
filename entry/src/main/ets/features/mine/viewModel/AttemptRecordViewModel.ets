/**
 * AttemptRecordViewModel — 考试记录页 ViewModel（viewModel 层）
 *
 * 【分层约束】
 *   1. @ObservedV2 class，继承 common/base/BaseViewModel
 *   2. 状态一律 @Trace，变更自动驱动 View 刷新
 *   3. 本文件零 UI 组件、零 @Builder、零导航栈操作（导航留在 View 层）
 *
 * 【分页契约】loadFirstPage 重置回第一页；loadMore 到底后 hasMore=false 且不再发请求。
 *
 * 【数据来源】真实后端（ExamService.getAttempts）；构造器注入便于单测塞假 Service。
 */
import { BaseViewModel, CommonConstants, Logger, submitTypeLabel } from '@zhititong/common'
import { AttemptRecord, ExamService } from '../../exam/service/ExamService'

@ObservedV2
export class AttemptRecordViewModel extends BaseViewModel {
  // 已加载的记录（分页追加）
  @Trace records: AttemptRecord[] = []

  // 是否还有下一页
  @Trace hasMore: boolean = true

  // 记录总数（摘要展示）
  @Trace total: number = 0

  // 分页尺寸
  private static readonly PAGE_SIZE: number = 10

  private currentPage: number = 0
  private examService: ExamService

  constructor(service: ExamService = new ExamService()) {
    super()
    this.logger = new Logger('[AttemptRecordViewModel]')
    this.examService = service
  }

  /**
   * 加载第一页（下拉刷新/首次进入）
   */
  async loadFirstPage(): Promise<void> {
    this.clearError()
    this.setLoading(true)
    this.currentPage = 0
    this.records = []
    this.hasMore = true
    try {
      await this.fetchNext()
      this.logger.info(`考试记录加载成功：共 ${this.total} 条`)
    } catch (e) {
      const errorMsg = (e as Error).message || '考试记录加载失败，请稍后重试'
      this.setError(errorMsg)
      this.logger.error(`考试记录加载失败：${errorMsg}`)
    } finally {
      this.setLoading(false)
    }
  }

  /**
   * 触底加载下一页（已到底则不请求）
   */
  async loadMore(): Promise<void> {
    if (!this.hasMore || this.loading) {
      return
    }
    this.setLoading(true)
    try {
      await this.fetchNext()
    } catch (e) {
      const errorMsg = (e as Error).message || '加载更多失败，请稍后重试'
      this.setError(errorMsg)
      this.logger.error(`加载更多失败：${errorMsg}`)
    } finally {
      this.setLoading(false)
    }
  }

  /**
   * 取下一页并追加（hasMore 由"已加载条数 < 总数"推导）
   */
  private async fetchNext(): Promise<void> {
    const next = this.currentPage + 1
    const page = await this.examService.getAttempts(next, AttemptRecordViewModel.PAGE_SIZE)
    this.currentPage = next
    this.total = page.total
    this.records = [...this.records, ...page.records]
    this.hasMore = this.records.length < page.total
  }

  /**
   * 得分颜色（通过绿 / 未通过红）
   */
  getScoreColor(record: AttemptRecord): string {
    return record.passed ? CommonConstants.COLOR_SUCCESS : CommonConstants.COLOR_ERROR
  }

  /**
   * 交卷方式文案（三态中文口径）
   */
  getSubmitTypeText(record: AttemptRecord): string {
    const label = submitTypeLabel(record.submitType)
    return label === '' ? record.submitType : label
  }
}
