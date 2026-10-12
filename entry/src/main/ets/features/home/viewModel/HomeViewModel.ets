/**
 * HomeViewModel — 首页 ViewModel（viewModel 层）
 *
 * 【分层约束】
 *   1. @ObservedV2 class，继承 common/base/BaseViewModel
 *   2. 状态一律 @Trace，变更自动驱动 View 刷新
 *   3. 异步业务方法返回 common/base/Result
 *   4. 本文件零 UI 组件、零 @Builder、零导航栈操作（导航留在 View 层）
 *
 * 【数据来源】
 *   真实后端（PaperService → BaseService → httpClient）；
 *   随机抽取复用 common/utils/PaperUtils 的纯函数。
 *   Service 经构造器注入：日常 new HomeViewModel() 无感知，单测可塞入假 Service。
 */
import { BaseViewModel } from '@zhititong/common'
import { Result } from '@zhititong/common'
import { CommonConstants } from '@zhititong/common'
import { RouteConstants } from '@zhititong/common'
import { Logger } from '@zhititong/common'
import { PaperInfo } from '@zhititong/common'
import { getRandomPapers } from '@zhititong/common'
import { BannerModel, RecommendedPaperItem } from '../model/BannerModel'
import { PaperService } from '../../exam/service/PaperService'

@ObservedV2
export class HomeViewModel extends BaseViewModel {
  // 推荐试卷张数
  private static readonly RECOMMEND_COUNT: number = 6

  // 顶部轮播数据（本模块专属模型）
  @Trace banners: BannerModel[] = []

  // 推荐试卷列表（含派生展示态）
  @Trace recommendPapers: RecommendedPaperItem[] = []

  private paperService: PaperService

  constructor(service: PaperService = new PaperService()) {
    super()
    this.logger = new Logger('[HomeViewModel]')
    this.paperService = service
    this.banners = this.buildBanners()
  }

  /**
   * 加载推荐试卷（真实接口 + 随机抽取）
   */
  async loadRecommendPapers(): Promise<Result<RecommendedPaperItem[]>> {
    this.clearError()
    this.setLoading(true)
    try {
      const all = await this.paperService.getPapers()
      const papers = getRandomPapers(all, HomeViewModel.RECOMMEND_COUNT)
      const items = this.buildRecommendedPapers(papers)
      this.recommendPapers = items
      this.logger.info(`推荐试卷加载成功：${items.length} 张`)
      return Result.ok<RecommendedPaperItem[]>(items)
    } catch (e) {
      // 联网重写的主体逻辑保留（后端 message 优先），master 的新失败文案吸收为兜底
      const errorMsg = (e as Error).message || '推荐试卷加载失败，请检查网络后重试'
      this.setError(errorMsg)
      this.logger.error(`推荐试卷加载失败：${errorMsg}`)
      return Result.fail<RecommendedPaperItem[]>(-1, errorMsg)
    } finally {
      this.setLoading(false)
    }
  }

  /**
   * 试卷卡片成绩角标颜色（展示规则由 ViewModel 决定，View 只取值渲染）
   */
  getScoreColor(item: RecommendedPaperItem): string {
    return item.hasScore ? CommonConstants.COLOR_SUCCESS : CommonConstants.COLOR_TEXT_HINT
  }

  /**
   * 试卷详情路由名：由 ViewModel 提供，View 层不写死路由字符串
   * （push 动作本身留在 View 层执行）
   */
  getExamDetailRoute(): string {
    return RouteConstants.EXAM_DETAIL
  }

  /**
   * 点击试卷卡片：产出导航参数，实际 push 由 View 层执行
   */
  getPaperRouteParam(item: RecommendedPaperItem): string {
    return item.paper.id
  }

  /**
   * 组装顶部轮播数据
   * 说明：只给出资源标识，资源对象由 View 层用 $r() 在渲染上下文解析
   */
  private buildBanners(): BannerModel[] {
    const banners: BannerModel[] = []
    banners.push(new BannerModel('banner1', 'app.media.banner1', '轮播图一'))
    banners.push(new BannerModel('banner2', 'app.media.banner2', '轮播图二'))
    banners.push(new BannerModel('banner3', 'app.media.banner3', '轮播图三'))
    return banners
  }

  /**
   * 把服务端试卷包装为带派生展示态的视图项
   */
  private buildRecommendedPapers(papers: PaperInfo[]): RecommendedPaperItem[] {
    const items: RecommendedPaperItem[] = []
    for (let i = 0; i < papers.length; i++) {
      const paper: PaperInfo = papers[i]
      const hasScore: boolean = paper.bestScore > 0
      const scoreText: string = hasScore ? `最好 ${paper.bestScore} 分` : '未考'
      items.push(new RecommendedPaperItem(paper, hasScore, scoreText))
    }
    return items
  }
}
