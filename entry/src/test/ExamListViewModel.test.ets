import { describe, it, expect } from '@ohos/hypium'
import { MockKit, when, ArgumentMatchers } from '@ohos/hamock'
import { filterByCategory } from '@zhititong/common'
import { ExamListViewModel } from '../main/ets/features/exam/viewModel/ExamListViewModel'
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

export default function examListViewModelTest() {
  describe('examListViewModelTest', () => {
    // 常规：按"HarmonyOS"过滤，标题与列表数据就位（夹具中 6 套）
    it('should_load_papers_by_category', 0, async () => {
      const vm = new ExamListViewModel(createMockedService())
      await vm.loadByCategory('HarmonyOS')
      expect(vm.categoryName).assertEqual('HarmonyOS')
      expect(vm.papers.length).assertEqual(6)
    })

    // 隐含约定：过滤结果全部属于目标科目
    it('should_only_contain_target_category', 0, async () => {
      const vm = new ExamListViewModel(createMockedService())
      await vm.loadByCategory('Java 程序设计')
      let allMatch = true
      for (const p of vm.papers) {
        if (p.categoryName !== 'Java 程序设计') {
          allMatch = false
        }
      }
      expect(allMatch).assertEqual(true)
      expect(vm.papers.length).assertEqual(2)
    })

    // 常规：不存在的科目返回空列表（View 依此展示空态）
    it('should_return_empty_for_unknown_category', 0, async () => {
      const vm = new ExamListViewModel(createMockedService())
      await vm.loadByCategory('不存在的科目')
      expect(vm.papers.length).assertEqual(0)
    })

    // 边界：空科目名返回空数组，且不修改夹具原数据
    it('should_return_empty_for_blank_category', 0, async () => {
      const before = FIXTURE_PAPERS.length
      const direct = filterByCategory(FIXTURE_PAPERS, '')
      expect(direct.length).assertEqual(0)
      expect(FIXTURE_PAPERS.length).assertEqual(before)
    })

    // 异常路径：Service 抛错时 loading 归位并落到 errorMessage
    it('should_reset_loading_and_set_error_on_failure', 0, async () => {
      const service = new PaperService()
      const mockKit = new MockKit()
      when(mockKit.mockFunc(service, service.getPapers))(ArgumentMatchers.any)
        .afterAction(() => Promise.reject(new Error('未登录，请先登录')))
      const vm = new ExamListViewModel(service)
      await vm.loadByCategory('HarmonyOS')
      expect(vm.loading).assertEqual(false)
      expect(vm.errorMessage).assertEqual('未登录，请先登录')
    })
  })
}
