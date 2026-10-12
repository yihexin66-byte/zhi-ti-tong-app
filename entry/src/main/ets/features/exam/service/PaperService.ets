import { BaseService, PaperInfo } from '@zhititong/common'

export class PaperService extends BaseService {
  /** 可考试卷列表：契约已按 App 模型命名，直取直用 */
  getPapers(): Promise<PaperInfo[]> {
    return this.getJson<PaperInfo[]>('/api/exam/papers')
  }
}
