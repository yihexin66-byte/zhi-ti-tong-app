/**
 * 轻量日志封装：业务代码不直接依赖 hilog 细节
 */
import { hilog } from '@kit.PerformanceAnalysisKit'

export class Logger {
  private static readonly DOMAIN: number = 0x0000
  private tag: string

  constructor(tag: string) {
    this.tag = tag
  }

  info(msg: string): void {
    hilog.info(Logger.DOMAIN, this.tag, '%{public}s', msg)
  }

  warn(msg: string): void {
    hilog.warn(Logger.DOMAIN, this.tag, '%{public}s', msg)
  }

  error(msg: string): void {
    hilog.error(Logger.DOMAIN, this.tag, '%{public}s', msg)
  }
}