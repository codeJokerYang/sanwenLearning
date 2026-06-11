/**
 * DailyQuestion — AI 每日一问卡片
 * 展示问题、来源课程、难度标识，提供思考与换题操作
 */
@Component
export struct DailyQuestion {
  @Prop question: string = '';
  @Prop sourceCourse: string = '';
  @Prop difficulty: string = 'medium';
  onThink: () => void = () => {};
  onChange: () => void = () => {};

  private getDiffColor(): string {
    if (this.difficulty === 'easy') return '#4CAF50';
    if (this.difficulty === 'hard') return '#FF9800';
    return '#FFC107';
  }

  build() {
    Column() {
      Row() {
        Text('\u{1F4A1}').fontSize(18)
        Blank().width(6)
        Text($r('app.string.home_daily_question')).fontSize(15).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
      }
      Blank().height(10)
      Text(this.question).fontSize(15).fontColor('rgba(255,255,255,0.85)')
        .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
      Blank().height(10)
      Row() {
        if (this.sourceCourse) {
          Text(this.sourceCourse).fontSize(10).fontColor('rgba(124,77,255,0.9)')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 }).borderRadius(10)
            .backgroundColor('rgba(124,77,255,0.12)')
        }
        Blank().width(8)
        Circle({ width: 8, height: 8 }).fill(this.getDiffColor())
        Blank().layoutWeight(1)
      }.width('100%')
      Blank().height(14)
      Row() {
        Button($r('app.string.home_start_thinking'))
          .fontSize(13).fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
          .height(36).borderRadius(18).layoutWeight(1)
          .linearGradient({ angle: 90, colors: [['#5C6BC0', 0], ['#3949AB', 1]] })
          .onClick(() => this.onThink())
        Blank().width(10)
        Button($r('app.string.home_change_question'))
          .fontSize(13).fontColor('rgba(255,255,255,0.6)')
          .height(36).borderRadius(18).backgroundColor('rgba(255,255,255,0.08)')
          .onClick(() => this.onChange())
      }.width('100%')
    }.width('100%').padding(16).borderRadius(16)
    .backgroundColor('rgba(255,255,255,0.06)').border({ width: 0.5, color: 'rgba(255,255,255,0.08)' })
    .accessibilityText($r('app.string.a11y_home_daily_question'))
  }
}
