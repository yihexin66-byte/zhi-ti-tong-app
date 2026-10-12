import { describe, it, expect } from '@ohos/hypium'
import { MockKit, when, ArgumentMatchers } from '@ohos/hamock'
import { HomeViewModel } from '../main/ets/features/home/viewModel/HomeViewModel'
import { PaperService } from '../main/ets/features/exam/service/PaperService'
import { FIXTURE_PAPERS } from './Fixtures'

/** 造一个被 hamock 接管的假 PaperService：网络层被整体掐断 */
function createMockedService(): PaperService {
  const service = new PaperService()
  const mockKit = new MockKit()
  when(mockKit.mockFunc(service, service.getPapers))(ArgumentMatchers.any)
    .afterReturn(Promise.resolve(FIXTURE_PAPERS))
  return service
}

export default function homeViewModelTest() {
  describe('homeViewModelTest', () => {
    // 常规：加载后推荐位数量为 6（产品需求已从 4 张扩到 6 张，断言随需求更新）
    it('should_load_six_recommend_papers', 0, async () => {
      const vm = new HomeViewModel(createMockedService())
      const res = await vm.loadRecommendPapers()
      expect(res.ok).assertEqual(true)
      expect(vm.recommendPapers.length).assertEqual(6)
    })

    // 隐含约定：推荐结果全部来自夹具池（不多不少，抽取不凭空造数据）
    it('should_pick_papers_from_fixture', 0, async () => {
      const vm = new HomeViewModel(createMockedService())
      await vm.loadRecommendPapers()
      const ids: string[] = FIXTURE_PAPERS.map((p) => p.id)
      let allFromFixture = true
      for (const p of vm.recommendPapers) {
        if (!ids.includes(p.paper.id)) {
          allFromFixture = false
        }
      }
      expect(allFromFixture).assertEqual(true)
    })

    // 契约语义：失败兜底文案取产品新版（master 热修口径），后端 message 仍优先
    it('should_use_product_fallback_text_on_failure', 0, async () => {
      const service = new PaperService()
      const mockKit = new MockKit()
      when(mockKit.mockFunc(service, service.getPapers))(ArgumentMatchers.any)
        .afterAction(() => Promise.reject(new Error('')))
      const vm = new HomeViewModel(service)
      await vm.loadRecommendPapers()
      expect(vm.errorMessage).assertEqual('推荐试卷加载失败，请检查网络后重试')
    })

    // 派生展示态：考过（bestScore > 0）显示"最好 X 分"，没考过显示"未考"
    it('should_derive_score_text_by_best_score', 0, async () => {
      const vm = new HomeViewModel(createMockedService())
      await vm.loadRecommendPapers()
      let derivedOk = true
      for (const item of vm.recommendPapers) {
        if (item.paper.bestScore > 0) {
          if (!item.hasScore || item.scoreText !== `最好 ${item.paper.bestScore} 分`) {
            derivedOk = false
          }
        } else {
          if (item.hasScore || item.scoreText !== '未考') {
            derivedOk = false
          }
        }
      }
      expect(derivedOk).assertEqual(true)
    })

    // 隐含约定：加载完成后 loading 归 false（finally 兜底）
    it('should_reset_loading_after_load', 0, async () => {
      const vm = new HomeViewModel(createMockedService())
      await vm.loadRecommendPapers()
      expect(vm.loading).assertEqual(false)
      expect(vm.errorMessage).assertEqual('')
    })

    // 异常路径：Service 抛错时，错误信息落进 errorMessage 且 loading 归位
    it('should_set_error_when_service_fails', 0, async () => {
      const service = new PaperService()
      const mockKit = new MockKit()
      when(mockKit.mockFunc(service, service.getPapers))(ArgumentMatchers.any)
        .afterAction(() => Promise.reject(new Error('未登录，请先登录')))
      const vm = new HomeViewModel(service)
      const res = await vm.loadRecommendPapers()
      expect(res.ok).assertEqual(false)
      expect(vm.errorMessage).assertEqual('未登录，请先登录')
      expect(vm.loading).assertEqual(false)
    })
  })
}
