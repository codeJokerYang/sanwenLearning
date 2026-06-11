/**
 * ContentPreviewCard - AI 生成内容预览卡片
 * 展示思维导图/学习文档/知识框架/知识摘要的结构化内容
 */
@Component
export struct ContentPreviewCard {
  @Prop contentType: string = 'knowledge'
  @Prop contentData: object | null = null
  @Prop isExpanded: boolean = false
  private onToggleExpand: () => void = () => {}
  private onRegenerate: () => void = () => {}
  private onSaveToMaterial: () => void = () => {}
  private onContinueChat: () => void = () => {}

  build() {
    Column() {
      // 标题行
      Row() {
        Text(this.getTypeLabel())
          .fontSize(13)
          .fontColor('#7C8CFF')
          .fontWeight(FontWeight.Medium)

        Blank()

        // 展开/收起
        Text(this.isExpanded ? '收起' : '展开')
          .fontSize(11)
          .fontColor('rgba(255,255,255,0.5)')
          .onClick(() => {
            this.onToggleExpand()
          })
      }
      .width('100%')
      .margin({ bottom: 6 })

      // 内容摘要
      if (this.contentData) {
        Text(this.extractSummary())
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.65)')
          .lineHeight(18)
          .maxLines(this.isExpanded ? 20 : 3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ bottom: 8 })
      }

      // 操作按钮行
      Row() {
        Button('重新生成')
          .fontSize(11)
          .fontColor('#7C8CFF')
          .backgroundColor('rgba(124,140,255,0.10)')
          .borderRadius(10)
          .height(26)
          .padding({ left: 10, right: 10 })
          .onClick(() => {
            this.onRegenerate()
          })

        Button('保存')
          .fontSize(11)
          .fontColor('#4CAF50')
          .backgroundColor('rgba(76,175,80,0.10)')
          .borderRadius(10)
          .height(26)
          .padding({ left: 10, right: 10 })
          .onClick(() => {
            this.onSaveToMaterial()
          })

        Button('继续对话')
          .fontSize(11)
          .fontColor('rgba(255,255,255,0.6)')
          .backgroundColor('rgba(255,255,255,0.06)')
          .borderRadius(10)
          .height(26)
          .padding({ left: 10, right: 10 })
          .onClick(() => {
            this.onContinueChat()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .padding(10)
    .borderRadius(10)
    .backgroundColor('rgba(124,140,255,0.06)')
    .border({ width: 0.5, color: 'rgba(124,140,255,0.20)' })
  }

  private getTypeLabel(): string {
    const labels: Record<string, string> = {
      'mindmap': '思维导图',
      'studydoc': '学习文档',
      'framework': '知识框架',
      'knowledge': '知识摘要'
    }
    return labels[this.contentType] ?? 'AI 内容'
  }

  private extractSummary(): string {
    if (!this.contentData) {
      return ''
    }
    try {
      const data = this.contentData as Record<string, Object>
      // 尝试提取常见字段
      const summary = data['summary'] as string | undefined
      if (summary) return summary
      const title = data['title'] as string | undefined
      if (title) return title
      const content = data['content'] as string | undefined
      if (content) return content.substring(0, 200)
      return JSON.stringify(data).substring(0, 200)
    } catch (_e) {
      return ''
    }
  }
}
