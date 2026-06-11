/**
 * CreateCourseDialog — 创建课程对话框
 * 从 HomePage 拆分，保持相同接口
 */
@CustomDialog
export struct CreateCourseDialog {
  controller: CustomDialogController;
  @State title: string = '';
  onTitleChange?: (value: string) => void;
  onConfirm?: () => void;
  onCancel?: () => void;

  build() {
    Column() {
      // Icon + Title row
      Row() {
        Stack() {
          Circle({ width: 44, height: 44 })
            .fill('#1A007AFF')
          Text('?')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.color_primary'))
        }
        .width(44)
        .height(44)

        Blank().width(12)

        Column() {
          Text($r('app.string.home_new_course_title'))
            .fontSize($r('app.float.font_size_subtitle'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.color_text_primary'))
          Text('输入你想学习的主题，开启三问探索之旅')
            .fontSize($r('app.float.font_size_caption'))
            .fontColor($r('app.color.color_text_disabled'))
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Blank().height(20)

      // Input field
      TextInput({ text: this.title, placeholder: $r('app.string.home_new_course_placeholder') })
        .onChange((value: string) => {
          this.title = value;
          if (this.onTitleChange) {
            this.onTitleChange(value);
          }
        })
        .width('100%')
        .height(48)
        .fontSize($r('app.float.font_size_body'))
        .padding({ left: 16, right: 16 })
        .borderRadius($r('app.float.border_radius_button'))
        .backgroundColor($r('app.color.color_bg_input'))
        .border({ width: 1, color: $r('app.color.color_divider') })
        .margin({ bottom: 8 })

      // Hint text below input
      Text('例如：量子力学基础、中国古代史、Python入门')
        .fontSize($r('app.float.font_size_micro'))
        .fontColor($r('app.color.color_text_disabled'))
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ bottom: 20 })

      // Buttons
      Row() {
        Button($r('app.string.home_new_course_cancel'))
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

        Button($r('app.string.home_new_course_create'))
          .fontSize($r('app.float.font_size_body'))
          .fontColor('#FFFFFF')
          .backgroundColor(this.title.trim().length > 0 ? $r('app.color.color_primary') : $r('app.color.color_text_disabled'))
          .layoutWeight(1)
          .height(44)
          .borderRadius($r('app.float.border_radius_button'))
          .enabled(this.title.trim().length > 0)
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
    .accessibilityText($r('app.string.a11y_create_dialog'))
  }
}
