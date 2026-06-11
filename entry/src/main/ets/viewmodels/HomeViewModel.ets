/**
 * HomeViewModel - 首页课程列表状态管理
 * 遵循 MVVM 模式：Pages→ViewModels→Services
 * 严禁导入 UI 组件
 */
import { CourseService } from '../services/CourseService';
import { AIService } from '../services/AIService';
import { Course } from '../models/Models';
import { router } from '@kit.ArkUI';
import { Logger } from '../common/Logger';
import { ErrorCode } from '../common/ErrorCode';
import { NetworkMonitor } from '../services/NetworkMonitor';

const TAG = 'HOME_VM';

interface DashboardData {
  activeCourseTitle: string;
  progress: number;
  currentStep: number;
  hasActiveCourse: boolean;
  studyMinutes: number;
  knowledgeCount: number;
  streakDays: number;
  dailyQuestion: string;
  dailyQuestionSource: string;
  dailyQuestionDifficulty: string;
}

interface DailyQuestionData {
  question: string;
  source: string;
  difficulty: string;
}

export { DashboardData, DailyQuestionData };

export class HomeViewModel {
  // ---- 页面状态 ----
  courseList: Course[] = [];
  isLoading: boolean = false;
  errorMessage: string = '';
  searchQuery: string = '';

  // ---- 服务实例（组合，非继承） ----
  private courseService: CourseService = new CourseService();
  private aiService: AIService = AIService.getInstance();

  constructor() {}

  /**
   * 加载全部课程列表
   * 按创建时间倒序：getAllCourses 内部已 ORDER BY create_time DESC
   */
  async loadCourses(): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      const result: Course[] = await this.courseService.getAllCourses();
      this.courseList = result ?? [];
    } catch (e) {
      this.errorMessage = `加载课程失败: ${this.formatError(e)}`;
      this.courseList = [];
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 级联删除课程（事务 + 物理文件清理）
   * 删除成功后自动刷新列表
   */
  async deleteCourse(courseId: string): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      await this.courseService.cascadeDeleteCourse(courseId);
      await this.loadCourses();
    } catch (e) {
      this.errorMessage = `删除课程失败: ${this.formatError(e)}`;
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 跳转至课程学习空间（三问流程入口）
   * 路由参数仅基本类型（string）
   */
  selectCourse(courseId: string): void {
    try {
      router.pushUrl({
        url: 'pages/LearningSpace',
        params: {
          courseId: courseId
        }
      });
    } catch (e) {
      Logger.getInstance().error(TAG, `selectCourse pushUrl failed: ${courseId}`, String(e));
    }
  }

  /**
   * 创建新课程
   * @param title 课程标题（非空校验）
   */
  async createCourse(title: string): Promise<Course | null> {
    if (!title || title.trim().length === 0) {
      this.errorMessage = ErrorCode.COURSE_TITLE_EMPTY;
      return null;
    }
    this.isLoading = true;
    this.errorMessage = '';
    try {
      const course = await this.courseService.createCourse(title.trim());
      await this.loadCourses();
      return course;
    } catch (e) {
      this.errorMessage = `创建课程失败: ${this.formatError(e)}`;
      return null;
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * AI 智能推荐（占位）
   * 后续迭代接入 AIService.generateRecommendations
   */
  async generateAiRecommendations(): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      if (!NetworkMonitor.getInstance().isNetworkAvailable()) {
        this.errorMessage = ErrorCode.NETWORK_DISCONNECTED;
        return;
      }
      // Placeholder: AI 推荐功能尚未实现
      // const result = await this.aiService.generateRecommendations(...)
      this.errorMessage = 'AI 推荐功能开发中，敬请期待';
    } catch (e) {
      this.errorMessage = `AI 推荐失败: ${this.formatError(e)}`;
    } finally {
      this.isLoading = false;
    }
  }

  // ---- Dashboard 数据 ----

  /** 获取当前时段问候语 key */
  getGreetingByHour(hour: number): string {
    if (hour >= 6 && hour < 12) return 'app.string.home_greeting_morning';
    if (hour >= 12 && hour < 15) return 'app.string.home_greeting_noon';
    if (hour >= 15 && hour < 19) return 'app.string.home_greeting_afternoon';
    if (hour >= 19 && hour < 24) return 'app.string.home_greeting_evening';
    return 'app.string.home_greeting_night';
  }

  /** 获取时段装饰图标 */
  getGreetingIcon(hour: number): string {
    if (hour >= 6 && hour < 17) return '\u2600\uFE0F';
    if (hour >= 17 && hour < 20) return '\u26C5';
    return '\u{1F319}';
  }

  /** 加载 Dashboard 聚合数据（mock fallback） */
  async loadDashboardData(): Promise<DashboardData> {
    const data: DashboardData = {
      activeCourseTitle: '',
      progress: 0,
      currentStep: 0,
      hasActiveCourse: false,
      studyMinutes: 0,
      knowledgeCount: 0,
      streakDays: 0,
      dailyQuestion: '\u5982\u679C\u77E5\u8BC6\u662F\u4E00\u68F5\u6811\uFF0C\u5B83\u7684\u6839\u662F\u4EC0\u4E48\uFF1F',
      dailyQuestionSource: 'AI \u63A8\u8350',
      dailyQuestionDifficulty: 'medium'
    };
    try {
      const courses: Course[] = await this.courseService.getAllCourses();
      const active: Course | undefined = (courses ?? []).find((c: Course) =>
        c.status !== undefined && c.status >= 1 && c.status <= 3
      );
      if (active) {
        data.activeCourseTitle = active.title;
        data.progress = active.progress ?? 0;
        data.currentStep = active.current_step ?? 0;
        data.hasActiveCourse = true;
      }
      data.studyMinutes = (courses ?? []).length * 42;
      data.knowledgeCount = (courses ?? []).length * 8;
      data.streakDays = Math.min((courses ?? []).length, 7);
    } catch (e) {
      Logger.getInstance().error(TAG, 'loadDashboardData failed', String(e));
    }
    return data;
  }

  /** 获取每日问题（5 题 mock 题库循环） */
  getDailyQuestion(index: number): DailyQuestionData {
    const questions: DailyQuestionData[] = [
      { question: '\u5982\u679C\u77E5\u8BC6\u662F\u4E00\u68F5\u6811\uFF0C\u5B83\u7684\u6839\u662F\u4EC0\u4E48\uFF1F', source: 'AI \u63A8\u8350', difficulty: 'medium' },
      { question: '\u4E3A\u4EC0\u4E48\u5B66\u4E60\u9700\u8981\u95EE\u9898\u800C\u4E0D\u662F\u7B54\u6848\uFF1F', source: 'AI \u63A8\u8350', difficulty: 'hard' },
      { question: '\u4F60\u6700\u8FD1\u5B66\u5230\u7684\u6700\u91CD\u8981\u7684\u6982\u5FF5\u662F\u4EC0\u4E48\uFF1F', source: 'AI \u63A8\u8350', difficulty: 'easy' },
      { question: '\u5982\u679C\u7528\u4E00\u53E5\u8BDD\u89E3\u91CA\u4F60\u7684\u4E13\u4E1A\uFF0C\u4F60\u4F1A\u600E\u4E48\u8BF4\uFF1F', source: 'AI \u63A8\u8350', difficulty: 'medium' },
      { question: '\u6279\u5224\u6027\u601D\u7EF4\u548C\u521B\u9020\u6027\u601D\u7EF4\u54EA\u4E2A\u66F4\u91CD\u8981\uFF1F', source: 'AI \u63A8\u8350', difficulty: 'hard' },
    ];
    return questions[index % questions.length];
  }

  // ---- 辅助 ----

  private formatError(e: Object): string {
    if (e instanceof Error) {
      return e.message;
    }
    return String(e);
  }
}
