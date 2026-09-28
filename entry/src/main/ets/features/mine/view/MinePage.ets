/**
 * MinePage — 「我的」页面组件（View 层）
 *
 * 【作用】
 *   展示用户信息卡片 + 设置功能列表 + 退出登录按钮。
 *   被 MainPage.ets 通过 import 引入，放在 TabContent 中调用。
 *
 * 【分层职责（View 层）】
 *   零业务判断：用户昵称与签名来自 MineViewModel，四个设置项为纯静态展示；
 *   导航留在本层：退出登录操作根栈 pageStack.clear() 回登录页。
 *
 * 【域根结构（必须原样保留）】
 *   Navigation(mineStack) 自持子栈 + MineRouter 域内路由注册（预留）。
 */
import { CommonConstants } from '@zhititong/common'
import { FontSetting, FONT_LEVELS, FontLevel, StateKeys } from '@zhititong/common'
import { PersistenceV2 } from '@kit.ArkUI'
import { MineViewModel } from '../viewModel/MineViewModel'

// ===== 设置条目子组件 =====
// 作用：渲染一行设置项，左边是标题，右边是箭头 >
// 注意：没有 export，只能在 MinePage.ets 内部使用；纯静态展示，不建模
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

  // 页面动态状态都在 ViewModel 上（@Local 持有实例）
  @Local viewModel: MineViewModel = new MineViewModel()

  // 全局字号设置：connect 同一 key，拿到的是应用级单例（@Trace 变化即刷新本页）
  @Local font: FontSetting = PersistenceV2.connect(FontSetting, StateKeys.FONT_SETTING, () => new FontSetting())!

  // 五档下拉选项：由 FONT_LEVELS 单一数据源派生（value 取档位文案）
  private fontOptions: SelectOption[] = FONT_LEVELS.map((level: FontLevel): SelectOption => {
    const option: SelectOption = { value: level.label }
    return option
  })

  /**
   * 当前字号偏移量对应的档位下标（反查失败回退"标准"档）
   */
  private getLevelIndex(): number {
    const index: number = FONT_LEVELS.findIndex((level: FontLevel) => level.size === this.font.fontSize)
    if (index >= 0) {
      return index
    }
    // 找不到匹配：回退到 size 为 0 的"标准"档
    const standard: number = FONT_LEVELS.findIndex((level: FontLevel) => level.size === 0)
    return standard >= 0 ? standard : 0
  }

  /**
   * 当前档位文案（Select 收起态显示）
   */
  private getLevelLabel(): string {
    return FONT_LEVELS[this.getLevelIndex()].label
  }

  // Mine 域内路由注册（预留）
  @Builder
  MineRouter(name: string, param: Object) {
  }

  // 进入页面时触发用户信息加载（View 只负责触发，业务在 ViewModel 内完成）
  aboutToAppear(): void {
    this.viewModel.loadUserInfo()
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

          // 右侧：用户名 + 个性签名（数据来自 ViewModel）
          Column() {
            Text(this.viewModel.user.nickname)
              .fontSize(CommonConstants.FONT_SUBTITLE + this.font.fontSize)  // 基准 18 + 全局偏移
              .fontColor(CommonConstants.COLOR_TEXT_MAIN)
              .fontWeight(FontWeight.Bold)                 // 加粗

            Text(this.viewModel.user.signature)
              .fontSize(CommonConstants.FONT_CAPTION + this.font.fontSize)   // 基准 14 + 全局偏移
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
          // 「字号大小」：五档下拉，选择后写入全局状态（用户名/签名即时缩放）
          // 本行字号固定：设置行自身不参与缩放
          Row() {
            Text('字号大小')
              .fontSize(CommonConstants.FONT_BODY)
              .fontColor(CommonConstants.COLOR_TEXT_MAIN)

            Blank()

            Select(this.fontOptions)
              .selected(this.getLevelIndex())
              .value(this.getLevelLabel())
              .font({ size: CommonConstants.FONT_BODY })
              .onSelect((index: number) => {
                // 档位 → 偏移量：FONT_LEVELS 是唯一数据源
                this.font.fontSize = FONT_LEVELS[index].size
              })
          }
          .width('100%')
          .height(CommonConstants.BTN_HEIGHT)                  // 行高与相邻设置行一致
          .padding({ left: CommonConstants.SPACE_M, right: CommonConstants.SPACE_M })
          .alignItems(VerticalAlign.Center)

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
            // 导航留在 View 层：清空根栈，栈空后显示 Navigation 的内容页，即登录页——登出闭环
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
