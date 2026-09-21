/**
 * ViewModel 基类：统一的 loading / error 状态管理
 */
import { Logger } from '../log/Logger'

@ObservedV2
export abstract class BaseViewModel {
  // 页面加载态
  @Trace loading: boolean = false

  // 页面可展示的错误信息（怎么渲染由 View 决定）
  @Trace errorMessage: string = ''

  // 子类可覆盖 tag
  protected logger: Logger = new Logger('[ViewModel]')

  protected setLoading(v: boolean): void {
    this.loading = v
  }

  protected setError(msg: string): void {
    this.errorMessage = msg
  }

  protected clearError(): void {
    this.errorMessage = ''
  }
}