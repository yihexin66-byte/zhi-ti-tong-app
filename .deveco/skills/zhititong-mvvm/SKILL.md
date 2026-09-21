---
name: zhititong-mvvm
description: 智题通 MVVM 分层与工程规范。当用户要求创建或改造 features 模块、提到 MVVM、分层、ViewModel、模块重构时必须使用本技能。
---

# 智题通 MVVM 分层规范

## 分层规则
1. model 层：纯数据类，零逻辑、零 UI import；跨模块共享的模型放 common/models，模块专属模型才放 features/<模块>/model。
2. viewModel 层：@ObservedV2 class，继承 common/base/BaseViewModel；状态一律用 @Trace；异步业务方法返回 common/base/Result；全文件零 UI 组件、零 @Builder。
3. view 层：@ComponentV2 struct，零业务判断；状态全部来自 viewModel（用 @Local 持有实例）；事件只转发给 viewModel 方法；导航操作留在 view 层（@Consumer 取导航栈）。

## 工程约定
- 目录：features/<模块>/{model, view, viewModel}；一个文件一个主组件或类，文件名与类名一致。
- 命名：XxxViewModel、XxxPage、可复用子组件独立成文件。
- 样式常量一律用 common/constants/CommonConstants，禁止魔法数。
- ForEach 的 keyGenerator 必须用数据的唯一 id，禁止用下标。
- 页面根节点：被路由的页面用 NavDestination；域根页面用 Navigation(自持子栈) 并注册域内路由。
- Mock 数据一律来自 common/mock，禁止在模块内新造数据。
- 改造已有模块时：不改变页面视觉效果；除新增公共代码外，不得改动其他模块与公共层的既有代码。

## 参考样板
features/login 是本工程的 MVVM 标准样板（LoginViewModel + LoginPage），动手前先完整阅读。