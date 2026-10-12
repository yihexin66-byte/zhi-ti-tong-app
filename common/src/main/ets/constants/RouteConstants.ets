// 路由常量统一收敛，避免到处写魔法字符串
// 命名规范：应用级路由加 app. 前缀；域内路由直接用功能名
export class RouteConstants {
  // 应用级路由（根栈 RootDomain）
  static readonly LOGIN: string = 'app.Login'
  static readonly MAIN: string = 'app.Main'

  // 沉浸式详情页：统一注册到根栈（push 后盖住底部 Tab）
  static readonly EXAM_DETAIL: string = 'ExamDetail'
  static readonly ANSWER_RESULT: string = 'AnswerResult'
  // 逐题回顾：从结果页（根栈）push，仍走根栈
  static readonly REVIEW: string = 'Review'

  // Exam 域内路由（examStack，push 后保留底部 Tab）
  static readonly EXAM_LIST: string = 'ExamList'

  // Mine 域内路由（mineStack，push 后保留底部 Tab）
  static readonly ATTEMPT_RECORD: string = 'AttemptRecord'
  static readonly CERTIFICATE: string = 'Certificate'
}
