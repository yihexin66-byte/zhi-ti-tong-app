/**
 * BannerModel — Home 模块专属模型（model 层）
 *
 * 【分层约束】
 *   纯数据类：零逻辑、零 UI import（不 import 任何 @Component/@Builder 相关能力）。
 *   image 字段存"资源标识字符串"（如 'app.media.banner1'），属于纯数据；
 *   由 View 层在渲染时用 $r(banner.image) 解析为真实资源对象，
 *   既避免 model/viewModel 依赖资源系统，也保证资源解析一定发生在渲染上下文内。
 *   公共模型（PaperInfo 等）已在 common/models，模块不重复定义，只做引用与再包装。
 */
import { PaperInfo } from '../../../common/models/QuestionModel'

// 首页顶部轮播项
export class BannerModel {
  id: string = ''
  image: string = ''
  title: string = ''

  constructor(id: string, image: string, title: string) {
    this.id = id
    this.image = image
    this.title = title
  }
}

/**
 * 推荐试卷视图项
 * 作用：把 common/models 的 PaperInfo 与"展示态派生数据"绑定在一起，
 *      使 View 层不再出现 `bestScore > 0` 之类业务判断与拼接文案。
 * 注意：PaperInfo 是跨模块共享模型，按规范留在 common/models，模块侧只包装不复制。
 */
export class RecommendedPaperItem {
  paper: PaperInfo = {
    id: '',
    paperName: '',
    categoryName: '',
    levelName: '',
    totalScore: 0,
    passScore: 0,
    duration: 0,
    questionCount: 0,
    maxAttempts: 0,
    attemptCount: 0,
    bestScore: 0
  }
  // 派生展示态：是否考过（原 View 中的 bestScore > 0 判断）
  hasScore: boolean = false
  // 派生展示态：成绩角标文案（原 View 中的 `最好 x 分` / `未考`）
  scoreText: string = ''

  constructor(paper: PaperInfo, hasScore: boolean, scoreText: string) {
    this.paper = paper
    this.hasScore = hasScore
    this.scoreText = scoreText
  }
}