/**
 * MineUserModel — 个人中心用户信息模型（model 层）
 *
 * 【分层约束】
 *   纯数据类，零逻辑、零 UI import；mine 模块专属（项目 6 接真实用户接口时换数据源）。
 */
export class MineUserModel {
  nickname: string = ''
  signature: string = ''

  constructor(nickname: string, signature: string) {
    this.nickname = nickname
    this.signature = signature
  }
}
