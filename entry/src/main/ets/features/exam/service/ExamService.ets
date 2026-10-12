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

// ---- 请求体接口：ArkTS 不允许"无名分"的对象字面量（arkts-no-untyped-obj-literals） ----

export interface StartExamRequest {
  paperId: string
}

export interface SaveAnswerRequest {
  questionId: string
  answer: string
}

export interface SubmitRequest {
  submitType: string                // MANUAL / TIMEOUT / TAB_SWITCH
  tabSwitchCount: number
}

export class ExamService extends BaseService {
  /** 开考（或断点续考：后端对进行中的场次幂等返回） */
  startExam(paperId: string): Promise<AttemptInfo> {
    const req: StartExamRequest = { paperId: paperId }
    return this.postJson<AttemptInfo>('/api/exam/attempts', req)
  }

  /** 实时保存单题答案 */
  saveAnswer(attemptId: string, questionId: string, answer: string): Promise<void> {
    const req: SaveAnswerRequest = { questionId: questionId, answer: answer }
    return this.putJson<void>(`/api/exam/attempts/${attemptId}/answer`, req)
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
}
