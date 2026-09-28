/**
 * 统一结果封装：调用方只看 ok，不用 try/catch 满天飞
 */
export class Result<T> {
  ok: boolean = false
  code: number = 0
  value?: T
  errorMessage?: string

  static ok<T>(value: T): Result<T> {
    const r = new Result<T>()
    r.ok = true
    r.code = 0
    r.value = value
    return r
  }

  static fail<T>(code: number, message: string): Result<T> {
    const r = new Result<T>()
    r.ok = false
    r.code = code
    r.errorMessage = message
    return r
  }
}