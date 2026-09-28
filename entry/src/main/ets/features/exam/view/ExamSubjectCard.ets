/**
 * ExamSubjectCard — 科目卡片子组件（View 层）
 *
 * 【作用】
 *   展示一个科目的名称和试卷套数；点击后 push 到 Exam 域内考卷列表页。
 *
 * 【架构位置】
 *   features/exam/view/ 目录 → 可复用子组件独立成文件（文件名与类名一致）。
 *
 * 【分层职责（View 层）】
 *   纯展示 + 事件转发：所有展示数据由 @Param 传入；
 *   导航操作留在 View 层（@Consumer 取 exam 域内子栈）。
 */
import { CommonConstants } from '@zhititong/common'
import { RouteConstants } from '@zhititong/common'
import { CategoryGroup } from '@zhititong/common'

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
