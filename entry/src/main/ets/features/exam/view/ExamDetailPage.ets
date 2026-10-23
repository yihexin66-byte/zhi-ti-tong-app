// 考试模式答题页（View 层）：展示试卷信息、题目内容及选项，支持上下题切换
//
// 【分层职责（View 层）】
//   零业务判断：题号、选中态、题型文案、倒计时文本、已答/存疑判定全部来自 ExamDetailViewModel；
//   事件只转发：选项点击 → vm.selectOption，切题 → vm.prevQuestion / vm.nextQuestion，
//              标记 → vm.toggleFlag，答题卡点号 → vm.jumpTo，切屏 → vm.onTabSwitch；
//   导航留在本层，且只有一个出口：@Monitor 盯着 finishedAttemptId 这盏灯，
//   灯亮则 replacePathByName 跳结果页（用 replace 而非 push，交卷后不允许返回答题页）。
import { CommonConstants } from '@zhititong/common'
import { RouteConstants } from '@zhititong/common'
import { OptionItem, QuestionItem } from '@zhititong/common'
import { formatCountdown } from '@zhititong/common'
import { FontSetting, StateKeys } from '@zhititong/common'
import { BackgroundMonitor } from '@zhititong/common'
import { Logger } from '@zhititong/common'
import { PersistenceV2, AppStorageV2 } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { ApplicationStateChangeCallback } from '@kit.AbilityKit'
import { ExamDetailViewModel } from '../viewModel/ExamDetailViewModel'

// 工程日志口径：文件顶层 const，标签取文件主体名（struct 与 class 通吃、无实例开销）
const logger: Logger = new Logger('ExamDetailPage')

// 答题卡格子尺寸（面板内五列排布）
const CARD_CELL_SIZE: number = 48

/**
 * 应用前后台监听器：防作弊 Toast 的触发点。
 * 说明：@Monitor 会在退后台瞬间（count 自增时）同步触发，此时 UI 已不可见，Toast 弹不出；
 * NavDestination.onShown 在应用回前台时也不会触发。因此挂应用级
 * applicationStateChange 监听，在 onApplicationForeground（回到前台）后再弹提示。
 */
class ForegroundWatcher extends ApplicationStateChangeCallback {
  // 回前台时要执行的动作（由页面注入，避免 watcher 反向依赖 struct）
  private onForegroundAction: () => void = () => {}

  setAction(action: () => void): void {
    this.onForegroundAction = action
  }

  onApplicationForeground(): void {
    this.onForegroundAction()
  }

  onApplicationBackground(): void {
    // 退后台无需处理：计数已由 EntryAbility.onBackground 上报
  }
}

@ComponentV2
export struct ExamDetailPage {
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()

  // 页面所有状态都在 ViewModel 上（@Local 持有实例）
  @Local viewModel: ExamDetailViewModel = new ExamDetailViewModel()

  // 全局字号设置：与"我的"页 connect 同一个 key、同一个实例
  // 仅题干与选项消费该偏移量；倒计时、按钮、进度、答题卡等保持固定字号
  @Local font: FontSetting = PersistenceV2.connect(FontSetting, StateKeys.FONT_SETTING, () => new FontSetting())!

  // 切后台监视器：与 EntryAbility connect 同一个 key、同一个实例
  @Local monitor: BackgroundMonitor = AppStorageV2.connect(BackgroundMonitor, StateKeys.BACKGROUND_MONITOR,
    () => new BackgroundMonitor())!

  // 答题卡半模态面板开合
  @Local showCard: boolean = false

  // 题目区滚动控制器：切题时回到题首，避免沿用上一题的滚动偏移
  private questionScroller: Scroller = new Scroller()

  // 应用前后台监听（aboutToAppear 注册 / aboutToDisappear 注销）
  private foregroundWatcher: ForegroundWatcher = new ForegroundWatcher()

  aboutToAppear(): void {
    this.foregroundWatcher.setAction(() => {
      this.notifySwitchCount()
    })
    const context = this.getUIContext().getHostContext()
    if (context !== undefined) {
      context.getApplicationContext().on('applicationStateChange', this.foregroundWatcher)
    }
  }

  // 页面销毁兜底：定时器必须清理，否则离开页面后仍会 tick
  aboutToDisappear(): void {
    const context = this.getUIContext().getHostContext()
    if (context !== undefined) {
      context.getApplicationContext().off('applicationStateChange', this.foregroundWatcher)
    }
    this.viewModel.dispose()
  }

  // onWillDisappear 在导航切换（含被结果页 replace）时触发，是清理定时器的正位
  onWillDisappear(): void {
    this.viewModel.dispose()
  }

  /**
   * 回到前台后弹切后台计数提示（仅考试进行中且已有切出记录时打扰）
   * 弹出失败（如窗口未就绪）降级记 warn，不影响计数与考试流程
   */
  private notifySwitchCount(): void {
    if (!this.monitor.monitoring || this.monitor.count <= 0) {
      return
    }
    try {
      this.getUIContext().getPromptAction().showToast({
        message: `检测到切出应用，已记录 ${this.monitor.count} 次，请专心作答`,
        duration: 3000
      })
    } catch (e) {
      const error = e as BusinessError
      logger.warn(`切后台提示弹出失败：code=${error.code}, message=${error.message}`)
    }
  }

  /**
   * 答题卡格子底色：橙=存疑 / 绿=已答 / 灰=未答（判定全部来自 ViewModel）
   */
  private cardBackground(index: number): string {
    if (this.viewModel.isFlagged(index)) {
      return CommonConstants.COLOR_WARN
    }
    if (this.viewModel.isAnswered(index)) {
      return CommonConstants.COLOR_SUCCESS
    }
    return CommonConstants.COLOR_TEXT_HINT
  }

  // 答题卡面板（bindSheet 半模态）：Grid 渲染全卷题号，点击直达该题
  @Builder
  AnswerCardSheet() {
    Column({ space: CommonConstants.SPACE_M }) {
      Row() {
        Text('答题卡')
          .fontSize(CommonConstants.FONT_SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(CommonConstants.COLOR_TEXT_MAIN)
        Blank()
        Text(`已答 ${this.viewModel.getAnsweredCount()}/${this.viewModel.questions.length}`)
          .fontSize(CommonConstants.FONT_CAPTION)
          .fontColor(CommonConstants.COLOR_TEXT_SUB)
      }
      .width('100%')

      Grid() {
        ForEach(this.viewModel.questions, (question: QuestionItem, index: number) => {
          GridItem() {
            Column() {
              Text(`${index + 1}`)
                .fontSize(CommonConstants.FONT_BODY)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
            }
            .width(CARD_CELL_SIZE)
            .height(CARD_CELL_SIZE)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.cardBackground(index))
            .borderRadius(6)
            // 蓝框=当前题
            .borderWidth(index === this.viewModel.currentIndex ? 2 : 0)
            .borderColor(CommonConstants.COLOR_PRIMARY)
            .borderStyle(BorderStyle.Solid)
            .onClick(() => {
              // 事件只转发：跳题（含边界保护）在 ViewModel
              this.viewModel.jumpTo(index)
              this.questionScroller.scrollEdge(Edge.Top)
              this.showCard = false
            })
          }
        }, (question: QuestionItem) => question.id)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
      .rowsGap(CommonConstants.SPACE_M)
      .columnsGap(CommonConstants.SPACE_M)
      .width('100%')
      .layoutWeight(1)

      // 图例：四态对照
      Row({ space: CommonConstants.SPACE_M }) {
        this.LegendItem(CommonConstants.COLOR_SUCCESS, '已答')
        this.LegendItem(CommonConstants.COLOR_WARN, '存疑')
        this.LegendItem(CommonConstants.COLOR_TEXT_HINT, '未答')
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding(CommonConstants.SPACE_M)
  }

  @Builder
  LegendItem(color: string, label: string) {
    Row({ space: 4 }) {
      Column()
        .width(12)
        .height(12)
        .backgroundColor(color)
        .borderRadius(3)
      Text(label)
        .fontSize(CommonConstants.FONT_CAPTION)
        .fontColor(CommonConstants.COLOR_TEXT_SUB)
    }
  }

  build() {
    NavDestination() {
      Column() {
        // ========== 顶部标题区 ==========
        Column() {
          Text(this.viewModel.paperName)
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

            // 倒计时文本：服务端时间权威，前端每秒只做视觉递减
            Text(formatCountdown(this.viewModel.remainingSeconds))
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
        // 题干与选项可纵向滚动：长题/大字号下内容不被底部按钮区挤掉
        Scroll(this.questionScroller) {
          Column() {
            if (this.viewModel.questions.length === 0) {
              // 开考请求进行中：整卷尚未装载
              Column() {
                LoadingProgress()
                  .width(40)
                  .height(40)
                Text(this.viewModel.errorMessage !== '' ? this.viewModel.errorMessage : '正在开考...')
                  .fontSize(CommonConstants.FONT_CAPTION)
                  .fontColor(CommonConstants.COLOR_TEXT_SUB)
                  .margin({ top: CommonConstants.SPACE_M })
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            } else {
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
                .fontSize(CommonConstants.FONT_BODY + this.font.fontSize)
                .fontColor(CommonConstants.COLOR_TEXT_MAIN)
                .lineHeight(24)
                .margin({ top: CommonConstants.SPACE_M })
                .width('100%')

              // 选项列表：单选/判断渲染 Radio，多选渲染 Checkbox；
              // 选中态与点选语义统一由 ViewModel 的 answers 事实源派生
              ForEach(this.viewModel.questions[this.viewModel.currentIndex].options, (option: OptionItem) => {
                Row() {
                  if (this.viewModel.isCurrentMulti()) {
                    Checkbox()
                      .select(this.viewModel.isChecked(option.label))
                      .onChange((isChecked: boolean) => {
                        // 事件只转发：toggle 语义与实时保存由 ViewModel 处理
                        this.viewModel.selectOption(option.label)
                      })
                  } else {
                    Radio({ value: option.label, group: `q_${this.viewModel.currentIndex}` })
                      .checked(this.viewModel.isChecked(option.label))
                      .onChange((isChecked: boolean) => {
                        if (isChecked) {
                          // 事件只转发：替换语义与实时保存由 ViewModel 处理
                          this.viewModel.selectOption(option.label)
                        }
                      })
                  }
                  // 占满剩余宽度：长选项自动换行，不再被屏幕右缘裁掉
                  Text(`${option.label}. ${option.content}`)
                    .fontSize(CommonConstants.FONT_BODY + this.font.fontSize)
                    .fontColor(CommonConstants.COLOR_TEXT_MAIN)
                    .lineHeight(24)
                    .wordBreak(WordBreak.BREAK_WORD)
                    .layoutWeight(1)
                    .margin({ left: 8 })
                }
                .width('100%')
                .alignItems(VerticalAlign.Top)
                .margin({ top: CommonConstants.SPACE_M })
              }, (option: OptionItem) => `${this.viewModel.currentIndex}_${option.label}`)
            }
          }
          .width('100%')
          .padding(CommonConstants.SPACE_M)
        }
        .width('100%')
        .layoutWeight(1)
        // Scroll 默认居中放置内容；题目区要求从顶部开始排版
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

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
                // 事件只转发：边界保护在 ViewModel
                this.viewModel.prevQuestion()
                this.questionScroller.scrollEdge(Edge.Top)
              })

            Button('下一题')
              .type(ButtonType.Normal)
              .layoutWeight(1)
              .backgroundColor(CommonConstants.COLOR_TEXT_HINT)
              .fontColor(CommonConstants.COLOR_TEXT_MAIN)
              .fontSize(CommonConstants.FONT_CAPTION)
              .enabled(this.viewModel.currentIndex < this.viewModel.questions.length - 1)
              .onClick(() => {
                // 事件只转发：边界保护在 ViewModel
                this.viewModel.nextQuestion()
                this.questionScroller.scrollEdge(Edge.Top)
              })

            // 标记存疑：已存疑时按钮换文案与强调色（状态由 ViewModel 判定）
            Button(this.viewModel.isCurrentFlagged() ? '已存疑' : '标记存疑')
              .type(ButtonType.Normal)
              .layoutWeight(1)
              .backgroundColor(this.viewModel.isCurrentFlagged()
                ? CommonConstants.COLOR_WARN : CommonConstants.COLOR_TEXT_HINT)
              .fontColor(this.viewModel.isCurrentFlagged() ? Color.White : CommonConstants.COLOR_WARN)
              .fontSize(CommonConstants.FONT_CAPTION)
              .onClick(() => {
                // 事件只转发：状态翻转与上报在 ViewModel
                this.viewModel.toggleFlag()
              })

            Button('答题卡')
              .type(ButtonType.Normal)
              .layoutWeight(1)
              .backgroundColor(CommonConstants.COLOR_TEXT_HINT)
              .fontColor(CommonConstants.COLOR_TEXT_MAIN)
              .fontSize(CommonConstants.FONT_CAPTION)
              .onClick(() => {
                this.showCard = true
              })
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
            .enabled(this.viewModel.questions.length > 0)
            .onClick(() => {
              // 事件只转发：交卷与闸门在 ViewModel；跳转由 finishedAttemptId 信号驱动
              this.viewModel.submit('MANUAL')
            })
        }
        .width('100%')
        .padding(CommonConstants.SPACE_M)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(CommonConstants.COLOR_BG_PAGE)
      // 答题卡半模态面板
      .bindSheet($$this.showCard, this.AnswerCardSheet(), {
        height: SheetSize.MEDIUM,
        dragBar: true,
        showClose: true
      })
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      // onReady 每次导航进入只触发一次：取路由参数（paperId）开考/续考
      // SDK 中 NavPathInfo.param 声明为 unknown（ArkTS 禁止 unknown 类型），故按契约强转为 string
      const paperId = context.pathInfo?.param as string
      this.viewModel.startExam(paperId === undefined ? '' : paperId)
    })
  }

  // 交卷完成信号灯：灯亮则携带场次号跳结果页
  // replace 而非 push——交卷后不允许返回答题页
  @Monitor('viewModel.finishedAttemptId')
  onFinished(): void {
    if (this.viewModel.finishedAttemptId !== '') {
      this.pageStack.replacePathByName(RouteConstants.ANSWER_RESULT, this.viewModel.finishedAttemptId)
    }
  }

  // 切屏计数增长 → 如实上报给后端，由服务端裁决；服务端判"强制交卷"则立即交卷
  @Monitor('monitor.count')
  onSwitchCountChanged(): void {
    if (this.monitor.count > 0) {
      this.viewModel.onTabSwitch(this.monitor.count)
    }
  }
}
