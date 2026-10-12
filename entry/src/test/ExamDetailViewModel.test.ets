import { describe, it, expect } from '@ohos/hypium'
import { MockKit, when, ArgumentMatchers } from '@ohos/hamock'
import { ExamDetailViewModel } from '../main/ets/features/exam/viewModel/ExamDetailViewModel'
import { AttemptInfo, ExamService, TabSwitchResult } from '../main/ets/features/exam/service/ExamService'
import { FIXTURE_ATTEMPT, FIXTURE_ATTEMPT_RESUMED, FIXTURE_SUBMIT_RESULT } from './Fixtures'

/** 交卷请求的账本：交互断言用 */
class SubmitLedger {
  types: string[] = []
  counts: number[] = []
}

/** 切屏上报的账本：交互断言用 */
class SwitchLedger {
  reported: number[] = []
}

/** 等一小段真实时间，让 tick 里"点火即忘"的异步交卷跑完 */
function sleep(ms: number): Promise<void> {
  return new Promise<void>((resolve: () => void) => setTimeout(resolve, ms))
}

/** 切屏上报夹具：超限即裁决强制交卷 */
function tabSwitchResult(tabSwitchCount: number, tabSwitchLimit: number,
                         shouldAutoSubmit: boolean): TabSwitchResult {
  const result: TabSwitchResult = {
    tabSwitchCount: tabSwitchCount,
    tabSwitchLimit: tabSwitchLimit,
    shouldAutoSubmit: shouldAutoSubmit
  }
  return result
}

/** 造一个被 hamock 接管的假 ExamService：网络层被整体掐断 */
function createMockedService(attempt: AttemptInfo, ledger?: SubmitLedger): ExamService {
  const service = new ExamService()
  const mockKit = new MockKit()
  when(mockKit.mockFunc(service, service.startExam))(ArgumentMatchers.any)
    .afterReturn(Promise.resolve(attempt))
  when(mockKit.mockFunc(service, service.saveAnswer))(ArgumentMatchers.any)
    .afterReturn(Promise.resolve())
  when(mockKit.mockFunc(service, service.submit))(ArgumentMatchers.any)
    .afterAction((attemptId: string, submitType: string, tabSwitchCount: number) => {
      if (ledger !== undefined) {
        ledger.types.push(submitType)
        ledger.counts.push(tabSwitchCount)
      }
      return Promise.resolve(FIXTURE_SUBMIT_RESULT)
    })
  return service
}

export default function examDetailViewModelTest() {
  describe('examDetailViewModelTest', () => {
    // ===== 必核：多选点两次同一选项等于取消（toggle 语义） =====
    it('should_toggle_off_when_multi_select_twice', 0, async () => {
      const vm = new ExamDetailViewModel(createMockedService(FIXTURE_ATTEMPT))
      await vm.startExam('1001')
      vm.currentIndex = 2                        // 第 3 题是多选
      vm.selectOption('A')
      expect(vm.isChecked('A')).assertEqual(true)
      vm.selectOption('A')
      expect(vm.isChecked('A')).assertEqual(false)
    })

    // ===== 必核：单选替换语义 =====
    it('should_replace_old_single_selection', 0, async () => {
      const vm = new ExamDetailViewModel(createMockedService(FIXTURE_ATTEMPT))
      await vm.startExam('1001')
      vm.currentIndex = 1                        // 第 2 题是单选
      vm.selectOption('A')
      expect(vm.isChecked('A')).assertEqual(true)
      vm.selectOption('C')
      expect(vm.isChecked('C')).assertEqual(true)
      expect(vm.isChecked('A')).assertEqual(false)
    })

    // 常规：多选互不影响，且答案串按契约口径升序拼接（先 D 后 A → "AD"）
    it('should_join_multi_labels_in_order', 0, async () => {
      const saved: string[] = []
      const service = new ExamService()
      const mockKit = new MockKit()
      when(mockKit.mockFunc(service, service.startExam))(ArgumentMatchers.any)
        .afterReturn(Promise.resolve(FIXTURE_ATTEMPT))
      when(mockKit.mockFunc(service, service.saveAnswer))(ArgumentMatchers.any)
        .afterAction((attemptId: string, questionId: string, answer: string) => {
          saved.push(answer)
          return Promise.resolve()
        })
      const vm = new ExamDetailViewModel(service)
      await vm.startExam('1001')
      vm.currentIndex = 2                        // 第 3 题是多选
      vm.selectOption('D')
      vm.selectOption('A')
      expect(vm.isChecked('A')).assertEqual(true)
      expect(vm.isChecked('D')).assertEqual(true)
      expect(vm.isChecked('B')).assertEqual(false)
      // 最后一次上报的答案串：升序无分隔（"AD" 而非 "DA"）
      expect(saved[saved.length - 1]).assertEqual('AD')
      vm.dispose()
    })

    // ===== 必核：断点续考——已答题目随 myAnswer 回填进事实源 =====
    it('should_fill_answers_on_resume', 0, async () => {
      const vm = new ExamDetailViewModel(createMockedService(FIXTURE_ATTEMPT_RESUMED))
      await vm.startExam('1001')
      vm.currentIndex = 0
      expect(vm.isChecked('A')).assertEqual(true)      // 第 1 题回填 A
      vm.currentIndex = 2
      expect(vm.isChecked('A')).assertEqual(true)      // 第 3 题回填 AD
      expect(vm.isChecked('D')).assertEqual(true)
      expect(vm.isChecked('B')).assertEqual(false)
    })

    // ===== 必核：tick() 直调——时间从"等来的"变成"喂进去的" =====
    it('should_count_down_by_direct_tick', 0, async () => {
      const vm = new ExamDetailViewModel(createMockedService(FIXTURE_ATTEMPT))
      await vm.startExam('1001')
      expect(vm.remainingSeconds).assertEqual(600)
      vm.tick()
      vm.tick()
      vm.tick()
      expect(vm.remainingSeconds).assertEqual(597)
      vm.dispose()
    })

    // ===== 必核：倒计时归零自动交卷（TIMEOUT），并点亮信号灯 =====
    it('should_auto_submit_on_timeout', 0, async () => {
      const ledger = new SubmitLedger()
      const vm = new ExamDetailViewModel(createMockedService(FIXTURE_ATTEMPT, ledger))
      await vm.startExam('1001')
      vm.remainingSeconds = 1
      vm.tick()
      await sleep(30)                            // 等 tick 内部的异步交卷跑完
      expect(vm.remainingSeconds).assertEqual(0)
      expect(vm.finishedAttemptId).assertEqual('5001')
      expect(ledger.types[0]).assertEqual('TIMEOUT')
      vm.dispose()
    })

    // ===== 必核：防重复交卷闸门——手动与超时同时到达也只交一次 =====
    it('should_submit_only_once_when_called_twice', 0, async () => {
      const ledger = new SubmitLedger()
      const vm = new ExamDetailViewModel(createMockedService(FIXTURE_ATTEMPT, ledger))
      await vm.startExam('1001')
      await vm.submit('MANUAL')
      await vm.submit('TIMEOUT')                 // 应被闸门挡下
      expect(ledger.types.length).assertEqual(1)
      expect(ledger.types[0]).assertEqual('MANUAL')
      vm.dispose()
    })

    // 交互断言：点选选项会即时把答案发给服务端（实时保存）
    it('should_save_answer_on_select', 0, async () => {
      const saved: string[] = []
      const service = new ExamService()
      const mockKit = new MockKit()
      when(mockKit.mockFunc(service, service.startExam))(ArgumentMatchers.any)
        .afterReturn(Promise.resolve(FIXTURE_ATTEMPT))
      when(mockKit.mockFunc(service, service.saveAnswer))(ArgumentMatchers.any)
        .afterAction((attemptId: string, questionId: string, answer: string) => {
          saved.push(`${questionId}=${answer}`)
          return Promise.resolve()
        })
      const vm = new ExamDetailViewModel(service)
      await vm.startExam('1001')
      vm.currentIndex = 0
      vm.selectOption('B')
      vm.dispose()
      expect(saved.length).assertEqual(1)
      expect(saved[0]).assertEqual('2001=B')
    })

    // 常规：题型中文换算（展示逻辑在 ViewModel）
    it('should_map_type_labels', 0, () => {
      const vm = new ExamDetailViewModel(createMockedService(FIXTURE_ATTEMPT))
      expect(vm.getTypeLabel('JUDGE')).assertEqual('判断题')
      expect(vm.getTypeLabel('SINGLE')).assertEqual('单选题')
      expect(vm.getTypeLabel('MULTI')).assertEqual('多选题')
      expect(vm.getTypeLabel('UNKNOWN')).assertEqual('')
    })

    // 边界：第一题上一题无效；最后一题下一题无效
    it('should_guard_paging_bounds', 0, async () => {
      const vm = new ExamDetailViewModel(createMockedService(FIXTURE_ATTEMPT))
      await vm.startExam('1001')
      vm.prevQuestion()
      expect(vm.currentIndex).assertEqual(0)
      vm.currentIndex = vm.questions.length - 1
      vm.nextQuestion()
      expect(vm.currentIndex).assertEqual(vm.questions.length - 1)
      vm.dispose()
    })

    // 隐含约定：开考失败时错误信息落进 errorMessage，且 loading 归位
    it('should_set_error_when_start_fails', 0, async () => {
      const service = new ExamService()
      const mockKit = new MockKit()
      when(mockKit.mockFunc(service, service.startExam))(ArgumentMatchers.any)
        .afterAction(() => Promise.reject(new Error('未登录，请先登录')))
      const vm = new ExamDetailViewModel(service)
      await vm.startExam('1001')
      expect(vm.errorMessage).assertEqual('未登录，请先登录')
      expect(vm.loading).assertEqual(false)
      vm.dispose()
    })

    // ===== 6-5：切屏上报——服务端裁决强制交卷，客户端只执行结果 =====
    it('should_auto_submit_when_server_decides', 0, async () => {
      const ledger = new SubmitLedger()
      const service = new ExamService()
      const mockKit = new MockKit()
      when(mockKit.mockFunc(service, service.startExam))(ArgumentMatchers.any)
        .afterReturn(Promise.resolve(FIXTURE_ATTEMPT))
      when(mockKit.mockFunc(service, service.reportTabSwitch))(ArgumentMatchers.any)
        .afterReturn(Promise.resolve(tabSwitchResult(4, 3, true)))
      when(mockKit.mockFunc(service, service.submit))(ArgumentMatchers.any)
        .afterAction((attemptId: string, submitType: string, count: number) => {
          ledger.types.push(submitType)
          ledger.counts.push(count)
          return Promise.resolve(FIXTURE_SUBMIT_RESULT)
        })
      const vm = new ExamDetailViewModel(service)
      await vm.startExam('1001')
      await vm.onTabSwitch(4)
      expect(ledger.types[0]).assertEqual('TAB_SWITCH')
      expect(ledger.counts[0]).assertEqual(4)      // 切出次数随交卷一并上报
      expect(vm.finishedAttemptId).assertEqual('5001')
      vm.dispose()
    })

    // ===== 6-5：未超限时只记账提示，不交卷 =====
    it('should_only_record_when_below_limit', 0, async () => {
      const ledger = new SubmitLedger()
      const switchLedger = new SwitchLedger()
      const service = new ExamService()
      const mockKit = new MockKit()
      when(mockKit.mockFunc(service, service.startExam))(ArgumentMatchers.any)
        .afterReturn(Promise.resolve(FIXTURE_ATTEMPT))
      when(mockKit.mockFunc(service, service.reportTabSwitch))(ArgumentMatchers.any)
        .afterAction((attemptId: string, count: number) => {
          switchLedger.reported.push(count)
          return Promise.resolve(tabSwitchResult(2, 3, false))
        })
      when(mockKit.mockFunc(service, service.submit))(ArgumentMatchers.any)
        .afterAction((attemptId: string, submitType: string, count: number) => {
          ledger.types.push(submitType)
          return Promise.resolve(FIXTURE_SUBMIT_RESULT)
        })
      const vm = new ExamDetailViewModel(service)
      await vm.startExam('1001')
      await vm.onTabSwitch(2)
      expect(switchLedger.reported[0]).assertEqual(2)     // 如实上报本地计数
      expect(vm.serverTabSwitchCount).assertEqual(2)      // 服务端记账回填
      expect(vm.tabSwitchLimit).assertEqual(3)
      expect(ledger.types.length).assertEqual(0)          // 未超限不交卷
      expect(vm.finishedAttemptId).assertEqual('')
      vm.dispose()
    })

    // ===== 6-5：存疑标记翻转（V2 数组整体替换语义） =====
    it('should_toggle_flag_on_current_question', 0, async () => {
      const vm = new ExamDetailViewModel(createMockedService(FIXTURE_ATTEMPT))
      await vm.startExam('1001')
      expect(vm.isCurrentFlagged()).assertEqual(false)
      vm.toggleFlag()
      expect(vm.isCurrentFlagged()).assertEqual(true)
      vm.toggleFlag()
      expect(vm.isCurrentFlagged()).assertEqual(false)
      vm.dispose()
    })

    // ===== 6-5：断点续考——存疑标记随 isFlagged 回填 =====
    it('should_fill_flags_on_resume', 0, async () => {
      const vm = new ExamDetailViewModel(createMockedService(FIXTURE_ATTEMPT_RESUMED))
      await vm.startExam('1001')
      expect(vm.isFlagged(1)).assertEqual(true)     // 第 2 题存疑
      expect(vm.isFlagged(0)).assertEqual(false)
      vm.dispose()
    })

    // 交互断言：存疑题的答案保存要带上 isFlagged，不能把标记冲掉
    it('should_send_flag_along_with_answer', 0, async () => {
      const flags: boolean[] = []
      const service = new ExamService()
      const mockKit = new MockKit()
      when(mockKit.mockFunc(service, service.startExam))(ArgumentMatchers.any)
        .afterReturn(Promise.resolve(FIXTURE_ATTEMPT_RESUMED))   // 第 2 题已存疑
      when(mockKit.mockFunc(service, service.saveAnswer))(ArgumentMatchers.any)
        .afterAction((attemptId: string, questionId: string, answer: string, isFlagged: boolean) => {
          flags.push(isFlagged)
          return Promise.resolve()
        })
      const vm = new ExamDetailViewModel(service)
      await vm.startExam('1001')
      vm.currentIndex = 1
      vm.selectOption('B')
      expect(flags[0]).assertEqual(true)
      vm.dispose()
    })

    // 边界：答题卡跳题含边界保护
    it('should_jump_to_index_with_bounds', 0, async () => {
      const vm = new ExamDetailViewModel(createMockedService(FIXTURE_ATTEMPT))
      await vm.startExam('1001')
      vm.jumpTo(2)
      expect(vm.currentIndex).assertEqual(2)
      vm.jumpTo(99)
      expect(vm.currentIndex).assertEqual(2)
      vm.jumpTo(-1)
      expect(vm.currentIndex).assertEqual(2)
      vm.dispose()
    })

    // 统计：已作答数（答题卡面板摘要）
    it('should_count_answered_questions', 0, async () => {
      const vm = new ExamDetailViewModel(createMockedService(FIXTURE_ATTEMPT_RESUMED))
      await vm.startExam('1001')
      // 夹具续考场次：第 1 题答 A、第 3 题答 AD，共 2 题已答
      expect(vm.getAnsweredCount()).assertEqual(2)
      vm.dispose()
    })
  })
}
