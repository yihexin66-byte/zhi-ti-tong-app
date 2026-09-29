import { describe, it, expect } from '@ohos/hypium'
import { ExamDetailViewModel } from '../main/ets/features/exam/viewModel/ExamDetailViewModel'
import { MOCK_QUESTIONS } from '@zhititong/common'

export default function examDetailViewModelTest() {
  describe('examDetailViewModelTest', () => {
    // ===== 断言一（剧本必核）：多选点两次同一选项等于取消 =====
    it('should_toggle_off_when_multi_select_twice', 0, async () => {
      const vm = new ExamDetailViewModel()
      vm.handleMultiSelect('A')
      expect(vm.isMultiChecked('A')).assertEqual(true)
      vm.handleMultiSelect('A')
      expect(vm.isMultiChecked('A')).assertEqual(false)
      expect(vm.multiAnswers.length).assertEqual(0)
    })

    // ===== 断言二（剧本必核）：切题后单选与多选选中态清空 =====
    it('should_reset_selections_after_switch', 0, async () => {
      const vm = new ExamDetailViewModel()
      vm.handleSingleSelect('A')
      vm.nextQuestion()
      vm.handleMultiSelect('B')
      expect(vm.isMultiChecked('B')).assertEqual(true)
      vm.nextQuestion()
      expect(vm.selectedAnswer).assertEqual('')
      expect(vm.multiAnswers.length).assertEqual(0)
    })

    // ===== 断言三（剧本必核）：单选切换选项时旧选项被替换 =====
    it('should_replace_old_single_selection', 0, async () => {
      const vm = new ExamDetailViewModel()
      vm.handleSingleSelect('A')
      expect(vm.isSingleChecked('A')).assertEqual(true)
      vm.handleSingleSelect('C')
      expect(vm.isSingleChecked('C')).assertEqual(true)
      expect(vm.isSingleChecked('A')).assertEqual(false)
      expect(vm.selectedAnswer).assertEqual('C')
    })

    // ===== 断言二补充：上一题同样触发重置 =====
    it('should_reset_selections_on_prev_question', 0, async () => {
      const vm = new ExamDetailViewModel()
      vm.nextQuestion()
      vm.handleMultiSelect('A')
      vm.handleMultiSelect('C')
      vm.prevQuestion()
      expect(vm.multiAnswers.length).assertEqual(0)
      expect(vm.selectedAnswer).assertEqual('')
    })

    // 常规：多选互不影响，可同时选中多项
    it('should_keep_other_multi_selections', 0, async () => {
      const vm = new ExamDetailViewModel()
      vm.handleMultiSelect('A')
      vm.handleMultiSelect('B')
      expect(vm.isMultiChecked('A')).assertEqual(true)
      expect(vm.isMultiChecked('B')).assertEqual(true)
      expect(vm.multiAnswers.length).assertEqual(2)
    })

    // 边界：第一题上一题无效（题号不动、选中态不清空）
    it('should_ignore_prev_on_first_question', 0, async () => {
      const vm = new ExamDetailViewModel()
      vm.handleSingleSelect('A')
      vm.prevQuestion()
      expect(vm.currentIndex).assertEqual(0)
      expect(vm.isSingleChecked('A')).assertEqual(true)
    })

    // 边界：最后一题下一题无效
    it('should_ignore_next_on_last_question', 0, async () => {
      const vm = new ExamDetailViewModel()
      const lastIndex = MOCK_QUESTIONS.length - 1
      vm.currentIndex = lastIndex
      vm.nextQuestion()
      expect(vm.currentIndex).assertEqual(lastIndex)
    })

    // 常规：题型中文换算（展示逻辑在 ViewModel）
    it('should_map_type_labels', 0, async () => {
      const vm = new ExamDetailViewModel()
      expect(vm.getTypeLabel('JUDGE')).assertEqual('判断题')
      expect(vm.getTypeLabel('SINGLE')).assertEqual('单选题')
      expect(vm.getTypeLabel('MULTI')).assertEqual('多选题')
      expect(vm.getTypeLabel('UNKNOWN')).assertEqual('')
    })

    // 常规：按路由参数 id 装载对应试卷（首页/列表页点击进入）
    it('should_load_paper_by_route_id', 0, async () => {
      const vm = new ExamDetailViewModel()
      vm.loadPaper('1953001000000000004')
      expect(vm.paper.paperName).assertEqual('Java 程序设计期末模拟卷 A')
      expect(vm.paper.duration).assertEqual(60)
    })

    // 边界：参数缺失或 id 未命中时保持默认 Mock 卷，不中断开考流程
    it('should_keep_default_paper_when_id_missing', 0, async () => {
      const vm = new ExamDetailViewModel()
      vm.loadPaper('')
      expect(vm.paper.id).assertEqual('1953001000000000001')
      vm.loadPaper('not-exist-id')
      expect(vm.paper.id).assertEqual('1953001000000000001')
    })
  })
}
