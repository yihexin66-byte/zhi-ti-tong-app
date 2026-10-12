import { describe, it, expect } from '@ohos/hypium'
import { MockKit, when, ArgumentMatchers } from '@ohos/hamock'
import { CommonConstants } from '@zhititong/common'
import { AttemptRecordViewModel } from '../main/ets/features/mine/viewModel/AttemptRecordViewModel'
import { AttemptPage, ExamService } from '../main/ets/features/exam/service/ExamService'
import { FIXTURE_ATTEMPT_RECORDS, FIXTURE_ATTEMPT_TOTAL, makeAttemptRecord } from './Fixtures'

/** 分页请求账本：交互断言用（记录每次调用的页码与尺寸） */
class PageLedger {
  pages: number[] = []
  sizes: number[] = []
}

/**
 * 分页桩：用 afterAction 替代 afterReturn——透传实参按页码分发不同夹具页，
 * 同时把每次调用的 (page, size) 抄送进账本。
 */
function createPagingService(ledger: PageLedger): ExamService {
  const service = new ExamService()
  const mockKit = new MockKit()
  when(mockKit.mockFunc(service, service.getAttempts))(ArgumentMatchers.any)
    .afterAction((page: number, size: number) => {
      ledger.pages.push(page)
      ledger.sizes.push(size)
      const start = (page - 1) * size
      const slice = FIXTURE_ATTEMPT_RECORDS.slice(start, start + size)
      const result: AttemptPage = {
        records: slice,
        total: FIXTURE_ATTEMPT_TOTAL,
        page: page,
        size: size
      }
      return Promise.resolve(result)
    })
  return service
}

export default function attemptRecordViewModelTest() {
  describe('attemptRecordViewModelTest', () => {
    // 常规：首页装载 10 条，总数 12，仍有下一页
    it('should_load_first_page', 0, async () => {
      const ledger = new PageLedger()
      const vm = new AttemptRecordViewModel(createPagingService(ledger))
      await vm.loadFirstPage()
      expect(vm.records.length).assertEqual(10)
      expect(vm.total).assertEqual(12)
      expect(vm.hasMore).assertEqual(true)
      expect(ledger.pages[0]).assertEqual(1)
      expect(ledger.sizes[0]).assertEqual(10)
    })

    // 常规：触底加载把第二页追加在尾部（10 + 2 = 12），到底后 hasMore=false
    it('should_append_next_page_until_end', 0, async () => {
      const ledger = new PageLedger()
      const vm = new AttemptRecordViewModel(createPagingService(ledger))
      await vm.loadFirstPage()
      await vm.loadMore()
      expect(vm.records.length).assertEqual(12)
      expect(vm.hasMore).assertEqual(false)
      expect(ledger.pages[1]).assertEqual(2)
    })

    // ===== 交互断言：到底之后不再发起请求 =====
    it('should_not_request_after_reaching_end', 0, async () => {
      const ledger = new PageLedger()
      const vm = new AttemptRecordViewModel(createPagingService(ledger))
      await vm.loadFirstPage()
      await vm.loadMore()                 // 到这里共 12 条，已到底
      expect(ledger.pages.length).assertEqual(2)
      await vm.loadMore()                 // 到底后连续触底：不应再发请求
      await vm.loadMore()
      expect(ledger.pages.length).assertEqual(2)
      expect(vm.records.length).assertEqual(12)
    })

    // 常规：重新加载回到第一页（不重复追加）
    it('should_reset_to_first_page_on_reload', 0, async () => {
      const ledger = new PageLedger()
      const vm = new AttemptRecordViewModel(createPagingService(ledger))
      await vm.loadFirstPage()
      await vm.loadMore()
      await vm.loadFirstPage()
      expect(vm.records.length).assertEqual(10)
      expect(ledger.pages[2]).assertEqual(1)
    })

    // 展示换算：得分颜色随通过与否，交卷方式按三态中文口径
    it('should_derive_score_color_and_submit_text', 0, async () => {
      const ledger = new PageLedger()
      const vm = new AttemptRecordViewModel(createPagingService(ledger))
      await vm.loadFirstPage()
      const passed = makeAttemptRecord(2)      // index 为偶数 → 通过
      const failed = makeAttemptRecord(1)
      expect(vm.getScoreColor(passed)).assertEqual(CommonConstants.COLOR_SUCCESS)
      expect(vm.getScoreColor(failed)).assertEqual(CommonConstants.COLOR_ERROR)
      expect(vm.getSubmitTypeText(passed)).assertEqual('手动交卷')
      expect(vm.getSubmitTypeText(makeAttemptRecord(3))).assertEqual('超时自动交卷')
    })

    // 异常路径：加载失败时 errorMessage 落值、loading 归位
    it('should_set_error_when_load_fails', 0, async () => {
      const service = new ExamService()
      const mockKit = new MockKit()
      when(mockKit.mockFunc(service, service.getAttempts))(ArgumentMatchers.any)
        .afterAction(() => Promise.reject(new Error('未登录，请先登录')))
      const vm = new AttemptRecordViewModel(service)
      await vm.loadFirstPage()
      expect(vm.errorMessage).assertEqual('未登录，请先登录')
      expect(vm.loading).assertEqual(false)
      expect(vm.records.length).assertEqual(0)
    })
  })
}
