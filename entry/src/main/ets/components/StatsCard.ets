/**
 * StatsCard — 统计数据卡片组件
 * 白色卡片 + 阴影 + 深色文字
 */
@Component
export struct StatsCard {
  @Prop icon: string = '';
  @Prop value: string = '0';
  @Prop label: ResourceStr = '';

  build() {
    Column() {
      // Icon
      Text(this.icon)
        .fontSize(20)

      Blank().height(6)

      // Value
      Text(this.value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A2E')

      Blank().height(2)

      // Label
      Text(this.label)
        .fontSize(10)
        .fontColor('#7B7B94')
    }
    .layoutWeight(1)
    .padding(12)
    .borderRadius(16)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFF')
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.04)',
      offsetX: 0,
      offsetY: 2
    })
    .shadow({
      radius: 16,
      color: 'rgba(0, 0, 0, 0.02)',
      offsetX: 0,
      offsetY: 4
    })
  }
}
