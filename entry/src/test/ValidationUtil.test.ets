import { describe, it, expect } from '@ohos/hypium'
import { ValidationUtil } from '../main/ets/common/utils/ValidationUtil'

export default function validationUtilTest() {
  describe('validateUsernameTest', () => {
    // 常规：合法用户名
    it('should_accept_valid_username', 0, () => {
      expect(ValidationUtil.validateUsername('admin').isValid).assertEqual(true)
    })
    // 边界：空字符串
    it('should_reject_empty_username', 0, () => {
      const r = ValidationUtil.validateUsername('')
      expect(r.isValid).assertEqual(false)
      expect(r.message).assertEqual('用户名不能为空')
    })
    // 边界：2 字符拒绝、恰好 3 字符通过——临界值两侧都要踩
    it('should_reject_2_chars_and_accept_3_chars', 0, () => {
      expect(ValidationUtil.validateUsername('ab').isValid).assertEqual(false)
      expect(ValidationUtil.validateUsername('abc').isValid).assertEqual(true)
    })
    // 边界：恰好 16 字符通过、17 字符拒绝
    it('should_accept_16_chars_and_reject_17_chars', 0, () => {
      expect(ValidationUtil.validateUsername('a234567890123456').isValid).assertEqual(true)
      expect(ValidationUtil.validateUsername('a2345678901234567').isValid).assertEqual(false)
    })
    // 常规：非法字符
    it('should_reject_illegal_chars', 0, () => {
      expect(ValidationUtil.validateUsername('ab-c').isValid).assertEqual(false)
    })
  })

  describe('validatePasswordTest', () => {
    it('should_accept_valid_password', 0, () => {
      expect(ValidationUtil.validatePassword('123456').isValid).assertEqual(true)
    })
    it('should_reject_short_password', 0, () => {
      expect(ValidationUtil.validatePassword('12345').isValid).assertEqual(false)
    })
    it('should_reject_empty_password', 0, () => {
      expect(ValidationUtil.validatePassword('').isValid).assertEqual(false)
    })
  })

  describe('validateConfirmPasswordTest', () => {
    it('should_accept_same_password', 0, () => {
      expect(ValidationUtil.validateConfirmPassword('123456', '123456').isValid).assertEqual(true)
    })
    it('should_reject_different_password', 0, () => {
      const r = ValidationUtil.validateConfirmPassword('123456', '654321')
      expect(r.isValid).assertEqual(false)
      expect(r.message).assertEqual('两次输入的密码不一致')
    })
  })
}