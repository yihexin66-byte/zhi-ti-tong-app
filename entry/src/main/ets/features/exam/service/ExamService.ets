import { BaseService, OptionItem, QuestionItem } from '@zhititong/common'

/** 开考响应（契约 3.2）：场次信息 + 整卷题目 */
export interface AttemptInfo {
  attemptId: string
  paperName: string
  totalScore: number
  passScore: number
  duration: number
  remainingSeconds: number          // 时间权威在服务端
  questions: QuestionItem[]         // 作答面题目：含 myAnswer 回填、无 correctAnswer
}

/** 交卷 / 结果响应（契约 3.4）：判分结果（字段以实测响应为准） */
export interface SubmitResult {
  attemptId: string
  score: number
  totalScore: number
  passScore: number
  correctCount: number
  totalQuestions: number
  passed: boolean
  usedTime: number
  submitType: string
  paperId: string
  certificateGenerated: boolean
}

/** 逐题回顾·单题（契约 3.8）：判分面——correctAnswer 在交卷后才可见 */
export interface ReviewQuestionDetail {
  questionId: string
  type: string
  content: string
  correctAnswer: string
  userAnswer: string | null         // 未作答为 null
  isCorrect: boolean
  earnedScore: number
  maxScore: number
  analysis: string                  // 契约坑：空串表示暂无解析，不是 null
  options: OptionItem[]
}

/** 逐题回顾·全量（契约 3.8） */
export interface ReviewDetail {
  attemptId: string
  paperName: string
  score: number
  totalScore: number
  isPassed: number                  // 契约坑：数字 1/0，不是布尔
  questions: ReviewQuestionDetail[]
}

/** 考试记录·单条（契约 3.6） */
export interface AttemptRecord {
  id: string
  startTime: string
  score: number
  passed: boolean
  usedTime: number
  submitType: string
  paperId: string
  paperName: string
}

/** 考试记录·分页壳（契约 3.6） */
export interface AttemptPage {
  records: AttemptRecord[]
  total: number
  page: number
  size: number
}

/** 我的证书·单张（契约 §四）：状态为英文枚举 VALID / EXPIRED */
export interface CertificateItem {
  id: string
  certificateNo: string
  name: string
  issueDate: string
  expiryDate: string
  status: string
}

// ---- 请求体接口：ArkTS 不允许"无名分"的对象字面量（arkts-no-untyped-obj-literals） ----

export interface StartExamRequest {
  paperId: string
}

export interface SaveAnswerRequest {
  questionId: string
  answer: string
  isFlagged: boolean
}

export interface SubmitRequest {
  submitType: string                // MANUAL / TIMEOUT / TAB_SWITCH
  tabSwitchCount: number
}

/**
 * 切屏上报请求（实测定稿）：字段名为 tabSwitchCount，客户端上报"本场累计次数"。
 * 【契约坑】教材稿写作 count，实测后端只认 tabSwitchCount——读契约要逐字，动手前先实测。
 */
export interface TabSwitchRequest {
  tabSwitchCount: number
}

/**
 * 切屏上报响应：服务端裁决结果
 * 【契约坑】教材稿写作 maxTabSwitch，实测字段为 tabSwitchLimit。
 */
export interface TabSwitchResult {
  tabSwitchCount: number            // 服务端记账的累计次数
  tabSwitchLimit: number            // 本卷允许的上限
  shouldAutoSubmit: boolean         // 裁决：是否立即强制交卷
}

export class ExamService extends BaseService {
  /** 开考（或断点续考：后端对进行中的场次幂等返回） */
  startExam(paperId: string): Promise<AttemptInfo> {
    const req: StartExamRequest = { paperId: paperId }
    return this.postJson<AttemptInfo>('/api/exam/attempts', req)
  }

  /** 实时保存单题答案（isFlagged 随答案一起透传：存疑标记跨进程保持） */
  saveAnswer(attemptId: string, questionId: string, answer: string, isFlagged: boolean): Promise<void> {
    const req: SaveAnswerRequest = {
      questionId: questionId,
      answer: answer,
      isFlagged: isFlagged
    }
    return this.putJson<void>(`/api/exam/attempts/${attemptId}/answer`, req)
  }

  /** 切屏上报：客户端如实上报，服务端独揽裁决 */
  reportTabSwitch(attemptId: string, tabSwitchCount: number): Promise<TabSwitchResult> {
    const req: TabSwitchRequest = { tabSwitchCount: tabSwitchCount }
    return this.putJson<TabSwitchResult>(`/api/exam/attempts/${attemptId}/tab-switch`, req)
  }

  /** 交卷判分 */
  submit(attemptId: string, submitType: string, tabSwitchCount: number): Promise<SubmitResult> {
    const req: SubmitRequest = { submitType: submitType, tabSwitchCount: tabSwitchCount }
    return this.postJson<SubmitResult>(`/api/exam/attempts/${attemptId}/submit`, req)
  }

  /** 按场次号取判分结果（结果页的两个数据源之一） */
  getAttemptResult(attemptId: string): Promise<SubmitResult> {
    return this.getJson<SubmitResult>(`/api/exam/attempts/${attemptId}/result`)
  }

  /** 按场次号取逐题回顾（结果页答题卡与回顾页共用；未交卷时后端返回 400） */
  getFullReview(attemptId: string): Promise<ReviewDetail> {
    return this.getJson<ReviewDetail>(`/api/exam/attempts/${attemptId}/review`)
  }

  /** 考试记录（分页） */
  getAttempts(page: number, size: number): Promise<AttemptPage> {
    return this.getJson<AttemptPage>('/api/exam/attempts',
      { 'page': `${page}`, 'size': `${size}` })
  }

  /** 我的证书列表（后端直接返回数组） */
  getCertificates(): Promise<CertificateItem[]> {
    return this.getJson<CertificateItem[]>('/api/exam/certificates')
  }
}
