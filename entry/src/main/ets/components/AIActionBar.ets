/**
 * AIActionBar - AI 功能模式切换栏
 * 提供 chat / retrieve / mindmap / studydoc / framework 五种模式切换
 */
@Component
export struct AIActionBar {
  @Prop currentMode: string = 'chat'
  private onModeChange: (mode: string) => void = (_mode: string) => {}

  private readonly modes: ModeItem[] = [
    { key: 'chat', label: '对话' },
    { key: 'retrieve', label: '检索' },
    { key: 'mindmap', label: '导图' },
    { key: 'studydoc', label: '文档' },
    { key: 'framework', label: '框架' }
  ]

  build() {
    Row() {
      ForEach(this.modes, (item: ModeItem) => {
        Button(item.label)
          .fontSize(12)
          .fontColor(this.currentMode === item.key ? Color.White : 'rgba(255,255,255,0.5)')
          .backgroundColor(this.currentMode === item.key ? 'rgba(124,140,255,0.35)' : Color.Transparent)
          .borderRadius(14)
          .height(28)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.onModeChange(item.key)
          })
      }, (item: ModeItem) => item.key)
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
    .justifyContent(FlexAlign.Start)
  }
}

interface ModeItem {
  key: string
  label: string
}
