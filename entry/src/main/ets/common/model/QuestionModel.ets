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