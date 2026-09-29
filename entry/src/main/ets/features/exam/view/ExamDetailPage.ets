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
import { FontSetting, StateKeys } from '@zhititong/common'
import { BackgroundMonitor } from '@zhititong/common'
import { Logger } from '@zhititong/common'
import { PersistenceV2, AppStorageV2 } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { ApplicationStateChangeCallback } from '@kit.AbilityKit'
import { ExamDetailViewModel } from '../viewModel/ExamDetailViewModel'

// 工程日志口径：文件顶层 const，标签取文件主体名（struct 与 class 通吃、无实例开销）
const logger: Logger = new Logger('ExamDetailPage')

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

  aboutToDisappear(): void {
    const context = this.getUIContext().getHostContext()
    if (context !== undefined) {
      context.getApplicationContext().off('applicationStateChange', this.foregroundWatcher)
    }
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
            .fontSize(CommonConstants.FONT_BODY + this.font.fontSize)
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
                .fontSize(CommonConstants.FONT_BODY + this.font.fontSize)
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
              // 交卷先定格计数（stop 只停不清），再执行跳转
              this.viewModel.submitPaper()
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
    .onReady((context: NavDestinationContext) => {
      // onReady 每次导航进入只触发一次：取路由参数装载对应试卷 + 开考监视
      // SDK 中 NavPathInfo.param 声明为 unknown（ArkTS 禁止 unknown 类型），故按契约强转为 string
      const paperId = context.pathInfo?.param as string
      this.viewModel.loadPaper(paperId === undefined ? '' : paperId)
      this.viewModel.startExam()
    })
    .onShown(() => {
      // onShown 只在导航返回（pop 弹回）时触发，应用回前台不会触发：
      // 交卷时监视器已 stop（monitoring=false），从结果页"重新刷题"pop 回本页
      // 即视为重新开考——清零计数并重新进入监视
      if (!this.monitor.monitoring) {
        this.viewModel.startExam()
      }
    })
  }
}
