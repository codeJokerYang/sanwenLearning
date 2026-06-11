/**
 * DeleteConfirmDialog — 删除确认对话框
 * 从 HomePage 拆分，保持相同接口
 */
@CustomDialog
export struct DeleteConfirmDialog {
  controller: CustomDialogController;
  onConfirm?: () => void;
  onCancel?: () => void;

  build() {
    Column() {
      // Warning icon + title
      Row() {
        Stack() {
          Circle({ width: 44, height: 44 })
            .fill('#1AFF3B30')
          Text('!')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.color_danger'))
        }
        .width(44)
        .height(44)

        Blank().width(12)

        Text($r('app.string.home_delete_confirm_title'))
          .fontSize($r('app.float.font_size_subtitle'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.color_text_primary'))
          .alignSelf(ItemAlign.Center)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 12 })

      Text($r('app.string.home_delete_confirm_message'))
        .fontSize($r('app.float.font_size_body'))
        .fontColor($r('app.color.color_text_secondary'))
        .lineHeight(22)
        .margin({ bottom: 24 })

      Row() {
        Button($r('app.string.home_delete_confirm_cancel'))
          .fontSize($r('app.float.font_size_body'))
          .fontColor($r('app.color.color_text_secondary'))
          .backgroundColor($r('app.color.color_bg_search'))
          .layoutWeight(1)
          .height(44)
          .borderRadius($r('app.float.border_radius_button'))
          .onClick(() => {
            if (this.onCancel) {
              this.onCancel();
            }
            this.controller.close();
          })

        Blank().width(12)

        Button($r('app.string.home_delete_confirm_ok'))
          .fontSize($r('app.float.font_size_body'))
          .fontColor('#FFFFFF')
          .backgroundColor($r('app.color.color_danger'))
          .layoutWeight(1)
          .height(44)
          .borderRadius($r('app.float.border_radius_button'))
          .onClick(() => {
            if (this.onConfirm) {
              this.onConfirm();
            }
            this.controller.close();
          })
      }
      .width('100%')
    }
    .padding(24)
    .accessibilityText($r('app.string.a11y_delete_dialog'))
  }
}
