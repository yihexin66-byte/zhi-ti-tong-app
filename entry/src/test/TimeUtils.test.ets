import { describe, it, expect } from '@ohos/hypium'
import { formatDuration, formatCountdown } from '@zhititong/common'

export default function timeUtilsTest() {
  describe('formatDurationTest', () => {
    // 断言1：常规值——754 秒 = 12 分 34 秒
    it('should_format_754_as_12min34s', 0, () => {
      expect(formatDuration(754)).assertEqual('12 分 34 秒')
    })
    // 断言2：整分钟——60 秒 = 1 分 0 秒（秒位不省略）
    it('should_format_60_as_1min0s', 0, () => {
      expect(formatDuration(60)).assertEqual('1 分 0 秒')
    })
    // 断言3：不足一分钟——59 秒 = 0 分 59 秒（分位不省略）
    it('should_format_59_as_0min59s', 0, () => {
      expect(formatDuration(59)).assertEqual('0 分 59 秒')
    })
    // 断言4（边界）：0 秒 = 0 分 0 秒
    it('should_format_0_as_0min0s', 0, () => {
      expect(formatDuration(0)).assertEqual('0 分 0 秒')
    })
  })

  describe('formatCountdownTest', () => {
    // 断言1：常见倒计时——3599 秒 = 59:59
    it('should_format_3599_as_59_59', 0, () => {
      expect(formatCountdown(3599)).assertEqual('59:59')
    })
    // 断言2：中部值——3539 秒 = 58:59
    it('should_format_3539_as_58_59', 0, () => {
      expect(formatCountdown(3539)).assertEqual('58:59')
    })
    // 断言3：补零——65 秒 = 01:05
    it('should_pad_single_digits', 0, () => {
      expect(formatCountdown(65)).assertEqual('01:05')
    })
    // 断言4（边界）：归零 = 00:00
    it('should_format_0_as_00_00', 0, () => {
      expect(formatCountdown(0)).assertEqual('00:00')
    })
    // 断言5（边界）：负数按 0 处理，不出现负号
    it('should_clamp_negative_to_zero', 0, () => {
      expect(formatCountdown(-5)).assertEqual('00:00')
    })
  })
}