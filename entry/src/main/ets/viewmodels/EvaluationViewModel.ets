/**
 * EvaluationViewModel - 评价报告页状态管理
 * 遵循 MVVM 模式：Pages→ViewModels→Services
 * 严禁导入 UI 组件
 */
import { EvaluationService } from '../services/EvaluationService';
import { EvaluationReport } from '../models/Models';
import { ErrorCode } from '../common/ErrorCode';
import { NetworkMonitor } from '../services/NetworkMonitor';

export class EvaluationViewModel {
  // ---- 页面状态 ----
  report: EvaluationReport | null = null;
  isLoading: boolean = false;
  errorMessage: string = '';

  // ---- 服务实例 ----
  private evaluationService: EvaluationService = EvaluationService.getInstance();

  constructor() {}

  /**
   * 生成课程评价报告
   * 评分规则：Q1=20%, Q2=40%, Q3=40%
   * 5 章节：学习总览、三问回顾、能力雷达图、错题溯源、诚信声明
   */
  async generateReport(courseId: string): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      if (!NetworkMonitor.getInstance().isNetworkAvailable()) {
        this.errorMessage = ErrorCode.NETWORK_DISCONNECTED;
        return;
      }
      this.report = await this.evaluationService.generateReport(courseId);
      if (!this.report) {
        this.errorMessage = ErrorCode.REPORT_NO_DATA;
      }
    } catch (e) {
      this.errorMessage = `生成报告失败: ${this.formatError(e)}`;
      this.report = null;
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 导出评价报告为 Markdown 文本
   * @returns Markdown 文本内容，失败返回空字符串
   */
  async exportReport(): Promise<string> {
    if (!this.report) {
      this.errorMessage = ErrorCode.REPORT_NO_EXPORT;
      return '';
    }
    this.isLoading = true;
    this.errorMessage = '';
    try {
      return await this.evaluationService.exportMarkdown(this.report);
    } catch (e) {
      this.errorMessage = `导出报告失败: ${this.formatError(e)}`;
      return '';
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 获取布鲁姆6层级得分
   * @returns 层级得分映射 { 1: 得分, 2: 得分, ... 6: 得分 }
   */
  getBloomScores(): Map<number, number> {
    return this.report?.bloom_scores ?? new Map();
  }

  /**
   * 获取总分（Q1 + Q2 + Q3）
   * @returns 总分，无报告时返回 0
   */
  getTotalScore(): number {
    if (!this.report) {
      return 0;
    }
    return this.report.total_score;
  }

  /**
   * 检查报告是否已生成
   */
  hasReport(): boolean {
    return this.report !== null;
  }

  // ---- 辅助 ----

  private formatError(e: Object): string {
    if (e instanceof Error) {
      return e.message;
    }
    return String(e);
  }
}
