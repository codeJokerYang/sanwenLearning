/**
 * AI 对话气泡组件 — 展示流式文本 + 输入光标
 * isStreaming 为 true 时显示闪烁光标
 */
@Component
export struct ChatBubble {
  @Prop text: string = '';
  @Prop isStreaming: boolean = false;
  @State private cursorVisible: boolean = true;
  private blinkTimerId: number = -1;

  aboutToAppear(): void {
    if (this.isStreaming) {
      this.startCursorBlink();
    }
  }

  aboutToDisappear(): void {
    this.cursorVisible = false;
    if (this.blinkTimerId !== -1) {
      clearTimeout(this.blinkTimerId);
      this.blinkTimerId = -1;
    }
  }

  build() {
    Row() {
      Column() {
        Row() {
          Text(this.text)
            .fontSize(14)
            .fontColor('rgba(255,255,255,0.80)')
            .lineHeight(21)
            .textAlign(TextAlign.Start)

          if (this.isStreaming && this.cursorVisible) {
            Text('|')
              .fontSize(14)
              .fontColor('#7C8CFF')
              .animation({ duration: 200, curve: Curve.Linear })
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }
      .padding(12)
      .borderRadius({ topLeft: 4, topRight: 14, bottomLeft: 14, bottomRight: 14 })
      .backgroundColor('rgba(92,107,192,0.10)')
      .border({ width: 0.5, color: 'rgba(124,140,255,0.15)' })
      .constraintSize({ maxWidth: '85%' })
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .padding({ left: 12, right: 12, top: 4, bottom: 4 })
    .accessibilityText(`${$r('app.string.ai_message_prefix')}${this.text}`)
    .accessibilityDescription($r('app.string.ai_message_description'))
  }

  private startCursorBlink(): void {
    if (!this.isStreaming) {
      return;
    }
    this.cursorVisible = !this.cursorVisible;
    this.blinkTimerId = setTimeout(() => {
      this.startCursorBlink();
    }, 500);
  }
}
