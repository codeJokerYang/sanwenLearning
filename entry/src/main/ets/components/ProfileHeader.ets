/**
 * ProfileHeader — 个人中心头部组件
 * 主色渐变背景 + 头像 + 用户名 + 简介
 */
@Component
export struct ProfileHeader {
  @Prop userName: string = '';
  @Prop userBio: string = '';
  onAvatarClick: () => void = () => {};

  build() {
    Column() {
      // Avatar circle
      Stack() {
        Circle({ width: 80, height: 80 })
          .fill('rgba(255,255,255,0.2)')
          .stroke('rgba(255,255,255,0.4)')
          .strokeWidth(1.5)
        Text('\u{1F464}')
          .fontSize(36)
      }
      .width(80)
      .height(80)
      .margin({ top: 8 })

      Blank().height(12)

      // Username
      Text(this.userName)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Blank().height(4)

      // Bio
      Text(this.userBio)
        .fontSize(13)
        .fontColor('rgba(255,255,255,0.8)')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding({ top: 24, bottom: 16, left: 16, right: 16 })
    .alignItems(HorizontalAlign.Center)
    .linearGradient({
      angle: 135,
      colors: [
        ['#5C6BC0', 0],
        ['#3949AB', 1]
      ]
    })
    .borderRadius({ bottomLeft: 24, bottomRight: 24 })
    .shadow({
      radius: 12,
      color: 'rgba(92, 107, 192, 0.2)',
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      this.onAvatarClick();
    })
    .accessibilityText($r('app.string.a11y_profile_avatar'))
    .accessibilityDescription($r('app.string.a11y_profile_avatar'))
  }
}
