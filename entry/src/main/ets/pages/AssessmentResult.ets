/**
 * AssessmentResult — 评价报告页
 * 遵循 MVVM: Pages→ViewModels ONLY
 * 雷达图 + Q1/Q2/Q3 得分 + 弱项节点 + 导出报告 + 诚信声明
 */
import { EvaluationViewModel } from '../viewmodels/EvaluationViewModel';
import { RadarChart } from '../components/RadarChart';
import { EvaluationReport } from '../models/Models';
import { router } from '@kit.ArkUI';
import { ErrorCode, errorCodeToResource } from '../common/ErrorCode';
import { AIChatFab } from '../components/AIChatFab';
import { AIChatPanel } from '../components/AIChatPanel';

@Entry
@Component
struct AssessmentResult {
  @State report: EvaluationReport | null = null;
  @State isLoading: boolean = false;
  @State errorMessage: ResourceStr = '';
  @State hasSuspectRecords: boolean = false;
  private viewModel: EvaluationViewModel = new EvaluationViewModel();
  private courseId: string = '';
  @State chatOpen: boolean = false;

  aboutToAppear(): void {
    try {
      const params = router.getParams() as Record<string, Object>;
      if (params && params['courseId']) {
        this.courseId = params['courseId'] as string;
        this.loadReport();
      }
    } catch (_e) {
      // 路由参数获取失败
    }
  }

  aboutToDisappear(): void {
    // Release large report object per PERFORMANCE_CONVENTIONS
    this.report = null;
  }

  private async loadReport(): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      await this.viewModel.generateReport(this.courseId);
      this.report = this.viewModel.report;
      this.errorMessage = this.viewModel.errorMessage ? errorCodeToResource(this.viewModel.errorMessage) : '';
      this.hasSuspectRecords = this.report?.has_suspect_records ?? false;
    } catch (e) {
      const errCode = (e instanceof Error) ? e.message : '';
      if (errCode === ErrorCode.NETWORK_DISCONNECTED) {
        this.getUIContext().showAlertDialog({
          message: errorCodeToResource(ErrorCode.NETWORK_DISCONNECTED),
          autoCancel: false,
          buttons: [{
            value: $r('app.string.home_delete_confirm_cancel'),
            action: () => {}
          }]
        });
        this.errorMessage = errorCodeToResource(ErrorCode.NETWORK_DISCONNECTED);
      } else {
        this.errorMessage = this.viewModel.errorMessage ? errorCodeToResource(this.viewModel.errorMessage) : '';
      }
    } finally {
      this.isLoading = false;
    }
  }

  private onExportReport(): void {
    this.viewModel.exportReport().then((markdown: string) => {
      if (markdown && markdown.length > 0) {
        // Export successful — markdown captured
        // Could trigger share or save dialog
      }
      this.errorMessage = this.viewModel.errorMessage ? errorCodeToResource(this.viewModel.errorMessage) : '';
    });
  }

  build() {
    Stack() {
    Column() {
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(36)
            .height(36)
            .color($r('app.color.color_primary'))
          Blank().height(12)
          Text($r('app.string.assessment_result_loading'))
            .fontSize($r('app.float.font_size_body'))
            .fontColor($r('app.color.color_text_disabled'))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (!this.report) {
        Column() {
          Text($r('app.string.assessment_result_no_report'))
            .fontSize($r('app.float.font_size_body'))
            .fontColor($r('app.color.color_text_disabled'))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column() {
            // Title
            Text($r('app.string.assessment_result_title'))
              .fontSize($r('app.float.font_size_title'))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.color_text_primary'))
              .width('100%')
              .padding({ left: $r('app.float.spacing_page_horizontal'), top: 16, bottom: 4 })

            Text(this.report.course_title)
              .fontSize($r('app.float.font_size_body'))
              .fontColor($r('app.color.color_text_tertiary'))
              .width('100%')
              .padding({ left: 16, bottom: 16 })

            // --- Radar Chart Section ---
            Column() {
              Text($r('app.string.assessment_result_bloom_title'))
                .fontSize($r('app.float.font_size_subtitle'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.color_text_primary'))
                .width('100%')
                .margin({ bottom: 8 })

              Row() {
                RadarChart({
                  bloomScores: this.report.bloom_scores
                })
                .width('100%')
                .height(260)
              }
              .width('100%')
            }
            .width('100%')
            .padding($r('app.float.spacing_card_padding'))
            .margin({ left: $r('app.float.spacing_page_horizontal'), right: $r('app.float.spacing_page_horizontal'), top: 8 })
            .borderRadius($r('app.float.border_radius_card'))
            .backgroundColor($r('app.color.color_bg_card'))
            .shadow({ radius: 4, color: '#0F000000', offsetX: 0, offsetY: 2 })

            // --- Score Breakdown Section ---
            Column() {
              Text($r('app.string.assessment_result_score_breakdown'))
                .fontSize($r('app.float.font_size_subtitle'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.color_text_primary'))
                .width('100%')
                .margin({ bottom: 12 })

              this.buildScoreRow($r('app.string.assessment_result_q1_score'), this.report.q1_score, 20)
              this.buildScoreRow($r('app.string.assessment_result_q2_score'), this.report.q2_score, 40)
              this.buildScoreRow($r('app.string.assessment_result_q3_score'), this.report.q3_score, 40)

              Divider()
                .strokeWidth(1)
                .color($r('app.color.color_divider'))
                .margin({ top: 8, bottom: 8 })

              Row() {
                Text($r('app.string.assessment_result_total'))
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.color_text_primary'))
                  .layoutWeight(1)

                Text(`${this.report.total_score}/100`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.getTotalScoreColor(this.report.total_score))
              }
              .width('100%')
            }
            .width('100%')
            .padding($r('app.float.spacing_card_padding'))
            .margin({ left: $r('app.float.spacing_page_horizontal'), right: $r('app.float.spacing_page_horizontal'), top: 12 })
            .borderRadius($r('app.float.border_radius_card'))
            .backgroundColor($r('app.color.color_bg_card'))
            .shadow({ radius: 4, color: '#0F000000', offsetX: 0, offsetY: 2 })

            // --- Weak Nodes Section ---
            if (this.report.weak_nodes && this.report.weak_nodes.length > 0) {
              Column() {
                Text($r('app.string.assessment_result_weak_nodes'))
                  .fontSize($r('app.float.font_size_subtitle'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.color_text_primary'))
                  .width('100%')
                  .margin({ bottom: 8 })

                ForEach(this.report.weak_nodes, (nodeLabel: string) => {
                  Row() {
                    Text('\u26A0')
                      .fontSize($r('app.float.font_size_body'))
                      .margin({ right: 8 })

                    Text(nodeLabel)
                      .fontSize($r('app.float.font_size_body'))
                      .fontColor($r('app.color.color_warning'))
                      .layoutWeight(1)
                  }
                  .width('100%')
                  .padding({ top: 6, bottom: 6 })
                }, (label: string, idx: number) => `weak_${idx}`)
              }
              .width('100%')
              .padding($r('app.float.spacing_card_padding'))
              .margin({ left: $r('app.float.spacing_page_horizontal'), right: $r('app.float.spacing_page_horizontal'), top: 12 })
              .borderRadius($r('app.float.border_radius_card'))
              .backgroundColor($r('app.color.color_bg_card'))
              .shadow({ radius: 4, color: '#0F000000', offsetX: 0, offsetY: 2 })
            }

            // --- Integrity Declaration ---
            Column() {
              if (this.hasSuspectRecords) {
                Text($r('app.string.assessment_result_suspect_warning'))
                  .fontSize($r('app.float.font_size_caption'))
                  .fontColor($r('app.color.color_warning'))
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .margin({ bottom: 8 })
              }

              Text($r('app.string.assessment_result_integrity'))
                .fontSize($r('app.float.font_size_caption'))
                .fontColor(this.hasSuspectRecords ? $r('app.color.color_text_disabled') : $r('app.color.color_success'))
                .width('100%')
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .padding({ left: $r('app.float.spacing_page_horizontal'), right: $r('app.float.spacing_page_horizontal'), top: 12, bottom: 4 })

            // --- Export Button ---
            Button($r('app.string.assessment_result_export'))
              .fontSize($r('app.float.font_size_body'))
              .fontColor('#FFFFFF')
              .backgroundColor($r('app.color.color_primary'))
              .width('80%')
              .height(44)
              .borderRadius($r('app.float.border_radius_capsule'))
              .margin({ top: 16, bottom: 24 })
              .onClick(() => {
                this.onExportReport();
              })
              .accessibilityText($r('app.string.assessment_result_export'))
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }

      // Error message
      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontSize($r('app.float.font_size_caption'))
          .fontColor($r('app.color.color_danger'))
          .width('100%')
          .padding(8)
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.color_bg_page'))

      // === AI Chat FAB ===
      AIChatFab({
        isOpen: this.chatOpen,
        hasActiveCourse: true
      })
        .position({ x: '80%', y: '90%' })

      // === AI Chat Panel ===
      AIChatPanel({
        isOpen: this.chatOpen
      })
        .position({ x: 0, y: this.chatOpen ? '30%' : '100%' })
        .width('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildScoreRow(label: ResourceStr, score: number, maxScore: number) {
    Row() {
      Text(label)
        .fontSize($r('app.float.font_size_body'))
        .fontColor($r('app.color.color_text_secondary'))
        .layoutWeight(1)

      Text(`${score}/${maxScore}`)
        .fontSize($r('app.float.font_size_body'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.color_text_secondary'))

      Progress({
        value: score,
        total: maxScore,
        type: ProgressType.Linear
      })
        .width(80)
        .height(6)
        .style({ strokeWidth: 6 })
        .color(this.getScoreProgressColor(score, maxScore))
        .margin({ left: 8 })
    }
    .width('100%')
    .margin({ top: 6, bottom: 6 })
  }

  private getScoreProgressColor(score: number, max: number): ResourceColor {
    const ratio: number = score / max;
    if (ratio >= 0.8) {
      return '#34C759';
    } else if (ratio >= 0.5) {
      return '#FF9500';
    } else {
      return '#FF3B30';
    }
  }

  private getTotalScoreColor(score: number): ResourceColor {
    if (score >= 80) {
      return '#34C759';
    } else if (score >= 60) {
      return '#FF9500';
    } else {
      return '#FF3B30';
    }
  }
}
