import { PaperInfo } from '../models/QuestionModel'

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

// 科目聚合结果
export interface CategoryGroup {
  categoryName: string
  count: number
}

// 按 categoryName 聚合试卷数量（纯函数，不修改入参）
export function groupByCategory(papers: PaperInfo[]): CategoryGroup[] {
  const map: Record<string, number> = {}
  for (let i = 0; i < papers.length; i++) {
    const name: string = papers[i].categoryName
    if (map[name] === undefined) {
      map[name] = 1
    } else {
      map[name]++
    }
  }
  const keys: string[] = Object.keys(map)
  const result: CategoryGroup[] = []
  for (let i = 0; i < keys.length; i++) {
    const group: CategoryGroup = { categoryName: keys[i], count: map[keys[i]] }
    result.push(group)
  }
  return result
}

// 按科目名过滤试卷（纯函数，不修改入参）
// 约定：categoryName 为空字符串时返回空数组，由调用方决定空态展示
export function filterByCategory(papers: PaperInfo[], categoryName: string): PaperInfo[] {
  if (categoryName === '') {
    return []
  }
  return papers.filter((paper: PaperInfo) => paper.categoryName === categoryName)
}