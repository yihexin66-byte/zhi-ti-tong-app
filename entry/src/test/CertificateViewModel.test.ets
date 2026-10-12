import { describe, it, expect } from '@ohos/hypium'
import { MockKit, when, ArgumentMatchers } from '@ohos/hamock'
import { CommonConstants } from '@zhititong/common'
import { CertificateViewModel } from '../main/ets/features/mine/viewModel/CertificateViewModel'
import { ExamService } from '../main/ets/features/exam/service/ExamService'
import { FIXTURE_CERTIFICATES } from './Fixtures'

/** 造一个被 hamock 接管的假 ExamService */
function createMockedService(): ExamService {
  const service = new ExamService()
  const mockKit = new MockKit()
  when(mockKit.mockFunc(service, service.getCertificates))(ArgumentMatchers.any)
    .afterReturn(Promise.resolve(FIXTURE_CERTIFICATES))
  return service
}

export default function certificateViewModelTest() {
  describe('certificateViewModelTest', () => {
    // 常规：证书列表装载，编号与日期字段就位
    it('should_load_certificates', 0, async () => {
      const vm = new CertificateViewModel(createMockedService())
      await vm.loadCertificates()
      expect(vm.certificates.length).assertEqual(2)
      expect(vm.certificates[0].certificateNo).assertEqual('CERT-20261007-000001')
      expect(vm.certificates[0].issueDate).assertEqual('2026-10-07')
      expect(vm.certificates[0].expiryDate).assertEqual('2028-10-07')
    })

    // ===== 契约坑落地：英文枚举进、中文徽标出 =====
    it('should_translate_status_enum', 0, async () => {
      const vm = new CertificateViewModel(createMockedService())
      await vm.loadCertificates()
      expect(vm.getStatusText('VALID')).assertEqual('有效')
      expect(vm.getStatusText('EXPIRED')).assertEqual('已过期')
      expect(vm.getStatusColor('VALID')).assertEqual(CommonConstants.COLOR_SUCCESS)
      expect(vm.getStatusColor('EXPIRED')).assertEqual(CommonConstants.COLOR_TEXT_HINT)
    })

    // 边界：未知状态原样显示、按无效色渲染（不因新枚举值白屏）
    it('should_pass_through_unknown_status', 0, () => {
      const vm = new CertificateViewModel(createMockedService())
      expect(vm.getStatusText('REVOKED')).assertEqual('REVOKED')
      expect(vm.getStatusColor('REVOKED')).assertEqual(CommonConstants.COLOR_TEXT_HINT)
    })

    // 异常路径：加载失败时 errorMessage 落值、loading 归位
    it('should_set_error_when_load_fails', 0, async () => {
      const service = new ExamService()
      const mockKit = new MockKit()
      when(mockKit.mockFunc(service, service.getCertificates))(ArgumentMatchers.any)
        .afterAction(() => Promise.reject(new Error('未登录，请先登录')))
      const vm = new CertificateViewModel(service)
      await vm.loadCertificates()
      expect(vm.errorMessage).assertEqual('未登录，请先登录')
      expect(vm.loading).assertEqual(false)
    })
  })
}
