/**
 * CourseViewModel - 课程详情页状态管理
 * 遵循 MVVM 模式：Pages→ViewModels→Services
 * 严禁导入 UI 组件
 */
import { CourseService } from '../services/CourseService';
import { MaterialParser } from '../services/MaterialParser';
import { Course, Material } from '../models/Models';
import { ErrorCode } from '../common/ErrorCode';

export class CourseViewModel {
  // ---- 页面状态 ----
  course: Course | null = null;
  isLoading: boolean = false;
  errorMessage: string = '';
  materials: Material[] = [];

  // ---- 服务实例 ----
  private courseService: CourseService = new CourseService();
  private materialParser: MaterialParser = MaterialParser.getInstance();

  constructor() {}

  /**
   * 根据课程 ID 加载课程详情
   * 同步获取课程元数据 + 资料列表（当前版本资料列表为占位）
   */
  async loadCourse(courseId: string): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      this.course = await this.courseService.getCourseById(courseId);
      if (!this.course) {
        this.errorMessage = ErrorCode.COURSE_NOT_FOUND;
      }
      // [未来迭代] 资料列表：await this.courseService.getAllMaterials(courseId)
      this.materials = [];
    } catch (e) {
      this.errorMessage = `加载课程失败: ${this.formatError(e)}`;
      this.course = null;
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 级联删除课程（事务 + 物理文件清理）
   */
  async deleteCourse(courseId: string): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      await this.courseService.cascadeDeleteCourse(courseId);
      this.course = null;
    } catch (e) {
      this.errorMessage = `删除课程失败: ${this.formatError(e)}`;
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 计算 Q1 进度（0~33）
   * 严格防止除零：q1_total_core_count === 0 时返回 0
   * @returns Q1 进度百分比
   */
  calcProgress(): number {
    if (!this.course) {
      return 0;
    }
    return this.courseService.calcQ1Progress(this.course);
  }

  /**
   * 更新 Q1 点亮计数
   * @param activatedCount 已点亮核心节点数
   * @param totalCoreCount 核心节点总数
   */
  async updateProgress(activatedCount: number, totalCoreCount: number): Promise<void> {
    if (!this.course) {
      return;
    }
    this.isLoading = true;
    this.errorMessage = '';
    try {
      await this.courseService.updateQ1Counts(this.course.id, activatedCount, totalCoreCount);
      // 同步更新本地 course 对象
      this.course.q1_activated_count = activatedCount;
      this.course.q1_total_core_count = totalCoreCount;
    } catch (e) {
      this.errorMessage = `更新进度失败: ${this.formatError(e)}`;
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 检查课程是否为 null
   */
  hasCourse(): boolean {
    return this.course !== null;
  }

  // ---- 辅助 ----

  private formatError(e: Object): string {
    if (e instanceof Error) {
      return e.message;
    }
    return String(e);
  }
}
