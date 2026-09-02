// 登录页面：展示应用Logo、登录表单及注册提示
import { CommonConstants } from '../common/constants/CommonConstants'

@Entry
@ComponentV2
struct LoginPage {
  @Local username: string = ''
  @Local password: string = ''

  build() {
    Column() {
      // 上部Logo区
      Column() {
        Image($r('app.media.ic_app'))
          .width(80)
          .height(80)
          .objectFit(ImageFit.Contain)
        Text('欢迎使用智题通')
          .fontSize(CommonConstants.FONT_TITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(CommonConstants.COLOR_TEXT_MAIN)
          .margin({ top: CommonConstants.SPACE_M })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      // 下部表单区
      Column() {
        TextInput({ placeholder: '请输入用户名' })
          .width('80%')
          .height(CommonConstants.BTN_HEIGHT)
          .fontSize(CommonConstants.FONT_BODY)
          .fontColor(CommonConstants.COLOR_TEXT_MAIN)
          .placeholderColor(CommonConstants.COLOR_TEXT_HINT)
          .onChange((value: string) => {
            this.username = value
          })

        TextInput({ placeholder: '请输入密码' })
          .width('80%')
          .height(CommonConstants.BTN_HEIGHT)
          .type(InputType.Password)
          .fontSize(CommonConstants.FONT_BODY)
          .fontColor(CommonConstants.COLOR_TEXT_MAIN)
          .placeholderColor(CommonConstants.COLOR_TEXT_HINT)
          .margin({ top: CommonConstants.SPACE_M })
          .onChange((value: string) => {
            this.password = value
          })

        Button('登录')
          .width('80%')
          .height(CommonConstants.BTN_HEIGHT)
          .type(ButtonType.Capsule)
          .backgroundColor(CommonConstants.COLOR_PRIMARY)
          .fontSize(CommonConstants.FONT_SUBTITLE)
          .fontColor(Color.White)
          .margin({ top: CommonConstants.SPACE_L })
          .onClick(() => {
            console.info('执行登录')
          })

        Text() {
          Span('没有账号？')
            .fontSize(CommonConstants.FONT_CAPTION)
            .fontColor(CommonConstants.COLOR_TEXT_SUB)
          Span('立即注册')
            .fontSize(CommonConstants.FONT_CAPTION)
            .fontColor(CommonConstants.COLOR_PRIMARY)
        }
        .margin({ top: CommonConstants.SPACE_M })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .margin({ top: CommonConstants.SPACE_L })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.COLOR_BG_PAGE)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}
