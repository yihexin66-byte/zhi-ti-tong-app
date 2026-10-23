// 登录/注册页（View 层）：零业务逻辑，全部委托 LoginViewModel
import { CommonConstants } from '@zhititong/common'
import { RouteConstants } from '@zhititong/common'
import { SessionManager, SessionUser } from '@zhititong/common'
import { Result } from '@zhititong/common'
import { LoginResponseModel } from '../model/LoginResponseModel'
import { LoginViewModel } from '../viewModel/LoginViewModel'

@ComponentV2
export struct LoginPage {
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()

  // 持有 ViewModel 实例：页面所有状态都在它身上
  @Local viewModel: LoginViewModel = new LoginViewModel()

  // 连上全局会话：恢复会话（冷启动）与登录成功（手动）都会点亮 session.loggedIn 这盏灯
  @Local session: SessionUser = SessionManager.getUser()

  // 冷启动：loadFromDisk 先于页面构建时灯早已亮，aboutToAppear 补查一次
  aboutToAppear(): void {
    this.tryEnterMain()
  }

  // 手动登录成功：灯在页面存续期间亮起，@Monitor 应声而动
  @Monitor('session.loggedIn')
  onLoggedIn(): void {
    this.tryEnterMain()
  }

  /**
   * 进入主页的唯一出口：三个入口共用，靠"栈顶已是主页"这道闸门保证幂等
   *   - aboutToAppear：冷启动 loadFromDisk 先于页面构建时点亮（灯比页面早）
   *   - @Monitor     ：登录成功让灯在页面存续期间亮起（灯比页面晚）
   *   - submit 返回后：灯本来就亮着（从主页按返回键退回登录页再登录），
   *                    @Monitor 见不到 false→true 的跳变，只能由这条兜底
   * @Monitor 只对"变化"敏感，对"已经是 true"无感——这就是回退后登录进不去主页的根因。
   */
  private tryEnterMain(): void {
    if (!this.session.loggedIn) {
      return
    }
    const names: string[] = this.pageStack.getAllPathName()
    const top: string = names.length > 0 ? names[names.length - 1] : ''
    if (top === RouteConstants.MAIN) {
      return
    }
    this.pageStack.replacePathByName(RouteConstants.MAIN, null)
  }

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
              // View 不做业务判断，只转发事件、消费结果。
              // 正常路径：submit 内部 SessionManager.save() 点亮 session.loggedIn，
              //          @Monitor 应声跳转；这里这一句是给"灯本来就亮着"的场景兜底。
              // tryEnterMain 幂等，不会和 @Monitor 抢着压两遍主页。
              const result: Result<LoginResponseModel> = await this.viewModel.submit()
              if (result.ok) {
                this.tryEnterMain()
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