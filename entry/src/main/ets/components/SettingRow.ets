/**
 * SettingRow — 设置列表行组件
 * 左侧图标+标题，右侧值+箭头，可选底部分割线
 * 白色主题：深色文字 + 浅色分割线
 */
@Component
export struct SettingRow {
  @Prop icon: string = '';
  @Prop title: ResourceStr = '';
  @Prop value: ResourceStr = '';
  @Prop showDivider: boolean = true;
  onRowClick: () => void = () => {};

  build() {
    Column() {
      Row() {
        // Left: icon + title
        Text(this.icon)
          .fontSize(20)
          .margin({ right: 12 })

        Text(this.title)
          .fontSize(15)
          .fontColor('#1A1A2E')
          .layoutWeight(1)

        // Right: value + arrow
        Text(this.value)
          .fontSize(13)
          .fontColor('#7B7B94')
          .margin({ right: 6 })

        Text('\u203A')
          .fontSize(18)
          .fontColor('#C4C4D0')
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.onRowClick();
      })

      // Divider
      if (this.showDivider) {
        Divider()
          .color('#E8EAED')
          .strokeWidth(0.5)
          .margin({ left: 48, right: 16 })
      }
    }
    .accessibilityText($r('app.string.a11y_setting_theme'))
  }
}
