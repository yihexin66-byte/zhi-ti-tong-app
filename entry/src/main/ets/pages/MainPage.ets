/**
 * MainPage — 主容器页面（路由入口）
 * 
 * 【作用】
 *   应用启动后第一个页面，底部三个标签页装配首页/刷题/我的。
 *   本身是 @Entry 路由页面，由 EntryAbility 的 loadContent 加载。
 * 
 * 【架构位置】
 *   pages/ 目录 → 有 @Entry，被 main_pages.json 配置为路由页面（仅保留 Index 与 MainPage）
 *   features/<模块>/view/ 目录 → 无 @Entry，被本文件 import 后作为子组件嵌入 TabContent
 * 
 * 【关键概念】
 *   @Entry       : 标记此 struct 为路由页面入口，系统通过它找到页面
 *   @ComponentV2 : 声明为 ArkUI V2 组件（新版装饰器）
 *   @Local       : 组件内部状态变量，变化时自动触发 UI 重新渲染
 *   @Builder     : 自定义构建函数，封装一段可复用的 UI 片段
 *   Tabs/TabContent : 标签页容器，TabContent 是每页的内容，.tabBar 是标签
 */
import { CommonConstants } from '../common/constants/CommonConstants'
import { HomePage } from '../features/home/view/HomePage'           // 首页组件
import { ExamSubjectPage } from '../features/exam/view/ExamSubjectPage' // 刷题组件
import { MinePage } from '../features/mine/view/MinePage'           // 我的组件

// ===== 路由入口 =====
// @Entry 告诉系统：这个 struct 是一个页面，可以通过路由加载
// @ComponentV2 是最新的组件声明方式，比 @Component 功能更强
@Entry
@ComponentV2
struct MainPage {
  // ===== 状态变量 =====
  // @Local 是组件内部状态，修改它 → 自动重新渲染用到它的地方
  // currentIndex 记录当前选中了第几个标签（0=首页, 1=刷题, 2=我的）
  @Local currentIndex: number = 0

  // ===== 自定义标签栏 =====
  // @Builder 是"模板函数"，把一段 UI 封装起来，可以反复调用
  // 这里用来生成每个标签的样式：选中时主色加粗，未选中时灰色
  // title: 标签文字（如"首页"）
  // index: 标签序号（0/1/2），用来判断当前是否选中
  @Builder tabBarItem(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(CommonConstants.FONT_BODY)           // 字号 16
        // 三目运算符：如果 currentIndex 等于本标签的 index → 加粗，否则正常
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
        // 选中用主色蓝，未选中用提示灰
        .fontColor(this.currentIndex === index ? CommonConstants.COLOR_PRIMARY : CommonConstants.COLOR_TEXT_HINT)
    }
    .width('100%')
    .height(CommonConstants.BTN_HEIGHT)                 // 高度 50
    .justifyContent(FlexAlign.Center)                   // 文字居中
    .onClick(() => {
      // 点击标签 → 更新 currentIndex → Tabs 切换到对应页
      this.currentIndex = index
    })
  }

  // ===== 构建 UI =====
  build() {
    // Tabs 标签页容器
    // barPosition: BarPosition.End  → 标签栏放在底部
    // index: this.currentIndex      → 绑定状态，Tabs 根据它显示对应页
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      // ===== 第1页：首页 =====
      TabContent() {
        HomePage()     // 调用 HomePage 组件（从 features/home/view/ 导入）
      }
      .tabBar(this.tabBarItem('首页', 0))   // 标签文字"首页"，序号0

      // ===== 第2页：刷题 =====
      TabContent() {
        ExamSubjectPage()  // 调用 ExamSubjectPage 组件
      }
      .tabBar(this.tabBarItem('刷题', 1))   // 标签文字"刷题"，序号1

      // ===== 第3页：我的 =====
      TabContent() {
        MinePage()       // 调用 MinePage 组件
      }
      .tabBar(this.tabBarItem('我的', 2))   // 标签文字"我的"，序号2
    }
    .barHeight(CommonConstants.BTN_HEIGHT)   // 标签栏高度 50
    .scrollable(false)                       // 禁止左右滑动，只能点标签切换
    .onChange((index: number) => {
      // 标签切换时同步更新状态（比如通过代码切换时也能跟踪）
      this.currentIndex = index
    })
  }
}