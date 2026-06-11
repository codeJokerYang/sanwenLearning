/**
 * 争议分析卡片 — Q2 辩论双栏对比（宇宙风格毛玻璃卡片）
 * 布局：左右分栏展示 view_a / view_b，Checkbox 选择，TextArea 输入见解
 */
import { Controversy } from '../models/Models';
import { ManualInputBox } from './ManualInputBox';

@Component
export struct DebateCard {
  @Prop controversy: Controversy;
  @State selectedIndex: number = -1;
  @State insightText: string = '';
  onSubmitInsight?: (controversyId: string, userAnswer: string) => void;

  build() {
    Column() {
      // Card header with icon
      Row() {
        Circle({ width: 28, height: 28 })
          .fill('rgba(179,136,255,0.12)')
        Text('\u{1F4AD}')
          .fontSize(13)
          .position({ x: 0, y: 0 })
        Text(this.controversy.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: 14 })

      // Two-column debate views
      Row() {
        ViewColumn({
          header: $r('app.string.debate_view_a'),
          content: this.controversy.view_a,
          evidence: this.controversy.evidence_a,
          isSelected: this.selectedIndex === 0,
          onSelect: () => { this.selectedIndex = 0; },
          label: this.controversy.view_a
        })

        Blank().width(10)

        ViewColumn({
          header: $r('app.string.debate_view_b'),
          content: this.controversy.view_b,
          evidence: this.controversy.evidence_b,
          isSelected: this.selectedIndex === 1,
          onSelect: () => { this.selectedIndex = 1; },
          label: this.controversy.view_b
        })
      }
      .width('100%')

      if (this.selectedIndex !== -1) {
        Blank().height(12)

        ManualInputBox({
          onSubmit: (value: string) => {
            this.insightText = value;
            if (this.onSubmitInsight && this.selectedIndex !== -1) {
              const answer = this.selectedIndex === 0 ? 'A' : 'B';
              this.onSubmitInsight(this.controversy.id, answer);
            }
          }
        })

        Blank().height(8)

        Button($r('app.string.debate_submit'))
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .accessibilityText($r('app.string.a11y_debate_submit'))
          .width('100%').height(42).borderRadius(21)
          .linearGradient({ angle: 135, colors: [['#5C6BC0', 0], ['#3949AB', 1]] })
          .shadow({ radius: 12, color: '#40003D82', offsetX: 0, offsetY: 4 })
          .fontColor('#FFFFFF')
          .onClick(() => {
            if (this.onSubmitInsight && this.selectedIndex !== -1) {
              const answer = this.selectedIndex === 0 ? 'A' : 'B';
              this.onSubmitInsight(this.controversy.id, answer);
            }
          })
      }
    }
    .width('100%')
    .padding(16)
    .borderRadius(18)
    .backgroundColor('rgba(255,255,255,0.05)')
    .border({ width: 0.5, color: 'rgba(255,255,255,0.08)' })
    .shadow({ radius: 20, color: '#20000000', offsetY: 6 })
  }
}

@Component
struct ViewColumn {
  @Prop header: ResourceStr;
  @Prop content: string;
  @Prop evidence: string;
  @Prop isSelected: boolean;
  onSelect?: () => void;
  @Prop label: string;

  build() {
    Column() {
      Row() {
        Checkbox({ name: 'debate_view', group: 'debate_group' })
          .select(this.isSelected)
          .onChange((checked: boolean) => {
            if (checked && this.onSelect) { this.onSelect(); }
          })
          .accessibilityText(`${this.header}: ${this.label}`)
          .margin({ right: 6 })

        Text(this.header)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('rgba(255,255,255,0.75)')
      }
      .width('100%')
      .margin({ bottom: 7 })

      Text(this.content)
        .fontSize(13)
        .fontColor('rgba(255,255,255,0.60)')
        .width('100%')
        .maxLines(4)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .lineHeight(19)
        .margin({ bottom: 5 })

      if (this.evidence.length > 0) {
        Text(`${$r('app.string.debate_evidence_prefix')}${this.evidence}`)
          .fontSize(11)
          .fontColor('rgba(255,255,255,0.30)')
          .width('100%')
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .layoutWeight(1)
    .padding(11)
    .borderRadius(12)
    .backgroundColor(this.isSelected ? 'rgba(92,107,192,0.15)' : 'rgba(255,255,255,0.03)')
    .border({
      width: this.isSelected ? 1.5 : 0.5,
      color: this.isSelected ? '#7C8CFF' : 'rgba(255,255,255,0.06)'
    })
    .accessibilityText(`${this.header}: ${this.label}`)
  }
}
