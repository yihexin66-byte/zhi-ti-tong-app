import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

/**
 * Preferences 统一封装：
 *   - init(context) 在 EntryAbility.onCreate 注入一次，业务侧从此零参数调用
 *   - 同名实例缓存复用；写操作自动 flush 落盘
 */
export class PreferencesUtil {
  private static appContext?: common.UIAbilityContext
  private static cache: Map<string, preferences.Preferences> = new Map()

  /** 必须在 EntryAbility.onCreate 中调用一次 */
  static init(context: common.UIAbilityContext): void {
    PreferencesUtil.appContext = context
  }

  private static getPrefs(prefName: string): preferences.Preferences {
    let prefs: preferences.Preferences | undefined = PreferencesUtil.cache.get(prefName)
    if (prefs === undefined) {
      prefs = preferences.getPreferencesSync(PreferencesUtil.appContext!, { name: prefName })
      PreferencesUtil.cache.set(prefName, prefs)
    }
    return prefs
  }

  /** 写入字符串（自动 flush 落盘） */
  static async putString(prefName: string, key: string, value: string): Promise<void> {
    const prefs = PreferencesUtil.getPrefs(prefName)
    await prefs.put(key, value)
    await prefs.flush()
  }

  /** 同步读取字符串 */
  static getString(prefName: string, key: string, defaultValue: string = ''): string {
    return PreferencesUtil.getPrefs(prefName).getSync(key, defaultValue) as string
  }

  /** 删除指定 key */
  static async remove(prefName: string, key: string): Promise<void> {
    const prefs = PreferencesUtil.getPrefs(prefName)
    await prefs.delete(key)
    await prefs.flush()
  }

  /** 清空整个 prefName 下的全部数据 */
  static async clear(prefName: string): Promise<void> {
    const prefs = PreferencesUtil.getPrefs(prefName)
    await prefs.clear()
    await prefs.flush()
  }
}
