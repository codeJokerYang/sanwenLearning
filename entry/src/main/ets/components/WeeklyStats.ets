/**
 * WeeklyStats — 本周学习统计面板
 * 学习时长 / 知识点数 / 连续天数，含进度条
 */
@Component
export struct WeeklyStats {
  @Prop studyMinutes: number = 0;
  @Prop knowledgeCount: number = 0;
  @Prop streakDays: number = 0;

  build() {
    Column() {
      if (this.studyMinutes === 0 && this.knowledgeCount === 0 && this.streakDays === 0) {
        Text('\u5F00\u59CB\u5B66\u4E60\u540E\u8FD9\u91CC\u4F1A\u5C55\u793A\u4F60\u7684\u6570\u636E')
          .fontSize(13)
          .fontColor('rgba(255,255,255,0.4)')
          .textAlign(TextAlign.Center)
          .padding(24)
      } else {
        // Study minutes row
        Row() {
          Text('\u23F1').fontSize(16)
          Blank().width(8)
          Text(`${this.studyMinutes}`).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          Blank().width(4)
          Text('\u5206\u949F').fontSize(10).fontColor('rgba(255,255,255,0.4)')
          Blank().width(8)
          Text('\u672C\u5468\u5B66\u4E60').fontSize(10).fontColor('rgba(255,255,255,0.6)')
          Blank().layoutWeight(1)
          Row().width(`${this.getBarWidth(this.studyMinutes)}%`).height(3).borderRadius(1.5)
            .linearGradient({ angle: 90, colors: [['#5C6BC0', 0], ['#3949AB', 1]] })
        }.width('100%').alignItems(VerticalAlign.Center)

        Blank().height(14)

        // Knowledge count row
        Row() {
          Text('\u2B50').fontSize(16)
          Blank().width(8)
          Text(`${this.knowledgeCount}`).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          Blank().width(4)
          Text('\u4E2A\u77E5\u8BC6\u70B9').fontSize(10).fontColor('rgba(255,255,255,0.4)')
          Blank().width(8)
          Text('\u7D2F\u8BA1\u77E5\u8BC6').fontSize(10).fontColor('rgba(255,255,255,0.6)')
          Blank().layoutWeight(1)
          Row().width(`${this.getBarWidth(this.knowledgeCount)}%`).height(3).borderRadius(1.5)
            .linearGradient({ angle: 90, colors: [['#5C6BC0', 0], ['#3949AB', 1]] })
        }.width('100%').alignItems(VerticalAlign.Center)

        Blank().height(14)

        // Streak days row
        Row() {
          Text('\u{1F525}').fontSize(16)
          Blank().width(8)
          Text(`${this.streakDays}`).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          Blank().width(4)
          Text('\u5929\u8FDE\u7EED').fontSize(10).fontColor('rgba(255,255,255,0.4)')
          Blank().width(8)
          Text('\u8FDE\u7EED\u5B66\u4E60').fontSize(10).fontColor('rgba(255,255,255,0.6)')
          Blank().layoutWeight(1)
          Row().width(`${this.getBarWidth(this.streakDays)}%`).height(3).borderRadius(1.5)
            .linearGradient({ angle: 90, colors: [['#5C6BC0', 0], ['#3949AB', 1]] })
        }.width('100%').alignItems(VerticalAlign.Center)
      }
    }
    .width('100%').padding(16).borderRadius(16)
    .backgroundColor('rgba(255,255,255,0.06)')
    .border({ width: 0.5, color: 'rgba(255,255,255,0.08)' })
  }

  private getBarWidth(value: number): number {
    const maxVal = Math.max(this.studyMinutes, this.knowledgeCount, this.streakDays, 1);
    return Math.round((value / maxVal) * 100);
  }
}
