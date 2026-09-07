// 答题结果页：结果卡 + 证书提示条 + 答题卡 + 底部按钮组
import { CommonConstants } from '../common/constants/CommonConstants'
import { AnswerItem, ExamResult } from '../common/model/QuestionModel'
import { MOCK_RESULT } from '../common/mock/MockResultData'
import { formatDuration } from '../common/utils/TimeUtils'

// 本页专用字号：大号得分 48、说明行 12（任务指定，常量库暂无对应档位）
const FONT_SCORE: number = 48
const FONT_SMALL: number = 12

// 交卷方式文案：MANUAL 手动 / TIMEOUT 超时自动
function submitTypeText(submitType: string): string {
  return submitType === 'TIMEOUT' ? '超时自动交卷' : '手动交卷'
}

// 答题卡格子子组件：答对成功色底 / 答错错误色底 / 未答灰底
@ComponentV2
struct AnswerCell {
  @Param index: number = 0
  @Param answer: AnswerItem = { questionId: '', correct: false, answered: false }

  // 依据作答状态取格子背景色
  cellColor(): string {
    if (!this.answer.answered) {
      return CommonConstants.COLOR_TEXT_HINT
    }
    return this.answer.correct ? CommonConstants.COLOR_SUCCESS : CommonConstants.COLOR_ERROR
  }

  build() {
    Text(`${this.index + 1}`)
      .fontSize(CommonConstants.FONT_BODY)
      .fontWeight(FontWeight.Medium)
      .fontColor(Color.White)
      .textAlign(TextAlign.Center)
      .width(40)
      .height(40)
      .borderRadius(8)
      .backgroundColor(this.cellColor())
  }
}

@Entry
@ComponentV2
struct AnswerResultPage {
  // 项目 6 前用 Mock 数据，接入真实接口时只换数据源
  @Local result: ExamResult = MOCK_RESULT

  build() {
    Column() {
      // ========== 上方内容区（占满剩余空间，把按钮压到底部） ==========
      Column({ space: CommonConstants.SPACE_L }) {
        // ----- 结果卡：得分 + 通过标签 + 及格线/用时/交卷方式 -----
        Column() {
          Text(`${this.result.score}`)
            .fontSize(FONT_SCORE)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.result.passed ? CommonConstants.COLOR_SUCCESS : CommonConstants.COLOR_ERROR)

          Text(this.result.passed ? '通过' : '未通过')
            .fontSize(CommonConstants.FONT_CAPTION)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.result.passed ? CommonConstants.COLOR_SUCCESS : CommonConstants.COLOR_ERROR)
            .borderWidth(1)
            .borderColor(this.result.passed ? CommonConstants.COLOR_SUCCESS : CommonConstants.COLOR_ERROR)
            .borderRadius(4)
            .borderStyle(BorderStyle.Solid)
            .padding({ left: 10, right: 10, top: 2, bottom: 2 })
            .margin({ top: CommonConstants.SPACE_M })

          Text(`及格线 ${this.result.passScore} 分 · 用时 ${formatDuration(this.result.usedTime)} · ${submitTypeText(this.result.submitType)}`)
            .fontSize(FONT_SMALL)
            .fontColor(CommonConstants.COLOR_TEXT_SUB)
            .margin({ top: CommonConstants.SPACE_M })
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .padding(CommonConstants.SPACE_L)
        .alignItems(HorizontalAlign.Center)

        // ----- 证书提示条：仅通过时显示（静态占位） -----
        if (this.result.passed) {
          Text('✅ 已生成电子证书，可在个人中心查看')
            .fontSize(CommonConstants.FONT_CAPTION)
            .fontColor(CommonConstants.COLOR_SUCCESS)
            .textAlign(TextAlign.Center)
            .width('100%')
            .backgroundColor(CommonConstants.COLOR_BG_PAGE)
            .borderRadius(8)
            .padding(CommonConstants.SPACE_M)
        }

        // ----- 答题卡区：标题 + 六列格子 -----
        Column({ space: CommonConstants.SPACE_M }) {
          Text('答题卡')
            .fontSize(CommonConstants.FONT_SUBTITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(CommonConstants.COLOR_TEXT_MAIN)
            .width('100%')

          // 六列一行，格子高度固定（单行展示，无需滚动）
          Grid() {
            ForEach(this.result.answers, (answer: AnswerItem, index: number) => {
              GridItem() {
                AnswerCell({ index: index, answer: answer })
              }
            }, (answer: AnswerItem) => answer.questionId)
          }
          .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
          .width('100%')
          .height(44)
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .padding(CommonConstants.SPACE_M)
      }
      .width('100%')
      .layoutWeight(1)

      // ========== 底部按钮组行 ==========
      Row({ space: CommonConstants.SPACE_M }) {
        // 查看回顾：白底主色字
        Button('查看回顾')
          .type(ButtonType.Normal)
          .layoutWeight(1)
          .height(CommonConstants.BTN_HEIGHT)
          .backgroundColor(Color.White)
          .fontColor(CommonConstants.COLOR_PRIMARY)
          .fontSize(CommonConstants.FONT_BODY)
          .onClick(() => {
            console.info('查看回顾')
          })

        // 重新刷题：渐变主按钮
        Button('重新刷题')
          .layoutWeight(1)
          .height(CommonConstants.BTN_HEIGHT)
          .fontSize(CommonConstants.FONT_BODY)
          .fontColor(Color.White)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [[CommonConstants.GRADIENT_START, 0], [CommonConstants.GRADIENT_END, 1]]
          })
          .onClick(() => {
            console.info('重新刷题')
          })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.COLOR_BG_PAGE)
    .padding(CommonConstants.SPACE_M)
  }
}
