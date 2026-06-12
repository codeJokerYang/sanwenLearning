/**
 * HomePage — 学习仪表盘首页
 * 6 层信息架构：L1问候 → L2今日进度 → L3每日一问 → L4快捷操作 → L5数据概览 → L6发现推荐
 */
import { HomeViewModel, DashboardData, DailyQuestionData } from '../viewmodels/HomeViewModel';
import { GreetingHeader } from '../components/GreetingHeader';
import { TodayCard } from '../components/TodayCard';
import { DailyQuestion } from '../components/DailyQuestion';
import { QuickActions } from '../components/QuickActions';
import { WeeklyStats } from '../components/WeeklyStats';
import { DiscoverSection } from '../components/DiscoverSection';
import { DynamicBackground } from '../components/DynamicBackground';
import { BottomTabBar } from '../components/BottomTabBar';
import { CreateCourseDialog } from '../components/CreateCourseDialog';
import { AIService } from '../services/AIService';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct HomePage {
  @State dashboardData: DashboardData | null = null;
  @State currentHour: number = 12;
  @State questionIndex: number = 0;
  @State currentQuestion: DailyQuestionData | null = null;
  @State newCourseTitle: string = '';
  private viewModel: HomeViewModel = new HomeViewModel();

  private createDialogController: CustomDialogController = new CustomDialogController({
    builder: CreateCourseDialog({
      onTitleChange: (value: string) => { this.newCourseTitle = value; },
      onConfirm: () => { this.onCreateFromTemplate(); },
      onCancel: () => {}
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: false
  });

  aboutToAppear(): void {
    const now = new Date();
    this.currentHour = now.getHours();
    this.loadDashboard();
    this.promptApiKeySetupIfNeeded();
  }

  /**
   * 首次启动引导：未配置 API Key 时弹窗引导用户前往设置页
   * 应用不内置默认密钥，AI 功能（图谱/争议/测评/对话）依赖用户自行配置
   */
  private async promptApiKeySetupIfNeeded(): Promise<void> {
    try {
      const configured: boolean = await AIService.getInstance().isApiKeyConfigured();
      if (configured) {
        return;
      }
      const result: promptAction.ShowDialogSuccessResponse = await promptAction.showDialog({
        title: '配置 AI 服务',
        message: '尚未配置 API Key，知识图谱、争议分析、测评与对话等 AI 功能暂不可用。\n密钥将经 HUKS 加密存储在本机。',
        buttons: [
          { text: '稍后再说', color: '#999999' },
          { text: '去配置', color: '#7C8CFF' }
        ]
      });
      if (result.index === 1) {
        router.pushUrl({ url: 'pages/SettingsPage' });
      }
    } catch (_e) {
      // 弹窗失败不影响首页加载
    }
  }

  private async loadDashboard(): Promise<void> {
    try {
      this.dashboardData = await this.viewModel.loadDashboardData();
    } catch (e) {
      this.dashboardData = this.getDefaultDashboard();
    }
    this.currentQuestion = this.viewModel.getDailyQuestion(this.questionIndex);
  }

  private getDefaultDashboard(): DashboardData {
    return {
      activeCourseTitle: '', progress: 0, currentStep: 0,
      hasActiveCourse: false, studyMinutes: 0, knowledgeCount: 0,
      streakDays: 0, dailyQuestion: '', dailyQuestionSource: '',
      dailyQuestionDifficulty: 'medium'
    };
  }

  private onChangeQuestion(): void {
    this.questionIndex++;
    this.currentQuestion = this.viewModel.getDailyQuestion(this.questionIndex);
  }

  private onContinueLearning(): void {
    router.pushUrl({ url: 'pages/LearningHome' });
  }

  private onNewCourse(): void {
    this.newCourseTitle = '';
    this.createDialogController.open();
  }

  private async onCreateFromTemplate(): Promise<void> {
    if (!this.newCourseTitle || this.newCourseTitle.trim().length === 0) return;
    try {
      await this.viewModel.createCourse(this.newCourseTitle.trim());
      promptAction.showToast({ message: '\u8BFE\u7A0B\u521B\u5EFA\u6210\u529F' });
      this.loadDashboard();
    } catch (e) {
      promptAction.showToast({ message: '\u521B\u5EFA\u5931\u8D25' });
    }
  }

  private onUseTemplate(title: string): void {
    this.newCourseTitle = title;
    this.createDialogController.open();
  }

  build() {
    Stack() {
      // Background
      DynamicBackground().width('100%').height('100%')
      Column().width('100%').height('100%').backgroundColor('rgba(8,12,30,0.35)')

      // Scrollable content
      Scroll() {
        Column() {
          // L1: Greeting
          GreetingHeader({
            userName: '\u4E09\u95EE\u667A\u5B66\u5458',
            currentHour: this.currentHour
          })

          Blank().height(16)

          // L2: Today Card
          TodayCard({
            courseTitle: this.dashboardData?.activeCourseTitle ?? '',
            progress: this.dashboardData?.progress ?? 0,
            currentStep: this.dashboardData?.currentStep ?? 0,
            hasActiveCourse: this.dashboardData?.hasActiveCourse ?? false,
            onContinue: () => { this.onContinueLearning(); }
          })

          Blank().height(16)

          // L3: Daily Question
          if (this.currentQuestion) {
            DailyQuestion({
              question: this.currentQuestion.question,
              sourceCourse: this.currentQuestion.source,
              difficulty: this.currentQuestion.difficulty,
              onThink: () => { router.pushUrl({ url: 'pages/LearningHome' }); },
              onChange: () => { this.onChangeQuestion(); }
            })
          }

          Blank().height(16)

          // L4: Quick Actions
          QuickActions({
            onNewCourse: () => { this.onNewCourse(); },
            onUpload: () => { router.pushUrl({ url: 'pages/LearningHome' }); },
            onAssess: () => { router.pushUrl({ url: 'pages/Assessment' }); },
            onReport: () => { router.pushUrl({ url: 'pages/AssessmentResult' }); }
          })

          Blank().height(16)

          // L5: Weekly Stats
          WeeklyStats({
            studyMinutes: this.dashboardData?.studyMinutes ?? 0,
            knowledgeCount: this.dashboardData?.knowledgeCount ?? 0,
            streakDays: this.dashboardData?.streakDays ?? 0
          })

          Blank().height(16)

          // L6: Discover
          DiscoverSection({
            onUseTemplate: (title: string) => { this.onUseTemplate(title); },
            onStartPath: () => { promptAction.showToast({ message: '\u529F\u80FD\u5F00\u53D1\u4E2D' }); }
          })

          Blank().height(72)
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .width('100%').height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      // Bottom TabBar
      BottomTabBar({ activeTab: 'home' })
        .position({ bottom: 0, left: 0 })
    }
    .width('100%').height('100%')
  }
}
