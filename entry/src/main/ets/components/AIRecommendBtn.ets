/**
 * AI 推荐提问按钮 — 仅在知识库非空时显示
 * 加载中显示 spinner，无内容时完全隐藏
 */
@Component
export struct AIRecommendBtn {
  @Prop hasContent: boolean = false;
  @Prop isLoading: boolean = false;
  onRequestRecommend?: () => void;

  build() {
    if (this.hasContent) {
      Button() {
        Row() {
          if (this.isLoading) {
            LoadingProgress()
              .width(16)
              .height(16)
              .color('#FFFFFF')
              .margin({ right: 6 })
          }

          Text($r('app.string.ai_recommend_btn'))
            .fontSize($r('app.float.font_size_body'))
            .fontColor('#FFFFFF')
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .type(ButtonType.Capsule)
      .backgroundColor($r('app.color.color_purple'))
      .padding({ left: 20, right: 20, top: 8, bottom: 8 })
      .borderRadius($r('app.float.border_radius_capsule'))
      .shadow({ radius: 6, color: '#305856D6', offsetX: 0, offsetY: 3 })
      .enabled(!this.isLoading)
      .onClick(() => {
        if (!this.isLoading && this.onRequestRecommend) {
          this.onRequestRecommend();
        }
      })
      .accessibilityText($r('app.string.ai_recommend_accessibility'))
      .accessibilityDescription($r('app.string.ai_recommend_description'))
    }
  }
}
