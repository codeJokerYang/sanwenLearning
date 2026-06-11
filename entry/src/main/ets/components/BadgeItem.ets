/**
 * BadgeItem — 成就勋章项组件
 * 圆形图标 + 名称 + 描述，区分已解锁/未解锁状态
 * 白色主题：浅色背景 + 深色文字
 */
@Component
export struct BadgeItem {
  @Prop icon: string = '';
  @Prop name: ResourceStr = '';
  @Prop desc: ResourceStr = '';
  @Prop unlocked: boolean = false;
  @Prop marginL: number = 0;

  build() {
    Column() {
      // Icon circle
      Stack() {
        Circle({ width: 44, height: 44 })
          .fill(this.unlocked ? 'rgba(92,107,192,0.12)' : '#F0F2F8')
        Text(this.icon)
          .fontSize(22)
      }
      .width(44)
      .height(44)

      Blank().height(6)

      // Name
      Text(this.name)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.unlocked ? '#1A1A2E' : '#C4C4D0')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Blank().height(2)

      // Description
      Text(this.desc)
        .fontSize(9)
        .fontColor('#7B7B94')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .alignItems(HorizontalAlign.Center)
    .margin({ left: this.marginL })
    .accessibilityText(this.unlocked
      ? `${this.name} 已解锁`
      : `${this.name} 未解锁`)
  }
}
