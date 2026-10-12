// 考试域展示换算（纯函数，便于单元测试）
// 约定：只做"枚举 → 中文文案"的映射；未知取值返回空串，由调用方决定兜底

// 题型中文名：JUDGE 判断题 / SINGLE 单选题 / MULTI 多选题
export function questionTypeLabel(type: string): string {
  if (type === 'JUDGE') {
    return '判断题'
  }
  if (type === 'SINGLE') {
    return '单选题'
  }
  if (type === 'MULTI') {
    return '多选题'
  }
  return ''
}

// 交卷方式中文名（三态口径）：MANUAL 手动 / TIMEOUT 超时自动 / TAB_SWITCH 切屏超限自动
export function submitTypeLabel(submitType: string): string {
  if (submitType === 'MANUAL') {
    return '手动交卷'
  }
  if (submitType === 'TIMEOUT') {
    return '超时自动交卷'
  }
  if (submitType === 'TAB_SWITCH') {
    return '切屏超限自动交卷'
  }
  return ''
}
