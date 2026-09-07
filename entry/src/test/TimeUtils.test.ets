import { describe, it, expect } from '@ohos/hypium'
import { formatDuration } from '../main/ets/common/utils/TimeUtils'

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
}