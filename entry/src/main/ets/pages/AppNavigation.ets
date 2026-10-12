// 应用唯一入口（唯一 @Entry）
// RootDomain 只负责三件事：创建根栈 pageStack、注册根路由、首屏分流
import { RouteConstants } from '@zhititong/common'
import { MainPage } from './MainPage'
import { LoginPage } from '../features/login/view/LoginPage'
import { ExamDetailPage } from '../features/exam/view/ExamDetailPage'
import { AnswerResultPage } from '../features/exam/view/AnswerResultPage'
import { ReviewPage } from '../features/exam/view/ReviewPage'

@Entry
@ComponentV2
struct AppNavigation {
  // 一级导航：根栈。@Provider 提供给全局，任意层级用 @Consumer('pageStack') 直接消费
  @Provider('pageStack') pageStack: NavPathStack = new NavPathStack()

  // 根路由注册：应用级页面 + 挂根栈的沉浸式详情页
  @Builder
  RootRouter(name: string, param: Object) {
    if (name === RouteConstants.MAIN) {
      MainPage()
    } else if (name === RouteConstants.LOGIN) {
      LoginPage()
    } else if (name === RouteConstants.EXAM_DETAIL) {
      ExamDetailPage()
    } else if (name === RouteConstants.ANSWER_RESULT) {
      AnswerResultPage()
    } else if (name === RouteConstants.REVIEW) {
      ReviewPage()
    }
  }

  build() {
    // 首屏：登录页作为根栈底（栈空时显示的内容页）
    Navigation(this.pageStack) {
      LoginPage()
    }
    .mode(NavigationMode.Stack)
    .navDestination(this.RootRouter)
    .hideTitleBar(true)
  }
}
