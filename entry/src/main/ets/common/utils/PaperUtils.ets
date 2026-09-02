import { PaperInfo } from '../model/QuestionModel'

// 从试卷数组中随机抽取 n 张（Fisher-Yates 洗牌后取前 n 张）
// 约定：不修改原数组；n 大于等于总数时返回全部试卷的副本
export function getRandomPapers(papers: PaperInfo[], n: number): PaperInfo[] {
  const pool: PaperInfo[] = papers.slice()   // 副本，保护原数组
  for (let i = pool.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    const tmp: PaperInfo = pool[i]
    pool[i] = pool[j]
    pool[j] = tmp
  }
  return n >= pool.length ? pool : pool.slice(0, n)
}