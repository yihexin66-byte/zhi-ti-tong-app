/**
 * ExamDetailViewModel — 答题页 ViewModel（viewModel 层）
 *
 * 【分层约束】
 *   1. @ObservedV2 class，继承 common/base/BaseViewModel
 *   2. 状态一律 @Trace，变更自动驱动 View 刷新
 *   3. 本文件零 UI 组件、零 @Builder、零导航栈操作（导航留在 View 层）
 *
 * 【四个设计决策（本任务沉淀）】
 *   ① 时间权威在服务端：倒计时以 remainingSeconds 起跳，setInterval 只做"视觉每秒减一"
 *   ② tick() 公开化：把"跳一秒"做成公开方法，单测可直调而不必等真实时钟
 *   ③ 防重复交卷闸门：submitting 保证超时与手动同时到达也只交一次，失败放行
 *   ④ finishedAttemptId 信号灯：交卷成功只点灯，导航由 View 侧 @Monitor 执行
 *   ⑤ 防切后台：开考成功启监视、交卷开始停监视（AppStorageV2 全局运行期状态）
 *
 * 【数据来源】真实后端（ExamService → BaseService → httpClient）。
 */
import { BaseViewModel, Logger, QuestionItem } from '@zhititong/common'
import { BackgroundMonitor, StateKeys } from '@zhititong/common'
import { AppStorageV2 } from '@kit.ArkUI'
import { ExamService } from '../service/ExamService'

@ObservedV2
export class ExamDetailViewModel extends BaseViewModel {
  // 场次号（开考后由服务端下发）
  @Trace attemptId: string = ''

  // 试卷名（标题区展示）
  @Trace paperName: string = ''

  // 整卷题目（作答面：含 myAnswer 回填、无 correctAnswer）
  @Trace questions: QuestionItem[] = []

  // 当前题号（0 起）
  @Trace currentIndex: number = 0

  // 服务端驱动的剩余秒数
  @Trace remainingSeconds: number = 0

  /** 交卷完成信号：结果页导航的唯一出口（空串为未交卷） */
  @Trace finishedAttemptId: string = ''

  /** 存疑标记的题目 id 列表（V2 响应式：整体替换才触发刷新） */
  @Trace flaggedIds: string[] = []

  /** 服务端记账的切出次数（上报响应回填，供回前台提示用） */
  @Trace serverTabSwitchCount: number = 0

  /** 服务端下发的切出上限（展示用） */
  @Trace tabSwitchLimit: number = 0

  /** 唯一事实源：questionId → 已选答案（MULTI 为无序标签串，如 "ACD"） */
  private answers: Map<string, string> = new Map()

  /** 防重复交卷闸门 */
  private submitting: boolean = false

  private timerId: number = -1

  /** 本场切出应用次数（6-5 由切屏上报链路写入） */
  private tabSwitchCount: number = 0

  private examService: ExamService

  // 切后台监视器引用（运行期状态，全局单例）：懒连接，
  // 既避免构造函数触碰 UI 状态 API（保证单测可实例化），也避免重复 connect
  private monitorRef: BackgroundMonitor | undefined = undefined

  constructor(service: ExamService = new ExamService()) {
    super()
    this.logger = new Logger('[ExamDetailViewModel]')
    this.examService = service
  }

  /**
   * 取全局监视器（首次访问时 connect 同一 key，拿到的是应用级单例）
   */
  private getMonitor(): BackgroundMonitor {
    if (this.monitorRef === undefined) {
      this.monitorRef = AppStorageV2.connect(BackgroundMonitor, StateKeys.BACKGROUND_MONITOR,
        () => new BackgroundMonitor())!
    }
    return this.monitorRef
  }

  /**
   * 开考（或续考）：装载场次、回填已答、以服务端时间起跳倒计时
   */
  async startExam(paperId: string): Promise<void> {
    this.clearError()
    this.setLoading(true)
    try {
      const info = await this.examService.startExam(paperId)
      this.attemptId = info.attemptId
      this.paperName = info.paperName
      this.questions = info.questions
      this.remainingSeconds = info.remainingSeconds
      this.currentIndex = 0
      this.answers.clear()
      this.flaggedIds = []
      for (const q of info.questions) {
        if (q.myAnswer !== undefined && q.myAnswer !== null && q.myAnswer !== '') {
          this.answers.set(q.id, q.myAnswer)   // 断点续考：答案回填
        }
        if (q.isFlagged === true) {
          this.flaggedIds = [...this.flaggedIds, q.id]   // 断点续考：存疑标记回填（跨进程保持）
        }
      }
      this.startTimer()
      this.getMonitor().start()   // 防作弊：开考成功即进入监视并清零本场计数
      this.logger.info(`开考成功：${this.paperName}，共 ${this.questions.length} 题`)
    } catch (e) {
      const errorMsg = (e as Error).message
      this.setError(errorMsg)
      this.logger.error(`开考失败：${errorMsg}`)
    } finally {
      this.setLoading(false)
    }
  }

  /**
   * 起跳倒计时（重复调用安全：先清旧定时器）
   */
  private startTimer(): void {
    this.dispose()
    this.timerId = setInterval(() => this.tick(), 1000)
  }

  /**
   * 每秒一跳：倒计时唯一推进口。做成公开方法，单测可直调而不必等真实时钟
   */
  tick(): void {
    if (this.remainingSeconds > 0) {
      this.remainingSeconds--
    }
    if (this.remainingSeconds === 0) {
      this.submit('TIMEOUT')
    }
  }

  /**
   * 交卷：MANUAL 手动 / TIMEOUT 超时 / TAB_SWITCH 切屏超限
   */
  async submit(submitType: string): Promise<void> {
    if (this.submitting) {
      return                         // 闸门：超时与手动同时到达也只交一次
    }
    this.submitting = true
    try {
      await this.examService.submit(this.attemptId, submitType, this.tabSwitchCount)
      this.getMonitor().stop()         // 防作弊：交卷成功后停止计数（计数保留给结果页）
      this.dispose()
      this.finishedAttemptId = this.attemptId   // 点灯
      this.logger.info(`交卷成功：${submitType}`)
    } catch (e) {
      this.submitting = false        // 失败放行，允许用户重试
      const errorMsg = (e as Error).message
      this.setError(errorMsg)
      this.logger.error(`交卷失败：${errorMsg}`)
    }
  }

  /**
   * 清理定时器：页面销毁与交卷成功都要调
   */
  dispose(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
  }

  /**
   * 根据题型返回中文名称（展示换算由 ViewModel 决定，View 只取值渲染）
   */
  getTypeLabel(type: string): string {
    if (type === 'JUDGE') {
      return '判断题'
    }
    if (type === 'SINGLE') {
      return '单选题'
    }
    if (type === 'MULTI') {
      return '多选题'
    }
    return ''
  }

  /**
   * 当前题是否多选题（View 依此决定渲染 Checkbox 还是 Radio）
   */
  isCurrentMulti(): boolean {
    if (this.questions.length === 0) {
      return false
    }
    return this.questions[this.currentIndex].type === 'MULTI'
  }

  /**
   * 选项是否处于选中态（单选与多选统一从 answers 事实源派生）
   */
  isChecked(label: string): boolean {
    if (this.questions.length === 0) {
      return false
    }
    const current = this.answers.get(this.questions[this.currentIndex].id)
    if (current === undefined) {
      return false
    }
    return current.indexOf(label) !== -1
  }

  /**
   * 点选选项：单选替换、多选 toggle；随后异步实时保存到服务端
   */
  selectOption(label: string): void {
    if (this.questions.length === 0) {
      return
    }
    const question = this.questions[this.currentIndex]
    let next: string
    if (question.type === 'MULTI') {
      const labels = this.sortedLabels(this.answers.get(question.id) ?? '')
      const index = labels.indexOf(label)
      if (index !== -1) {
        labels.splice(index, 1)      // 已选再点=取消
      } else {
        labels.push(label)
      }
      next = labels.sort().join('')  // 契约口径：多选为升序无分隔标签串（ACD）
    } else {
      next = label                   // 单选/判断：替换语义
    }
    this.answers.set(question.id, next)
    this.questions = [...this.questions]   // V2 响应式：整体替换触发刷新
    this.persistAnswer(question.id, next)
  }

  /**
   * 实时保存单题答案（isFlagged 随答案一起透传，避免把存疑标记冲掉）
   * 失败仅记日志：不阻塞作答，下次点选会重发
   */
  private persistAnswer(questionId: string, answer: string): void {
    if (this.attemptId === '') {
      return
    }
    this.examService.saveAnswer(this.attemptId, questionId, answer, this.isFlaggedById(questionId))
      .catch((e: Error) => this.logger.warn(`答案保存失败：${e.message}`))
  }

  /**
   * 切屏上报：客户端如实上报本地计数，服务端独揽裁决
   * @param count 本地累计切出次数（由页面 @Monitor 监视 monitor.count 传入）
   */
  async onTabSwitch(count: number): Promise<void> {
    if (this.attemptId === '') {
      return
    }
    this.tabSwitchCount = count
    try {
      const result = await this.examService.reportTabSwitch(this.attemptId, count)
      this.serverTabSwitchCount = result.tabSwitchCount
      this.tabSwitchLimit = result.tabSwitchLimit
      this.logger.info(
        `切屏上报：本地 ${count} 次，服务端记账 ${result.tabSwitchCount} 次，强制交卷=${result.shouldAutoSubmit}`)
      if (result.shouldAutoSubmit) {
        // 裁决权在服务端：客户端只执行结果
        await this.submit('TAB_SWITCH')
      }
    } catch (e) {
      this.logger.warn(`切屏上报失败：${(e as Error).message}`)
    }
  }

  /**
   * 某个题目 id 是否被标记存疑
   */
  isFlaggedById(questionId: string): boolean {
    return this.flaggedIds.indexOf(questionId) !== -1
  }

  /**
   * 当前题是否已标记存疑
   */
  isCurrentFlagged(): boolean {
    if (this.questions.length === 0) {
      return false
    }
    return this.isFlaggedById(this.questions[this.currentIndex].id)
  }

  /**
   * 切换当前题的存疑标记（V2 响应式细节：数组整体替换才触发刷新）
   */
  toggleFlag(): void {
    if (this.questions.length === 0) {
      return
    }
    const questionId = this.questions[this.currentIndex].id
    const flagged = this.isFlaggedById(questionId)
    if (flagged) {
      this.flaggedIds = this.flaggedIds.filter((id: string) => id !== questionId)
    } else {
      this.flaggedIds = [...this.flaggedIds, questionId]
    }
    this.persistFlag(questionId, !flagged)
  }

  /**
   * 把存疑状态随答案一起上报（存疑跨进程保持的机制所在）
   */
  private persistFlag(questionId: string, isFlagged: boolean): void {
    if (this.attemptId === '') {
      return
    }
    const answer = this.answers.get(questionId) ?? ''
    this.examService.saveAnswer(this.attemptId, questionId, answer, isFlagged)
      .catch((e: Error) => this.logger.warn(`存疑标记保存失败：${e.message}`))
  }

  /**
   * 答题卡跳题（含边界保护）
   */
  jumpTo(index: number): void {
    if (index >= 0 && index < this.questions.length) {
      this.currentIndex = index
    }
  }

  /**
   * 指定题号是否被标记存疑（答题卡着色用）
   */
  isFlagged(index: number): boolean {
    if (index < 0 || index >= this.questions.length) {
      return false
    }
    return this.isFlaggedById(this.questions[index].id)
  }

  /**
   * 把 "ACD" 还原为标签数组（空串 → 空数组）
   */
  private sortedLabels(answer: string): string[] {
    if (answer === '') {
      return []
    }
    return answer.split('')
  }

  /**
   * 当前题已作答（供答题卡/存疑面板与摘要使用）
   */
  isAnswered(index: number): boolean {
    if (index < 0 || index >= this.questions.length) {
      return false
    }
    const answer = this.answers.get(this.questions[index].id)
    return answer !== undefined && answer !== ''
  }

  /**
   * 已作答题数（答题卡摘要与面板统计用）
   */
  getAnsweredCount(): number {
    let count: number = 0
    for (let i = 0; i < this.questions.length; i++) {
      if (this.isAnswered(i)) {
        count++
      }
    }
    return count
  }

  /**
   * 上一题（含边界保护）
   */
  prevQuestion(): void {
    if (this.currentIndex > 0) {
      this.currentIndex--
    }
  }

  /**
   * 下一题（含边界保护）
   */
  nextQuestion(): void {
    if (this.currentIndex < this.questions.length - 1) {
      this.currentIndex++
    }
  }
}
