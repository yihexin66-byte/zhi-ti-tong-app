// 首页：轮播区 + 推荐试卷列表
import { CommonConstants } from '../common/constants/CommonConstants'
import { PaperInfo } from '../common/model/QuestionModel'
import { MOCK_PAPERS } from '../common/mock/MockExamData'
import { getRandomPapers } from '../common/utils/PaperUtils'

// 试卷卡片组件：展示试卷名、等级标签、题目信息及成绩角标
@ComponentV2
struct PaperCard {
  @Param paper: PaperInfo = {
    id: '', paperName: '', categoryName: '', levelName: '',
    totalScore: 0, passScore: 0, duration: 0, questionCount: 0,
    maxAttempts: 0, attemptCount: 0, bestScore: 0
  }

  build() {
    Row() {
      // 左侧：试卷信息
      Column() {
        // 上行：试卷名 + 等级标签
        Row() {
          Text(this.paper.paperName)
            .fontSize(CommonConstants.FONT_BODY)
            .fontWeight(FontWeight.Bold)
            .fontColor(CommonConstants.COLOR_TEXT_MAIN)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          Text(this.paper.levelName)
            .fontSize(CommonConstants.FONT_CAPTION)
            .fontColor(CommonConstants.COLOR_PRIMARY)
            .borderWidth(1)
            .borderColor(CommonConstants.COLOR_PRIMARY)
            .borderRadius(4)
            .borderStyle(BorderStyle.Solid)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .margin({ left: CommonConstants.SPACE_M })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        // 下行：题目数 · 时长 · 及格分
        Text(`共 ${this.paper.questionCount} 题 · ${this.paper.duration} 分钟 · 及格 ${this.paper.passScore} 分`)
          .fontSize(CommonConstants.FONT_CAPTION)
          .fontColor(CommonConstants.COLOR_TEXT_SUB)
          .margin({ top: CommonConstants.SPACE_M })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 右侧角标：bestScore > 0 显示成绩，否则显示未考
      if (this.paper.bestScore > 0) {
        Text(`最好 ${this.paper.bestScore} 分`)
          .fontSize(CommonConstants.FONT_CAPTION)
          .fontColor(CommonConstants.COLOR_SUCCESS)
      } else {
        Text('未考')
          .fontSize(CommonConstants.FONT_CAPTION)
          .fontColor(CommonConstants.COLOR_TEXT_HINT)
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .padding(CommonConstants.SPACE_M)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      console.info(this.paper.paperName)
    })
  }
}

@Entry
@ComponentV2
struct HomePage {
  @Local paperList: PaperInfo[] = getRandomPapers(MOCK_PAPERS, 4)

  build() {
    Scroll() {
      Column({ space: CommonConstants.SPACE_L }) {
        // ========== 顶部轮播区 ==========
        Swiper() {
          Image($r('app.media.banner1'))
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)
          Image($r('app.media.banner2'))
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)
          Image($r('app.media.banner3'))
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)
        }
        .autoPlay(true)
        .interval(3000)
        .indicator(true)
        .height(160)
        .borderRadius(12)
        .clip(true)

        // ========== 推荐试卷区 ==========
        Column({ space: CommonConstants.SPACE_M }) {
          Text('推荐试卷')
            .fontSize(CommonConstants.FONT_SUBTITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(CommonConstants.COLOR_TEXT_MAIN)
            .width('100%')

          ForEach(this.paperList, (paper: PaperInfo) => {
            PaperCard({ paper: paper })
          }, (paper: PaperInfo) => paper.id)
        }
        .width('100%')
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.COLOR_BG_PAGE)
    .padding(CommonConstants.SPACE_M)
  }
}
