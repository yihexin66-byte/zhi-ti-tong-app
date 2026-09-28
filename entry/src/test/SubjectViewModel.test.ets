import { describe, it, expect } from '@ohos/hypium'
import { SubjectViewModel } from '../main/ets/features/exam/viewModel/SubjectViewModel'
import { MOCK_PAPERS } from '@zhititong/common'
import { groupByCategory } from '@zhititong/common'

export default function subjectViewModelTest() {
  describe('subjectViewModelTest', () => {
    // 常规：加载成功，科目数与 MOCK_PAPERS 聚合结果一致（3 个科目）
    it('should_load_categories_success', 0, async () => {
      const vm = new SubjectViewModel()
      const res = await vm.loadCategories()
      expect(res.ok).assertEqual(true)
      expect(vm.categories.length).assertEqual(3)
    })

    // 常规：每个科目的套数与按 MOCK_PAPERS 聚合的期望值一致
    it('should_count_papers_per_category', 0, async () => {
      const vm = new SubjectViewModel()
      await vm.loadCategories()
      const expected = groupByCategory(MOCK_PAPERS)
      for (let i = 0; i < expected.length; i++) {
        expect(vm.categories[i].categoryName).assertEqual(expected[i].categoryName)
        expect(vm.categories[i].count).assertEqual(expected[i].count)
      }
    })

    // 常规：聚合结果由 groupByCategory 复用得出，不重写、不改写 Mock 原数据
    it('should_not_mutate_mock_papers', 0, async () => {
      const before = MOCK_PAPERS.length
      const vm = new SubjectViewModel()
      await vm.loadCategories()
      expect(MOCK_PAPERS.length).assertEqual(before)
    })

    // 隐含约定：加载完成后 loading 归 false（finally 兜底）、无错误信息
    it('should_reset_loading_after_load', 0, async () => {
      const vm = new SubjectViewModel()
      await vm.loadCategories()
      expect(vm.loading).assertEqual(false)
      expect(vm.errorMessage).assertEqual('')
    })
  })
}
