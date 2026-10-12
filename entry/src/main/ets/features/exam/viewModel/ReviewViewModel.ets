/**
 * ReviewViewModel — 逐题回顾页 ViewModel（viewModel 层）
 *
 * 【分层约束】
 *   1. @ObservedV2 class，继承 common/base/BaseViewModel
 *   2. 状态一律 @Trace，变更自动驱动 View 刷新
 *   3. 异步业务方法返回 common/base/Result
 *   4. 本文件零 UI 组件、零 @Builder、零导航栈操作（导航留在 View 层）
 *
 * 【数据来源】真实后端（ExamService.getFullReview）；构造器注入便于单测塞假 Service。
 */
import { BaseViewModel, Result, Logger, questionTypeLabel } from '@zhititong/common'
import { ExamService, ReviewDetail, ReviewQuestionDetail } from '../service/ExamService'

@ObservedV2
export class ReviewViewModel extends BaseViewModel {
  // 回顾全量数据
  @Trace review: ReviewDetail | undefined = undefined

  // "只看错题"过滤开关
  @Trace showWrongOnly: boolean = false

  private examService: ExamService

  constructor(service: ExamService = new ExamService()) {
    super()
    this.logger = new Logger('[ReviewViewModel]')
    this.examService = service
  }

  /**
   * 按场次号装载逐题回顾
   */
  async loadReview(attemptId: string): Promise<Result<ReviewDetail>> {
    this.clearError()
    this.setLoading(true)
    try {
      const detail = await this.examService.getFullReview(attemptId)
      this.review = detail
      this.logger.info(`回顾加载成功：${detail.questions.length} 题`)
      return Result.ok<ReviewDetail>(detail)
    } catch (e) {
      const errorMsg = (e as Error).message || '回顾加载失败，请稍后重试'
      this.setError(errorMsg)
      this.logger.error(`回顾加载失败：${errorMsg}`)
      return Result.fail<ReviewDetail>(-1, errorMsg)
    } finally {
      this.setLoading(false)
    }
  }

  /**
   * 题型中文名（展示换算由 ViewModel 决定，View 只取值渲染）
   */
  getTypeText(type: string): string {
    return questionTypeLabel(type)
  }

  /**
   * 答对题数（派生展示态）
   */
  getCorrectCount(): number {
    if (this.review === undefined) {
      return 0
    }
    let count: number = 0
    for (const q of this.review.questions) {
      if (q.isCorrect) {
        count++
      }
    }
    return count
  }

  /**
   * 当前可见题目：开启"只看错题"时只含错题
   */
  getVisibleQuestions(): ReviewQuestionDetail[] {
    if (this.review === undefined) {
      return []
    }
    if (!this.showWrongOnly) {
      return this.review.questions
    }
    return this.review.questions.filter((q: ReviewQuestionDetail) => !q.isCorrect)
  }

  /**
   * 题目在整卷中的原始序号（1 起）：只看错题时仍保留整卷题号
   */
  getOriginalNumber(question: ReviewQuestionDetail): number {
    if (this.review === undefined) {
      return 0
    }
    return this.review.questions.findIndex(
      (q: ReviewQuestionDetail) => q.questionId === question.questionId) + 1
  }

  /**
   * 是否为正确答案（多选为标签串，如 "ABD"）
   */
  isCorrectOption(label: string, question: ReviewQuestionDetail): boolean {
    return question.correctAnswer.indexOf(label) !== -1
  }

  /**
   * 是否为我的作答（未作答返回 false）
   */
  isMyAnswer(label: string, question: ReviewQuestionDetail): boolean {
    if (question.userAnswer === null || question.userAnswer === '') {
      return false
    }
    return question.userAnswer.indexOf(label) !== -1
  }

  /**
   * 我的答案展示文案（未作答用占位）
   */
  getMyAnswerText(question: ReviewQuestionDetail): string {
    if (question.userAnswer === null || question.userAnswer === '') {
      return '未作答'
    }
    return question.userAnswer
  }

  /**
   * 解析文案：契约坑——analysis 为空串表示暂无解析，不是 null
   */
  getAnalysisText(question: ReviewQuestionDetail): string {
    return question.analysis === '' ? '暂无解析' : question.analysis
  }
}
