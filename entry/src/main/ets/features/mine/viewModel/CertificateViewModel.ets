/**
 * CertificateViewModel — 我的证书页 ViewModel（viewModel 层）
 *
 * 【分层约束】
 *   1. @ObservedV2 class，继承 common/base/BaseViewModel
 *   2. 状态一律 @Trace，变更自动驱动 View 刷新
 *   3. 本文件零 UI 组件、零 @Builder、零导航栈操作（导航留在 View 层）
 *
 * 【契约坑落地】后端状态是英文枚举 VALID / EXPIRED，页面要中文徽标——翻译在 App 侧完成。
 *
 * 【数据来源】真实后端（ExamService.getCertificates）；构造器注入便于单测塞假 Service。
 */
import { BaseViewModel, CommonConstants, Logger } from '@zhititong/common'
import { CertificateItem, ExamService } from '../../exam/service/ExamService'

@ObservedV2
export class CertificateViewModel extends BaseViewModel {
  // 证书列表
  @Trace certificates: CertificateItem[] = []

  private examService: ExamService

  constructor(service: ExamService = new ExamService()) {
    super()
    this.logger = new Logger('[CertificateViewModel]')
    this.examService = service
  }

  /**
   * 加载我的证书
   */
  async loadCertificates(): Promise<void> {
    this.clearError()
    this.setLoading(true)
    try {
      this.certificates = await this.examService.getCertificates()
      this.logger.info(`证书加载成功：共 ${this.certificates.length} 张`)
    } catch (e) {
      const errorMsg = (e as Error).message || '证书加载失败，请稍后重试'
      this.setError(errorMsg)
      this.logger.error(`证书加载失败：${errorMsg}`)
    } finally {
      this.setLoading(false)
    }
  }

  /**
   * 状态徽标文案：英文枚举进、中文徽标出（未知状态原样显示）
   */
  getStatusText(status: string): string {
    if (status === 'VALID') {
      return '有效'
    }
    if (status === 'EXPIRED') {
      return '已过期'
    }
    return status
  }

  /**
   * 状态徽标颜色：有效绿 / 已过期灰
   */
  getStatusColor(status: string): string {
    return status === 'VALID' ? CommonConstants.COLOR_SUCCESS : CommonConstants.COLOR_TEXT_HINT
  }
}
