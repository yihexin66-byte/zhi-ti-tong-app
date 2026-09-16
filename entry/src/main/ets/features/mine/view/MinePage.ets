/**
 * MinePage — 「我的」页面组件
 *
 * 【作用】
 *   展示用户信息卡片 + 设置功能列表 + 退出登录按钮。
 *   被 MainPage.ets 通过 import 引入，放在 TabContent 中调用。
 *
 * 【架构位置】
 *   features/mine/view/ 目录 → 无 @Entry，不是路由页面，而是可复用组件
 *   被 pages/MainPage.ets import 后调用：MinePage()
 *
 * 【关键概念】
 *   @ComponentV2 : 声明组件
 *   export struct : 导出组件，外部才能 import
 *   @Param       : 接收父组件传入的参数
 *   Blank        : 弹性空白占位，把按钮推到最底部
 *   Button       : 按钮组件
 *   Image($r())  : 加载资源图片
 */
import { CommonConstants } from '../../../common/constants/CommonConstants'

// ===== 设置条目子组件 =====
// 作用：渲染一行设置项，左边是标题，右边是箭头 >
// 注意：没有 export，只能在 MinePage.ets 内部使用
@ComponentV2
struct SettingItem {
  // @Param：父组件传入的标题文字
  @Param title: string = ''

  build() {
    // 一行：标题 + 空白 + 箭头
    Row() {
      Text(this.title)
        .fontSize(CommonConstants.FONT_BODY)            // 字号 16
        .fontColor(CommonConstants.COLOR_TEXT_MAIN)      // 主文本色 #333

      Blank()   // Blank 自动填充剩余空间，把 > 推到最右边

      Text('>')
        .fontSize(CommonConstants.FONT_BODY)
        .fontColor(CommonConstants.COLOR_TEXT_HINT)      // 箭头灰色 #999
    }
    .width('100%')
    .height(CommonConstants.BTN_HEIGHT)                  // 行高 50
    .padding({ left: CommonConstants.SPACE_M, right: CommonConstants.SPACE_M }) // 左右内边距 16
    .alignItems(VerticalAlign.Center)                    // 垂直居中
  }
}

// ===== 「我的」页面主组件（导出给外部使用）=====
// export 是必须的！没有它 MainPage 就 import 不到
@ComponentV2
export struct MinePage {
  // 三级导航：Mine 域自持子栈（预留）
    @Provider('mineStack') mineStack: NavPathStack = new NavPathStack()
    // 登出要操作根栈
    @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()

    // Mine 域内路由注册（预留）
    @Builder
    MineRouter(name: string, param: Object) {
    }

    build() {
      Navigation(this.mineStack) {
        // 整个页面用 Column 纵向排列
        Column() {
        // ===== 用户信息卡片 =====
        // Row 横向：左侧头像 + 右侧用户名/签名
        Row() {
          // 左侧：头像（圆形）
          Image($r('app.media.ic_app'))                    // 引用应用图标
            .width(60)
            .height(60)
            .borderRadius(30)                              // 圆角 30 → 圆形
            .objectFit(ImageFit.Cover)                     // 裁剪铺满

          // 右侧：用户名 + 个性签名
          Column() {
            Text('用户名')
              .fontSize(CommonConstants.FONT_SUBTITLE)     // 字号 18
              .fontColor(CommonConstants.COLOR_TEXT_MAIN)
              .fontWeight(FontWeight.Bold)                 // 加粗

            Text('个性签名')
              .fontSize(CommonConstants.FONT_CAPTION)      // 字号 14
              .fontColor(CommonConstants.COLOR_TEXT_SUB)   // 次文本色 #666
              .margin({ top: CommonConstants.SPACE_M })    // 与用户名间距 16
          }
          .alignItems(HorizontalAlign.Start)               // 左对齐
          .margin({ left: CommonConstants.SPACE_M })       // 与头像间距 16
        }
        .width('100%')
        .backgroundColor(Color.White)                      // 白底卡片
        .borderRadius(12)                                  // 圆角
        .padding(CommonConstants.SPACE_M)                  // 内边距 16
        .alignItems(VerticalAlign.Center)                  // 垂直居中

        // ===== 设置功能列表 =====
        Column() {
          // 调用 SettingItem 子组件，传入不同标题
          // 每个条目一行，点击后跳转到对应功能页（后续实现）
          SettingItem({ title: '我的收藏' })
          SettingItem({ title: '做题记录' })
          SettingItem({ title: '错题本' })
          SettingItem({ title: '关于我们' })
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .padding(CommonConstants.SPACE_M)
        .margin({ top: CommonConstants.SPACE_L })          // 与用户卡片间距 24

        // ===== 弹性空白 =====
        // Blank() 占满剩余空间，把退出按钮推到屏幕底部
        Blank()

        // ===== 退出登录按钮 =====
        Button('退出登录')
          .width('80%')
          .backgroundColor(Color.White)                     // 白底
          .fontColor(CommonConstants.COLOR_ERROR)           // 红色字 #F44336
          .fontSize(CommonConstants.FONT_BODY)
          .onClick(() => {
            // 清空根栈：栈空后显示 Navigation 的内容页，即登录页——登出闭环
            this.pageStack.clear()
          })
        }
      .width('100%')
      .height('100%')                                       // 占满全屏
      .backgroundColor(CommonConstants.COLOR_BG_PAGE)        // 页面背景 #F5F6FA
      .padding(CommonConstants.SPACE_M)                      // 整体内边距 16
    }
    .navDestination(this.MineRouter)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }
}
