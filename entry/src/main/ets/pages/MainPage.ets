// 主页面（TabDomain）：只负责 Tab 装配，不持有子栈、不注册路由
// 每个 Tab 对应的 Feature 根页面自持 Navigation + 子栈 + 域内路由
import { CommonConstants } from '@zhititong/common'
import { HomePage } from '../features/home/view/HomePage'
import { ExamSubjectPage } from '../features/exam/view/ExamSubjectPage'
import { MinePage } from '../features/mine/view/MinePage'

@ComponentV2
export struct MainPage {
  // 当前选中的 Tab 下标
  @Local currentIndex: number = 0

  // 自定义 TabBar：文字 + 选中变色（图标素材到位后再替换为图文版）
  @Builder
  tabBarBuilder(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(CommonConstants.FONT_BODY)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentIndex === index
          ? CommonConstants.COLOR_PRIMARY
          : CommonConstants.COLOR_TEXT_HINT)
    }
    .width('100%')
    .height(52)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      // 点击标签 → 更新 currentIndex → Tabs 切换到对应页
      this.currentIndex = index
    })
  }

  build() {
    NavDestination() {
      // 二级导航：三个 Tab 之间的切换
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        TabContent() {
          HomePage()
        }
        .tabBar(this.tabBarBuilder('首页', 0))

        TabContent() {
          ExamSubjectPage()
        }
        .tabBar(this.tabBarBuilder('刷题', 1))

        TabContent() {
          MinePage()
        }
        .tabBar(this.tabBarBuilder('我的', 2))
      }
      .scrollable(false)
      .onChange((index: number) => {
        this.currentIndex = index
      })
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
  }
}
