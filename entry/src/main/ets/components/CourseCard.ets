/**
 * 课程卡片组件 — 展示课程标题、状态标签与进度
 * 长按触发 onDeleteClick 回调
 */
import { Course, CourseStatus } from '../models/Models';
import { ProgressBar } from './ProgressBar';

@Component
export struct CourseCard {
  @Prop course: Course;
  @Prop isDarkMode: boolean = false;
  onCardClick?: () => void;
  onDeleteClick?: () => void;

  // Glassmorphism colors based on mode
  private get cardBg(): ResourceColor | string {
    return this.isDarkMode ? 'rgba(255,255,255,0.08)' : $r('app.color.color_bg_card');
  }

  private get cardBorder(): string {
    return this.isDarkMode ? 'rgba(255,255,255,0.1)' : 'transparent';
  }

  build() {
    Column() {
      // Top row: status icon indicator + title + status badge
      Row() {
        // Step number circle
        Stack() {
          Circle({ width: 32, height: 32 })
            .fill(this.isDarkMode ? 'rgba(255,255,255,0.12)' : this.getStepBgColor())
          Text(this.getStepNumber())
            .fontSize($r('app.float.font_size_caption'))
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isDarkMode ? '#FFFFFF' : '#FFFFFF')
        }
        .width(32)
        .height(32)

        Blank().width(10)

        // Title column
        Column() {
          Text(this.course.title)
            .fontSize($r('app.float.font_size_body'))
            .fontWeight(FontWeight.Medium)
            .fontColor(this.isDarkMode ? '#FFFFFF' : $r('app.color.color_text_primary'))
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          Text(this.getStepDescription())
            .fontSize($r('app.float.font_size_micro'))
            .fontColor(this.isDarkMode ? 'rgba(255,255,255,0.5)' : $r('app.color.color_text_disabled'))
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // Status badge
        Text(this.getStatusLabel())
          .fontSize($r('app.float.font_size_micro'))
          .fontColor('#FFFFFF')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .borderRadius($r('app.float.border_radius_capsule'))
          .backgroundColor(this.getStatusColor())
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Blank().height(14)

      // Progress section with label
      Column() {
        Row() {
          Text($r('app.string.progress_prefix'))
            .fontSize($r('app.float.font_size_micro'))
            .fontColor(this.isDarkMode ? 'rgba(255,255,255,0.45)' : $r('app.color.color_text_disabled'))
          Text(`${this.course.progress}%`)
            .fontSize($r('app.float.font_size_micro'))
            .fontColor(this.isDarkMode ? '#7CBBFF' : $r('app.color.color_primary'))
            .fontWeight(FontWeight.Medium)
          Blank()
          Text(this.getProgressLabel())
            .fontSize($r('app.float.font_size_micro'))
            .fontColor(this.isDarkMode ? 'rgba(255,255,255,0.35)' : $r('app.color.color_text_tertiary'))
        }
        .width('100%')

        Blank().height(6)

        ProgressBar({ progress: this.course.progress, showLabel: false })
      }
      .width('100%')

      if (this.onDeleteClick) {
        Divider().color(this.isDarkMode ? 'rgba(255,255,255,0.08)' : $r('app.color.color_divider')).strokeWidth(1).margin({ top: 12, bottom: 8 })

        Button() {
          Row() {
            Text('\u{1F5D1}')
              .fontSize(14)
              .margin({ right: 4 })
            Text($r('app.string.delete_course'))
              .fontSize($r('app.float.font_size_caption'))
              .fontColor(this.isDarkMode ? '#FF8A9B' : $r('app.color.color_danger'))
          }
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .width('100%')
        .height(36)
        .onClick(() => {
          if (this.onDeleteClick) {
            this.onDeleteClick();
          }
        })
      }
    }
    .width('100%')
    .padding($r('app.float.spacing_card_padding'))
    .borderRadius($r('app.float.border_radius_card'))
    .backgroundColor(this.cardBg as ResourceColor | string)
    .border({ width: this.isDarkMode ? 0.5 : 0, color: this.cardBorder })
    .shadow(this.isDarkMode
      ? { radius: 10, color: '#10000000', offsetX: 0, offsetY: 4 }
      : { radius: 6, color: '#14000000', offsetX: 0, offsetY: 2 })
    .gesture(
      LongPressGesture({ repeat: false, duration: 500 })
        .onAction(() => {
          if (this.onDeleteClick) {
            this.onDeleteClick();
          }
        })
    )
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick();
      }
    })
    .accessibilityText(`${this.course.title}, ${$r('app.string.progress_prefix')}${this.course.progress}%`)
    .accessibilityDescription($r('app.string.course_card_accessibility'))
  }

  private getStatusLabel(): ResourceStr {
    switch (this.course.status) {
      case CourseStatus.DRAFT:
        return $r('app.string.status_draft');
      case CourseStatus.GENERATING:
        return $r('app.string.status_generating');
      case CourseStatus.Q1_ACTIVE:
        return $r('app.string.status_q1');
      case CourseStatus.Q2_ACTIVE:
        return $r('app.string.status_q2');
      case CourseStatus.Q3_ACTIVE:
        return $r('app.string.status_q3');
      case CourseStatus.COMPLETED:
        return $r('app.string.status_completed');
      default:
        return '';
    }
  }

  private getStatusColor(): ResourceColor {
    switch (this.course.status) {
      case CourseStatus.DRAFT:
        return $r('app.color.color_text_disabled');
      case CourseStatus.GENERATING:
        return $r('app.color.color_warning');
      case CourseStatus.Q1_ACTIVE:
        return $r('app.color.color_primary');
      case CourseStatus.Q2_ACTIVE:
        return $r('app.color.color_purple');
      case CourseStatus.Q3_ACTIVE:
        return $r('app.color.color_danger');
      case CourseStatus.COMPLETED:
        return $r('app.color.color_success');
      default:
        return $r('app.color.color_text_disabled');
    }
  }

  private getStepNumber(): string {
    switch (this.course.status) {
      case CourseStatus.DRAFT:
        return '?';
      case CourseStatus.GENERATING:
      case CourseStatus.Q1_ACTIVE:
        return '1';
      case CourseStatus.Q2_ACTIVE:
        return '2';
      case CourseStatus.Q3_ACTIVE:
        return '3';
      case CourseStatus.COMPLETED:
        return '\u2713'; // checkmark
      default:
        return '?';
    }
  }

  private getStepBgColor(): ResourceColor {
    switch (this.course.status) {
      case CourseStatus.DRAFT:
        return $r('app.color.color_text_disabled');
      case CourseStatus.GENERATING:
        return $r('app.color.color_warning');
      case CourseStatus.Q1_ACTIVE:
        return $r('app.color.color_primary');
      case CourseStatus.Q2_ACTIVE:
        return $r('app.color.color_purple');
      case CourseStatus.Q3_ACTIVE:
        return $r('app.color.color_danger');
      case CourseStatus.COMPLETED:
        return $r('app.color.color_success');
      default:
        return $r('app.color.color_text_disabled');
    }
  }

  private getStepDescription(): string {
    switch (this.course.status) {
      case CourseStatus.DRAFT:
        return '等待开始学习';
      case CourseStatus.GENERATING:
        return '正在生成知识图谱...';
      case CourseStatus.Q1_ACTIVE:
        return '第一步：是什么 — 构建知识框架';
      case CourseStatus.Q2_ACTIVE:
        return '第二步：为什么 — 争议分析';
      case CourseStatus.Q3_ACTIVE:
        return '第三步：怎么用 — 能力测评';
      case CourseStatus.COMPLETED:
        return '已完成全部三问学习';
      default:
        return '';
    }
  }

  private getProgressLabel(): string {
    if (this.course.progress === 0) {
      return '未开始';
    } else if (this.course.progress < 33) {
      return '进行中';
    } else if (this.course.progress < 66) {
      return '过半';
    } else if (this.course.progress < 100) {
      return '即将完成';
    } else {
      return '已完成';
    }
  }
}
