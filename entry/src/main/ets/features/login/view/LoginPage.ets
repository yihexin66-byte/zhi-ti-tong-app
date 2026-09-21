// 登录/注册页（View 层）：零业务逻辑，全部委托 LoginViewModel
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { RouteConstants } from '../../../common/constants/RouteConstants'
import { LoginViewModel } from '../viewModel/LoginViewModel'

@ComponentV2
export struct LoginPage {
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()

  // 持有 ViewModel 实例：页面所有状态都在它身上
  @Local viewModel: LoginViewModel = new LoginViewModel()

  build() {
    NavDestination() {
      Column() {
        // 上部 Logo 区
        Column() {
          Image($r('app.media.ic_app'))
            .width(80)
            .height(80)
            .objectFit(ImageFit.Cover)

          Text(this.viewModel.isReg ? '注册智题通账号' : '欢迎使用智题通')
            .fontSize(CommonConstants.FONT_TITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(CommonConstants.COLOR_TEXT_MAIN)
            .margin({ top: CommonConstants.SPACE_M })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ top: CommonConstants.SPACE_L })

        // 下部表单区
        Column({ space: CommonConstants.SPACE_M }) {
          TextInput({ placeholder: '请输入用户名', text: this.viewModel.username })
            .width('80%')
            .fontSize(CommonConstants.FONT_BODY)
            .onChange((value: string) => {
              this.viewModel.username = value
            })

          TextInput({ placeholder: '请输入密码', text: this.viewModel.password })
            .width('80%')
            .fontSize(CommonConstants.FONT_BODY)
            .type(InputType.Password)
            .onChange((value: string) => {
              this.viewModel.password = value
            })

          // 注册态才出现的确认密码框（条件渲染由 isReg 驱动）
          if (this.viewModel.isReg) {
            TextInput({ placeholder: '请再次输入密码', text: this.viewModel.confirmPwd })
              .width('80%')
              .fontSize(CommonConstants.FONT_BODY)
              .type(InputType.Password)
              .onChange((value: string) => {
                this.viewModel.confirmPwd = value
              })
          }

          // 错误提示区（errorMessage 非空才渲染）
          if (this.viewModel.errorMessage !== '') {
            Text(this.viewModel.errorMessage)
              .fontSize(CommonConstants.FONT_CAPTION)
              .fontColor(CommonConstants.COLOR_ERROR)
              .width('80%')
          }

          Button(this.viewModel.loading
            ? '请稍候...'
            : (this.viewModel.isReg ? '注册' : '登录'))
            .type(ButtonType.Capsule)
            .width('80%')
            .height(CommonConstants.BTN_HEIGHT)
            .backgroundColor(CommonConstants.COLOR_PRIMARY)
            .fontColor(Color.White)
            .fontSize(CommonConstants.FONT_SUBTITLE)
            .enabled(!this.viewModel.loading)
            .onClick(async () => {
              // View 不做任何判断，只转发事件、消费结果
              const res = await this.viewModel.submit()
              if (res.ok) {
                this.pageStack.replacePathByName(RouteConstants.MAIN, null)
              }
            })

          // 登录/注册切换
          Row() {
            Text(this.viewModel.isReg ? '已有账号？' : '没有账号？')
              .fontSize(CommonConstants.FONT_CAPTION)
              .fontColor(CommonConstants.COLOR_TEXT_SUB)
            Text(this.viewModel.isReg ? '返回登录' : '立即注册')
              .fontSize(CommonConstants.FONT_CAPTION)
              .fontColor(CommonConstants.COLOR_PRIMARY)
              .onClick(() => {
                this.viewModel.isReg = !this.viewModel.isReg
                this.viewModel.errorMessage = ''
              })
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
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
    }
    .hideTitleBar(true)
  }
}