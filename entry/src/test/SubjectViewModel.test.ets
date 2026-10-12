import { describe, it, expect } from '@ohos/hypium'
import { MockKit, when, ArgumentMatchers } from '@ohos/hamock'
import { groupByCategory } from '@zhititong/common'
import { SubjectViewModel } from '../main/ets/features/exam/viewModel/SubjectViewModel'
import { PaperService } from '../main/ets/features/exam/service/PaperService'
import { FIXTURE_PAPERS } from './Fixtures'

/** 造一个被 hamock 接管的假 PaperService */
function createMockedService(): PaperService {
  const service = new PaperService()
  const mockKit = new MockKit()
  when(mockKit.mockFunc(service, service.getPapers))(ArgumentMatchers.any)
    .afterReturn(Promise.resolve(FIXTURE_PAPERS))
  return service
}

export default function subjectViewModelTest() {
  describe('subjectViewModelTest', () => {
    // 常规：加载成功，科目数与夹具聚合结果一致（2 个科目）
    it('should_load_categories_success', 0, async () => {
      const vm = new SubjectViewModel(createMockedService())
      const res = await vm.loadCategories()
      expect(res.ok).assertEqual(true)
      expect(vm.categories.length).assertEqual(2)
    })

    // 常规：每个科目的套数与按夹具聚合的期望值一致
    it('should_count_papers_per_category', 0, async () => {
      const vm = new SubjectViewModel(createMockedService())
      await vm.loadCategories()
      const expected = groupByCategory(FIXTURE_PAPERS)
      for (let i = 0; i < expected.length; i++) {
        expect(vm.categories[i].categoryName).assertEqual(expected[i].categoryName)
        expect(vm.categories[i].count).assertEqual(expected[i].count)
      }
      // 具体值锚定：HarmonyOS 6 套、Java 程序设计 2 套
      expect(vm.categories[0].count).assertEqual(6)
      expect(vm.categories[1].count).assertEqual(2)
    })

    // 常规：聚合结果由 groupByCategory 复用得出，不改写夹具原数据
    it('should_not_mutate_fixture_papers', 0, async () => {
      const before = FIXTURE_PAPERS.length
      const vm = new SubjectViewModel(createMockedService())
      await vm.loadCategories()
      expect(FIXTURE_PAPERS.length).assertEqual(before)
    })

    // 隐含约定：加载完成后 loading 归 false（finally 兜底）、无错误信息
    it('should_reset_loading_after_load', 0, async () => {
      const vm = new SubjectViewModel(createMockedService())
      await vm.loadCategories()
      expect(vm.loading).assertEqual(false)
      expect(vm.errorMessage).assertEqual('')
    })
  })
}
