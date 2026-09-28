/**
 * HomePage — 首页组件（View 层）
 *
 * 【作用】
 *   展示顶部轮播图 + 推荐试卷列表，作为 MainPage 第一个 Tab 的内容。
 *   被 MainPage.ets 通过 import 引入，放在 TabContent 中调用。
 *
 * 【架构位置】
 *   features/home/view/ 目录 → 无 @Entry，不是路由页面，而是可复用组件
 *   被 pages/MainPage.ets import 后调用：HomePage()
 *
 * 【分层职责（View 层）】
 *   零业务判断：轮播数据、推荐试卷、角标文案与颜色全部来自 HomeViewModel；
 *   事件只转发：点击卡片 → 转发给 viewModel 取路由参数 → 导航 push 留在本层；
 *   状态持有：用 @Local 持有 viewModel 实例，@Trace 字段变更自动刷新 UI。
 *
 * 【关键概念】
 *   @ComponentV2 : 声明组件（不加 @Entry 就不是页面，只是组件）
 *   @Local       : 组件内部持有的状态（这里是 ViewModel 实例）
 *   @Param       : 父组件传入的参数（类似 React 的 props）
 *   ForEach      : 循环渲染，遍历数组为每个元素生成 UI
 *   $r()         : 引用资源文件（图片等）—— 本层不再写死，由 ViewModel 提供
 */
import { CommonConstants } from '@zhititong/common'
import { RouteConstants } from '@zhititong/common'
import { BannerModel, RecommendedPaperItem } from '../model/BannerModel'
import { HomeViewModel } from '../viewModel/HomeViewModel'

// ===== 试卷卡片子组件 =====
// 作用：展示一张试卷的卡片（试卷名、等级标签、题目数、成绩角标）
// 注意：没有 export，所以只能在 HomePage.ets 内部使用
@ComponentV2
struct PaperCard {
  @Param @Require item: RecommendedPaperItem
  // 成绩角标颜色：展示规则由 ViewModel 计算，View 只做取值渲染
  @Param @Require scoreColor: string
  // 点击回调：子组件不碰导航栈，只把"被点击"这个事件上抛给 HomePage 处理
  @Param @Require onCardClick: () => void

  build() {
    // 整张卡片用 Row 横向布局
    Row() {
      // ===== 左侧：试卷信息 =====
      Column() {
        // 上行：试卷名 + 等级标签（横向排列）
        Row() {
          // 试卷名：加粗，最多一行，超长显示省略号
          Text(this.item.paper.paperName)
            .fontSize(CommonConstants.FONT_BODY)           // 字号 16
            .fontWeight(FontWeight.Bold)                    // 加粗
            .fontColor(CommonConstants.COLOR_TEXT_MAIN)     // 主文本色 #333
            .maxLines(1)                                    // 最多一行
            .textOverflow({ overflow: TextOverflow.Ellipsis }) // 超长截断加...
            .layoutWeight(1)                                // 占据剩余空间

          // 等级标签：带边框的文字标签
          Text(this.item.paper.levelName)
            .fontSize(CommonConstants.FONT_CAPTION)         // 字号 14
            .fontColor(CommonConstants.COLOR_PRIMARY)       // 主色蓝 #007AFF
            .borderWidth(1)                                 // 边框宽 1
            .borderColor(CommonConstants.COLOR_PRIMARY)     // 边框颜色
            .borderRadius(4)                                // 圆角 4
            .borderStyle(BorderStyle.Solid)                 // 实线边框
            .padding({ left: 6, right: 6, top: 2, bottom: 2 }) // 内边距
            .margin({ left: CommonConstants.SPACE_M })      // 与试卷名的间距 16
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)                   // 垂直居中

        // 下行：题目数 · 时长 · 及格分（文字说明）
        Text(`共 ${this.item.paper.questionCount} 题 · ${this.item.paper.duration} 分钟 · 及格 ${this.item.paper.passScore} 分`)
          .fontSize(CommonConstants.FONT_CAPTION)           // 字号 14
          .fontColor(CommonConstants.COLOR_TEXT_SUB)        // 次文本色 #666
          .margin({ top: CommonConstants.SPACE_M })         // 与上行间距 16
      }
      .layoutWeight(1)                                      // 左侧占满剩余空间
      .alignItems(HorizontalAlign.Start)                    // 左对齐

      // ===== 右侧：成绩角标 =====
      // 文案（最好 x 分 / 未考）与"是否考过"均由 ViewModel 派生，View 层不做业务判断
      Text(this.item.scoreText)
        .fontSize(CommonConstants.FONT_CAPTION)
        .fontColor(this.scoreColor)
    }
    .width('100%')
    .backgroundColor(Color.White)                           // 白底
    .borderRadius(12)                                       // 卡片圆角
    .padding(CommonConstants.SPACE_M)                       // 内边距 16
    .alignItems(VerticalAlign.Center)                       // 垂直居中
    .onClick(() => {
      // 事件只转发：把点击事件上抛，导航动作由 HomePage 统一执行
      this.onCardClick()
    })
  }
}

// ===== 首页主组件（导出给外部使用） =====
// export 是必须的！没有它 MainPage 就 import 不到
@ComponentV2
export struct HomePage {
  // 三级导航：Home 域自持子栈（本章 Home 域详情走根栈，子栈预留）
  @Provider('homeStack') homeStack: NavPathStack = new NavPathStack()

  // 页面所有状态都在 ViewModel 上（@Local 持有实例）
  @Local viewModel: HomeViewModel = new HomeViewModel()

  // Home 域内路由注册（预留）
  @Builder
  HomeRouter(name: string, param: Object) {
  }

  // 进入页面时触发首屏数据加载（View 只负责触发，业务在 ViewModel 内完成）
  aboutToAppear(): void {
    this.viewModel.loadRecommendPapers()
  }

  build() {
    Navigation(this.homeStack) {
      // Scroll 包裹整个内容，列表超出屏幕高度时可以上下滚动
      Scroll() {
        // 纵向排列：轮播区在上，推荐试卷区在下
        Column({ space: CommonConstants.SPACE_L }) {          // 间距 24
          // ===== 顶部轮播区 =====
          // Swiper 轮播组件：自动播放多张图片
          Swiper() {
            // 轮播数据来自 viewModel.banners（BannerModel.image 为资源标识，渲染时用 $r() 解析）
            ForEach(this.viewModel.banners, (banner: BannerModel) => {
              Image($r(banner.image))
                .width('100%')
                .height(160)
                .objectFit(ImageFit.Cover)                      // 裁剪铺满
            }, (banner: BannerModel) => banner.id)              // 用唯一 id 做 key
          }
          .autoPlay(true)                                      // 自动播放
          .interval(3000)                                      // 3秒切换一次
          .indicator(true)                                     // 显示底部小圆点
          .height(160)
          .borderRadius(12)                                    // 圆角
          .clip(true)                                          // 裁剪超出圆角的部分

          // ===== 推荐试卷区 =====
          Column({ space: CommonConstants.SPACE_M }) {          // 间距 16
            Text('推荐试卷')
              .fontSize(CommonConstants.FONT_SUBTITLE)         // 字号 18
              .fontWeight(FontWeight.Bold)
              .fontColor(CommonConstants.COLOR_TEXT_MAIN)
              .width('100%')

            // ForEach 循环渲染：遍历 recommendPapers 数组，为每张试卷创建一个 PaperCard
            // 第一个参数：要遍历的数组（状态来自 ViewModel）
            // 第二个参数：对每个元素执行的回调，返回 UI
            // 第三个参数：key 生成函数，用于 diff 优化，这里用试卷唯一 id
            ForEach(this.viewModel.recommendPapers, (item: RecommendedPaperItem) => {
              PaperCard({                                       // 向子组件传入参数 + 展示规则
                item: item,
                scoreColor: this.viewModel.getScoreColor(item),
                onCardClick: () => {                            // 事件只转发：导航留在 View 层
                  this.homeStack.pushPathByName(
                    this.viewModel.getExamDetailRoute(),
                    // 导航参数同样由 ViewModel 产出，View 不自行拼装业务参数
                    this.viewModel.getPaperRouteParam(item)
                  )
                }
              })
            }, (item: RecommendedPaperItem) => item.paper.id)
          }
          .width('100%')
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(CommonConstants.COLOR_BG_PAGE)          // 页面背景色 #F5F6FA
      .padding(CommonConstants.SPACE_M)                        // 整体内边距 16
    }
    .navDestination(this.HomeRouter)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }
}