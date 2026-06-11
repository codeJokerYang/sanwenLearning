/**
 * StudyDocViewer - 学习文档 Markdown 渲染器
 * 支持子集：H1-H3 / 列表 / 粗体斜体 / 代码块 / 分割线
 */
@Component
export struct StudyDocViewer {
  docData: object | null = null

  @State private sections: DocSection[] = []

  aboutToAppear(): void {
    this.parseDocument()
  }

  interface DocSection {
    heading: string       // H1/H2/H3 文本
    level: number         // 1/2/3
    content: string       // 正文 Markdown
    bulletPoints?: string[]
    codeBlock?: { language: string; code: string }
  }

  /** 解析文档数据为章节列表 */
  private parseDocument(): void {
    this.sections = []
    if (!this.docData) { return }
    try {
      const data: Record<string, Object> = this.docData as Record<string, Object>
      const rawSections: Array<Record<string, Object>> =
        (data['sections'] as Array<Record<string, Object>>) ?? []

      for (const s of rawSections) {
        const section: DocSection = {
          heading: (s['heading'] as string) ?? '',
          level: this.headingLevel((s['heading'] as string) ?? ''),
          content: (s['content'] as string) ?? '',
          bulletPoints: s['bulletPoints'] as string[] ?? undefined,
          codeBlock: s['codeBlock'] as { language: string; code: string } ?? undefined
        }
        this.sections.push(section)
      }
    } catch (_e) { /* ignore */ }
  }

  /** 从 heading 文本推断级别 */
  private headingLevel(text: string): number {
    if (text.startsWith('###')) { return 3 }
    if (text.startsWith('##')) { return 2 }
    return 1
  }

  /** 清理 heading 标记符号 */
  private cleanHeading(raw: string): string {
    return raw.replace(/^#{1,3}\s*/, '')
  }

  /** 获取标题字号 */
  private headingFontSize(level: number): number {
    if (level === 1) { return 20 }
    if (level === 2) { return 17 }
    return 14
  }

  /** 获取标题颜色 */
  private headingFontColor(level: number): string {
    if (level === 1) { return '#FFFFFF' }
    if (level === 2) { return 'rgba(255,255,255,0.9)' }
    return 'rgba(255,255,255,0.75)'
  }

  build() {
    Column() {
      // 文档头部信息
      if (this.docData) {
        try {
          const data: Record<string, Object> = this.docData as Record<string, Object>
          if (data['title']) {
            Text(data['title'] as string)
              .fontSize(22).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
              .width('100%').textAlign(TextAlign.Center)
              .margin({ bottom: 4 })
          }
          if (data['subject']) {
            Text(data['subject'] as string)
              .fontSize(13).fontColor('rgba(255,255,255,0.5)')
              .width('100%').textAlign(TextAlign.Center)
              .margin({ bottom: 16 })
          }
        } catch (_e) { /* ignore */ }
      }

      // 目录导航
      if (this.sections.length > 1) {
        this.buildTocNav()
        Divider().color('rgba(255,255,255,0.08)').margin({ top: 10, bottom: 14 })
      }

      // 章节内容
      ForEach(this.sections, (section: DocSection, index: number) => {
        Column() {
          // 标题
          Text(this.cleanHeading(section.heading))
            .fontSize(this.headingFontSize(section.level))
            .fontWeight(section.level <= 2 ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(this.headingFontColor(section.level))
            .width('100%')
            .margin({ top: index > 0 ? 20 : 0, bottom: 8 })

          // 正文内容（简单文本渲染）
          if (section.content && section.content.length > 0) {
            Text(section.content)
              .fontSize(14).fontColor('rgba(255,255,255,0.78)')
              .width('100%').lineHeight(22)
              .margin({ bottom: 8 })
          }

          // 要点列表
          if (section.bulletPoints && section.bulletPoints.length > 0) {
            ForEach(section.bulletPoints, (point: string, _idx: number) => {
              Row() {
                Text('\u2022').fontSize(14).fontColor('#5C6BC0').margin({ right: 8 })
                Text(point).fontSize(14).fontColor('rgba(255,255,255,0.78)').layoutWeight(1).lineHeight(20)
              }
              .width('100%').margin({ bottom: 4 })
            }, (point: string, idx: number) => `${idx}_${point}`)
          }

          // 代码块
          if (section.codeBlock) {
            Column() {
              if (section.codeBlock.language && section.codeBlock.language.length > 0) {
                Text(section.codeBlock.language)
                  .fontSize(11).fontColor('rgba(255,255,255,0.4)')
                  .width('100%').alignSelf(ItemAlign.Start)
                  .margin({ bottom: 6 })
              }
              Text(section.codeBlock.code)
                .fontSize(12).fontColor('rgba(255,255,255,0.85)')
                .fontFamily('monospace')
                .width('100%').lineHeight(18)
                .backgroundColor('rgba(0,0,0,0.25)')
                .padding(10).borderRadius(8)
                .margin({ top: 4 })
            }.width('100%')
          }
        }
        .width('100%').alignItems(HorizontalAlign.Start)
      }, (section: DocSection, index: number) => `sec_${index}`)

      // 关键术语表
      this.buildKeyTerms()

      Blank().height(24)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 16, bottom: 8 })
  }

  /** 构建目录导航 */
  @Builder buildTocNav(): void {
    Column() {
      Text('\u{1F4CB} \u76EE\u5F55').fontSize(13).fontWeight(FontWeight.Medium)
        .fontColor('rgba(255,255,255,0.55)').width('100%').margin({ bottom: 8 })

      ForEach(this.sections.filter((s: DocSection) => s.level <= 2),
        (section: DocSection, _index: number) => {
          Row() {
            Text(this.cleanHeading(section.heading))
              .fontSize(12).fontColor('rgba(255,255,255,0.6)')
              .layoutWeight(1)
          }
          .width('100%').padding({ left: section.level > 1 ? 16 : 0, top: 3, bottom: 3 })
          .onClick(() => { /* 滚动定位 — Phase 2 实现 */ })
        },
        (section: DocSection, index: number) => `toc_${index}`)
    }
    .width('100%').backgroundColor('rgba(255,255,255,0.03)').padding(12).borderRadius(10)
  }

  /** 构建关键术语表 */
  @Builder buildKeyTerms(): void {
    if (!this.docData) { return }
    try {
      const data: Record<string, Object> = this.docData as Record<string, Object>
      const terms: Array<Record<string, Object>> =
        (data['keyTerms'] as Array<Record<string, Object>>) ?? []

      if (terms.length === 0) { return }

      Divider().color('rgba(255,255,255,0.08)').margin({ top: 16, bottom: 12 })

      Text('\u{1F4D6} \u5173\u952E\u672F\u8BED')
        .fontSize(14).fontWeight(FontWeight.Medium).fontColor('rgba(255,255,255,0.8)')
        .width('100%').margin({ bottom: 10 })

      ForEach(terms, (term: Record<string, Object>, _index: number) => {
        Row() {
          Text(term['term'] as string ?? '')
            .fontSize(13).fontWeight(FontWeight.Medium).fontColor('#B388FF')
            .width(100)
          Text(term['definition'] as string ?? '')
            .fontSize(12).fontColor('rgba(255,255,255,0.65)').layoutWeight(1).lineHeight(18)
        }
        .width('100%').alignItems(VerticalAlign.Top).padding({ top: 4, bottom: 4 })
      }, (term: Record<string, Object>, index: number) => `term_${index}`)
    } catch (_e) { /* ignore */ }
  }
}
