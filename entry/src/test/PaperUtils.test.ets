import { describe, it, expect } from '@ohos/hypium'
import { getRandomPapers } from '../main/ets/common/utils/PaperUtils'
import { PaperInfo } from '../main/ets/common/model/QuestionModel'

// 造 5 张最简测试试卷（只需 id 有区分度）
function makePapers(count: number): PaperInfo[] {
  const arr: PaperInfo[] = []
  for (let i = 1; i <= count; i++) {
    arr.push({
      id: `${i}`, paperName: `测试卷${i}`, categoryName: '测试', levelName: '测试',
      totalScore: 100, passScore: 60, duration: 30, questionCount: 6,
      maxAttempts: 3, attemptCount: 0, bestScore: 0
    })
  }
  return arr
}

export default function paperUtilsTest(): void {
  describe('getRandomPapersTest', () => {
    // 断言1：抽取数量正确
    it('should_return_exact_n_papers', 0, () => {
      const result = getRandomPapers(makePapers(5), 3)
      expect(result.length).assertEqual(3)
    })
    // 断言2：n 超过总数时返回全部
    it('should_return_all_when_n_exceeds', 0, () => {
      const result = getRandomPapers(makePapers(5), 10)
      expect(result.length).assertEqual(5)
    })
    // 断言3：抽取结果不含重复试卷
    it('should_have_no_duplicates', 0, () => {
      const result = getRandomPapers(makePapers(5), 5)
      const ids: string[] = result.map((p: PaperInfo) => p.id)
      expect(new Set<string>(ids).size).assertEqual(5)
    })
    // 断言4：原数组不被修改
    it('should_not_mutate_source', 0, () => {
      const source = makePapers(5)
      getRandomPapers(source, 3)
      expect(source[0].id).assertEqual('1')
      expect(source.length).assertEqual(5)
    })
  })
}