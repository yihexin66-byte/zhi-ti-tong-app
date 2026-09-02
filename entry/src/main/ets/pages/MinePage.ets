// 「我的」页面：用户信息卡片、设置功能列表、退出登录按钮
import { CommonConstants } from '../common/constants/CommonConstants'

// 设置条目自定义组件：接收标题文本，渲染一行设置项
@ComponentV2
struct SettingItem {
  @Param title: string = ''

  build() {
    Row() {
      Text(this.title)
        .fontSize(CommonConstants.FONT_BODY)
        .fontColor(CommonConstants.COLOR_TEXT_MAIN)
      Blank()
      Text('>')
        .fontSize(CommonConstants.FONT_BODY)
        .fontColor(CommonConstants.COLOR_TEXT_HINT)
    }
    .width('100%')
    .height(CommonConstants.BTN_HEIGHT)
    .padding({ left: CommonConstants.SPACE_M, right: CommonConstants.SPACE_M })
    .alignItems(VerticalAlign.Center)
  }
}

@Entry
@ComponentV2
struct MinePage {
  build() {
    Column() {
      // ========== 用户信息卡片 ==========
      Row() {
        // 左侧头像
        Image($r('app.media.ic_app'))
          .width(60)
          .height(60)
          .borderRadius(30)
          .objectFit(ImageFit.Cover)

        // 右侧用户名与签名
        Column() {
          Text('用户名')
            .fontSize(CommonConstants.FONT_SUBTITLE)
            .fontColor(CommonConstants.COLOR_TEXT_MAIN)
            .fontWeight(FontWeight.Bold)
          Text('个性签名')
            .fontSize(CommonConstants.FONT_CAPTION)
            .fontColor(CommonConstants.COLOR_TEXT_SUB)
            .margin({ top: CommonConstants.SPACE_M })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: CommonConstants.SPACE_M })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .padding(CommonConstants.SPACE_M)
      .alignItems(VerticalAlign.Center)

      // ========== 设置功能列表 ==========
      Column() {
        SettingItem({ title: '我的收藏' })
        SettingItem({ title: '做题记录' })
        SettingItem({ title: '错题本' })
        SettingItem({ title: '关于我们' })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .padding(CommonConstants.SPACE_M)
      .margin({ top: CommonConstants.SPACE_L })

      // 弹性空白，将退出登录按钮推至底部
      Blank()

      // ========== 退出登录按钮 ==========
      Button('退出登录')
        .width('80%')
        .backgroundColor(Color.White)
        .fontColor(CommonConstants.COLOR_ERROR)
        .fontSize(CommonConstants.FONT_BODY)
        .onClick(() => {
          console.info('退出登录')
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.COLOR_BG_PAGE)
    .padding(CommonConstants.SPACE_M)
  }
}
