/**
 * LearningSpace — 学习空间页（Q2: 为什么 — 争议分析）
 * 宇宙星空风格：深色渐变背景 + 发光装饰 + 毛玻璃卡片
 * 遵循 MVVM: Pages→ViewModels ONLY
 */
import { ThreeAskViewModel } from '../viewmodels/ThreeAskViewModel';
import { ThreeAskStepper } from '../components/ThreeAskStepper';
import { CourseTitleBar } from '../components/CourseTitleBar';
import { DebateCard } from '../components/DebateCard';
import { ManualInputBox } from '../components/ManualInputBox';
import { ChatBubble } from '../components/ChatBubble';
import { Controversy } from '../models/Models';
import { router } from '@kit.ArkUI';
import { ErrorCode, errorCodeToResource } from '../common/ErrorCode';
import { AIChatFab } from '../components/AIChatFab';
import { AIChatPanel } from '../components/AIChatPanel';
import { ChatViewModel } from '../viewmodels/ChatViewModel';
import { RdbHelper } from '../db/RdbHelper';
import { Course } from '../models/Models';

@Entry
@Component
struct LearningSpace {
  @State currentStep: number = 1;
  @State q1Completed: boolean = false;
  @State q2Completed: boolean = false;
  @State isLoading: boolean = false;
  @State errorMessage: ResourceStr = '';
  @State pageStatus: 'loading' | 'empty' | 'error' | 'content' = 'content';
  @State controversies: Controversy[] = [];
  @State streamText: string = '';
  @State isStreaming: boolean = false;
  @State showSkipButton: boolean = false;
  @State skipTimerExpired: boolean = false;
  @State chatOpen: boolean = false;
  @State courseName: string = '';
  private viewModel: ThreeAskViewModel = new ThreeAskViewModel();
  private chatVm: ChatViewModel = ChatViewModel.getInstance();
  private courseId: string = '';
  private currentRecordId: string = '';
  private skipTimer: number = 0;

  aboutToAppear(): void {
    try {
      const params = router.getParams() as Record<string, Object>;
      if (params && params['courseId']) {
        this.courseId = params['courseId'] as string;
        this.loadCourseName();
        this.startQ2();
      }
    } catch (_e) {}
  }

  /** 查询课程名称 */
  private async loadCourseName(): Promise<void> {
    try {
      const rdb: RdbHelper = RdbHelper.getInstance();
      const course: Course | null = await rdb.queryCourseById(this.courseId);
      if (course) {
        this.courseName = course.title;
      }
    } catch (_e) { /* ignore */ }
  }

  aboutToDisappear(): void {
    if (this.skipTimer !== 0) {
      clearTimeout(this.skipTimer);
      this.skipTimer = 0;
    }
  }

  private async startQ2(): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      await this.viewModel.startQ2(this.courseId);
      this.syncState();
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
        this.errorMessage = errorCodeToResource(ErrorCode.LEARNING_LOAD_FAILED);
      }
    } finally {
      this.isLoading = false;
    }
  }

  private syncState(): void {
    this.currentStep = this.viewModel.currentStep;
    this.q1Completed = this.viewModel.q1Completed;
    this.q2Completed = this.viewModel.q2Completed;
    this.controversies = this.viewModel.controversies ?? [];
    this.errorMessage = this.viewModel.errorMessage ? errorCodeToResource(this.viewModel.errorMessage) : '';
    this.isLoading = this.viewModel.isLoading;
  }

  private onInsightSubmit(controversyId: string, userAnswer: string): void {
    this.viewModel.submitInsight(this.courseId, controversyId, userAnswer).then((record) => {
      if (record) {
        this.currentRecordId = record.id;
        this.isStreaming = true;
        this.streamText = '';
        this.showSkipButton = false;
        this.skipTimerExpired = false;
        this.startSkipTimer();

        this.viewModel.submitInsightForEvaluation(this.courseId, record.id, userAnswer).then(() => {
          this.isStreaming = false;
          this.syncState();
        }).catch((_e: Error) => {
          this.isStreaming = false;
          this.errorMessage = errorCodeToResource(ErrorCode.AI_FAILED);
        });
      }
      this.syncState();
    }).catch((_e: Error) => {
      this.errorMessage = errorCodeToResource(ErrorCode.INSIGHT_SUBMIT_FAILED);
    });
  }

  private startSkipTimer(): void {
    if (this.skipTimer !== 0) {
      clearTimeout(this.skipTimer);
    }
    this.skipTimer = setTimeout(() => {
      this.skipTimerExpired = true;
      if (this.isStreaming) {
        this.showSkipButton = true;
      }
    }, 15000);
  }

  private onSkipEvaluation(): void {
    if (this.currentRecordId.length === 0) return;
    this.showSkipButton = false;
    this.isStreaming = false;
    this.viewModel.skipEvaluation(this.courseId, this.currentRecordId).then(() => {
      this.syncState();
      if (this.viewModel.q2Completed) {
        router.pushUrl({
          url: 'pages/Assessment',
          params: { courseId: this.courseId }
        });
      }
    });
  }

  /**
   * 打开 AIChatPanel 并绑定课程上下文（异步）
   * 修复1：原 switchCourse 未 await，导致 hasActiveCourse 状态不一致
   * 修复2：非 chat 模式下自动触发内容生成请求
   */
  private async openAIChatPanel(mode?: string): Promise<void> {
    // 1. 先绑定课程到 ChatViewModel（必须 await 确保 hasActiveCourse 生效）
    if (this.courseId.length > 0) {
      await this.chatVm.switchCourse(this.courseId)
      // 2. 预加载已有素材到消息列表
      await this.chatVm.preloadContent(this.courseId)
    }
    // 3. 切换模式（如果指定）
    if (mode && mode !== 'chat') {
      this.chatVm.switchMode(mode)
    }
    // 4. 打开面板
    this.chatOpen = true

    // 5. 非 chat 模式：自动触发内容生成（用户期望点击即出结果）
    if (mode && mode !== 'chat' && this.courseId.length > 0) {
      const topic: string = this.courseName || this.courseId
      setTimeout(() => {
        this.chatVm.sendMessage(topic)
      }, 300)
    }
  }

  build() {
    Stack() {
      // === Layer 1: Cosmic gradient background ===
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [
            ['#0D1442', 0],     // deep space blue
            ['#162055', 0.3],
            ['#1A2765', 0.55],
            ['#1E1E4A', 0.8],
            ['#12122A', 1]     // very dark bottom
          ]
        })

      // === Layer 2: Decorative cosmic elements ===
      // Top-right nebula glow
      Column()
        .width(220)
        .height(220)
        .borderRadius(110)
        .position({ x: '60%', y: -40 })
        .linearGradient({ angle: 135, colors: [
          ['rgba(124,77,255,0.12)', 0],
          ['rgba(124,77,255,0.03)', 0.6],
          ['rgba(124,77,255,0)', 1]
        ]})

      // Bottom-left accent
      Column()
        .width(160)
        .height(160)
        .borderRadius(80)
        .position({ x: '-30%', y: '65%' })
        .linearGradient({ angle: 200, colors: [
          ['rgba(0,188,212,0.08)', 0],
          ['rgba(0,188,212,0.02)', 0.7],
          ['transparent', 1]
        ]})

      // Scattered stars
      Circle({ width: 4, height: 4 }).fill('rgba(220,225,255,0.20)').position({ x: '15%', y: '18%' })
      Circle({ width: 3, height: 3 }).fill('rgba(220,225,255,0.14)').position({ x: '80%', y: '25%' })
      Circle({ width: 3.5, height: 3.5 }).fill('rgba(220,225,255,0.16)').position({ x: '70%', y: '72%' })
      Circle({ width: 2.5, height: 2.5 }).fill('rgba(220,225,255,0.11)').position({ x: '25%', y: '82%' })
      Circle({ width: 3, height: 3 }).fill('rgba(220,225,255,0.13)').position({ x: '88%', y: '58%' })
      Circle({ width: 2, height: 2 }).fill('rgba(220,225,255,0.18)').position({ x: '10%', y: '48%' })
      Circle({ width: 3.5, height: 3.5 }).fill('rgba(220,225,255,0.09)').position({ x: '50%', y: '8%' })

      // === Layer 3: Foreground content ===
      Scroll() {
        Column() {
          // ===== Course Title Bar (替换原 Stepper + 标题) =====
          CourseTitleBar({
            courseName: this.courseName,
            currentStep: this.currentStep
          })

          // Subtitle description
          Text('探索不同观点，培养批判性思维')
            .fontSize(13)
            .fontColor('rgba(255,255,255,0.42)')
            .padding({ left: 20, right: 20, bottom: 12 })

          // ===== Content Area =====
          if (this.isLoading) {
            // Loading state with animated skeleton
            Column() {
              Blank().height(32)

              // Pulsing orb animation
              Stack() {
                Circle({ width: 64, height: 64 })
                  .fill('rgba(92,107,192,0.12)')
                Circle({ width: 44, height: 44 })
                  .fill('rgba(92,107,192,0.18)')
                Circle({ width: 24, height: 24 })
                  .fill('rgba(140,150,230,0.35)')
              }
              .width(64).height(64)

              Blank().height(24)

              Text('AI 正在生成争议观点...')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('rgba(255,255,255,0.75)')

              Blank().height(8)

              Text('正在分析资料中的矛盾与分歧点')
                .fontSize(13)
                .fontColor('rgba(255,255,255,0.35)')

              Blank().height(28)

              // Animated dots
              Row() {
                ForEach([0, 1, 2], (dotIdx: number, index: number) => {
                  Circle({ width: 9, height: 9 })
                    .fill(index === 0 ? '#7C8CFF' : index === 1 ? '#B388FF' : '#CE93D8')
                    .opacity(index === 0 ? 1 : 0.6)
                    .scale({ x: index === 0 ? 1.15 : 0.85, y: index === 0 ? 1.15 : 0.85 })
                    .animation({ duration: 600, iterations: -1, curve: Curve.EaseInOut })
                }, (index: number) => `ldot_${index}`)
              }
              .justifyContent(FlexAlign.SpaceEvenly).width(60)

              Blank().height(48)
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

          } else if (this.controversies.length === 0) {
            // AI 引导入口 — 暂无争议点时显示功能入口
            Column() {
              Blank().height(30)
              Stack() {
                Circle({ width: 64, height: 64 }).fill('rgba(124,77,255,0.08)')
                Text('?').fontSize(28).fontWeight(FontWeight.Bold).fontColor('#B388FF')
              }.width(64).height(64)
              Blank().height(16)
              Text('\u6682\u65E0\u4E89\u8BAE\u70B9\uFF0C\u8BA9 AI \u6765\u5E2E\u4F60')
                .fontSize(15).fontColor('rgba(255,255,255,0.7)').textAlign(TextAlign.Center)
              Text('\u4E0A\u4F20\u5B66\u4E60\u8D44\u6599\u540E\uFF0CAI \u5C06\u81EA\u52A8\u63D0\u53D6\u4E89\u8BAE\u89C2\u70B9')
                .fontSize(12).fontColor('rgba(255,255,255,0.4)').textAlign(TextAlign.Center)
                .margin({ top: 4 })
              Blank().height(20)

              // 2x2 功能入口网格
              Grid() {
                GridItem() {
                  this.AiGuideButton('\u{1F50D}', '\u68C0\u7D22\u76F8\u5173\u77E5\u8BC6', () => { this.openAIChatPanel('retrieve') })
                }.columnStart(0).rowStart(0)

                GridItem() {
                  this.AiGuideButton('\u{1F5FA}', '\u751F\u6210\u601D\u7EF4\u5BFC\u56FE', () => { this.openAIChatPanel('mindmap') })
                }.columnStart(1).rowStart(0)

                GridItem() {
                  this.AiGuideButton('\u{1F4C4}', '\u751F\u6210\u5B66\u4E60\u6587\u6863', () => { this.openAIChatPanel('studydoc') })
                }.columnStart(0).rowStart(1)

                GridItem() {
                  this.AiGuideButton('\u{1F4AC}', '\u5411 AI \u63D0\u95EE', () => { this.openAIChatPanel('chat') })
                }.columnStart(1).rowStart(1)
              }
              .columnsTemplate('1fr 1fr')
              .rowsTemplate('1fr 1fr')
              .columnsGap(10)
              .rowsGap(10)
              .width('100%').height(160)
              .padding({ left: 20, right: 20 })
            }
            .width('100%').layoutWeight(1).justifyContent(FlexAlign.Start).alignItems(HorizontalAlign.Center)
            .padding({ left: 24, right: 24 })

          } else {
            // Content: debate cards list
            Column() {
              ForEach(this.controversies, (controversy: Controversy) => {
                DebateCard({
                  controversy: controversy,
                  onSubmitInsight: (controversyId: string, userAnswer: string) => {
                    this.onInsightSubmit(controversyId, userAnswer);
                  }
                })
                .margin({ left: 16, right: 16, top: 8, bottom: 8 })
              }, (controversy: Controversy) => controversy.id)
            }
            .width('100%')
          }

          // AI streaming evaluation area
          if (this.isStreaming) {
            Column() {
              // Streaming header
              Row() {
                Circle({ width: 8, height: 8 })
                  .fill('#7C8CFF')
                Text('AI 正在分析你的见解...')
                  .fontSize(13)
                  .fontColor('rgba(255,255,255,0.55)')
                  .margin({ left: 8 })
              }
              .margin({ bottom: 8 })

              ChatBubble({
                text: this.streamText,
                isStreaming: this.isStreaming
              })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 8 })
            .backgroundColor('rgba(255,255,255,0.03)')
            .border({ width: { top: 0.5 }, color: 'rgba(255,255,255,0.06)' })
          }

          // Skip button
          if (this.showSkipButton && !this.q2Completed) {
            Button($r('app.string.learning_space_skip_evaluation'))
              .fontSize(14)
              .fontColor('rgba(255,193,7,0.85)')
              .backgroundColor(Color.Transparent)
              .width('100%')
              .height(44)
              .onClick(() => { this.onSkipEvaluation(); })
              .padding({ left: 16, right: 16, bottom: 8 })
              .accessibilityText($r('app.string.learning_space_skip_evaluation'))
          }

          // Error banner
          if (this.pageStatus === 'error' && this.errorMessage) {
            Row() {
              Text('!')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .width(22).height(22)
                .borderRadius(11)
                .backgroundColor('rgba(255,59,48,0.6)')
                .textAlign(TextAlign.Center)
                .margin({ right: 8 })
              Text(this.errorMessage)
                .fontSize(13)
                .fontColor('rgba(255,182,185,0.9)')
                .layoutWeight(1)
            }
            .width('100%')
            .padding(12)
            .margin({ left: 16, right: 16, top: 4, bottom: 4 })
            .borderRadius(12)
            .backgroundColor('rgba(255,59,48,0.08)')
            .border({ width: 0.5, color: 'rgba(255,59,48,0.15)' })
          }

          Blank().height(24)
        }
        .width('100%')
      }
      .width('100%').height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      // === AI Chat FAB ===
      AIChatFab({
        isOpen: this.chatOpen,
        hasActiveCourse: this.courseId.length > 0,
        onToggle: (): void => { this.openAIChatPanel() }
      })
        .position({ x: '80%', y: '90%' })

      // === AI Chat Panel ===
      AIChatPanel({
        isOpen: this.chatOpen
      })
        .position({ x: 0, y: this.chatOpen ? '30%' : '100%' })
        .width('100%')
    }
    .width('100%').height('100%')
  }

  @Builder
  AiGuideButton(icon: string, label: string, onClickAction: () => void): void {
    Column() {
      Text(icon).fontSize(22).margin({ bottom: 6 })
      Text(label).fontSize(11).fontColor('rgba(255,255,255,0.7)')
    }
    .width('100%').height(68)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(124,77,255,0.08)')
    .borderRadius(12)
    .border({ width: 1, color: 'rgba(124,77,255,0.15)' })
    .onClick(onClickAction)
  }
}

// Small tip chip for empty state illustration
@Component
struct TipChip {
  @Prop text: string = '';
  @Prop subtext: string = '';
  @Prop marginL: number = 0;

  build() {
    Column() {
      Text(this.text)
        .fontSize(11)
        .fontWeight(FontWeight.Medium)
        .fontColor('rgba(179,136,255,0.85)')
      Text(this.subtext)
        .fontSize(9)
        .fontColor('rgba(255,255,255,0.25)')
        .margin({ top: 1 })
    }
    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
    .borderRadius(10)
    .backgroundColor('rgba(124,77,255,0.07)')
    .border({ width: 0.5, color: 'rgba(124,77,255,0.12)' })
    .margin({ left: this.marginL })
  }
}
