/**
 * CourseTitleBar - 学习界面顶部课程标题栏
 * 显示当前课程名称 + 三问步骤指示器
 */
@Component
export struct CourseTitleBar {
  /** 课程名称 */
  @Prop courseName: string = ''
  /** 当前三问阶段 (1=是什么, 2=为什么, 3=怎么用) */
  @Prop currentStep: number = 1
  /** 设置按钮回调 */
  onSettingClick?: () => void

  /** 步骤标签 */
  private readonly stepLabels: string[] = ['是什么', '为什么', '怎么用']

  build() {
    Column() {
      // 标题行：课程名 + 操作按钮
      Row() {
        Text(this.courseName)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
          .accessibilityText(`当前课程: ${this.courseName}`)

        if (this.onSettingClick) {
          Button({ type: ButtonType.Circle }) {
            Text('\u2699')  // ⚙
              .fontSize(20)
              .fontColor('rgba(255,255,255,0.7)')
          }
          .width(36)
          .height(36)
          .backgroundColor('rgba(255,255,255,0.08)')
          .onClick(() => {
            if (this.onSettingClick) {
              this.onSettingClick()
            }
          })
          .accessibilityText('课程设置')
          .accessibilityDescription('打开课程设置')
        }
      }
      .width('100%')
      .height(48)
      .alignItems(VerticalAlign.Center)

      // 三问步骤指示器
      Row() {
        ForEach(this.stepLabels, (label: string, idx: number) => {
          Row() {
            // 步骤圆点
            Text(`${idx + 1}`)
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor(idx + 1 === this.currentStep ? '#FFFFFF' : 'rgba(255,255,255,0.4)')
              .textAlign(TextAlign.Center)
              .width(22)
              .height(22)
              .borderRadius(11)
              .backgroundColor(idx + 1 === this.currentStep ? '#5C6BC0' :
                (idx + 1 < this.currentStep ? 'rgba(92,107,192,0.4)' : 'rgba(255,255,255,0.1)'))

            // 步骤标签
            Text(label)
              .fontSize(12)
              .fontColor(idx + 1 === this.currentStep ? '#FFFFFF' : 'rgba(255,255,255,0.5)')
              .margin({ left: 6 })

            // 连接线（非最后一个）
            if (idx < 2) {
              Row()
                .width(24)
                .height(2)
                .backgroundColor(idx + 1 < this.currentStep ? 'rgba(92,107,192,0.6)' : 'rgba(255,255,255,0.1)')
                .margin({ left: 8, right: 8 })
            }
          }
          .layoutWeight(idx < 2 ? 0 : 1)
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
        }, (label: string, idx: number) => `${idx}`)
      }
      .width('100%')
      .height(36)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 8, bottom: 4 })
    .accessibilityText(`课程标题栏: ${this.courseName}, 当前第${this.currentStep}步`)
  }
}
