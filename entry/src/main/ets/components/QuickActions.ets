/**
 * QuickActions — 四宫格快捷操作按钮
 * 新建课程 / 上传资料 / 开始测评 / 查看报告
 */
@Component
export struct QuickActions {
  onNewCourse: () => void = () => {};
  onUpload: () => void = () => {};
  onAssess: () => void = () => {};
  onReport: () => void = () => {};

  build() {
    Row() {
      // New Course
      Column() {
        Text('\u{1F3AF}').fontSize(24)
        Blank().height(6)
        Text('\u65B0\u5EFA\u8BFE\u7A0B').fontSize(11).fontColor('rgba(255,255,255,0.6)')
      }
      .layoutWeight(1).height(80).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
      .borderRadius(12).onClick(() => this.onNewCourse())
      .accessibilityText('\u65B0\u5EFA\u8BFE\u7A0B\u5FEB\u6377\u6309\u94AE')

      // Upload
      Column() {
        Text('\u{1F4C1}').fontSize(24)
        Blank().height(6)
        Text('\u4E0A\u4F20\u8D44\u6599').fontSize(11).fontColor('rgba(255,255,255,0.6)')
      }
      .layoutWeight(1).height(80).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
      .borderRadius(12).onClick(() => this.onUpload())
      .accessibilityText('\u4E0A\u4F20\u8D44\u6599\u5FEB\u6377\u6309\u94AE')

      // Assess
      Column() {
        Text('\u{1F4CA}').fontSize(24)
        Blank().height(6)
        Text('\u5F00\u59CB\u6D4B\u8BC4').fontSize(11).fontColor('rgba(255,255,255,0.6)')
      }
      .layoutWeight(1).height(80).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
      .borderRadius(12).onClick(() => this.onAssess())
      .accessibilityText('\u5F00\u59CB\u6D4B\u8BC4\u5FEB\u6377\u6309\u94AE')

      // Report
      Column() {
        Text('\u{1F4CB}').fontSize(24)
        Blank().height(6)
        Text('\u67E5\u770B\u62A5\u544A').fontSize(11).fontColor('rgba(255,255,255,0.6)')
      }
      .layoutWeight(1).height(80).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
      .borderRadius(12).onClick(() => this.onReport())
      .accessibilityText('\u67E5\u770B\u62A5\u544A\u5FEB\u6377\u6309\u94AE')
    }
    .width('100%').padding(12).borderRadius(16)
    .backgroundColor('rgba(255,255,255,0.06)')
    .border({ width: 0.5, color: 'rgba(255,255,255,0.08)' })
  }
}
