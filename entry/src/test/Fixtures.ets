/**
 * 测试夹具（fixture）集中声明：一套受控的"世界观"，所有用例共享。
 *
 * 约定：
 *   - 试卷统一用"HarmonyOS 应用开发·3 题小卷"系列命名；
 *   - id 一律用字符串（雪花 ID 在 App 内始终是字符串，避免精度问题）；
 *   - 夹具不复用 common/mock，与生产数据解耦——测试断言的是我们自己的逻辑。
 */
import { PaperInfo, SessionUserData } from '@zhititong/common'
import { LoginResult } from '../main/ets/features/login/service/LoginService'

/** 夹具试卷共 8 套：HarmonyOS 6 套 + Java 程序设计 2 套 */
export const FIXTURE_PAPERS: PaperInfo[] = [
  { id: '1001', paperName: 'HarmonyOS 应用开发·3 题小卷（一）', categoryName: 'HarmonyOS', levelName: '基础', totalScore: 30, passScore: 18, duration: 10, questionCount: 3, maxAttempts: 0, attemptCount: 0, bestScore: 0 },
  { id: '1002', paperName: 'HarmonyOS 应用开发·3 题小卷（二）', categoryName: 'HarmonyOS', levelName: '基础', totalScore: 30, passScore: 18, duration: 10, questionCount: 3, maxAttempts: 0, attemptCount: 1, bestScore: 30 },
  { id: '1003', paperName: 'HarmonyOS 应用开发·3 题小卷（三）', categoryName: 'HarmonyOS', levelName: '基础', totalScore: 30, passScore: 18, duration: 10, questionCount: 3, maxAttempts: 3, attemptCount: 2, bestScore: 24 },
  { id: '1004', paperName: 'HarmonyOS 应用开发·3 题小卷（四）', categoryName: 'HarmonyOS', levelName: '高级', totalScore: 30, passScore: 24, duration: 12, questionCount: 3, maxAttempts: 0, attemptCount: 0, bestScore: 0 },
  { id: '1005', paperName: 'HarmonyOS 应用开发·3 题小卷（五）', categoryName: 'HarmonyOS', levelName: '高级', totalScore: 30, passScore: 24, duration: 12, questionCount: 3, maxAttempts: 1, attemptCount: 1, bestScore: 27 },
  { id: '1006', paperName: 'HarmonyOS 应用开发·3 题小卷（六）', categoryName: 'HarmonyOS', levelName: '高级', totalScore: 30, passScore: 24, duration: 12, questionCount: 3, maxAttempts: 0, attemptCount: 0, bestScore: 0 },
  { id: '1007', paperName: 'Java 程序设计·3 题小卷（一）', categoryName: 'Java 程序设计', levelName: '期末', totalScore: 30, passScore: 18, duration: 10, questionCount: 3, maxAttempts: 0, attemptCount: 0, bestScore: 0 },
  { id: '1008', paperName: 'Java 程序设计·3 题小卷（二）', categoryName: 'Java 程序设计', levelName: '期末', totalScore: 30, passScore: 18, duration: 10, questionCount: 3, maxAttempts: 2, attemptCount: 1, bestScore: 21 }
]

/** 夹具用户信息（登录成功返回的 userInfo 形状） */
export const FIXTURE_USER: SessionUserData = {
  id: '9001',
  username: 'student',
  role: '考生'
}

/** 夹具登录结果（成功）：token + 用户信息 */
export const FIXTURE_LOGIN_OK: LoginResult = {
  token: 'fixture-token',
  userInfo: FIXTURE_USER
}

/** 夹具登录结果（管理员） */
export const FIXTURE_LOGIN_ADMIN: LoginResult = {
  token: 'fixture-token-admin',
  userInfo: { id: '9002', username: 'admin', role: '管理员' }
}

/** 夹具注册成功返回的用户信息 */
export const FIXTURE_REGISTER_OK: SessionUserData = {
  id: '9003',
  username: 'xyr001',
  role: '考生'
}

/** 夹具错误文案：与后端 message 同源（BaseService 原样抛出） */
export const FIXTURE_ERROR_WRONG_PASSWORD: string = '账号或密码错误'
export const FIXTURE_ERROR_USER_EXISTS: string = '账号已存在'
