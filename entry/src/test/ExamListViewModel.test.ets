import { describe, it, expect } from '@ohos/hypium'
import { ExamListViewModel } from '../main/ets/features/exam/viewModel/ExamListViewModel'
import { MOCK_PAPERS } from '@zhititong/common'
import { filterByCategory } from '@zhititong/common'

export default function examListViewModelTest() {
  describe('examListViewModelTest', () => {
    // 常规：按"鸿蒙认证"过滤，标题与列表数据就位（Mock 中 4 套）
    it('should_load_papers_by_category', 0, async () => {
      const vm = new ExamListViewModel()
      vm.loadByCategory('鸿蒙认证')
      expect(vm.categoryName).assertEqual('鸿蒙认证')
      expect(vm.papers.length).assertEqual(4)
    })

    // 隐含约定：过滤结果全部属于目标科目
    it('should_only_contain_target_category', 0, async () => {
      const vm = new ExamListViewModel()
      vm.loadByCategory('计算机网络')
      let allMatch = true
      for (const p of vm.papers) {
        if (p.categoryName !== '计算机网络') {
          allMatch = false
        }
      }
      expect(allMatch).assertEqual(true)
      expect(vm.papers.length).assertEqual(2)
    })

    // 常规：不存在的科目返回空列表（View 依此展示空态）
    it('should_return_empty_for_unknown_category', 0, async () => {
      const vm = new ExamListViewModel()
      vm.loadByCategory('不存在的科目')
      expect(vm.papers.length).assertEqual(0)
    })

    // 边界：空科目名返回空数组，且不修改 Mock 原数据
    it('should_return_empty_for_blank_category', 0, async () => {
      const before = MOCK_PAPERS.length
      const direct = filterByCategory(MOCK_PAPERS, '')
      expect(direct.length).assertEqual(0)
      expect(MOCK_PAPERS.length).assertEqual(before)
    })
  })
}
