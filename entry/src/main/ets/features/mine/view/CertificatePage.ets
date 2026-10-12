// 我的证书页（View 层，mine 域内路由页面）
//
// 【分层职责（View 层）】
//   零业务判断：证书数据、状态徽标文案与颜色全部来自 CertificateViewModel；
//   状态枚举翻译（VALID → 有效）是契约坑的 App 侧处置，落在 ViewModel。
import { CommonConstants } from '@zhititong/common'
import { CertificateItem } from '../../exam/service/ExamService'
import { CertificateViewModel } from '../viewModel/CertificateViewModel'

@ComponentV2
export struct CertificatePage {
  @Local viewModel: CertificateViewModel = new CertificateViewModel()

  build() {
    NavDestination() {
      if (this.viewModel.certificates.length === 0) {
        // ===== 空态 =====
        Column() {
          Text(this.viewModel.loading
            ? '加载中...'
            : (this.viewModel.errorMessage !== '' ? this.viewModel.errorMessage : '还没有证书，通过考试后即可获得'))
            .fontSize(CommonConstants.FONT_BODY)
            .fontColor(CommonConstants.COLOR_TEXT_HINT)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        // ===== 证书列表 =====
        List({ space: CommonConstants.SPACE_M }) {
          ForEach(this.viewModel.certificates, (item: CertificateItem) => {
            ListItem() {
              Column() {
                Row() {
                  Text(item.name)
                    .fontSize(CommonConstants.FONT_BODY)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(CommonConstants.COLOR_TEXT_MAIN)
                    .layoutWeight(1)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  // 状态徽标：英文枚举进、中文徽标出
                  Text(this.viewModel.getStatusText(item.status))
                    .fontSize(CommonConstants.FONT_CAPTION)
                    .fontColor(this.viewModel.getStatusColor(item.status))
                    .borderWidth(1)
                    .borderColor(this.viewModel.getStatusColor(item.status))
                    .borderRadius(4)
                    .borderStyle(BorderStyle.Solid)
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)

                Text(`证书编号 ${item.certificateNo}`)
                  .fontSize(CommonConstants.FONT_CAPTION)
                  .fontColor(CommonConstants.COLOR_TEXT_SUB)
                  .width('100%')
                  .margin({ top: CommonConstants.SPACE_M })

                Text(`颁发 ${item.issueDate} · 到期 ${item.expiryDate}`)
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
          }, (item: CertificateItem) => item.id)
        }
        .width('100%')
        .height('100%')
        .padding(CommonConstants.SPACE_M)
      }
    }
    .title('我的证书')
    .backgroundColor(CommonConstants.COLOR_BG_PAGE)
    .onReady(() => {
      this.viewModel.loadCertificates()
    })
  }
}
