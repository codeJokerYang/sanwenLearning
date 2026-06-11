/**
 * PuzzleFragmentAnim — 知识节点拼图碎片动画
 * 三问第一问：点击碎片→点亮动画→完成状态
 * 架构：交互回调组件，严禁导入 Services/RdbHelper
 * 动画限制：max 5 simultaneous animations (per PERFORMANCE_CONVENTIONS)
 */
@Component
export struct PuzzleFragmentAnim {
  @Prop nodeLabel: string = '';
  @Prop isActivated: boolean = false;
  @State animState: 'fragment' | 'animating' | 'lit' = 'fragment';
  @State private animOpacity: number = 1.0;
  @State private animScale: number = 1.0;
  @State private showFragment: boolean = true;
  onActivate?: () => void;
  onAnimComplete?: () => void;

  aboutToAppear(): void {
    if (this.isActivated) {
      this.animState = 'lit';
      this.showFragment = false;
    } else {
      this.animState = 'fragment';
      this.showFragment = true;
    }
  }

  build() {
    Stack() {
      // Fragment state: puzzle piece stylized card
      if (this.showFragment) {
        Column() {
          Text(this.nodeLabel)
            .fontSize($r('app.float.font_size_body'))
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width(80)
        .height(80)
        .borderRadius($r('app.float.border_radius_card'))
        .backgroundColor($r('app.color.color_purple'))
        .shadow({ radius: 6, color: 'rgba(124, 77, 255, 0.3)', offsetY: 3 })
        .opacity(this.showFragment ? 1 : 0)
        .scale({ x: this.animScale, y: this.animScale })
        .onClick(() => {
          if (this.animState !== 'fragment') {
            return;
          }
          this.playActivationAnimation();
        })
        .accessibilityText(this.getFragmentAccessibilityText())
      }

      // Lit state: solid colored circle with checkmark
      if (this.animState === 'lit') {
        Column() {
          Text('\u2713')
            .fontSize(24)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .width(80)
        .height(80)
        .borderRadius(40)
        .backgroundColor($r('app.color.color_fragment_selected'))
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .opacity(this.showFragment ? 0 : 1)
        .scale({ x: this.animScale, y: this.animScale })
        .accessibilityText(this.getLitAccessibilityText())
      }
    }
    .width(88)
    .height(88)
    .alignContent(Alignment.Center)
  }

  /**
   * Play the fragment-to-lit transition animation
   * animateTo: 500ms duration, easeInOut curve
   */
  private playActivationAnimation(): void {
    this.animState = 'animating';

    animateTo({
      duration: 500,
      curve: Curve.EaseInOut,
      onFinish: () => {
        this.animState = 'lit';
        this.showFragment = false;
        this.animOpacity = 1.0;
        this.animScale = 1.0;
        if (this.onAnimComplete) {
          this.onAnimComplete();
        }
      }
    }, () => {
      this.animOpacity = 0;
      this.animScale = 0.1;
    });

    if (this.onActivate) {
      this.onActivate();
    }
  }

  /**
   * Computed accessibility text — fragment state
   */
  private getFragmentAccessibilityText(): string {
    if (this.isActivated) {
      return getContext(this).resourceManager.getStringByNameSync('puzzle_fragment_accessibility')
        .replace('%s', this.nodeLabel);
    }
    return getContext(this).resourceManager.getStringByNameSync('puzzle_fragment_accessibility_tap')
      .replace('%s', this.nodeLabel);
  }

  /**
   * Computed accessibility text — lit state
   */
  private getLitAccessibilityText(): string {
    return getContext(this).resourceManager.getStringByNameSync('puzzle_lit_accessibility')
      .replace('%s', this.nodeLabel);
  }
}
