/**
 * 进度条子组件 — 水平进度条 + 百分比标签
 * 颜色过渡：0-33 灰色, 34-66 蓝色, 67-100 绿色
 */
@Component
export struct ProgressBar {
  @Prop progress: number = 0;
  @Prop showLabel: boolean = true;

  build() {
    Row() {
      Progress({
        value: this.progress,
        total: 100,
        type: ProgressType.Linear
      })
        .width('100%')
        .height(8)
        .style({ strokeWidth: 8 })
        .color(this.getProgressColor())
        .backgroundColor($r('app.color.color_divider'))
        .animation({ duration: 400, curve: Curve.EaseOut })

      if (this.showLabel) {
        Text(`${Math.round(this.progress)}%`)
          .fontSize($r('app.float.font_size_caption'))
          .fontColor(this.getProgressColor())
          .margin({ left: 8 })
      }
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  private getProgressColor(): ResourceColor {
    if (this.progress <= 33) {
      return $r('app.color.color_text_disabled');
    } else if (this.progress <= 66) {
      return $r('app.color.color_primary');
    } else {
      return $r('app.color.color_success');
    }
  }
}
