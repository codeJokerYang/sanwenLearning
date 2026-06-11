/**
 * StatusLayout — 通用状态布局组件
 * 封装 Loading/Empty/Error/Content 四种状态视图
 */
@Component
export struct StatusLayout {
  @Prop status: 'loading' | 'empty' | 'error' | 'content' = 'loading'
  @Prop emptyMessage: ResourceStr = ''
  @Prop emptyActionText: ResourceStr = ''
  @Prop errorMessage: ResourceStr = ''
  @Prop retryText: ResourceStr = ''
  onEmptyAction?: () => void
  onRetry?: () => void
  @BuilderParam contentSlot: () => void

  build() {
    Stack() {
      if (this.status === 'loading') {
        Column() {
          LoadingProgress()
            .width(36)
            .height(36)
            .color($r('app.color.color_primary'))
          Blank().height(12)
          Text($r('app.string.home_loading_courses'))
            .fontSize($r('app.float.font_size_body'))
            .fontColor($r('app.color.color_text_disabled'))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.status === 'empty') {
        Column() {
          Text(this.emptyMessage)
            .fontSize($r('app.float.font_size_body'))
            .fontColor($r('app.color.color_text_disabled'))
            .textAlign(TextAlign.Center)
          if (this.emptyActionText && this.onEmptyAction) {
            Blank().height(16)
            Button(this.emptyActionText)
              .fontSize($r('app.float.font_size_body'))
              .fontColor($r('app.color.color_primary'))
              .backgroundColor($r('app.color.color_bg_search'))
              .height(36)
              .padding({ left: 24, right: 24 })
              .borderRadius($r('app.float.border_radius_button'))
              .onClick(() => {
                if (this.onEmptyAction) {
                  this.onEmptyAction()
                }
              })
          }
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .padding({ left: 32, right: 32 })
      } else if (this.status === 'error') {
        Column() {
          Text(this.errorMessage)
            .fontSize($r('app.float.font_size_body'))
            .fontColor($r('app.color.color_text_secondary'))
            .textAlign(TextAlign.Center)
          if (this.retryText && this.onRetry) {
            Blank().height(16)
            Button(this.retryText)
              .fontSize($r('app.float.font_size_body'))
              .fontColor('#FFFFFF')
              .backgroundColor($r('app.color.color_primary'))
              .height(36)
              .padding({ left: 24, right: 24 })
              .borderRadius($r('app.float.border_radius_button'))
              .onClick(() => {
                if (this.onRetry) {
                  this.onRetry()
                }
              })
          }
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .padding({ left: 32, right: 32 })
      } else {
        this.contentSlot()
      }
    }
    .width('100%')
    .height('100%')
  }
}
