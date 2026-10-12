import { describe, it, expect } from '@ohos/hypium'
import { MockKit, when, ArgumentMatchers } from '@ohos/hamock'
import { httpClient, HttpResult } from '@zhititong/common'
import { PaperService } from '../main/ets/features/exam/service/PaperService'
import { FIXTURE_PAPERS } from './Fixtures'

/**
 * PaperService + BaseService 两层拆包的单测。
 *
 * 拦截层次：mock 掉全局 httpClient.get（网络层），
 * 这样既不发真实请求，又能验证 Service 是否走到了契约路径、拆包是否正确。
 */
export default function paperServiceTest() {
  describe('paperServiceTest', () => {
    // 交互断言：不只验证结果，还验证"它有没有按约定调用依赖"
    it('should_fetch_from_contract_path', 0, async () => {
      const ledger: string[] = []
      const okBody: HttpResult = {
        code: 200,
        raw: JSON.stringify({ code: 200, message: '操作成功', data: FIXTURE_PAPERS })
      }
      const mockKit = new MockKit()
      when(mockKit.mockFunc(httpClient, httpClient.get))(ArgumentMatchers.any)
        .afterAction((path: string) => {
          ledger.push(path)
          return Promise.resolve(okBody)
        })
      const service = new PaperService()
      const papers = await service.getPapers()
      expect(papers.length).assertEqual(8)
      expect(ledger.length).assertEqual(1)
      expect(ledger[0]).assertEqual('/api/exam/papers')
    })

    // 两层拆包：HTTP 层 401 但业务 code != 200 时，抛后端 message 原文
    it('should_throw_backend_message_when_code_not_200', 0, async () => {
      const unauthorizedBody: HttpResult = {
        code: 401,
        raw: JSON.stringify({ code: 401, message: '未登录，请先登录', data: null })
      }
      const mockKit = new MockKit()
      when(mockKit.mockFunc(httpClient, httpClient.get))(ArgumentMatchers.any)
        .afterReturn(Promise.resolve(unauthorizedBody))
      const service = new PaperService()
      let msg = ''
      try {
        await service.getPapers()
      } catch (e) {
        msg = (e as Error).message
      }
      expect(msg).assertEqual('未登录，请先登录')
    })

    // 拆包：响应体不是合法 JSON 时给出"响应解析失败"错误
    it('should_report_parse_failure_for_invalid_json', 0, async () => {
      const brokenBody: HttpResult = {
        code: 500,
        raw: '<html>Internal Server Error</html>'
      }
      const mockKit = new MockKit()
      when(mockKit.mockFunc(httpClient, httpClient.get))(ArgumentMatchers.any)
        .afterReturn(Promise.resolve(brokenBody))
      const service = new PaperService()
      let msg = ''
      try {
        await service.getPapers()
      } catch (e) {
        msg = (e as Error).message
      }
      expect(msg).assertEqual('HTTP 500，响应解析失败')
    })
  })
}
