import { ExamResult } from '../model/QuestionModel'

// Mock 交卷结果：与 MOCK_PAPER / MOCK_QUESTIONS 六道题对应
// 覆盖三种状态：4 对（101/102/104/105）、1 错（103）、1 未答（106）
export const MOCK_RESULT: ExamResult = {
  score: 80,
  totalScore: 100,
  passScore: 60,
  passed: true,
  usedTime: 754,
  submitType: 'MANUAL',
  answers: [
    { questionId: '1953001000000000101', correct: true, answered: true },
    { questionId: '1953001000000000102', correct: true, answered: true },
    { questionId: '1953001000000000103', correct: false, answered: true },
    { questionId: '1953001000000000104', correct: true, answered: true },
    { questionId: '1953001000000000105', correct: true, answered: true },
    { questionId: '1953001000000000106', correct: false, answered: false }
  ]
}
