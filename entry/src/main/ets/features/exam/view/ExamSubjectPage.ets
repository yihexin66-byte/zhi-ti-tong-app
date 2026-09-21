/**
 * ExamSubjectPage — 考试科目页组件（View 层）
 *
 * 【作用】
 *   按科目分组展示试卷，两列网格展示科目卡片。
 *   被 MainPage.ets 通过 import 引入，放在 TabContent 中调用。
 *
 * 【分层职责（View 层）】
 *   零业务判断：科目分组数据全部来自 SubjectViewModel；
 *   事件只转发：点击卡片 → 导航 push 留在本层（卡片组件内）；
 *   状态持有：用 @Local 持有 viewModel 实例，@Trace 字段变更自动刷新 UI。
 *
 * 【域根结构（必须原样保留）】
 *   Navigation(examStack) 自持子栈 + ExamRouter 域内路由注册。
 *
 * 【关键概念】
 *   @ComponentV2 : 声明组件
 *   export struct : 导出组件，外部才能 import
 *   @Local       : 组件内部状态变量（此处持有 ViewModel 实例）
 *   Grid/GridItem : 网格布局组件，按行列排列项目
 *   columnsTemplate : 定义网格列数及比例（'1fr 1fr' = 两列等宽）
 *   ForEach      : 循环渲染，key 用科目唯一名
 */
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { RouteConstants } from '../../../common/constants/RouteConstants'
import { CategoryGroup } from '../../../common/utils/PaperUtils'
import { ExamSubjectCard } from './ExamSubjectCard'
import { ExamListPage } from './ExamListPage'
import { SubjectViewModel } from '../viewModel/SubjectViewModel'

// ===== 考试科目页主组件（导出给外部使用）=====
// export 是必须的！没有它 MainPage 就 import 不到
@ComponentV2
export struct ExamSubjectPage {
  // 三级导航：Exam 域自持子栈
  @Provider('examStack') examStack: NavPathStack = new NavPathStack()

  // 页面所有状态都在 ViewModel 上（@Local 持有实例）
  @Local viewModel: SubjectViewModel = new SubjectViewModel()

  // 进入页面时触发首屏数据加载（View 只负责触发，业务在 ViewModel 内完成）
  aboutToAppear(): void {
    this.viewModel.loadCategories()
  }

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
          // ForEach 遍历科目列表，每个科目生成一个 GridItem 卡片（数据来自 ViewModel）
          ForEach(this.viewModel.categories, (group: CategoryGroup) => {
            GridItem() {
              ExamSubjectCard({ group: group })              // 向子组件传入 group 参数
            }
          }, (group: CategoryGroup) => group.categoryName)   // 用科目名做唯一 key
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
