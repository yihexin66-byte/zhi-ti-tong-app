/**
 * AnswerCell — 答题卡格子子组件（View 层）
 *
 * 【作用】
 *   展示一个题号格子；背景色含义（未答灰 / 答对绿 / 答错红）由 ResultViewModel
 *   派生后经 @Param 传入，本组件纯展示。
 *
 * 【架构位置】
 *   features/exam/view/ 目录 → 可复用子组件独立成文件（文件名与类名一致）。
 */
import { CommonConstants } from '@zhititong/common'

@ComponentV2
export struct AnswerCell {
  // 题序号（0 起，展示 +1）
  @Param index: number = 0
  // 格子背景色（展示规则由 ViewModel 计算，View 只取值渲染）
  @Param color: string = CommonConstants.COLOR_TEXT_HINT

  build() {
    Text(`${this.index + 1}`)
      .fontSize(CommonConstants.FONT_BODY)
      .fontWeight(FontWeight.Medium)
      .fontColor(Color.White)
      .textAlign(TextAlign.Center)
      .width(40)
      .height(40)
      .borderRadius(8)
      .backgroundColor(this.color)
  }
}
