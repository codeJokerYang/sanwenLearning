/**
 * GreetingHeader — 时间感知问候头部组件
 * 根据当前时段显示不同问候语与图标
 */
@Component
export struct GreetingHeader {
  @Prop userName: string = '';
  @Prop currentHour: number = 12;

  build() {
    Row() {
      Column() {
        Text(this.getGreeting())
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')

        Blank().height(4)

        Text(this.userName || $r('app.string.profile_default_name'))
          .fontSize(16)
          .fontColor('rgba(255,255,255,0.6)')

        Blank().height(2)

        Text(this.getDateString())
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.35)')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(this.getTimeIcon())
        .fontSize(32)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 24 })
    .alignItems(VerticalAlign.Center)
    .accessibilityText($r('app.string.a11y_home_greeting'))
  }

  private getGreeting(): ResourceStr {
    if (this.currentHour >= 6 && this.currentHour <= 11) {
      return $r('app.string.home_greeting_morning');
    } else if (this.currentHour >= 12 && this.currentHour <= 14) {
      return $r('app.string.home_greeting_noon');
    } else if (this.currentHour >= 15 && this.currentHour <= 18) {
      return $r('app.string.home_greeting_afternoon');
    } else if (this.currentHour >= 19 && this.currentHour <= 23) {
      return $r('app.string.home_greeting_evening');
    } else {
      return $r('app.string.home_greeting_night');
    }
  }

  private getTimeIcon(): string {
    if (this.currentHour >= 6 && this.currentHour <= 17) {
      return '\u2600\uFE0F';
    } else if (this.currentHour >= 18 && this.currentHour <= 20) {
      return '\u26C5';
    } else {
      return '\u{1F319}';
    }
  }

  private getDateString(): string {
    const now = new Date();
    const month = now.getMonth() + 1;
    const day = now.getDate();
    return `${month < 10 ? '0' + month : month}/${day < 10 ? '0' + day : day}`;
  }
}
