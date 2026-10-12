/**
 * ResultViewModel — 答题结果页 ViewModel（viewModel 层）
 *
 * 【分层约束】
 *   1. @ObservedV2 class，继承 common/base/BaseViewModel
 *   2. 状态一律 @Trace，变更自动驱动 View 刷新
 *   3. 异步业务方法返回 common/base/Result
 *   4. 本文件零 UI 组件、零 @Builder、零导航栈操作（导航留在 View 层）
 *
 * 【职责边界】
 *   按场次号拉取真实判分（/result）与答题卡（/review），再换算成 View 直取的展示态：
 *   得分颜色、通过标签、说明行文案、格子颜色均由本类派生，View 只取值渲染。
 *
 * 【数据来源】真实后端（ExamService → BaseService → httpClient）。
 */
import { BaseViewModel, Result, CommonConstants, Logger } from '@zhititong/common'
import { AnswerItem, ExamResult } from '@zhititong/common'
import { formatDuration } from '@zhititong/common'
import { BackgroundMonitor, StateKeys } from '@zhititong/common'
import { AppStorageV2 } from '@kit.ArkUI'
import { ExamService, ReviewDetail, SubmitResult } from '../service/ExamService'

@ObservedV2
export class ResultViewModel extends BaseViewModel {
  // 交卷结果（loadResult 装载；首帧保留空壳保证不崩）
  @Trace result: ExamResult = ResultViewModel.emptyResult()

  // 切后台监视器引用（运行期状态，全局单例）：懒连接，
  // 既避免构造函数触碰 UI 状态 API（保证单测可实例化），也避免重复 connect
  private monitorRef: BackgroundMonitor | undefined = undefined

  private examService: ExamService

  constructor(service: ExamService = new ExamService()) {
    super()
    this.logger = new Logger('[ResultViewModel]')
    this.examService = service
  }

  /**
   * 取全局监视器（首次访问时 connect 同一 key，读取交卷时定格的计数）
   */
  private getMonitor(): BackgroundMonitor {
    if (this.monitorRef === undefined) {
      this.monitorRef = AppStorageV2.connect(BackgroundMonitor, StateKeys.BACKGROUND_MONITOR,
        () => new BackgroundMonitor())!
    }
    return this.monitorRef
  }

  /**
   * 本场切出应用提示文案（展示换算由 ViewModel 派生，View 只取值渲染）
   */
  getSwitchCountText(): string {
    const count: number = this.getMonitor().count
    return count > 0 ? `本场切出应用 ${count} 次` : '本场未切出应用'
  }

  /**
   * 加载交卷结果：判分（/result）与答题卡（/review）两个接口合成页面所需模型
   */
  async loadResult(attemptId: string): Promise<Result<ExamResult>> {
    this.clearError()
    this.setLoading(true)
    try {
      const summary = await this.examService.getAttemptResult(attemptId)
      const review = await this.examService.getFullReview(attemptId)
      this.result = ResultViewModel.toExamResult(summary, review)
      this.logger.info(`结果加载成功：${this.result.score} 分`)
      return Result.ok<ExamResult>(this.result)
    } catch (e) {
      const errorMsg = (e as Error).message || '结果加载失败，请稍后重试'
      this.setError(errorMsg)
      this.logger.error(`结果加载失败：${errorMsg}`)
      return Result.fail<ExamResult>(-1, errorMsg)
    } finally {
      this.setLoading(false)
    }
  }

  /**
   * 得分数字颜色（通过绿 / 未通过红）
   */
  getScoreColor(): string {
    return this.result.passed ? CommonConstants.COLOR_SUCCESS : CommonConstants.COLOR_ERROR
  }

  /**
   * 通过标签文案
   */
  getPassedLabel(): string {
    return this.result.passed ? '通过' : '未通过'
  }

  /**
   * 通过标签描边色（与文字同色）
   */
  getPassedBorderColor(): string {
    return this.getScoreColor()
  }

  /**
   * 说明行文案：及格线 · 用时 · 交卷方式（时间格式化在本层完成）
   */
  getSummaryText(): string {
    const submitType = this.result.submitType === 'TIMEOUT' ? '超时自动交卷' : '手动交卷'
    return `及格线 ${this.result.passScore} 分 · 用时 ${formatDuration(this.result.usedTime)} · ${submitType}`
  }

  /**
   * 是否展示证书提示条
   */
  showCertificate(): boolean {
    return this.result.passed
  }

  /**
   * 答题卡格子背景色：未答灰 / 答对绿 / 答错红（展示规则由 ViewModel 决定）
   */
  getCellColor(answer: AnswerItem): string {
    if (!answer.answered) {
      return CommonConstants.COLOR_TEXT_HINT
    }
    return answer.correct ? CommonConstants.COLOR_SUCCESS : CommonConstants.COLOR_ERROR
  }

  /**
   * 判分 + 回顾 → 页面展示模型（答题卡逐题对错来自 /review）
   */
  private static toExamResult(summary: SubmitResult, review: ReviewDetail): ExamResult {
    const answers: AnswerItem[] = []
    for (const q of review.questions) {
      const item: AnswerItem = {
        questionId: q.questionId,
        correct: q.isCorrect,
        answered: q.userAnswer !== null && q.userAnswer !== ''
      }
      answers.push(item)
    }
    const result: ExamResult = {
      score: summary.score,
      totalScore: summary.totalScore,
      passScore: summary.passScore,
      passed: summary.passed,
      usedTime: summary.usedTime,
      submitType: summary.submitType,
      answers: answers
    }
    return result
  }

  /**
   * 首帧空壳（避免未装载时读取字段崩溃）
   */
  private static emptyResult(): ExamResult {
    const result: ExamResult = {
      score: 0,
      totalScore: 0,
      passScore: 0,
      passed: false,
      usedTime: 0,
      submitType: 'MANUAL',
      answers: []
    }
    return result
  }
}
