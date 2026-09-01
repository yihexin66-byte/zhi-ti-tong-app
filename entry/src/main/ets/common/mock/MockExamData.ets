import { PaperInfo, QuestionItem } from '../model/QuestionModel'

// Mock 试卷（字段与契约对齐）
export const MOCK_PAPER: PaperInfo = {
  id: '1953001000000000001',
  paperName: 'HarmonyOS 应用开发基础模拟卷（一）',
  categoryName: '鸿蒙认证',
  levelName: '基础认证',
  totalScore: 100,
  passScore: 60,
  duration: 30,
  questionCount: 6
}

// Mock 题目：判断题 A=正确 B=错误；单选 4 项；多选 4 项
export const MOCK_QUESTIONS: QuestionItem[] = [
  {
    id: '1953001000000000101', type: 'JUDGE', score: 10,
    content: 'ArkTS 是基于 TypeScript 扩展而来的开发语言。',
    options: [
      { label: 'A', content: '正确' },
      { label: 'B', content: '错误' }
    ]
  },
  {
    id: '1953001000000000102', type: 'SINGLE', score: 20,
    content: '下列哪个组件用于在界面中显示文本内容？',
    options: [
      { label: 'A', content: 'Image' },
      { label: 'B', content: 'Text' },
      { label: 'C', content: 'Button' },
      { label: 'D', content: 'Progress' }
    ]
  },
  {
    id: '1953001000000000103', type: 'MULTI', score: 20,
    content: '下列属于 ArkUI 线性布局容器的有哪些？',
    options: [
      { label: 'A', content: 'Column' },
      { label: 'B', content: 'Row' },
      { label: 'C', content: 'Stack' },
      { label: 'D', content: 'RelativeContainer' }
    ]
  },
  {
    id: '1953001000000000104', type: 'JUDGE', score: 10,
    content: 'Span 组件可以脱离 Text 组件单独使用。',
    options: [
      { label: 'A', content: '正确' },
      { label: 'B', content: '错误' }
    ]
  },
  {
    id: '1953001000000000105', type: 'SINGLE', score: 20,
    content: 'Button 组件默认的按钮类型是哪一种？',
    options: [
      { label: 'A', content: 'ButtonType.Normal' },
      { label: 'B', content: 'ButtonType.Circle' },
      { label: 'C', content: 'ButtonType.Capsule' },
      { label: 'D', content: 'ButtonType.Toggle' }
    ]
  },
  {
    id: '1953001000000000106', type: 'MULTI', score: 20,
    content: '关于 $r() 资源引用，下列说法正确的有哪些？',
    options: [
      { label: 'A', content: '可以引用字符串资源' },
      { label: 'B', content: '可以引用颜色资源' },
      { label: 'C', content: '便于多语言适配' },
      { label: 'D', content: '只能在 Text 组件中使用' }
    ]
  }
]