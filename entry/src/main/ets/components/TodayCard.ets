/**
 * TodayCard — 今日学习进度卡片
 * Canvas 环形进度 + 三问步骤指示 + CTA 按钮
 */
@Component
export struct TodayCard {
  @Prop courseTitle: string = '';
  @Prop progress: number = 0;
  @Prop currentStep: number = 0;
  @Prop hasActiveCourse: boolean = false;
  onContinue: () => void = () => {};
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  build() {
    Row() {
      Canvas(this.context).width(100).height(100).onReady(() => { this.drawRing(); })
      Blank().width(16)
      Column() {
        Text(this.hasActiveCourse ? this.courseTitle : $r('app.string.home_no_active_course'))
          .fontSize(15).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
          .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
        Blank().height(10)
        Row() {
          this.StepDot('Q1', this.stepState(1))
          this.StepDot('Q2', this.stepState(2))
          this.StepDot('Q3', this.stepState(3))
        }.width('100%').justifyContent(FlexAlign.Start)
        Blank().height(12)
        Button(this.hasActiveCourse ? $r('app.string.home_continue_learning') : $r('app.string.home_start_explore'))
          .fontSize(13).fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
          .height(36).borderRadius(18)
          .linearGradient({ angle: 90, colors: [['#5C6BC0', 0], ['#3949AB', 1]] })
          .onClick(() => this.onContinue())
          .accessibilityText($r('app.string.a11y_home_continue_learning'))
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
    }.width('100%').padding(16).borderRadius(16)
    .backgroundColor('rgba(255,255,255,0.06)').border({ width: 0.5, color: 'rgba(255,255,255,0.08)' })
  }

  @Builder StepDot(label: string, state: number) {
    Row() {
      Circle({ width: 20, height: 20 })
        .fill(state === 0 ? '#43A047' : state === 1 ? '#5C6BC0' : 'transparent')
        .stroke(state === 2 ? 'rgba(255,255,255,0.2)' : Color.Transparent).strokeWidth(1.5)
      Text(label).fontSize(9)
        .fontColor(state === 0 ? 'rgba(255,255,255,0.85)' : state === 1 ? '#B8BFFF' : 'rgba(255,255,255,0.3)')
        .margin({ left: 4 })
    }.margin({ right: 14 })
  }

  private stepState(step: number): number {
    if (step < this.currentStep) return 0;
    if (step === this.currentStep) return 1;
    return 2;
  }

  private drawRing(): void {
    const ctx = this.context;
    const cx = 50; const cy = 50; const r = 38;
    ctx.beginPath(); ctx.arc(cx, cy, r, 0, Math.PI * 2);
    ctx.strokeStyle = 'rgba(255,255,255,0.08)'; ctx.lineWidth = 8; ctx.lineCap = 'round'; ctx.stroke();
    const start = -Math.PI / 2;
    const sweep = (this.progress / 100) * Math.PI * 2;
    ctx.beginPath(); ctx.arc(cx, cy, r, start, start + sweep);
    ctx.strokeStyle = '#5C6BC0'; ctx.lineWidth = 8; ctx.lineCap = 'round'; ctx.stroke();
    ctx.fillStyle = '#FFFFFF'; ctx.font = 'bold 24px sans-serif';
    ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
    ctx.fillText(`${Math.round(this.progress)}`, cx, cy - 6);
    ctx.font = '10px sans-serif'; ctx.fillStyle = 'rgba(255,255,255,0.5)';
    ctx.fillText('\u4ECA\u65E5\u8FDB\u5EA6', cx, cy + 14);
  }
}
