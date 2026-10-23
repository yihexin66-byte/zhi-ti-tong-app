export class AppConfig {
  /**
   * 后端 Base URL —— 写你开发电脑的局域网 IP（课前准备 ipconfig 查到的那个）。
   * 口径：一律写 IP、不写 localhost：模拟器/真机里的 localhost 是设备自己，不是你的电脑。
   */
  static readonly BASE_URL: string = 'http://10.55.157.156:8080'

  /** 连接超时（毫秒） */
  static readonly CONNECT_TIMEOUT: number = 10000

  /** 读取超时（毫秒） */
  static readonly READ_TIMEOUT: number = 10000

  /** 网络请求日志开关（开发期 true / 上线前 false） */
  static readonly ENABLE_HTTP_LOG: boolean = true
}
