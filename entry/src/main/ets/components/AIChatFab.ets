/**
 * AIChatFab - 右下角悬浮 AI 对话入口按钮
 * 44vp×44vp 圆形，渐变紫色调，带活跃态指示点
 */
@Component
export struct AIChatFab {
  @Link isOpen: boolean
  @Prop hasActiveCourse: boolean = false
  onToggle: () => void = (): void => { this.isOpen = !this.isOpen }

  build() {
    Stack() {
      // 主按钮
      Button() {
        Text(this.isOpen ? '✕' : 'AI')
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .width(44)
      .height(44)
      .borderRadius(22)
      .linearGradient({
        angle: 135,
        colors: [['#7C8CFF', 0], ['#5C6BC0', 1]]
      })
      .shadow({ radius: 8, color: 'rgba(124,140,255,0.35)', offsetY: 2 })
      .onClick(() => {
        this.onToggle()
      })

      // 活跃态指示点（有课程时显示）
      if (this.hasActiveCourse && !this.isOpen) {
        Circle()
          .width(8)
          .height(8)
          .fill('#4CAF50')
          .position({ x: 34, y: 2 })
      }
    }
    .width(44)
    .height(44)
    .accessibilityText('AI对话按钮')
    .accessibilityDescription('点击打开AI学习伙伴对话面板')
  }
}
