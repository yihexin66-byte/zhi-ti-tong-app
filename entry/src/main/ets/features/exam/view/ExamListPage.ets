/**
 * ExamListPage — 考卷列表页（Exam 域内路由页面，View 层）
 *
 * 【作用】
 *   接收科目页传入的 categoryName，展示该科目下过滤后的考卷列表；
 *   点击任意考卷行 → 通过根栈 pageStack 打开沉浸式答题页（盖住底部 Tab）。
 *
 * 【分层职责（View 层）】
 *   零业务判断：科目名与考卷列表数据全部来自 ExamListViewModel；
 *   导航职责留在本层：onReady 从路由参数取科目名后交给 ViewModel；
 *   状态持有：用 @Local 持有 viewModel 实例，@Trace 字段变更自动刷新 UI。
 *
 * 【关键概念】
 *   NavDestination         : 导航目标页根容器（页面根节点）
 *   onReady                : 在子组件构建前触发，用于从 NavDestinationContext 取路由参数
 *   pathInfo.param         : 上游 pushPathByName(name, param) 传入的参数
 *   @Local                 : 页面内部状态（此处持有 ViewModel 实例）
 *   @Consumer('pageStack') : 跨层级直取根栈，用于沉浸式跳转
 *   List/ListItem          : 列表容器与列表项
 *   ForEach                : 循环渲染，key 用全局唯一的 paper.id
 */
import { CommonConstants } from '@zhititong/common'
import { RouteConstants } from '@zhititong/common'
import { PaperInfo } from '@zhititong/common'
import { ExamListViewModel } from '../viewModel/ExamListViewModel'

// ===== 考卷行子组件 =====
// 作用：展示一张考卷的完整信息（名称、等级标签、题量/时长/及格分、已考次数、成绩）
@ComponentV2
struct ExamPaperRow {
  @Param @Require paper: PaperInfo
  // 沉浸式详情：跨层级直取根栈，push 后盖住底部 Tab（与首页 PaperCard 一致）
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()

  build() {
    Column() {
      // ===== 上行：试卷名 + 等级描边标签 =====
      Row() {
        Text(this.paper.paperName)
          .fontSize(CommonConstants.FONT_BODY)              // 字号 16
          .fontWeight(FontWeight.Bold)                       // 加粗
          .fontColor(CommonConstants.COLOR_TEXT_MAIN)        // 主文本色 #333
          .maxLines(1)                                       // 最多一行
          .textOverflow({ overflow: TextOverflow.Ellipsis }) // 超长截断加...
          .layoutWeight(1)                                   // 占据剩余空间

        Text(this.paper.levelName)
          .fontSize(CommonConstants.FONT_CAPTION)            // 字号 14
          .fontColor(CommonConstants.COLOR_PRIMARY)          // 主色蓝 #007AFF
          .borderWidth(1)                                    // 描边宽 1
          .borderColor(CommonConstants.COLOR_PRIMARY)        // 描边颜色
          .borderStyle(BorderStyle.Solid)                    // 实线
          .borderRadius(4)                                   // 圆角 4
          .padding({ left: 6, right: 6, top: 2, bottom: 2 }) // 标签内边距
          .margin({ left: CommonConstants.SPACE_M })         // 与试卷名间距 16
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)                      // 垂直居中

      // ===== 中行：题量 · 时长 · 及格分 =====
      Text(`共 ${this.paper.questionCount} 题 · ${this.paper.duration} 分钟 · 及格 ${this.paper.passScore} 分`)
        .fontSize(CommonConstants.FONT_CAPTION)              // 字号 14
        .fontColor(CommonConstants.COLOR_TEXT_SUB)           // 次文本色 #666
        .width('100%')
        .margin({ top: CommonConstants.SPACE_M })            // 与上行间距 16

      // ===== 下行：已考次数 + 成绩 =====
      Row() {
        Text(`已考 ${this.paper.attemptCount}/${this.paper.maxAttempts} 次`)
          .fontSize(CommonConstants.FONT_CAPTION)
          .fontColor(CommonConstants.COLOR_TEXT_SUB)

        // 条件渲染：考过显示最好成绩，否则显示"未考"
        if (this.paper.bestScore > 0) {
          Text(`最好 ${this.paper.bestScore} 分`)
            .fontSize(CommonConstants.FONT_CAPTION)
            .fontColor(CommonConstants.COLOR_SUCCESS)        // 成功绿 #4CAF50
        } else {
          Text('未考')
            .fontSize(CommonConstants.FONT_CAPTION)
            .fontColor(CommonConstants.COLOR_TEXT_HINT)      // 提示灰 #999
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)                // 两端对齐
      .margin({ top: CommonConstants.SPACE_M })              // 与中行间距 16
    }
    .width('100%')
    .backgroundColor(Color.White)                            // 白底卡片
    .borderRadius(12)                                        // 卡片圆角
    .padding(CommonConstants.SPACE_M)                        // 内边距 16
    .alignItems(HorizontalAlign.Start)                       // 左对齐
    .onClick(() => {
      // 沉浸式详情：push 到根栈，盖住底部 Tab
      this.pageStack.pushPathByName(RouteConstants.EXAM_DETAIL, this.paper.id)
    })
  }
}

// ===== 考卷列表页主组件（导出给 ExamRouter 使用）=====
@ComponentV2
export struct ExamListPage {
  // 页面所有状态都在 ViewModel 上（@Local 持有实例）
  @Local viewModel: ExamListViewModel = new ExamListViewModel()

  build() {
    NavDestination() {
      if (this.viewModel.papers.length === 0) {
        // ===== 空态：该科目下没有考卷 =====
        Column() {
          Text('该科目暂无考卷')
            .fontSize(CommonConstants.FONT_BODY)
            .fontColor(CommonConstants.COLOR_TEXT_HINT)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        // ===== 考卷列表 =====
        List({ space: CommonConstants.SPACE_M }) {           // 行间距 16
          ForEach(this.viewModel.papers, (paper: PaperInfo) => {
            ListItem() {
              ExamPaperRow({ paper: paper })                 // 向行组件传入 paper
            }
          }, (paper: PaperInfo) => paper.id)                 // key 用全局唯一的 paper.id
        }
        .width('100%')
        .height('100%')
        .padding(CommonConstants.SPACE_M)                    // 内边距 16
      }
    }
    .title(this.viewModel.categoryName)                      // 标题栏显示科目名
    .backgroundColor(CommonConstants.COLOR_BG_PAGE)          // 页面背景 #F5F6FA
    .onReady((context: NavDestinationContext) => {
      // 导航职责留在 View 层：onReady 在子组件构建前取参数，避免先闪空态再出列表
      // SDK 中 NavPathInfo.param 声明为 unknown（ArkTS 禁止 unknown 类型），故按契约强转为 string
      const param = context.pathInfo?.param as string
      // 业务交给 ViewModel：按科目过滤试卷（过滤逻辑下沉为 PaperUtils 可测纯函数）
      this.viewModel.loadByCategory(param === undefined ? '' : param)
    })
  }
}