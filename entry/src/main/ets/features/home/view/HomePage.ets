/**
 * HomePage — 首页组件
 *
 * 【作用】
 *   展示顶部轮播图 + 推荐试卷列表，作为 MainPage 第一个 Tab 的内容。
 *   被 MainPage.ets 通过 import 引入，放在 TabContent 中调用。
 *
 * 【架构位置】
 *   features/home/view/ 目录 → 无 @Entry，不是路由页面，而是可复用组件
 *   被 pages/MainPage.ets import 后调用：HomePage()
 *
 * 【关键概念】
 *   @ComponentV2 : 声明组件（不加 @Entry 就不是页面，只是组件）
 *   export struct : 导出组件，外部才能 import 它
 *   @Local       : 组件内部状态变量
 *   @Param       : 父组件传入的参数（类似 React 的 props）
 *   Scroll       : 可滚动容器，内容超出屏幕时可以上下滑动
 *   Swiper       : 轮播组件，多张图片自动轮播切换
 *   ForEach      : 循环渲染，遍历数组为每个元素生成 UI
 *   $r()         : 引用资源文件（图片等），路径来自 resources 目录
 */
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { PaperInfo } from '../../../common/models/QuestionModel'
import { MOCK_PAPERS } from '../../../common/mock/MockExamData'
import { getRandomPapers } from '../../../common/utils/PaperUtils'

// ===== 试卷卡片子组件 =====
// 作用：展示一张试卷的卡片（试卷名、等级标签、题目数、成绩角标）
// 注意：没有 export，所以只能在 HomePage.ets 内部使用
@ComponentV2
struct PaperCard {
  // @Param：父组件传入的参数
  // 这里接收一个 PaperInfo 对象，包含试卷的所有信息
  // 后面的 = {...} 是默认值，防止父组件没传参时报错
  @Param paper: PaperInfo = {
    id: '', paperName: '', categoryName: '', levelName: '',
    totalScore: 0, passScore: 0, duration: 0, questionCount: 0,
    maxAttempts: 0, attemptCount: 0, bestScore: 0
  }

  build() {
    // 整张卡片用 Row 横向布局
    Row() {
      // ===== 左侧：试卷信息 =====
      Column() {
        // 上行：试卷名 + 等级标签（横向排列）
        Row() {
          // 试卷名：加粗，最多一行，超长显示省略号
          Text(this.paper.paperName)
            .fontSize(CommonConstants.FONT_BODY)           // 字号 16
            .fontWeight(FontWeight.Bold)                    // 加粗
            .fontColor(CommonConstants.COLOR_TEXT_MAIN)     // 主文本色 #333
            .maxLines(1)                                    // 最多一行
            .textOverflow({ overflow: TextOverflow.Ellipsis }) // 超长截断加...
            .layoutWeight(1)                                // 占据剩余空间

          // 等级标签：带边框的文字标签
          Text(this.paper.levelName)
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
        Text(`共 ${this.paper.questionCount} 题 · ${this.paper.duration} 分钟 · 及格 ${this.paper.passScore} 分`)
          .fontSize(CommonConstants.FONT_CAPTION)           // 字号 14
          .fontColor(CommonConstants.COLOR_TEXT_SUB)        // 次文本色 #666
          .margin({ top: CommonConstants.SPACE_M })         // 与上行间距 16
      }
      .layoutWeight(1)                                      // 左侧占满剩余空间
      .alignItems(HorizontalAlign.Start)                    // 左对齐

      // ===== 右侧：成绩角标 =====
      // 条件渲染：if/else 根据 bestScore 显示不同内容
      if (this.paper.bestScore > 0) {
        // 考过 → 显示最好成绩，绿色
        Text(`最好 ${this.paper.bestScore} 分`)
          .fontSize(CommonConstants.FONT_CAPTION)
          .fontColor(CommonConstants.COLOR_SUCCESS)         // 成功绿 #4CAF50
      } else {
        // 没考过 → 显示"未考"，灰色
        Text('未考')
          .fontSize(CommonConstants.FONT_CAPTION)
          .fontColor(CommonConstants.COLOR_TEXT_HINT)       // 提示灰 #999
      }
    }
    .width('100%')
    .backgroundColor(Color.White)                           // 白底
    .borderRadius(12)                                       // 卡片圆角
    .padding(CommonConstants.SPACE_M)                       // 内边距 16
    .alignItems(VerticalAlign.Center)                       // 垂直居中
    .onClick(() => {
      // 点击卡片事件（暂时只打印日志，后续接入真实跳转）
      console.info(this.paper.paperName)
    })
  }
}

// ===== 首页主组件（导出给外部使用） =====
// export 是必须的！没有它 MainPage 就 import 不到
@ComponentV2
export struct HomePage {
  // @Local：组件内部状态
  // 从 Mock 数据中随机抽取 4 张试卷，作为推荐列表
  // getRandomPapers 是工具函数，使用 Fisher-Yates 洗牌算法随机取
  @Local paperList: PaperInfo[] = getRandomPapers(MOCK_PAPERS, 4)

  build() {
    // Scroll 包裹整个内容，列表超出屏幕高度时可以上下滚动
    Scroll() {
      // 纵向排列：轮播区在上，推荐试卷区在下
      Column({ space: CommonConstants.SPACE_L }) {          // 间距 24
        // ===== 顶部轮播区 =====
        // Swiper 轮播组件：自动播放多张图片
        Swiper() {
          // $r('app.media.banner1') 引用 resources/base/media 下的图片
          Image($r('app.media.banner1'))
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)                      // 裁剪铺满
          Image($r('app.media.banner2'))
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)
          Image($r('app.media.banner3'))
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)
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

          // ForEach 循环渲染：遍历 paperList 数组，为每张试卷创建一个 PaperCard
          // 第一个参数：要遍历的数组
          // 第二个参数：对每个元素执行的回调，返回 UI
          // 第三个参数：key 生成函数，用于 diff 优化，这里用试卷 id
          ForEach(this.paperList, (paper: PaperInfo) => {
            PaperCard({ paper: paper })                     // 向子组件传入 paper 参数
          }, (paper: PaperInfo) => paper.id)
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
}