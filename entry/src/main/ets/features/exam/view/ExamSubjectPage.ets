/**
 * ExamSubjectPage — 考试科目页组件
 *
 * 【作用】
 *   按科目分组展示试卷，两列网格展示科目卡片。
 *   被 MainPage.ets 通过 import 引入，放在 TabContent 中调用。
 *
 * 【架构位置】
 *   features/exam/view/ 目录 → 无 @Entry，不是路由页面，而是可复用组件
 *   被 pages/MainPage.ets import 后调用：ExamSubjectPage()
 *
 * 【关键概念】
 *   @ComponentV2 : 声明组件
 *   export struct : 导出组件，外部才能 import
 *   @Param       : 接收父组件传入的参数
 *   @Local       : 组件内部状态变量
 *   Grid/GridItem : 网格布局组件，按行列排列项目
 *   columnsTemplate : 定义网格列数及比例（'1fr 1fr' = 两列等宽）
 *   ForEach      : 循环渲染
 *   groupByCategory : 工具函数，按 categoryName 聚合试卷数量
 */
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { RouteConstants } from '../../../common/constants/RouteConstants'
import { MOCK_PAPERS } from '../../../common/mock/MockExamData'
import { CategoryGroup, groupByCategory } from '../../../common/utils/PaperUtils'
import { ExamListPage } from './ExamListPage'

// ===== 科目卡片子组件 =====
// 作用：展示一个科目的名称和试卷套数
// 注意：没有 export，只能在 ExamSubjectPage.ets 内部使用
@ComponentV2
export struct ExamSubjectCard {
  @Param @Require group: CategoryGroup
  @Consumer('examStack') examStack: NavPathStack = new NavPathStack()

  build() {
    // 卡片：垂直居中，显示科目名 + 套数
    Column() {
      // 科目名称
      Text(this.group.categoryName)
        .fontSize(CommonConstants.FONT_BODY)              // 字号 16
        .fontWeight(FontWeight.Bold)                       // 加粗
        .fontColor(CommonConstants.COLOR_TEXT_MAIN)        // 主文本色 #333

      // 试卷套数（如"共 5 套"）
      Text(`共 ${this.group.count} 套`)
        .fontSize(CommonConstants.FONT_CAPTION)            // 字号 14
        .fontColor(CommonConstants.COLOR_TEXT_SUB)         // 次文本色 #666
        .margin({ top: CommonConstants.SPACE_M })          // 与科目名间距 16
    }
    .width('100%')
    .backgroundColor(Color.White)                          // 白底卡片
    .borderRadius(12)                                      // 圆角
    .padding(CommonConstants.SPACE_M)                      // 内边距 16
    .alignItems(HorizontalAlign.Center)                    // 水平居中
    .justifyContent(FlexAlign.Center)                      // 垂直居中
    .onClick(() => {
      // 域内跳转：push 到 examStack，底部 Tab 仍然可见——对比首页卡片的根栈跳转
      this.examStack.pushPathByName(RouteConstants.EXAM_LIST, this.group.categoryName)
    })
  }
}

// ===== 考试科目页主组件（导出给外部使用）=====
// export 是必须的！没有它 MainPage 就 import 不到
@ComponentV2
export struct ExamSubjectPage {
  // 三级导航：Exam 域自持子栈
  @Provider('examStack') examStack: NavPathStack = new NavPathStack()
  @Local categories: CategoryGroup[] = groupByCategory(MOCK_PAPERS)

  // Exam 域内路由注册
  @Builder
  ExamRouter(name: string, param: Object) {
    if (name === RouteConstants.EXAM_LIST) {
      ExamListPage()
    }
  }

  build() {
    Navigation(this.examStack) {
      Column() {
        // ===== 顶部标题 =====
        Text('考试科目')
          .fontSize(CommonConstants.FONT_SUBTITLE)           // 字号 18
          .fontWeight(FontWeight.Bold)                        // 加粗
          .fontColor(CommonConstants.COLOR_TEXT_MAIN)
          .width('100%')

        // ===== 科目网格 =====
        // Grid 网格布局，columnsTemplate 定义列数及比例
        // '1fr 1fr' 表示两列等宽（fr = fraction，等分剩余空间）
        Grid() {
          // ForEach 遍历科目列表，每个科目生成一个 GridItem 卡片
          ForEach(this.categories, (group: CategoryGroup) => {
            GridItem() {
              ExamSubjectCard({ group: group })              // 向子组件传入 group 参数
            }
          }, (group: CategoryGroup) => group.categoryName)   // 用科目名做 key
        }
        .columnsTemplate('1fr 1fr')                          // 两列等宽
        .rowsGap(CommonConstants.SPACE_M)                    // 行间距 16
        .columnsGap(CommonConstants.SPACE_M)                 // 列间距 16
        .width('100%')
        .margin({ top: CommonConstants.SPACE_L })            // 与标题间距 24
      }
      .width('100%')
      .height('100%')
      .backgroundColor(CommonConstants.COLOR_BG_PAGE)         // 页面背景 #F5F6FA
      .padding(CommonConstants.SPACE_M)                       // 整体内边距 16
    }
    .navDestination(this.ExamRouter)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }
}