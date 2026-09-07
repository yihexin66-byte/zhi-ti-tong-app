// 选项：与后端契约一致，label 为 A/B/C/D，content 为选项文字
export interface OptionItem {
  label: string
  content: string
}

// 题目：id 用 string 模拟雪花 ID；type 为 JUDGE | SINGLE | MULTI
export interface QuestionItem {
  id: string
  type: string
  content: string
  options: OptionItem[]
  score: number
}

// 试卷信息：字段名与契约对齐，项目 6 接入真实接口时只换数据源
export interface PaperInfo {
  id: string
  paperName: string
  categoryName: string
  levelName: string
  totalScore: number
  passScore: number
  duration: number        // 分钟
  questionCount: number

  maxAttempts: number     // 最大可考次数（契约字段）
  attemptCount: number    // 已考次数（卡片角标用）
  bestScore: number       // 最好成绩（0 表示未考过）
}

// 逐题作答结果：与后端交卷接口契约对齐
export interface AnswerItem {
  questionId: string
  correct: boolean     // 该题是否答对
  answered: boolean    // 是否作答
}

// 交卷结果：字段与后端交卷接口契约对齐
export interface ExamResult {
  score: number        // 得分
  totalScore: number   // 总分
  passScore: number    // 及格分
  passed: boolean      // 是否通过
  usedTime: number     // 用时（秒）
  submitType: string   // 交卷方式：MANUAL 手动 / TIMEOUT 超时自动
  answers: AnswerItem[] // 逐题结果
}