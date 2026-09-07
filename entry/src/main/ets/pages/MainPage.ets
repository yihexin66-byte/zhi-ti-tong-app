// 主容器页面：底部标签页装配首页、刷题、我的三个页面
import { CommonConstants } from '../common/constants/CommonConstants'
import { HomePage } from '../components/HomePage'
import { ExamSubjectPage } from '../components/ExamSubjectPage'
import { MinePage } from '../components/MinePage'

@Entry
@ComponentV2
struct MainPage {
  // 当前选中的标签下标
  @Local currentIndex: number = 0

  // 自定义文字版标签项：选中主色加粗，未选中提示色
  @Builder tabBarItem(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(CommonConstants.FONT_BODY)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentIndex === index ? CommonConstants.COLOR_PRIMARY : CommonConstants.COLOR_TEXT_HINT)
    }
    .width('100%')
    .height(CommonConstants.BTN_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      // 点击标签切换到对应页签
      this.currentIndex = index
    })
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      // 首页
      TabContent() {
        HomePage()
      }
      .tabBar(this.tabBarItem('首页', 0))

      // 刷题
      TabContent() {
        ExamSubjectPage()
      }
      .tabBar(this.tabBarItem('刷题', 1))

      // 我的
      TabContent() {
        MinePage()
      }
      .tabBar(this.tabBarItem('我的', 2))
    }
    .barHeight(CommonConstants.BTN_HEIGHT)
    // 禁用左右滑动，仅可点击标签切换
    .scrollable(false)
    // 监听页签切换，同步更新下标状态
    .onChange((index: number) => {
      this.currentIndex = index
    })
  }
}
