// 秒数换算为"X 分 X 秒"文本（纯函数，便于单元测试）
// 约定：只处理非负整数秒；秒数不足 1 分钟时分钟位为 0
export function formatDuration(seconds: number): string {
  const total: number = Math.max(0, Math.floor(seconds))
  const minutes: number = Math.floor(total / 60)
  const secs: number = total % 60
  return `${minutes} 分 ${secs} 秒`
}

// 秒数换算为倒计时 mm:ss 文本（纯函数，便于单元测试）
// 约定：只处理非负整数秒；不足两位数补零（如 3599 → "59:59"，0 → "00:00"）
export function formatCountdown(seconds: number): string {
  const total: number = Math.max(0, Math.floor(seconds))
  const minutes: number = Math.floor(total / 60)
  const secs: number = total % 60
  const mm: string = minutes < 10 ? `0${minutes}` : `${minutes}`
  const ss: string = secs < 10 ? `0${secs}` : `${secs}`
  return `${mm}:${ss}`
}
