# 6-2 MVVM 架构说明 · 登录联网与 Token 持久化

> 配套图：`6-2-MVVM架构.drawio`（单页分层总览）
> 时序细节见另一份：`6-2-流程时序.drawio` / `6-2-流程时序.md`

---

## 1. 一句话主线

6-1 已经把网络层、拦截器链、HttpClient 都埋好了；6-2 只做三件事：**声明 INTERNET 权限**、**用 SessionManager 把登录态收成三层**、**在 `EntryAbility.onCreate` 里用一行 `setTokenProvider` 让整条链路通电**。所以这张图的重点不在"新写了多少代码"，而在"哪根线被接上了"。

---

## 2. 分层与依赖

依赖方向单向自上而下，反向零依赖：

```
View  →  ViewModel  →  Service  →  BaseService  →  HttpClient  →  @kit.NetworkKit
```

| 层 | 位置 | 允许做 | 禁止做 |
|---|---|---|---|
| View | `pages/` + `features/*/view/` | 摆控件、转发事件、消费 `Result`、导航 | 任何业务判断、任何网络调用 |
| ViewModel | `features/*/viewModel/` | 校验三连、编排 Service、派生展示态（`@Trace loading / errorMessage`） | 认识 UI、认识页面栈 |
| Service | `features/*/service/` | 纯声明：路径 + 请求/响应类型 | 写 `if (code !== 200)` —— 错误处理收在 `BaseService.unwrap` |
| common HAR | `@zhititong/common` | HttpClient、拦截器链、SessionManager、PreferencesUtil、Result、常量 | 反向 import 业务层 |

**目录结构就是架构的广告牌**：`service/` 与 `model/ view/ viewModel/` 平铺并列。一旦把 `service/` 嵌进 `viewModel/` 里，"Service 是独立数据源"这件事就从结构上消失了，单测也就没法靠"给 ViewModel 塞一个假 Service"来隔离。

外部世界（进程外 / 系统能力）单独一条带：Spring Boot（`http://10.58.178.156:8080`，数据落 `exam.db`）、HiLog、AppStorageV2、Preferences 沙箱文件。它们不是代码层，是架构的边界。

---

## 3. 登录态为什么是三层，不是两层

| 层 | 载体 | 存什么 | 谁读 | 生命周期 |
|---|---|---|---|---|
| 内存 | `SessionManager.cachedToken` | token 字符串 | `TokenInterceptor`（每次请求，同步、零 IO） | 进程内 |
| 运行态 | `AppStorageV2['session_user']` → `SessionUser`（`@ObservedV2` + `@Trace`） | username / role / loggedIn | UI：`@Monitor`、`@Consumer` | 进程内，变化即刷新 |
| 磁盘 | `Preferences` 的 `user_session`：`token` + `user_info`(JSON) | 凭证与身份 | `loadFromDisk()` 冷启动回灌 | 跨进程、跨重启 |

两条判断口径：**token 是凭证 → Preferences**；**"当前用户是谁"是运行态 UI 数据 → AppStorageV2**。

少一层会怎样：少了内存层，拦截器每个请求都要做一次磁盘同步读；少了磁盘层，杀进程重开就得重新登录；少了运行态层，UI 只能靠轮询才知道登录状态变了。三层各司其职，没有一层多余。

登出同理，清理顺序不能反：**先 `SessionManager.logout()` 清状态，再 `pageStack.clear()` 清栈**，否则会露出一帧"主页还在、人已经登出"的缝。

---

## 4. 启动接线：`onCreate` 三步，顺序敏感

```ts
PreferencesUtil.init(this.context)                 // ① 没有 UIAbilityContext，Preferences 一把钥匙都拿不到
SessionManager.loadFromDisk()                      // ② 磁盘 → 内存 cachedToken + 运行态 SessionUser
setTokenProvider(() => SessionManager.getToken())  // ③ 一行通电：此后每个 httpClient 请求自动带 Bearer
```

① 必须在 ② 前：`loadFromDisk` 里所有 `PreferencesUtil.getString(...)` 都是零参数调用，靠的就是 ① 注入的那次 context。
③ 是 6-1 就埋好的注入点：`http.ets` 里 `let tokenProvider` 一直空着，6-2 只是把它接上——**这就是"一行激活"的含义**。

`onWindowStageCreate` 里 `loadContent('pages/AppNavigation')` 只加载外壳，**不把登录页当首页**：栈空时显示谁是 `Navigation(pageStack)` 的内容页决定的，而 `LoginPage` 的 `aboutToAppear` 会补查一次登录态。

---

## 5. 两个容易踩的硬约束

`BASE_URL` 一律写局域网 IP（`http://10.58.178.156:8080`）：设备里的 `localhost` 是设备自己，不是你的电脑。

`entry/src/main/module.json5` 的 `requestPermissions` 必须有 `ohos.permission.INTERNET`：normal 级权限，安装即授予、不弹窗，但**不声明则 `http.request` 被系统直接拒绝**——联网调试最易漏的一步。

---

## 6. 读图口诀

实线＝编译期调用（上层依赖下层，反向不依赖）｜紫虚线＝模块级装配｜绿虚线＝运行时状态读写（响应式 / 磁盘）｜红＝跨进程边界（HTTP / 磁盘 / HiLog）｜黄色斜体＝启动期一次性接线。
