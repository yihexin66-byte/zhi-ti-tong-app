// 考试记录页（View 层，mine 域内路由页面）
//
// 【分层职责（View 层）】
//   零业务判断：记录数据、得分颜色、交卷方式文案全部来自 AttemptRecordViewModel；
//   触底加载只转发事件，分页规则（到底不再请求）在 ViewModel。
import { CommonConstants } from '@zhititong/common'
import { formatDuration } from '@zhititong/common'
import { AttemptRecord } from '../../exam/service/ExamService'
import { AttemptRecordViewModel } from '../viewModel/AttemptRecordViewModel'

@ComponentV2
export struct AttemptRecordPage {
  @Local viewModel: AttemptRecordViewModel = new AttemptRecordViewModel()

  build() {
    NavDestination() {
      if (this.viewModel.records.length === 0) {
        // ===== 空态 =====
        Column() {
          Text(this.viewModel.loading
            ? '加载中...'
            : (this.viewModel.errorMessage !== '' ? this.viewModel.errorMessage : '还没有考试记录，快去考一场吧'))
            .fontSize(CommonConstants.FONT_BODY)
            .fontColor(CommonConstants.COLOR_TEXT_HINT)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        // ===== 记录列表（触底加载下一页） =====
        List({ space: CommonConstants.SPACE_M }) {
          ForEach(this.viewModel.records, (record: AttemptRecord) => {
            ListItem() {
              Column() {
                Text(record.paperName)
                  .fontSize(CommonConstants.FONT_BODY)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(CommonConstants.COLOR_TEXT_MAIN)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')

                Row() {
                  Text(`${record.score} 分`)
                    .fontSize(CommonConstants.FONT_SUBTITLE)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.viewModel.getScoreColor(record))
                  Blank()
                  Text(record.passed ? '通过' : '未通过')
                    .fontSize(CommonConstants.FONT_CAPTION)
                    .fontColor(this.viewModel.getScoreColor(record))
                }
                .width('100%')
                .margin({ top: CommonConstants.SPACE_M })

                Text(`${record.startTime} · 用时 ${formatDuration(record.usedTime)} · ${this.viewModel.getSubmitTypeText(record)}`)
                  .fontSize(CommonConstants.FONT_CAPTION)
                  .fontColor(CommonConstants.COLOR_TEXT_SUB)
                  .width('100%')
                  .margin({ top: 4 })
              }
              .width('100%')
              .padding(CommonConstants.SPACE_M)
              .backgroundColor(Color.White)
              .borderRadius(12)
              .alignItems(HorizontalAlign.Start)
            }
          }, (record: AttemptRecord) => record.id)

          // 底部哨兵：触底即加载下一页；到底后给出提示
          ListItem() {
            Row() {
              Text(this.viewModel.hasMore ? '加载中...' : `已全部加载（共 ${this.viewModel.total} 条）`)
                .fontSize(CommonConstants.FONT_CAPTION)
                .fontColor(CommonConstants.COLOR_TEXT_HINT)
            }
            .width('100%')
            .height(48)
            .justifyContent(FlexAlign.Center)
            .onAppear(() => {
              // 事件只转发：是否真的请求由 ViewModel 的 hasMore 决定
              this.viewModel.loadMore()
            })
          }
        }
        .width('100%')
        .height('100%')
        .padding(CommonConstants.SPACE_M)
      }
    }
    .title('做题记录')
    .backgroundColor(CommonConstants.COLOR_BG_PAGE)
    .onReady(() => {
      this.viewModel.loadFirstPage()
    })
  }
}
