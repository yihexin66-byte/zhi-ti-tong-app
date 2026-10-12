/**
 * 测试夹具（fixture）集中声明：一套受控的"世界观"，所有用例共享。
 *
 * 约定：
 *   - 试卷统一用"HarmonyOS 应用开发·3 题小卷"系列命名；
 *   - id 一律用字符串（雪花 ID 在 App 内始终是字符串，避免精度问题）；
 *   - 夹具不复用 common/mock，与生产数据解耦——测试断言的是我们自己的逻辑。
 */
import { PaperInfo, SessionUserData, QuestionItem } from '@zhititong/common'
import { LoginResult } from '../main/ets/features/login/service/LoginService'
import { AttemptInfo, SubmitResult, ReviewDetail, ReviewQuestionDetail } from '../main/ets/features/exam/service/ExamService'

/** 夹具试卷共 8 套：HarmonyOS 6 套 + Java 程序设计 2 套 */
export const FIXTURE_PAPERS: PaperInfo[] = [
  { id: '1001', paperName: 'HarmonyOS 应用开发·3 题小卷（一）', categoryName: 'HarmonyOS', levelName: '基础', totalScore: 30, passScore: 18, duration: 10, questionCount: 3, maxAttempts: 0, attemptCount: 0, bestScore: 0 },
  { id: '1002', paperName: 'HarmonyOS 应用开发·3 题小卷（二）', categoryName: 'HarmonyOS', levelName: '基础', totalScore: 30, passScore: 18, duration: 10, questionCount: 3, maxAttempts: 0, attemptCount: 1, bestScore: 30 },
  { id: '1003', paperName: 'HarmonyOS 应用开发·3 题小卷（三）', categoryName: 'HarmonyOS', levelName: '基础', totalScore: 30, passScore: 18, duration: 10, questionCount: 3, maxAttempts: 3, attemptCount: 2, bestScore: 24 },
  { id: '1004', paperName: 'HarmonyOS 应用开发·3 题小卷（四）', categoryName: 'HarmonyOS', levelName: '高级', totalScore: 30, passScore: 24, duration: 12, questionCount: 3, maxAttempts: 0, attemptCount: 0, bestScore: 0 },
  { id: '1005', paperName: 'HarmonyOS 应用开发·3 题小卷（五）', categoryName: 'HarmonyOS', levelName: '高级', totalScore: 30, passScore: 24, duration: 12, questionCount: 3, maxAttempts: 1, attemptCount: 1, bestScore: 27 },
  { id: '1006', paperName: 'HarmonyOS 应用开发·3 题小卷（六）', categoryName: 'HarmonyOS', levelName: '高级', totalScore: 30, passScore: 24, duration: 12, questionCount: 3, maxAttempts: 0, attemptCount: 0, bestScore: 0 },
  { id: '1007', paperName: 'Java 程序设计·3 题小卷（一）', categoryName: 'Java 程序设计', levelName: '期末', totalScore: 30, passScore: 18, duration: 10, questionCount: 3, maxAttempts: 0, attemptCount: 0, bestScore: 0 },
  { id: '1008', paperName: 'Java 程序设计·3 题小卷（二）', categoryName: 'Java 程序设计', levelName: '期末', totalScore: 30, passScore: 18, duration: 10, questionCount: 3, maxAttempts: 2, attemptCount: 1, bestScore: 21 }
]

/** 夹具用户信息（登录成功返回的 userInfo 形状） */
export const FIXTURE_USER: SessionUserData = {
  id: '9001',
  username: 'student',
  role: '考生'
}

/** 夹具登录结果（成功）：token + 用户信息 */
export const FIXTURE_LOGIN_OK: LoginResult = {
  token: 'fixture-token',
  userInfo: FIXTURE_USER
}

/** 夹具登录结果（管理员） */
export const FIXTURE_LOGIN_ADMIN: LoginResult = {
  token: 'fixture-token-admin',
  userInfo: { id: '9002', username: 'admin', role: '管理员' }
}

/** 夹具注册成功返回的用户信息 */
export const FIXTURE_REGISTER_OK: SessionUserData = {
  id: '9003',
  username: 'xyr001',
  role: '考生'
}

/** 夹具错误文案：与后端 message 同源（BaseService 原样抛出） */
export const FIXTURE_ERROR_WRONG_PASSWORD: string = '账号或密码错误'
export const FIXTURE_ERROR_USER_EXISTS: string = '账号已存在'

// ==================== 考试链路夹具 ====================

/** 夹具场次的三道题：判断 / 单选 / 多选（"3 题小卷"） */
export const FIXTURE_QUESTIONS: QuestionItem[] = [
  {
    id: '2001', type: 'JUDGE', score: 10,
    content: 'ArkTS 是基于 TypeScript 扩展而来的开发语言。',
    options: [{ label: 'A', content: '正确' }, { label: 'B', content: '错误' }]
  },
  {
    id: '2002', type: 'SINGLE', score: 10,
    content: '下列哪个组件用于显示文本内容？',
    options: [
      { label: 'A', content: 'Image' }, { label: 'B', content: 'Text' },
      { label: 'C', content: 'Button' }, { label: 'D', content: 'Progress' }
    ]
  },
  {
    id: '2003', type: 'MULTI', score: 10,
    content: '下列属于 ArkUI 线性布局容器的有哪些？',
    options: [
      { label: 'A', content: 'Column' }, { label: 'B', content: 'Row' },
      { label: 'C', content: 'Stack' }, { label: 'D', content: 'Flex' }
    ]
  }
]

/** 全新开考：无 myAnswer 回填、剩余 600 秒 */
export const FIXTURE_ATTEMPT: AttemptInfo = {
  attemptId: '5001',
  paperName: 'HarmonyOS 应用开发·3 题小卷',
  totalScore: 30,
  passScore: 18,
  duration: 10,
  remainingSeconds: 600,
  questions: FIXTURE_QUESTIONS
}

/** 断点续考：后端幂等还场，已答题目随 myAnswer 回传，剩余时间缩水 */
export const FIXTURE_ATTEMPT_RESUMED: AttemptInfo = {
  attemptId: '5001',
  paperName: 'HarmonyOS 应用开发·3 题小卷',
  totalScore: 30,
  passScore: 18,
  duration: 10,
  remainingSeconds: 337,
  questions: [
    {
      id: '2001', type: 'JUDGE', score: 10,
      content: 'ArkTS 是基于 TypeScript 扩展而来的开发语言。',
      options: [{ label: 'A', content: '正确' }, { label: 'B', content: '错误' }],
      myAnswer: 'A'
    },
    {
      id: '2002', type: 'SINGLE', score: 10,
      content: '下列哪个组件用于显示文本内容？',
      options: [
        { label: 'A', content: 'Image' }, { label: 'B', content: 'Text' },
        { label: 'C', content: 'Button' }, { label: 'D', content: 'Progress' }
      ]
    },
    {
      id: '2003', type: 'MULTI', score: 10,
      content: '下列属于 ArkUI 线性布局容器的有哪些？',
      options: [
        { label: 'A', content: 'Column' }, { label: 'B', content: 'Row' },
        { label: 'C', content: 'Stack' }, { label: 'D', content: 'Flex' }
      ],
      myAnswer: 'AD'
    }
  ]
}

/** 交卷判分结果：得分 20 / 及格线 18 → 通过 */
export const FIXTURE_SUBMIT_RESULT: SubmitResult = {
  attemptId: '5001',
  score: 20,
  totalScore: 30,
  passScore: 18,
  correctCount: 2,
  totalQuestions: 3,
  passed: true,
  usedTime: 123,
  submitType: 'MANUAL',
  paperId: '1001',
  certificateGenerated: true
}

/** 逐题回顾：一错两对；第 3 题用户答 AD、正确答案 ABD（多选部分对不得分） */
export const FIXTURE_REVIEW: ReviewDetail = {
  attemptId: '5001',
  paperName: 'HarmonyOS 应用开发·3 题小卷',
  score: 20,
  totalScore: 30,
  isPassed: 1,
  questions: [
    {
      questionId: '2001', type: 'JUDGE',
      content: 'ArkTS 是基于 TypeScript 扩展而来的开发语言。',
      correctAnswer: 'A', userAnswer: 'A', isCorrect: true, earnedScore: 10, maxScore: 10,
      analysis: 'ArkTS 在 TypeScript 基础上增加了静态类型约束与 ArkUI 装饰器。',
      options: [{ label: 'A', content: '正确' }, { label: 'B', content: '错误' }]
    },
    {
      questionId: '2002', type: 'SINGLE',
      content: '下列哪个组件用于显示文本内容？',
      correctAnswer: 'B', userAnswer: 'C', isCorrect: false, earnedScore: 0, maxScore: 10,
      analysis: '',
      options: [
        { label: 'A', content: 'Image' }, { label: 'B', content: 'Text' },
        { label: 'C', content: 'Button' }, { label: 'D', content: 'Progress' }
      ]
    },
    {
      questionId: '2003', type: 'MULTI',
      content: '下列属于 ArkUI 线性布局容器的有哪些？',
      correctAnswer: 'ABD', userAnswer: 'AD', isCorrect: false, earnedScore: 0, maxScore: 10,
      analysis: '',
      options: [
        { label: 'A', content: 'Column' }, { label: 'B', content: 'Row' },
        { label: 'C', content: 'Stack' }, { label: 'D', content: 'Flex' }
      ]
    }
  ]
}

/** 走查用的单题夹具（回顾页着色断言） */
export const FIXTURE_REVIEW_MULTI: ReviewQuestionDetail = FIXTURE_REVIEW.questions[2]
