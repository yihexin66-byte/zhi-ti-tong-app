/**
 * 切后台监视器（防作弊）：
 *   - monitoring 为 true 时（考试进行中），每次应用切到后台 count + 1
 *   - 运行期状态：用 AppStorageV2 全局共享，不做持久化——
 *     每场考试独立计数，应用重启即清零（与 5-3 的 PersistenceV2 对比）
 */
@ObservedV2
export class BackgroundMonitor {
  @Trace count: number = 0
  @Trace monitoring: boolean = false

  /** 开考调用：进入监视并清零计数 */
  start(): void {
    this.count = 0
    this.monitoring = true
  }

  /** 交卷/离场调用：停止监视（计数保留，供结果页读取） */
  stop(): void {
    this.monitoring = false
  }

  /** 仅在监视中累计（由 EntryAbility.onBackground 调用） */
  increase(): void {
    if (this.monitoring) {
      this.count++
    }
  }
}