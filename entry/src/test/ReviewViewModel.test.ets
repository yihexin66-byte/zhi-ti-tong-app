import { describe, it, expect } from '@ohos/hypium'
import { MockKit, when, ArgumentMatchers } from '@ohos/hamock'
import { ReviewViewModel } from '../main/ets/features/exam/viewModel/ReviewViewModel'
import { ExamService, ReviewQuestionDetail } from '../main/ets/features/exam/service/ExamService'
import { FIXTURE_REVIEW } from './Fixtures'

/** 造一个被 hamock 接管的假 ExamService */
function createMockedService(): ExamService {
  const service = new ExamService()
  const mockKit = new MockKit()
  when(mockKit.mockFunc(service, service.getFullReview))(ArgumentMatchers.any)
    .afterReturn(Promise.resolve(FIXTURE_REVIEW))
  return service
}

export default function reviewViewModelTest() {
  describe('reviewViewModelTest', () => {
    // 常规：装载回顾数据，题数与答对数换算正确（夹具一错两对 → 答对 2）
    it('should_load_review_and_count_correct', 0, async () => {
      const vm = new ReviewViewModel(createMockedService())
      const res = await vm.loadReview('5001')
      expect(res.ok).assertEqual(true)
      expect(vm.review?.questions.length).assertEqual(3)
      expect(vm.getCorrectCount()).assertEqual(2)
    })

    // 只看错题：开启后只含错题，题号仍取整卷序号（第 3 题过滤后依然叫第 3 题）
    it('should_filter_wrong_only_keeping_original_number', 0, async () => {
      const vm = new ReviewViewModel(createMockedService())
      await vm.loadReview('5001')
      vm.showWrongOnly = true
      const visible: ReviewQuestionDetail[] = vm.getVisibleQuestions()
      expect(visible.length).assertEqual(1)
      expect(visible[0].questionId).assertEqual('2003')
      expect(vm.getOriginalNumber(visible[0])).assertEqual(3)
    })

    // 双中标判定：先查正确答案再查我的选择——ABD 对上 AD，B 是正确答案、A/D 是双中标
    it('should_resolve_double_marked_options', 0, async () => {
      const vm = new ReviewViewModel(createMockedService())
      await vm.loadReview('5001')
      const multi = vm.getVisibleQuestions()[2]
      expect(vm.isCorrectOption('B', multi)).assertEqual(true)    // 只在正确答案里
      expect(vm.isMyAnswer('B', multi)).assertEqual(false)
      expect(vm.isCorrectOption('A', multi)).assertEqual(true)    // 双中标：正确答案优先
      expect(vm.isMyAnswer('A', multi)).assertEqual(true)
      expect(vm.isCorrectOption('C', multi)).assertEqual(false)   // 只在选项表里，两边都不是
      expect(vm.isMyAnswer('C', multi)).assertEqual(false)
    })

    // 契约坑：analysis 为空串显示"暂无解析"占位（第 2、3 题解析为空串）
    it('should_placeholder_empty_analysis', 0, async () => {
      const vm = new ReviewViewModel(createMockedService())
      await vm.loadReview('5001')
      const questions = vm.getVisibleQuestions()
      expect(vm.getAnalysisText(questions[0])).assertEqual('ArkTS 在 TypeScript 基础上增加了静态类型约束与 ArkUI 装饰器。')
      expect(vm.getAnalysisText(questions[1])).assertEqual('暂无解析')
      expect(vm.getAnalysisText(questions[2])).assertEqual('暂无解析')
    })

    // 未作答：userAnswer 为 null 时展示"未作答"，且不算作我的选择
    it('should_show_placeholder_for_unanswered', 0, async () => {
      const vm = new ReviewViewModel(createMockedService())
      await vm.loadReview('5001')
      const unanswered: ReviewQuestionDetail = {
        questionId: '2004', type: 'JUDGE', content: '题干', correctAnswer: 'A',
        userAnswer: null, isCorrect: false, earnedScore: 0, maxScore: 10, analysis: '',
        options: [{ label: 'A', content: '正确' }, { label: 'B', content: '错误' }]
      }
      expect(vm.getMyAnswerText(unanswered)).assertEqual('未作答')
      expect(vm.isMyAnswer('A', unanswered)).assertEqual(false)
    })

    // 题型中文换算（回顾卡片标签）
    it('should_map_type_text', 0, async () => {
      const vm = new ReviewViewModel(createMockedService())
      expect(vm.getTypeText('JUDGE')).assertEqual('判断题')
      expect(vm.getTypeText('SINGLE')).assertEqual('单选题')
      expect(vm.getTypeText('MULTI')).assertEqual('多选题')
    })

    // 异常路径：回顾接口报错时 loading 归位、错误落进 errorMessage
    it('should_set_error_when_review_fails', 0, async () => {
      const service = new ExamService()
      const mockKit = new MockKit()
      when(mockKit.mockFunc(service, service.getFullReview))(ArgumentMatchers.any)
        .afterAction(() => Promise.reject(new Error('考试未交卷，无法回顾')))
      const vm = new ReviewViewModel(service)
      const res = await vm.loadReview('5001')
      expect(res.ok).assertEqual(false)
      expect(vm.errorMessage).assertEqual('考试未交卷，无法回顾')
      expect(vm.loading).assertEqual(false)
    })
  })
}
