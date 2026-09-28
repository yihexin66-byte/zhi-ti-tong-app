/**
 * ExamDetailViewModel — 答题页 ViewModel（viewModel 层）
 *
 * 【分层约束】
 *   1. @ObservedV2 class，继承 common/base/BaseViewModel
 *   2. 状态一律 @Trace，变更自动驱动 View 刷新
 *   3. 本文件零 UI 组件、零 @Builder、零导航栈操作（导航留在 View 层）
 *
 * 【职责边界】
 *   答题页全部业务状态集中于此：当前题号、单选选中项、多选选中项；
 *   选项选择、切题重置为纯逻辑方法（单测覆盖）；
 *   提交后跳转结果页属于导航，由 View 层执行。
 *
 * 【数据来源】
 *   Mock 数据只来自 common/mock（MOCK_PAPER / MOCK_QUESTIONS），模块内不新造业务数据。
 */
import { BaseViewModel } from '@zhititong/common'
import { Logger } from '@zhititong/common'
import { MOCK_PAPER, MOCK_QUESTIONS } from '@zhititong/common'
import { PaperInfo, QuestionItem } from '@zhititong/common'

@ObservedV2
export class ExamDetailViewModel extends BaseViewModel {
  // 试卷信息与题目列表（Mock 只读数据，非响应式）
  readonly paper: PaperInfo = MOCK_PAPER
  readonly questions: QuestionItem[] = MOCK_QUESTIONS

  // 当前题号（0 起）
  @Trace currentIndex: number = 0

  // 单选/判断题选中项（切题重置）
  @Trace selectedAnswer: string = ''

  // 多选题选中项集合（切题重置）
  @Trace multiAnswers: string[] = []

  constructor() {
    super()
    this.logger = new Logger('[ExamDetailViewModel]')
  }

  /**
   * 根据题型返回中文名称（展示换算由 ViewModel 决定，View 只取值渲染）
   */
  getTypeLabel(type: string): string {
    if (type === 'JUDGE') {
      return '判断题'
    }
    if (type === 'SINGLE') {
      return '单选题'
    }
    if (type === 'MULTI') {
      return '多选题'
    }
    return ''
  }

  /**
   * 当前题是否多选题（View 依此决定渲染 Checkbox 还是 Radio）
   */
  isCurrentMulti(): boolean {
    return this.questions[this.currentIndex].type === 'MULTI'
  }

  /**
   * 单选题：选项被点选（单选替换语义：新选项直接覆盖旧选项）
   */
  handleSingleSelect(label: string): void {
    this.selectedAnswer = label
  }

  /**
   * 单选题：选项是否处于选中态
   */
  isSingleChecked(label: string): boolean {
    return this.selectedAnswer === label
  }

  /**
   * 多选题：切换选项选中态（toggle 语义：已选中再点一次=取消）
   */
  handleMultiSelect(label: string): void {
    if (this.multiAnswers.indexOf(label) !== -1) {
      this.multiAnswers = this.multiAnswers.filter((item: string) => item !== label)
    } else {
      this.multiAnswers = [...this.multiAnswers, label]
    }
  }

  /**
   * 多选题：选项是否处于选中态
   */
  isMultiChecked(label: string): boolean {
    return this.multiAnswers.indexOf(label) !== -1
  }

  /**
   * 上一题（含边界保护）；切题后单选与多选选中态全部清空
   */
  prevQuestion(): void {
    if (this.currentIndex > 0) {
      this.currentIndex--
      this.resetSelections()
    }
  }

  /**
   * 下一题（含边界保护）；切题后单选与多选选中态全部清空
   */
  nextQuestion(): void {
    if (this.currentIndex < this.questions.length - 1) {
      this.currentIndex++
      this.resetSelections()
    }
  }

  /**
   * 切题重置：清空单选与多选选中态（纯逻辑，单测覆盖）
   */
  private resetSelections(): void {
    this.selectedAnswer = ''
    this.multiAnswers = []
  }
}
