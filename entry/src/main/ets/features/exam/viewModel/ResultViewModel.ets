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
 *   结果数据加载 + 展示换算全部下沉：得分颜色、通过标签、说明行文案、
 *   答题卡格子颜色均由本类派生，View 只取值渲染（理想态：View 零三元业务判断）；
 *   "重新刷题"的 pop 属导航，留在 View 层。
 *
 * 【数据来源】
 *   Mock 数据只来自 common/mock（MOCK_RESULT），项目 6 接真实接口时只换数据源。
 */
import { BaseViewModel } from '@zhititong/common'
import { Result } from '@zhititong/common'
import { CommonConstants } from '@zhititong/common'
import { Logger } from '@zhititong/common'
import { MOCK_RESULT } from '@zhititong/common'
import { AnswerItem, ExamResult } from '@zhititong/common'
import { formatDuration } from '@zhititong/common'
import { BackgroundMonitor, StateKeys } from '@zhititong/common'
import { AppStorageV2 } from '@kit.ArkUI'

@ObservedV2
export class ResultViewModel extends BaseViewModel {
  // 交卷结果（初始即 Mock，保证首帧不空；loadResult 为项目 6 接口的换入点）
  @Trace result: ExamResult = MOCK_RESULT

  // 切后台监视器引用（运行期状态，全局单例）：懒连接，
  // 既避免构造函数触碰 UI 状态 API（保证单测可实例化），也避免重复 connect
  private monitorRef: BackgroundMonitor | undefined = undefined

  constructor() {
    super()
    this.logger = new Logger('[ResultViewModel]')
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
   * 加载交卷结果（当前走 Mock，项目 6 换网络请求时 View 层零改动）
   */
  async loadResult(): Promise<Result<ExamResult>> {
    this.clearError()
    this.setLoading(true)
    try {
      this.result = MOCK_RESULT
      this.logger.info(`结果加载完成：${this.result.score} 分`)
      return Result.ok<ExamResult>(this.result)
    } catch (e) {
      const errorMsg = '结果加载失败，请稍后重试'
      this.setError(errorMsg)
      this.logger.error(errorMsg)
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
}
