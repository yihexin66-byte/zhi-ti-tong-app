import { describe, it, expect } from '@ohos/hypium'
import { HomeViewModel } from '../main/ets/features/home/viewModel/HomeViewModel'
import { MOCK_PAPERS } from '../main/ets/common/mock/MockExamData'

export default function homeViewModelTest() {
  describe('homeViewModelTest', () => {
    // 常规：加载后推荐位数量为 4（HomeViewModel.RECOMMEND_COUNT）
    it('should_load_4_recommend_papers', 0, async () => {
      const vm = new HomeViewModel()
      const res = await vm.loadRecommendPapers()
      expect(res.ok).assertEqual(true)
      expect(vm.recommendPapers.length).assertEqual(4)
    })

    // 隐含约定：推荐结果全部来自 MOCK_PAPERS
    it('should_pick_papers_from_mock', 0, async () => {
      const vm = new HomeViewModel()
      await vm.loadRecommendPapers()
      const ids: string[] = MOCK_PAPERS.map(p => p.id)
      let allFromMock = true
      for (const p of vm.recommendPapers) {
        if (!ids.includes(p.paper.id)) {
          allFromMock = false
        }
      }
      expect(allFromMock).assertEqual(true)
    })

    // 隐含约定：加载完成后 loading 归 false（finally 兜底）
    it('should_reset_loading_after_load', 0, async () => {
      const vm = new HomeViewModel()
      await vm.loadRecommendPapers()
      expect(vm.loading).assertEqual(false)
    })
  })
}
