/**
 * QuizCard — 测评题目卡片组件
 * 从 Assessment 页拆分，展示单道布鲁姆题目
 * 支持客观题（单选）和主观题（手动输入）
 */
import { QuizQuestion } from '../models/Models';
import { ManualInputBox } from './ManualInputBox';

@Component
export struct QuizCard {
  @Prop quiz: QuizQuestion;
  @Prop questionIndex: number = 1;
  @Prop isAnswered: boolean = false;
  @Prop userAnswer: string = '';
  @Prop aiEvaluation: string = '';
  onSubmit?: (questionId: string, answer: string) => void;

  build() {
    Column() {
      // Question number and bloom level
      Row() {
        Text(`Q${this.questionIndex}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.color_primary'))
          .margin({ right: 8 })

        Text(this.getBloomLabel(this.quiz.bloom_level))
          .fontSize($r('app.float.font_size_micro'))
          .fontColor('#FFFFFF')
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(4)
          .backgroundColor(this.getBloomColor(this.quiz.bloom_level))
      }
      .width('100%')
      .margin({ bottom: 8 })

      // Question text
      Text(this.quiz.question_text)
        .fontSize($r('app.float.font_size_body'))
        .fontColor($r('app.color.color_text_secondary'))
        .lineHeight(22)
        .width('100%')
        .margin({ bottom: 12 })

      // Options (if objective) or ManualInputBox (if subjective)
      if (this.isObjective()) {
        Text($r('app.string.assessment_objective_label'))
          .fontSize($r('app.float.font_size_micro'))
          .fontColor($r('app.color.color_text_disabled'))
          .width('100%')
          .margin({ bottom: 4 })

        Column() {
          ForEach(this.parseOptions(), (option: string, optIndex: number) => {
            Row() {
              Text(option)
                .fontSize($r('app.float.font_size_body'))
                .fontColor($r('app.color.color_text_secondary'))
                .layoutWeight(1)
              Radio({ value: `q${this.quiz.id}_${optIndex}`, group: `radio_${this.quiz.id}` })
                .checked(this.userAnswer === option)
                .accessibilityText(option)
                .onChange((checked: boolean) => {
                  if (checked && this.onSubmit) {
                    this.onSubmit(this.quiz.id, option);
                  }
                })
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 })
          }, (opt: string, idx: number) => `${this.quiz.id}_opt_${idx}`)
        }
        .width('100%')
      } else {
        Text($r('app.string.assessment_subjective_label'))
          .fontSize($r('app.float.font_size_micro'))
          .fontColor($r('app.color.color_text_disabled'))
          .width('100%')
          .margin({ bottom: 4 })

        ManualInputBox({
          onSubmit: (value: string) => {
            if (this.onSubmit) {
              this.onSubmit(this.quiz.id, value);
            }
          }
        })
      }
    }
    .width('100%')
    .padding($r('app.float.spacing_card_padding'))
    .borderRadius($r('app.float.border_radius_card'))
    .backgroundColor($r('app.color.color_bg_card'))
    .shadow({ radius: 4, color: '#0F000000', offsetX: 0, offsetY: 2 })
    .margin({ left: $r('app.float.spacing_page_horizontal'), right: $r('app.float.spacing_page_horizontal'), top: 8, bottom: 8 })
  }

  private getBloomLabel(level: number): ResourceStr {
    switch (level) {
      case 1:
        return $r('app.string.assessment_bloom_remember');
      case 2:
        return $r('app.string.assessment_bloom_understand');
      case 3:
        return $r('app.string.assessment_bloom_apply');
      case 4:
        return $r('app.string.assessment_bloom_analyze');
      case 5:
        return $r('app.string.assessment_bloom_evaluate');
      case 6:
        return $r('app.string.assessment_bloom_create');
      default:
        return '';
    }
  }

  private isObjective(): boolean {
    return typeof this.quiz.options === 'string' && this.quiz.options.length > 0 && this.quiz.options !== '';
  }

  private parseOptions(): string[] {
    if (!this.quiz.options || this.quiz.options === '') {
      return [];
    }
    try {
      const parsed: string[] = JSON.parse(this.quiz.options) as string[]
      return Array.isArray(parsed) ? parsed : [];
    } catch (_e) {
      return [];
    }
  }

  private getBloomColor(level: number): ResourceColor {
    const colors: Record<number, ResourceColor> = {
      1: '#34C759',
      2: '#007AFF',
      3: '#5856D6',
      4: '#FF9500',
      5: '#FF2D55',
      6: '#AF52DE'
    };
    return colors[level] || '#999999';
  }
}
