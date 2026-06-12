/**
 * Assessment — 测评页（Q3: 怎么用）
 * 遵循 MVVM: Pages→ViewModels ONLY
 * 布鲁姆9题：题目列表 + 作答 + 防呆 + 布鲁姆校验失败处理
 */
import { ThreeAskViewModel } from '../viewmodels/ThreeAskViewModel';
import { QuizCard } from '../components/QuizCard';
import { QuizQuestion } from '../models/Models';
import { router } from '@kit.ArkUI';
import { ErrorCode, errorCodeToResource } from '../common/ErrorCode';
import { StatusLayout } from '../components/StatusLayout';
import { AIChatFab } from '../components/AIChatFab';
import { AIChatPanel } from '../components/AIChatPanel';

@Entry
@Component
struct Assessment {
  @State questions: QuizQuestion[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: ResourceStr = '';
  @State pageStatus: 'loading' | 'empty' | 'error' | 'content' = 'loading';
  @State q3Completed: boolean = false;
  @State bloomRetryCount: number = 0;
  @State showRetryButton: boolean = false;
  private viewModel: ThreeAskViewModel = new ThreeAskViewModel();
  private courseId: string = '';
  private answers: Map<string, string> = new Map();
  private answeredCount: number = 0;
  @State chatOpen: boolean = false;

  aboutToAppear(): void {
    try {
      const params = router.getParams() as Record<string, Object>;
      if (params && params['courseId']) {
        this.courseId = params['courseId'] as string;
        this.startQ3();
      }
    } catch (_e) {
      // 路由参数获取失败
    }
  }

  private async startQ3(): Promise<void> {
    this.isLoading = true;
    this.pageStatus = 'loading';
    this.errorMessage = '';
    this.showRetryButton = false;
    try {
      await this.viewModel.startQ3(this.courseId);
      this.syncState();

      // Check if bloom validation failed and retries exhausted
      if (this.viewModel.bloomRetryCount >= this.viewModel.BLOOM_MAX_RETRIES &&
        this.viewModel.questions.length === 0) {
        this.showRetryButton = true;
        this.pageStatus = 'empty';
      } else if (this.questions.length === 0) {
        this.pageStatus = 'empty';
      } else {
        this.pageStatus = 'content';
      }
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
        this.errorMessage = errorCodeToResource(ErrorCode.ASSESSMENT_LOAD_FAILED);
      }
      this.pageStatus = 'error';
    } finally {
      this.isLoading = false;
    }
  }

  private syncState(): void {
    this.questions = this.viewModel.questions ?? [];
    this.errorMessage = this.viewModel.errorMessage ? errorCodeToResource(this.viewModel.errorMessage) : '';
    this.q3Completed = this.viewModel.q3Completed;
    this.bloomRetryCount = this.viewModel.bloomRetryCount;
  }

  private onManualRetry(): void {
    this.viewModel.bloomRetryCount = 0;
    this.startQ3();
  }

  private onAnswerSubmit(questionId: string, userAnswer: string): void {
    // Record the answer
    this.answers.set(questionId, userAnswer);

    this.viewModel.submitAnswer(this.courseId, questionId, userAnswer).then((record) => {
      if (record) {
        this.answeredCount++;
      }
      this.syncState();

      // Check if all 9 answered
      if (this.answeredCount >= 9 && !this.viewModel.q3Completed) {
        this.viewModel.onQ3Completed(this.courseId).then(() => {
          this.syncState();
          // Navigate to AssessmentResult
          try {
            router.replaceUrl({
              url: 'pages/AssessmentResult',
              params: { courseId: this.courseId }
            });
          } catch (_e) {
            // 路由跳转失败静默处理
          }
        });
      }
    });
  }

  build() {
    Stack() {
    Column() {
      // Title
      Text($r('app.string.assessment_title'))
        .fontSize($r('app.float.font_size_subtitle'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.color_text_primary'))
        .width('100%')
        .padding({ left: $r('app.float.spacing_page_horizontal'), top: 12, bottom: 4 })

      StatusLayout({
        status: this.pageStatus,
        emptyMessage: $r('app.string.assessment_no_questions'),
        errorMessage: this.errorMessage,
        retryText: $r('app.string.assessment_retry'),
        onRetry: () => { this.onManualRetry() }
      }) {
        // Content: question list
        Scroll() {
          Column() {
            ForEach(this.questions, (question: QuizQuestion, index: number) => {
              QuizCard({
                quiz: question,
                questionIndex: index + 1,
                isAnswered: this.answers.has(question.id),
                userAnswer: this.answers.get(question.id) ?? '',
                aiEvaluation: '',
                onSubmit: (questionId: string, answer: string) => {
                  this.onAnswerSubmit(questionId, answer);
                }
              })
            }, (question: QuizQuestion) => question.id)
          }
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        // Bottom submit area
        Row() {
          Text(`${this.answeredCount}/${this.questions.length}`)
            .fontSize($r('app.float.font_size_caption'))
            .fontColor($r('app.color.color_text_disabled'))
          Text(' ')
            .fontSize($r('app.float.font_size_caption'))
          Text($r('app.string.assessment_complete'))
            .fontSize($r('app.float.font_size_caption'))
            .fontColor($r('app.color.color_text_disabled'))
        }
        .width('100%')
        .padding({ left: $r('app.float.spacing_page_horizontal'), right: $r('app.float.spacing_page_horizontal'), top: 8, bottom: 8 })
        .border({ width: { top: 1 }, color: $r('app.color.color_divider') })
      }

      // Error message
      if (this.pageStatus === 'error' && this.errorMessage) {
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

}
