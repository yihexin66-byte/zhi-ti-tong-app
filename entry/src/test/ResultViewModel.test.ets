import { describe, it, expect } from '@ohos/hypium'
import { ResultViewModel } from '../main/ets/features/exam/viewModel/ResultViewModel'
import { AnswerItem } from '../main/ets/common/models/QuestionModel'
import { CommonConstants } from '../main/ets/common/constants/CommonConstants'

export default function resultViewModelTest() {
  describe('resultViewModelTest', () => {
    // 常规：加载成功，结果数据就位（Mock 80 分、通过）
    it('should_load_result_success', 0, async () => {
      const vm = new ResultViewModel()
      const res = await vm.loadResult()
      expect(res.ok).assertEqual(true)
      expect(vm.result.score).assertEqual(80)
      expect(vm.result.passed).assertEqual(true)
    })

    // 展示换算：通过态得分颜色为成功绿、标签文案"通过"、证书条可见
    it('should_derive_passed_display', 0, async () => {
      const vm = new ResultViewModel()
      await vm.loadResult()
      expect(vm.getScoreColor()).assertEqual(CommonConstants.COLOR_SUCCESS)
      expect(vm.getPassedLabel()).assertEqual('通过')
      expect(vm.showCertificate()).assertEqual(true)
    })

    // 展示换算：未通过态换算正确（红 / 未通过 / 无证书条）
    it('should_derive_failed_display', 0, async () => {
      const vm = new ResultViewModel()
      await vm.loadResult()
      vm.result.passed = false
      expect(vm.getScoreColor()).assertEqual(CommonConstants.COLOR_ERROR)
      expect(vm.getPassedLabel()).assertEqual('未通过')
      expect(vm.showCertificate()).assertEqual(false)
    })

    // 展示换算：说明行含及格线、格式化用时与交卷方式
    it('should_build_summary_text', 0, async () => {
      const vm = new ResultViewModel()
      await vm.loadResult()
      expect(vm.getSummaryText()).assertEqual('及格线 60 分 · 用时 12 分 34 秒 · 手动交卷')
    })

    // 展示换算：超时交卷文案切换
    it('should_show_timeout_submit_type', 0, async () => {
      const vm = new ResultViewModel()
      await vm.loadResult()
      vm.result.submitType = 'TIMEOUT'
      expect(vm.getSummaryText()).assertEqual('及格线 60 分 · 用时 12 分 34 秒 · 超时自动交卷')
    })

    // 展示换算：答题卡格子颜色三分支（答对绿/答错红/未答灰）
    it('should_color_answer_cells', 0, async () => {
      const vm = new ResultViewModel()
      await vm.loadResult()
      const correct: AnswerItem = { questionId: '1', correct: true, answered: true }
      const wrong: AnswerItem = { questionId: '2', correct: false, answered: true }
      const blank: AnswerItem = { questionId: '3', correct: false, answered: false }
      expect(vm.getCellColor(correct)).assertEqual(CommonConstants.COLOR_SUCCESS)
      expect(vm.getCellColor(wrong)).assertEqual(CommonConstants.COLOR_ERROR)
      expect(vm.getCellColor(blank)).assertEqual(CommonConstants.COLOR_TEXT_HINT)
    })

    // 隐含约定：加载完成后 loading 归 false（finally 兜底）
    it('should_reset_loading_after_load', 0, async () => {
      const vm = new ResultViewModel()
      await vm.loadResult()
      expect(vm.loading).assertEqual(false)
    })
  })
}
