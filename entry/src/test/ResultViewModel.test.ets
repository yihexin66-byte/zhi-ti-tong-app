import { describe, it, expect } from '@ohos/hypium'
import { MockKit, when, ArgumentMatchers } from '@ohos/hamock'
import { AnswerItem, CommonConstants } from '@zhititong/common'
import { ResultViewModel } from '../main/ets/features/exam/viewModel/ResultViewModel'
import { ExamService } from '../main/ets/features/exam/service/ExamService'
import { FIXTURE_REVIEW, FIXTURE_SUBMIT_RESULT } from './Fixtures'

/** 造一个被 hamock 接管的假 ExamService：判分与回顾均返回夹具 */
function createMockedService(): ExamService {
  const service = new ExamService()
  const mockKit = new MockKit()
  when(mockKit.mockFunc(service, service.getAttemptResult))(ArgumentMatchers.any)
    .afterReturn(Promise.resolve(FIXTURE_SUBMIT_RESULT))
  when(mockKit.mockFunc(service, service.getFullReview))(ArgumentMatchers.any)
    .afterReturn(Promise.resolve(FIXTURE_REVIEW))
  return service
}

export default function resultViewModelTest() {
  describe('resultViewModelTest', () => {
    // 常规：按场次号装载判分与答题卡（夹具 20 分 / 及格线 18 → 通过）
    it('should_load_result_by_attempt_id', 0, async () => {
      const vm = new ResultViewModel(createMockedService())
      const res = await vm.loadResult('5001')
      expect(res.ok).assertEqual(true)
      expect(vm.result.score).assertEqual(20)
      expect(vm.result.passed).assertEqual(true)
    })

    // 答题卡：逐题对错来自回顾接口，长度与题目一致（3 题）
    it('should_build_answer_card_from_review', 0, async () => {
      const vm = new ResultViewModel(createMockedService())
      await vm.loadResult('5001')
      expect(vm.result.answers.length).assertEqual(3)
      expect(vm.result.answers[0].correct).assertEqual(true)
      expect(vm.result.answers[1].correct).assertEqual(false)
      expect(vm.result.answers[0].answered).assertEqual(true)
    })

    // 展示换算：通过态得分颜色为成功绿、标签文案"通过"、证书条可见
    it('should_derive_passed_display', 0, async () => {
      const vm = new ResultViewModel(createMockedService())
      await vm.loadResult('5001')
      expect(vm.getScoreColor()).assertEqual(CommonConstants.COLOR_SUCCESS)
      expect(vm.getPassedLabel()).assertEqual('通过')
      expect(vm.showCertificate()).assertEqual(true)
    })

    // 展示换算：未通过态换算正确（红 / 未通过 / 无证书条）
    it('should_derive_failed_display', 0, async () => {
      const vm = new ResultViewModel(createMockedService())
      await vm.loadResult('5001')
      vm.result.passed = false
      expect(vm.getScoreColor()).assertEqual(CommonConstants.COLOR_ERROR)
      expect(vm.getPassedLabel()).assertEqual('未通过')
      expect(vm.showCertificate()).assertEqual(false)
    })

    // 展示换算：说明行含及格线、格式化用时与交卷方式（夹具用时 123 秒）
    it('should_build_summary_text', 0, async () => {
      const vm = new ResultViewModel(createMockedService())
      await vm.loadResult('5001')
      expect(vm.getSummaryText()).assertEqual('及格线 18 分 · 用时 2 分 3 秒 · 手动交卷')
    })

    // 展示换算：超时交卷文案切换
    it('should_show_timeout_submit_type', 0, async () => {
      const vm = new ResultViewModel(createMockedService())
      await vm.loadResult('5001')
      vm.result.submitType = 'TIMEOUT'
      expect(vm.getSummaryText()).assertEqual('及格线 18 分 · 用时 2 分 3 秒 · 超时自动交卷')
    })

    // 展示换算：答题卡格子颜色三分支（答对绿/答错红/未答灰）
    it('should_color_answer_cells', 0, () => {
      const vm = new ResultViewModel(createMockedService())
      const correct: AnswerItem = { questionId: '1', correct: true, answered: true }
      const wrong: AnswerItem = { questionId: '2', correct: false, answered: true }
      const blank: AnswerItem = { questionId: '3', correct: false, answered: false }
      expect(vm.getCellColor(correct)).assertEqual(CommonConstants.COLOR_SUCCESS)
      expect(vm.getCellColor(wrong)).assertEqual(CommonConstants.COLOR_ERROR)
      expect(vm.getCellColor(blank)).assertEqual(CommonConstants.COLOR_TEXT_HINT)
    })

    // 隐含约定：加载完成后 loading 归 false（finally 兜底）
    it('should_reset_loading_after_load', 0, async () => {
      const vm = new ResultViewModel(createMockedService())
      await vm.loadResult('5001')
      expect(vm.loading).assertEqual(false)
      expect(vm.errorMessage).assertEqual('')
    })

    // 异常路径：回顾接口报错（如未交卷）时错误落到 errorMessage
    it('should_set_error_when_review_fails', 0, async () => {
      const service = new ExamService()
      const mockKit = new MockKit()
      when(mockKit.mockFunc(service, service.getAttemptResult))(ArgumentMatchers.any)
        .afterReturn(Promise.resolve(FIXTURE_SUBMIT_RESULT))
      when(mockKit.mockFunc(service, service.getFullReview))(ArgumentMatchers.any)
        .afterAction(() => Promise.reject(new Error('考试未交卷，无法回顾')))
      const vm = new ResultViewModel(service)
      const res = await vm.loadResult('5001')
      expect(res.ok).assertEqual(false)
      expect(vm.errorMessage).assertEqual('考试未交卷，无法回顾')
      expect(vm.loading).assertEqual(false)
    })
  })
}
