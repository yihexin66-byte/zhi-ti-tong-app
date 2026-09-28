// 考试模式答题页（View 层）：展示试卷信息、题目内容及选项，支持上下题切换
//
// 【分层职责（View 层）】
//   零业务判断：题号、选中态、题型文案全部来自 ExamDetailViewModel；
//   事件只转发：选项点击 → vm.handleSingleSelect / vm.handleMultiSelect，
//              切题 → vm.prevQuestion / vm.nextQuestion；
//   导航留在本层：提交试卷 push 到根栈结果页。
import { CommonConstants } from '@zhititong/common'
import { RouteConstants } from '@zhititong/common'
import { OptionItem } from '@zhititong/common'
import { ExamDetailViewModel } from '../viewModel/ExamDetailViewModel'

@ComponentV2
export struct ExamDetailPage {
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()

  // 页面所有状态都在 ViewModel 上（@Local 持有实例）
  @Local viewModel: ExamDetailViewModel = new ExamDetailViewModel()

  build() {
    NavDestination() {
      Column() {
        // ========== 顶部标题区 ==========
        Column() {
          Text(this.viewModel.paper.paperName)
            .fontSize(CommonConstants.FONT_BODY)
            .fontWeight(FontWeight.Bold)
            .fontColor(CommonConstants.COLOR_TEXT_MAIN)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          Row() {
            Text() {
              Span('第 ')
              Span(`${this.viewModel.currentIndex + 1}`)
                .fontColor(CommonConstants.COLOR_WARN)
              Span(' 题 / 共 ')
              Span(`${this.viewModel.questions.length}`)
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
          // 题型标签（换算逻辑在 ViewModel）
          Text(this.viewModel.getTypeLabel(this.viewModel.questions[this.viewModel.currentIndex].type))
            .fontSize(CommonConstants.FONT_CAPTION)
            .fontColor(CommonConstants.COLOR_PRIMARY)
            .borderWidth(1)
            .borderColor(CommonConstants.COLOR_PRIMARY)
            .borderRadius(4)
            .borderStyle(BorderStyle.Solid)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })

          // 题干内容
          Text(this.viewModel.questions[this.viewModel.currentIndex].content)
            .fontSize(CommonConstants.FONT_BODY)
            .fontColor(CommonConstants.COLOR_TEXT_MAIN)
            .lineHeight(24)
            .margin({ top: CommonConstants.SPACE_M })
            .width('100%')

          // 选项列表
          ForEach(this.viewModel.questions[this.viewModel.currentIndex].options, (option: OptionItem) => {
            Row() {
              if (this.viewModel.isCurrentMulti()) {
                Checkbox()
                  .select(this.viewModel.isMultiChecked(option.label))
                  .onChange((isChecked: boolean) => {
                    // 事件只转发：toggle 语义由 ViewModel 处理（已选再点=取消）
                    this.viewModel.handleMultiSelect(option.label)
                  })
              } else {
                Radio({ value: option.label, group: `q_${this.viewModel.currentIndex}` })
                  .checked(this.viewModel.isSingleChecked(option.label))
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      // 事件只转发：单选替换语义由 ViewModel 处理
                      this.viewModel.handleSingleSelect(option.label)
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
          }, (option: OptionItem) => `${this.viewModel.currentIndex}_${option.label}`)
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
              .enabled(this.viewModel.currentIndex > 0)
              .onClick(() => {
                // 事件只转发：边界保护与切题重置在 ViewModel
                this.viewModel.prevQuestion()
              })

            Button('下一题')
              .type(ButtonType.Normal)
              .layoutWeight(1)
              .backgroundColor(CommonConstants.COLOR_TEXT_HINT)
              .fontColor(CommonConstants.COLOR_TEXT_MAIN)
              .fontSize(CommonConstants.FONT_CAPTION)
              .enabled(this.viewModel.currentIndex < this.viewModel.questions.length - 1)
              .onClick(() => {
                // 事件只转发：边界保护与切题重置在 ViewModel
                this.viewModel.nextQuestion()
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
              // 导航留在 View 层：push 到根栈结果页
              this.pageStack.pushPathByName(RouteConstants.ANSWER_RESULT, null)
            })
        }
        .width('100%')
        .padding(CommonConstants.SPACE_M)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(CommonConstants.COLOR_BG_PAGE)
    }
    .hideTitleBar(true)
  }
}
