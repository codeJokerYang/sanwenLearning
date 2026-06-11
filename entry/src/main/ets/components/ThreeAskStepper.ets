/**
 * 三问步骤指示器 — 宇宙风格三阶段导航
 * Q1(是什么) → Q2(为什么) → Q3(怎么用)
 * 当前步骤高亮发光，已完成显示勾号，未激活暗淡
 */
@Component
export struct ThreeAskStepper {
  @Prop currentStep: number = 1;
  @Prop q1Completed: boolean = false;
  @Prop q2Completed: boolean = false;
  @Prop q3Completed: boolean = false;
  @Prop isDarkMode: boolean = true;

  build() {
    Row() {
      StepItem({
        label: $r('app.string.three_ask_q1'),
        subLabel: '是什么',
        icon: '\u{1F4DD}',
        stepIndex: 1,
        currentStep: this.currentStep,
        isCompleted: this.q1Completed,
        isDarkMode: this.isDarkMode
      })

      ConnectorLine({ isActive: this.currentStep > 1 || this.q1Completed, isDarkMode: this.isDarkMode })

      StepItem({
        label: $r('app.string.three_ask_q2'),
        subLabel: '为什么',
        icon: '\u{1F50D}',
        stepIndex: 2,
        currentStep: this.currentStep,
        isCompleted: this.q2Completed,
        isDarkMode: this.isDarkMode
      })

      ConnectorLine({ isActive: this.currentStep > 2 || this.q2Completed, isDarkMode: this.isDarkMode })

      StepItem({
        label: $r('app.string.three_ask_q3'),
        subLabel: '怎么用',
        icon: '\u{1F680}',
        stepIndex: 3,
        currentStep: this.currentStep,
        isCompleted: this.q3Completed,
        isDarkMode: this.isDarkMode
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(VerticalAlign.Center)
    .padding({ top: 14, bottom: 12 })
  }
}

@Component
struct StepItem {
  @Prop label: ResourceStr;
  @Prop subLabel: string = '';
  @Prop icon: string = '';
  @Prop stepIndex: number;
  @Prop currentStep: number;
  @Prop isCompleted: boolean;
  @Prop isDarkMode: boolean;

  build() {
    Column() {
      // Step circle with glow for active step
      Stack() {
        if (this.stepIndex === this.currentStep && !this.isCompleted) {
          // Glow ring behind active step
          Circle({ width: 44, height: 44 })
            .fill(this.isDarkMode ? 'rgba(92,107,192,0.25)' : 'rgba(63,81,181,0.15)')
            .scale({ x: 1.25, y: 1.25 })
        }

        Circle({ width: 36, height: 36 })
          .fill(this.getStepBgColor())
          .border({ width: this.stepIndex === this.currentStep && !this.isCompleted ? 2 : 0,
                    color: this.isDarkMode ? '#7C8CFF' : '#5C6BC0' })

        if (this.isCompleted) {
          Text('\u2713')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        } else {
          Text(`${this.stepIndex}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getStepTextColor())
        }
      }
      .width(36).height(36)

      Blank().height(5)

      Text(this.subLabel)
        .fontSize(11)
        .fontWeight(this.stepIndex === this.currentStep ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.getLabelColor())

      Text(this.label)
        .fontSize(9)
        .fontColor(this.getSubLabelColor())
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 1 })
    }
    .alignItems(HorizontalAlign.Center)
    .opacity(this.stepIndex > this.currentStep && !this.isCompleted ? 0.35 : 1.0)
    .animation({ duration: 300, curve: Curve.EaseOut })
    .accessibilityText(this.getAccessibilityLabel())
  }

  private getStepBgColor(): ResourceColor | string {
    if (this.isCompleted) {
      return '#43A047';
    }
    if (this.stepIndex === this.currentStep) {
      return this.isDarkMode ? '#3949AB' : '#5C6BC0';
    }
    return this.isDarkMode ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.06)';
  }

  private getStepTextColor(): ResourceColor | string {
    if (this.stepIndex === this.currentStep) {
      return '#FFFFFF';
    }
    return this.isDarkMode ? 'rgba(255,255,255,0.45)' : 'rgba(0,0,0,0.35)';
  }

  private getLabelColor(): ResourceColor | string {
    if (this.stepIndex === this.currentStep) {
      return this.isDarkMode ? '#B8BFFF' : '#5C6BC0';
    }
    if (this.isCompleted) {
      return '#66BB6A';
    }
    return this.isDarkMode ? 'rgba(255,255,255,0.35)' : 'rgba(0,0,0,0.30)';
  }

  private getSubLabelColor(): ResourceColor | string {
    return this.isDarkMode ? 'rgba(255,255,255,0.22)' : 'rgba(0,0,0,0.25)';
  }

  private getAccessibilityLabel(): string {
    if (this.isCompleted) {
      return `${this.label}, ${$r('app.string.step_completed')}`;
    }
    if (this.stepIndex === this.currentStep) {
      return `${this.label}, ${$r('app.string.step_current')}`;
    }
    return `${this.label}, ${$r('app.string.step_pending')}`;
  }
}

@Component
struct ConnectorLine {
  @Prop isActive: boolean = false;
  @Prop isDarkMode: boolean = true;

  build() {
    Row()
      .width(28)
      .height(2)
      .borderRadius(1)
      .backgroundColor(this.isActive
        ? (this.isDarkMode ? '#5C6BC0' : '#7986CB')
        : (this.isDarkMode ? 'rgba(255,255,255,0.10)' : 'rgba(0,0,0,0.10)'))
      .animation({ duration: 300, curve: Curve.EaseOut })
  }
}
