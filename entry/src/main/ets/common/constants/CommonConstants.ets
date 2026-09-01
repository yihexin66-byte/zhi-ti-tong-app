// 通用常量类：集中管理颜色、字号、间距，避免魔法数散落各页面（DRY 伏笔）
export class CommonConstants {
  // 颜色
  static readonly COLOR_PRIMARY: string = '#007AFF'      // 主色（按钮、强调）
  static readonly COLOR_TEXT_MAIN: string = '#333333'    // 主文本
  static readonly COLOR_TEXT_SUB: string = '#666666'     // 次文本
  static readonly COLOR_TEXT_HINT: string = '#999999'    // 提示文本
  static readonly COLOR_BG_PAGE: string = '#F5F6FA'      // 页面背景
  static readonly COLOR_SUCCESS: string = '#4CAF50'      // 成功/正确
  static readonly COLOR_ERROR: string = '#F44336'        // 失败/错误
  static readonly COLOR_WARN: string = '#FF6600'         // 强调/倒计时
  // 渐变（提交按钮）
  static readonly GRADIENT_START: string = '#70b8f8'
  static readonly GRADIENT_END: string = '#416ff5'
  // 字号
  static readonly FONT_TITLE: number = 24
  static readonly FONT_SUBTITLE: number = 18
  static readonly FONT_BODY: number = 16
  static readonly FONT_CAPTION: number = 14
  // 尺寸
  static readonly BTN_HEIGHT: number = 50
  static readonly SPACE_M: number = 16
  static readonly SPACE_L: number = 24
}