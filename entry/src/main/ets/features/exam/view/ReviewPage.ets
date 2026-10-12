// 逐题回顾页（View 层，根栈注册的沉浸式页面）
//
// 【分层职责（View 层）】
//   零业务判断：成绩摘要、可见题目、只看错题开关、题号与解析文案全部来自 ReviewViewModel；
//   导航职责留在本层：onReady 从路由参数取场次号后交给 ViewModel。
import { CommonConstants } from '@zhititong/common'
import { ReviewQuestionDetail } from '../service/ExamService'
import { ReviewViewModel } from '../viewModel/ReviewViewModel'
import { ReviewQuestionCard } from './ReviewQuestionCard'

@ComponentV2
export struct ReviewPage {
  @Local viewModel: ReviewViewModel = new ReviewViewModel()

  build() {
    NavDestination() {
      Column() {
        // ===== 顶部成绩摘要条 =====
        Row() {
          Column() {
            Text(`得分 ${this.viewModel.review?.score ?? 0}`)
              .fontSize(CommonConstants.FONT_SUBTITLE)
              .fontWeight(FontWeight.Bold)
              .fontColor(CommonConstants.COLOR_TEXT_MAIN)
            Text(`共 ${this.viewModel.review?.questions.length ?? 0} 题 · 答对 ${this.viewModel.getCorrectCount()} 题`)
              .fontSize(CommonConstants.FONT_CAPTION)
              .fontColor(CommonConstants.COLOR_TEXT_SUB)
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          // "只看错题"开关
          Row({ space: 8 }) {
            Text('只看错题')
              .fontSize(CommonConstants.FONT_CAPTION)
              .fontColor(CommonConstants.COLOR_TEXT_SUB)
            Toggle({ type: ToggleType.Switch, isOn: this.viewModel.showWrongOnly })
              .onChange((isOn: boolean) => {
                // 事件只转发：过滤逻辑在 ViewModel
                this.viewModel.showWrongOnly = isOn
              })
          }
        }
        .width('100%')
        .padding(CommonConstants.SPACE_M)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .alignItems(VerticalAlign.Center)

        // ===== 题目列表 =====
        if (this.viewModel.loading) {
          Column() {
            Text('加载中...')
              .fontSize(CommonConstants.FONT_CAPTION)
              .fontColor(CommonConstants.COLOR_TEXT_SUB)
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.viewModel.getVisibleQuestions().length === 0) {
          Column() {
            Text(this.viewModel.errorMessage !== '' ? this.viewModel.errorMessage : '没有需要展示的题目')
              .fontSize(CommonConstants.FONT_BODY)
              .fontColor(CommonConstants.COLOR_TEXT_HINT)
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: CommonConstants.SPACE_M }) {
            ForEach(this.viewModel.getVisibleQuestions(), (question: ReviewQuestionDetail) => {
              ListItem() {
                ReviewQuestionCard({
                  question: question,
                  // 只看错题时题号仍取整卷序号
                  number: this.viewModel.getOriginalNumber(question),
                  viewModel: this.viewModel
                })
              }
            }, (question: ReviewQuestionDetail) => question.questionId)
          }
          .width('100%')
          .layoutWeight(1)
          .margin({ top: CommonConstants.SPACE_M })
        }
      }
      .width('100%')
      .height('100%')
      .padding(CommonConstants.SPACE_M)
      .backgroundColor(CommonConstants.COLOR_BG_PAGE)
    }
    .title('逐题回顾')
    .backgroundColor(CommonConstants.COLOR_BG_PAGE)
    .onReady((context: NavDestinationContext) => {
      // 导航职责留在 View 层：onReady 取路由参数（场次号）后交给 ViewModel
      // SDK 中 NavPathInfo.param 声明为 unknown（ArkTS 禁止 unknown 类型），故按契约强转为 string
      const attemptId = context.pathInfo?.param as string
      this.viewModel.loadReview(attemptId === undefined ? '' : attemptId)
    })
  }
}
