import { describe, it, expect } from '@ohos/hypium'
import { BackgroundMonitor } from '@zhititong/common'

// BackgroundMonitor 单测：把"什么时候计数"的规则钉死在测试里
// 三个 describe 按方法组织：start（启） / increase（计） / stop（停）
export default function backgroundMonitorTest(): void {
  describe('backgroundMonitorStartTest', () => {
    // 断言1：start 后进入监视状态
    it('should_set_monitoring_true_after_start', 0, () => {
      const monitor = new BackgroundMonitor()
      monitor.start()
      expect(monitor.monitoring).assertTrue()
    })
    // 断言2：start 清零历史计数（重新开考从 0 累计）
    it('should_clear_count_after_start', 0, () => {
      const monitor = new BackgroundMonitor()
      monitor.increase()          // 未监视前不计，此处仅为制造非零前置状态
      monitor.start()
      expect(monitor.count).assertEqual(0)
    })
  })

  describe('backgroundMonitorIncreaseTest', () => {
    // 断言3a：未 start 时 increase 不计数
    it('should_not_count_before_start', 0, () => {
      const monitor = new BackgroundMonitor()
      monitor.increase()
      expect(monitor.count).assertEqual(0)
    })
    // 断言3：监视中 increase 逐次 +1
    it('should_increase_count_step_by_step', 0, () => {
      const monitor = new BackgroundMonitor()
      monitor.start()
      monitor.increase()
      expect(monitor.count).assertEqual(1)
      monitor.increase()
      expect(monitor.count).assertEqual(2)
      monitor.increase()
      expect(monitor.count).assertEqual(3)
    })
    // 断言3b：stop 之后 increase 不计数（交卷后再切后台不再累计）
    it('should_not_count_after_stop', 0, () => {
      const monitor = new BackgroundMonitor()
      monitor.start()
      monitor.increase()
      monitor.stop()
      monitor.increase()
      expect(monitor.count).assertEqual(1)
    })
  })

  describe('backgroundMonitorStopTest', () => {
    // 断言4a：stop 后退出监视状态
    it('should_stop_monitoring_after_stop', 0, () => {
      const monitor = new BackgroundMonitor()
      monitor.start()
      monitor.stop()
      expect(monitor.monitoring).assertFalse()
    })
    // 断言4：stop 只停不清——计数保留，供结果页读取
    it('should_keep_count_after_stop', 0, () => {
      const monitor = new BackgroundMonitor()
      monitor.start()
      monitor.increase()
      monitor.increase()
      monitor.stop()
      expect(monitor.count).assertEqual(2)
    })
  })
}