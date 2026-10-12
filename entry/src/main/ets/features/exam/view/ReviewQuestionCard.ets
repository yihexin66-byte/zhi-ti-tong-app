// 逐题回顾·单题卡片（View 层子组件）
//
// 【分层职责（View 层）】
//   零业务判断：选项高亮归属（我的答案 / 正确答案）、答案行文案、解析占位文案
//   全部来自 ReviewViewModel；本组件只负责按归属取色渲染。
//   对错用左边框色带：绿对红错。
import { CommonConstants } from '@zhititong/common'
import { OptionItem } from '@zhititong/common'
import { ReviewQuestionDetail } from '../service/ExamService'
import { ReviewViewModel } from '../viewModel/ReviewViewModel'

// 本卡片专用字号
const FONT_SMALL: number = 12

@ComponentV2
export struct ReviewQuestionCard {
  @Param @Require question: ReviewQuestionDetail
  // 题号取整卷序号（只看错题过滤后仍保留整卷题号）
  @Param @Require number: number
  // 业务判定统一来自 ViewModel（View 只用它取值着色）
  @Param @Require viewModel: ReviewViewModel

  /**
   * 选项文字颜色：先查正确答案（绿），再查我的选择（橙）——双中标落绿
   */
  private optionColor(option: OptionItem): string {
    if (this.viewModel.isCorrectOption(option.label, this.question)) {
      return CommonConstants.COLOR_SUCCESS
    }
    if (this.viewModel.isMyAnswer(option.label, this.question)) {
      return CommonConstants.COLOR_WARN
    }
    return CommonConstants.COLOR_TEXT_MAIN
  }

  build() {
    Column() {
      // ===== 首行：题号 + 题型标签 =====
      Row() {
        Text(`第 ${this.number} 题`)
          .fontSize(CommonConstants.FONT_CAPTION)
          .fontWeight(FontWeight.Bold)
          .fontColor(CommonConstants.COLOR_TEXT_MAIN)

        Text(this.viewModel.getTypeText(this.question.type))
          .fontSize(FONT_SMALL)
          .fontColor(CommonConstants.COLOR_PRIMARY)
          .borderWidth(1)
          .borderColor(CommonConstants.COLOR_PRIMARY)
          .borderRadius(4)
          .borderStyle(BorderStyle.Solid)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .margin({ left: CommonConstants.SPACE_M })
      }
      .width('100%')

      // ===== 题干 =====
      Text(this.question.content)
        .fontSize(CommonConstants.FONT_BODY)
        .fontColor(CommonConstants.COLOR_TEXT_MAIN)
        .lineHeight(22)
        .width('100%')
        .margin({ top: CommonConstants.SPACE_M })

      // ===== 选项列表（我的答案橙 / 正确答案绿 / 双中标绿） =====
      ForEach(this.question.options, (option: OptionItem) => {
        Row() {
          Text(`${option.label}. ${option.content}`)
            .fontSize(CommonConstants.FONT_BODY)
            .fontColor(this.optionColor(option))
            .width('100%')
        }
        .width('100%')
        .margin({ top: CommonConstants.SPACE_M })
      }, (option: OptionItem) => `${this.question.questionId}_${option.label}`)

      // ===== 底部：我的答案 / 正确答案 =====
      Row() {
        Text(`我的答案 ${this.viewModel.getMyAnswerText(this.question)}`)
          .fontSize(FONT_SMALL)
          .fontColor(this.question.isCorrect ? CommonConstants.COLOR_SUCCESS : CommonConstants.COLOR_ERROR)
        Text(`正确答案 ${this.question.correctAnswer}`)
          .fontSize(FONT_SMALL)
          .fontColor(CommonConstants.COLOR_SUCCESS)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: CommonConstants.SPACE_M })

      // ===== 解析区（空串显示"暂无解析"占位） =====
      Text(this.viewModel.getAnalysisText(this.question))
        .fontSize(FONT_SMALL)
        .fontColor(CommonConstants.COLOR_TEXT_SUB)
        .width('100%')
        .padding(CommonConstants.SPACE_M)
        .backgroundColor(CommonConstants.COLOR_BG_PAGE)
        .borderRadius(8)
        .margin({ top: CommonConstants.SPACE_M })
    }
    .width('100%')
    .padding(CommonConstants.SPACE_M)
    .backgroundColor(Color.White)
    .borderRadius(12)
    // 对错色带：左边框 4px，绿对红错
    .borderWidth({ left: 4 })
    .borderColor(this.question.isCorrect ? CommonConstants.COLOR_SUCCESS : CommonConstants.COLOR_ERROR)
    .alignItems(HorizontalAlign.Start)
  }
}
