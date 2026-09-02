// 考试模式答题页：展示试卷信息、题目内容及选项，支持上下题切换
import { CommonConstants } from '../common/constants/CommonConstants'
import { MOCK_PAPER, MOCK_QUESTIONS } from '../common/mock/MockExamData'
import { OptionItem } from '../common/model/QuestionModel'

@Entry
@ComponentV2
struct ExamDetailPage {
  @Local currentIndex: number = 0
  @Local selectedAnswer: string = ''
  @Local multiAnswers: string[] = []

  // 根据题型返回中文名称
  getTypeLabel(type: string): string {
    if (type === 'JUDGE') {
      return '判断题'
    }
    if (type === 'SINGLE') {
      return '单选题'
    }
    if (type === 'MULTI') {
      return '多选题'
    }
    return ''
  }

  build() {
    Column() {
      // ========== 顶部标题区 ==========
      Column() {
        Text(MOCK_PAPER.paperName)
          .fontSize(CommonConstants.FONT_BODY)
          .fontWeight(FontWeight.Bold)
          .fontColor(CommonConstants.COLOR_TEXT_MAIN)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Row() {
          Text() {
            Span('第 ')
            Span(`${this.currentIndex + 1}`)
              .fontColor(CommonConstants.COLOR_WARN)
            Span(' 题 / 共 ')
            Span(`${MOCK_QUESTIONS.length}`)
              .fontColor(CommonConstants.COLOR_TEXT_SUB)
            Span(' 题')
          }
          .fontSize(CommonConstants.FONT_CAPTION)
          .fontColor(CommonConstants.COLOR_TEXT_SUB)

          Text('29:59')
            .fontSize(CommonConstants.FONT_CAPTION)
            .fontColor(CommonConstants.COLOR_WARN)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: CommonConstants.SPACE_M })
      }
      .width('100%')
      .padding(CommonConstants.SPACE_M)

      // ========== 中部题目区域 ==========
      Column() {
        // 题型标签
        Text(this.getTypeLabel(MOCK_QUESTIONS[this.currentIndex].type))
          .fontSize(CommonConstants.FONT_CAPTION)
          .fontColor(CommonConstants.COLOR_PRIMARY)
          .borderWidth(1)
          .borderColor(CommonConstants.COLOR_PRIMARY)
          .borderRadius(4)
          .borderStyle(BorderStyle.Solid)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })

        // 题干内容
        Text(MOCK_QUESTIONS[this.currentIndex].content)
          .fontSize(CommonConstants.FONT_BODY)
          .fontColor(CommonConstants.COLOR_TEXT_MAIN)
          .lineHeight(24)
          .margin({ top: CommonConstants.SPACE_M })
          .width('100%')

        // 选项列表
        ForEach(MOCK_QUESTIONS[this.currentIndex].options, (option: OptionItem) => {
          Row() {
            if (MOCK_QUESTIONS[this.currentIndex].type === 'MULTI') {
              Checkbox()
                .select(this.multiAnswers.indexOf(option.label) !== -1)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.multiAnswers = [...this.multiAnswers, option.label]
                  } else {
                    this.multiAnswers = this.multiAnswers.filter((item: string) => item !== option.label)
                  }
                })
            } else {
              Radio({ value: option.label, group: `q_${this.currentIndex}` })
                .checked(this.selectedAnswer === option.label)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.selectedAnswer = option.label
                  }
                })
            }
            Text(`${option.label}. ${option.content}`)
              .fontSize(CommonConstants.FONT_BODY)
              .fontColor(CommonConstants.COLOR_TEXT_MAIN)
              .margin({ left: 8 })
          }
          .width('100%')
          .margin({ top: CommonConstants.SPACE_M })
        }, (option: OptionItem) => `${this.currentIndex}_${option.label}`)
      }
      .width('100%')
      .padding(CommonConstants.SPACE_M)
      .layoutWeight(1)

      // ========== 底部操作区 ==========
      Column() {
        Row({ space: CommonConstants.SPACE_M }) {
          Button('上一题')
            .type(ButtonType.Normal)
            .layoutWeight(1)
            .backgroundColor(CommonConstants.COLOR_TEXT_HINT)
            .fontColor(CommonConstants.COLOR_TEXT_MAIN)
            .fontSize(CommonConstants.FONT_CAPTION)
            .enabled(this.currentIndex > 0)
            .onClick(() => {
              if (this.currentIndex > 0) {
                this.currentIndex--
                this.selectedAnswer = ''
                this.multiAnswers = []
              }
            })

          Button('下一题')
            .type(ButtonType.Normal)
            .layoutWeight(1)
            .backgroundColor(CommonConstants.COLOR_TEXT_HINT)
            .fontColor(CommonConstants.COLOR_TEXT_MAIN)
            .fontSize(CommonConstants.FONT_CAPTION)
            .enabled(this.currentIndex < MOCK_QUESTIONS.length - 1)
            .onClick(() => {
              if (this.currentIndex < MOCK_QUESTIONS.length - 1) {
                this.currentIndex++
                this.selectedAnswer = ''
                this.multiAnswers = []
              }
            })

          Button('标记存疑')
            .type(ButtonType.Normal)
            .layoutWeight(1)
            .backgroundColor(CommonConstants.COLOR_TEXT_HINT)
            .fontColor(CommonConstants.COLOR_WARN)
            .fontSize(CommonConstants.FONT_CAPTION)

          Button('答题卡')
            .type(ButtonType.Normal)
            .layoutWeight(1)
            .backgroundColor(CommonConstants.COLOR_TEXT_HINT)
            .fontColor(CommonConstants.COLOR_TEXT_MAIN)
            .fontSize(CommonConstants.FONT_CAPTION)
        }
        .width('100%')

        Button('提交试卷')
          .width('100%')
          .height(CommonConstants.BTN_HEIGHT)
          .fontSize(CommonConstants.FONT_SUBTITLE)
          .fontColor(Color.White)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [[CommonConstants.GRADIENT_START, 0], [CommonConstants.GRADIENT_END, 1]]
          })
          .margin({ top: CommonConstants.SPACE_M })
          .onClick(() => {
            console.info('提交试卷')
          })
      }
      .width('100%')
      .padding(CommonConstants.SPACE_M)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.COLOR_BG_PAGE)
  }
}
