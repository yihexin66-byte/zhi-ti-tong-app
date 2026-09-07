// 考试科目页：按 categoryName 聚合展示科目网格
import { CommonConstants } from '../common/constants/CommonConstants'
import { MOCK_PAPERS } from '../common/mock/MockExamData'
import { CategoryGroup, groupByCategory } from '../common/utils/PaperUtils'

// 科目卡片组件：展示科目名与试卷套数
@ComponentV2
struct ExamSubjectCard {
  @Param group: CategoryGroup = { categoryName: '', count: 0 }

  build() {
    Column() {
      Text(this.group.categoryName)
        .fontSize(CommonConstants.FONT_BODY)
        .fontWeight(FontWeight.Bold)
        .fontColor(CommonConstants.COLOR_TEXT_MAIN)
      Text(`共 ${this.group.count} 套`)
        .fontSize(CommonConstants.FONT_CAPTION)
        .fontColor(CommonConstants.COLOR_TEXT_SUB)
        .margin({ top: CommonConstants.SPACE_M })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .padding(CommonConstants.SPACE_M)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      console.info(this.group.categoryName)
    })
  }
}

@ComponentV2
export struct ExamSubjectPage {
  @Local categoryList: CategoryGroup[] = groupByCategory(MOCK_PAPERS)

  build() {
    Column() {
      // 顶部标题
      Text('考试科目')
        .fontSize(CommonConstants.FONT_SUBTITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(CommonConstants.COLOR_TEXT_MAIN)
        .width('100%')

      // 科目网格：两列
      Grid() {
        ForEach(this.categoryList, (group: CategoryGroup) => {
          GridItem() {
            ExamSubjectCard({ group: group })
          }
        }, (group: CategoryGroup) => group.categoryName)
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(CommonConstants.SPACE_M)
      .columnsGap(CommonConstants.SPACE_M)
      .width('100%')
      .margin({ top: CommonConstants.SPACE_L })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.COLOR_BG_PAGE)
    .padding(CommonConstants.SPACE_M)
  }
}
