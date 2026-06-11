/**
 * DiscoverSection — 发现与推荐区域
 * 横向滚动模板列表 + AI 学习路径推荐卡片
 */
interface TemplateData {
  title: string;
  desc: string;
  color: string;
}

@Component
export struct DiscoverSection {
  @State templates: TemplateData[] = [];
  onUseTemplate: (title: string) => void = () => {};
  onStartPath: () => void = () => {};

  aboutToAppear(): void {
    this.templates = [
      { title: '\u91CF\u5B50\u529B\u5B66\u57FA\u7840', desc: '\u4ECE\u6CE2\u7C92\u4E8C\u8C61\u6027\u5230\u91CF\u5B50\u7EA0\u7F20', color: '#5C6BC0' },
      { title: '\u4E2D\u56FD\u53E4\u4EE3\u53F2\u5165\u95E8', desc: '\u4ECE\u5148\u79E6\u5230\u660E\u6E05\u7684\u6587\u660E\u8109\u7EDC', color: '#7B1FA2' },
      { title: 'Python \u7F16\u7A0B\u5165\u95E8', desc: '\u4ECE\u53D8\u91CF\u5230\u9762\u5411\u5BF9\u8C61', color: '#00897B' },
    ];
  }

  build() {
    Column() {
      Row() {
        Text('\u{1F525}').fontSize(16)
        Blank().width(6)
        Text($r('app.string.home_discover_title')).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
      }
      Blank().height(12)
      List({ space: 10 }) {
        ForEach(this.templates, (item: TemplateData, index: number) => {
          ListItem() {
            Column() {
              Row().width('100%').height(40).borderRadius({ topLeft: 8, topRight: 8 })
                .backgroundColor(item.color).opacity(0.15)
              Blank().height(8)
              Text(item.title).fontSize(13).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
                .maxLines(1).padding({ left: 8, right: 8 })
              Blank().height(4)
              Text(item.desc).fontSize(10).fontColor('rgba(255,255,255,0.5)')
                .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).padding({ left: 8, right: 8 })
              Blank().height(8)
              Button($r('app.string.home_template_use')).fontSize(10).fontColor('#B8BFFF')
                .height(24).borderRadius(12).backgroundColor('rgba(92,107,192,0.2)')
                .onClick(() => this.onUseTemplate(item.title))
            }.width(140).height(130).borderRadius(8)
            .backgroundColor('rgba(255,255,255,0.04)').border({ width: 0.5, color: 'rgba(255,255,255,0.06)' })
          }
        }, (item: TemplateData, index: number) => `tpl_${index}`)
      }.listDirection(Axis.Horizontal).width('100%').height(140).scrollBar(BarState.Off)
      Blank().height(12)
      Row() {
        Text('\u{1F9ED}').fontSize(22)
        Blank().width(10)
        Column() {
          Text($r('app.string.home_path_title')).fontSize(13).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
          Text($r('app.string.home_path_desc')).fontSize(10).fontColor('rgba(255,255,255,0.5)')
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        }.alignItems(HorizontalAlign.Start).layoutWeight(1)
        Button($r('app.string.home_path_start')).fontSize(11).fontColor('#FFFFFF')
          .height(28).borderRadius(14).backgroundColor('#5C6BC0')
          .onClick(() => this.onStartPath()).accessibilityText($r('app.string.home_path_start'))
      }.width('100%').padding(12).borderRadius(12)
      .backgroundColor('rgba(255,255,255,0.06)').border({ width: 0.5, color: 'rgba(255,255,255,0.08)' })
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
