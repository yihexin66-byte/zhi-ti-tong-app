// 答题结果页（View 层）：结果卡 + 证书提示条 + 答题卡 + 底部按钮组
//
// 【分层职责（View 层）】
//   零业务判断：结果数据、得分颜色、通过标签、说明行文案、答题卡格子颜色
//   全部来自 ResultViewModel，View 只取值渲染（无三元业务判断）；
//   导航留在本层："重新刷题" pop 弹回答题页。
import { CommonConstants } from '@zhititong/common'
import { AnswerItem } from '@zhititong/common'
import { Logger } from '@zhititong/common'
import { AnswerCell } from './AnswerCell'
import { ResultViewModel } from '../viewModel/ResultViewModel'

// 本页专用字号：大号得分 48、说明行 12（任务指定，常量库暂无对应档位）
const FONT_SCORE: number = 48
const FONT_SMALL: number = 12

// 工程日志口径：文件顶层 const，标签取文件主体名
const logger: Logger = new Logger('AnswerResultPage')

@ComponentV2
export struct AnswerResultPage {
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()

  // 页面所有状态都在 ViewModel 上（@Local 持有实例）
  @Local viewModel: ResultViewModel = new ResultViewModel()

  build() {
    NavDestination() {
      Column() {
        // ========== 上方内容区（占满剩余空间，把按钮压到底部） ==========
        Column({ space: CommonConstants.SPACE_L }) {
          // ----- 结果卡：得分 + 通过标签 + 及格线/用时/交卷方式 -----
          Column() {
            Text(`${this.viewModel.result.score}`)
              .fontSize(FONT_SCORE)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.viewModel.getScoreColor())

            Text(this.viewModel.getPassedLabel())
              .fontSize(CommonConstants.FONT_CAPTION)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.viewModel.getScoreColor())
              .borderWidth(1)
              .borderColor(this.viewModel.getPassedBorderColor())
              .borderRadius(4)
              .borderStyle(BorderStyle.Solid)
              .padding({ left: 10, right: 10, top: 2, bottom: 2 })
              .margin({ top: CommonConstants.SPACE_M })

            Text(this.viewModel.getSummaryText())
              .fontSize(FONT_SMALL)
              .fontColor(CommonConstants.COLOR_TEXT_SUB)
              .margin({ top: CommonConstants.SPACE_M })

            // 切后台防作弊：本场切出次数（交卷时定格，文案由 ViewModel 派生）
            Text(this.viewModel.getSwitchCountText())
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
          if (this.viewModel.showCertificate()) {
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
              ForEach(this.viewModel.result.answers, (answer: AnswerItem, index: number) => {
                GridItem() {
                  AnswerCell({
                    index: index,
                    color: this.viewModel.getCellColor(answer)
                  })
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
              // 项目 6 预留的占位实现：本次只换日志出口，不动按钮交互
              logger.info('查看回顾')
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
              // 导航留在 View 层：弹出结果页，回到答题页重新作答
              // （按记录跳转的完整逻辑项目 6 接入数据后实现）
              this.pageStack.pop()
            })
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(CommonConstants.COLOR_BG_PAGE)
      .padding(CommonConstants.SPACE_M)
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      // onReady 取路由参数（交卷时点灯传下来的场次号），按场次号拉真实判分与答题卡
      // SDK 中 NavPathInfo.param 声明为 unknown（ArkTS 禁止 unknown 类型），故按契约强转为 string
      const attemptId = context.pathInfo?.param as string
      this.viewModel.loadResult(attemptId === undefined ? '' : attemptId)
    })
  }
}
