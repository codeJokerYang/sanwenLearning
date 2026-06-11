/**
 * ThreeAskViewModel - 三问流程状态机
 * 遵循 MVVM：Pages→ViewModels→Services，严禁导入 UI 组件
 */
import { CourseService } from '../services/CourseService';
import { AIService } from '../services/AIService';
import { EvaluationService } from '../services/EvaluationService';
import { RdbHelper } from '../db/RdbHelper';
import { Logger } from '../common/Logger';
import { ANTI_CHEAT_CONFIG } from '../common/Config';
import { CourseStatus, NodeType, CorrectStatus } from '../models/Models';
import {
  KnowledgeNode, KnowledgeEdge, Controversy, QuizQuestion, QuestionRecord
} from '../models/Models';
import { relationalStore } from '@kit.ArkData';
import { ErrorCode } from '../common/ErrorCode';
import { NetworkMonitor } from '../services/NetworkMonitor';

const TAG = 'THREE_ASK_VM';

export class ThreeAskViewModel {
  currentStep: number = 0;
  isLoading: boolean = false;
  errorMessage: string = '';
  streamText: string = '';
  nodes: KnowledgeNode[] = [];
  edges: KnowledgeEdge[] = [];
  q1Completed: boolean = false;
  controversies: Controversy[] = [];
  q2Completed: boolean = false;
  questions: QuizQuestion[] = [];
  q3Completed: boolean = false;
  inputStartTime: number = 0;
  isSuspect: boolean = false;
  bloomRetryCount: number = 0;
  readonly BLOOM_MAX_RETRIES: number = 2;
  private courseService: CourseService = new CourseService();
  private aiService: AIService = AIService.getInstance();
  private evaluationService: EvaluationService = EvaluationService.getInstance();
  private rdb: RdbHelper = RdbHelper.getInstance();

  // === Q1 ===
  async startQ1(courseId: string): Promise<void> {
    this.isLoading = true; this.errorMessage = '';
    try {
      // Check for valid materials before starting Q1
      const parsedContents = await this.collectParsedContents(courseId);
      if (!parsedContents || parsedContents.length === 0) {
        this.errorMessage = ErrorCode.NO_VALID_MATERIAL;
        return;
      }
      this.currentStep = 1;
      await this.loadNodesAndEdges(courseId);
      await this.courseService.updateCourseStatus(courseId, CourseStatus.Q1_ACTIVE);
    } catch (e) { this.errorMessage = `启动第一问失败: ${this.fmt(e)}`; }
    finally { this.isLoading = false; }
  }
  async callAiGenerateKnowledgeGraph(courseId: string): Promise<void> {
    this.isLoading = true; this.errorMessage = '';
    try {
      if (!NetworkMonitor.getInstance().isNetworkAvailable()) {
        this.errorMessage = ErrorCode.NETWORK_DISCONNECTED;
        return;
      }
      await this.aiService.generateKnowledgeGraph(courseId, await this.collectParsedContents(courseId));
      await this.loadNodesAndEdges(courseId);
    } catch (e) { this.errorMessage = `AI 生成知识图谱失败: ${this.fmt(e)}`; }
    finally { this.isLoading = false; }
  }
  async activateNode(courseId: string, nodeId: string): Promise<void> {
    this.isLoading = true; this.errorMessage = '';
    try {
      await this.rdb.execute('UPDATE knowledge_node SET is_activated = ? WHERE id = ? AND course_id = ?',
        [RdbHelper.boolToDb(true), nodeId, courseId]);
      const node = this.nodes.find(n => n.id === nodeId);
      if (node) node.is_activated = true;
      const cn = this.nodes.filter(n => n.type === NodeType.CORE);
      const ac = cn.filter(n => n.is_activated);
      if (cn.length > 0 && ac.length === cn.length) await this.onQ1Completed(courseId, ac.length, cn.length);
    } catch (e) { this.errorMessage = `点亮节点失败: ${this.fmt(e)}`; }
    finally { this.isLoading = false; }
  }
  async onQ1Completed(courseId: string, ac: number, tc: number): Promise<void> {
    this.q1Completed = true;
    await this.courseService.updateQ1Counts(courseId, ac, tc);
    await this.courseService.updateCourseStatus(courseId, CourseStatus.Q2_ACTIVE);
    await this.courseService.updateCourseStep(courseId, 2, 33);
    Logger.getInstance().info(TAG, `Q1 completed: ${courseId}`);
  }
  // === Q2 ===
  async startQ2(courseId: string): Promise<void> {
    this.isLoading = true; this.errorMessage = '';
    try { this.currentStep = 2; await this.loadControversies(courseId); }
    catch (e) { this.errorMessage = `启动第二问失败: ${this.fmt(e)}`; }
    finally { this.isLoading = false; }
  }
  async callAiGenerateControversies(courseId: string): Promise<void> {
    this.isLoading = true; this.errorMessage = '';
    try {
      if (!NetworkMonitor.getInstance().isNetworkAvailable()) {
        this.errorMessage = ErrorCode.NETWORK_DISCONNECTED;
        return;
      }
      await this.aiService.generateControversies(courseId, await this.collectParsedContents(courseId));
      await this.loadControversies(courseId);
    } catch (e) { this.errorMessage = `AI 生成争议失败: ${this.fmt(e)}`; }
    finally { this.isLoading = false; }
  }
  async submitInsight(courseId: string, controversyId: string, userAnswer: string): Promise<QuestionRecord | null> {
    this.isLoading = true; this.errorMessage = '';
    try {
      const suspect = this.detectCheat(userAnswer);
      const cv = this.controversies.find(c => c.id === controversyId);
      const record: QuestionRecord = {
        id: this.uuid(), course_id: courseId, step: 2, quiz_question_id: null,
        controversy_id: controversyId, question_content: cv ? cv.title : '',
        user_original_answer: userAnswer, ai_evaluation: null, standard_answer: null,
        is_correct: CorrectStatus.PENDING, is_suspect: suspect, create_time: Date.now()
      };
      await this.insertQuestionRecord(record);
      this.inputStartTime = 0;
      return record;
    } catch (e) { this.errorMessage = `提交见解失败: ${this.fmt(e)}`; return null; }
    finally { this.isLoading = false; }
  }
  async submitInsightForEvaluation(courseId: string, recordId: string, userAnswer: string): Promise<void> {
    this.isLoading = true; this.errorMessage = '';
    try {
      if (!NetworkMonitor.getInstance().isNetworkAvailable()) {
        this.errorMessage = ErrorCode.NETWORK_DISCONNECTED;
        return;
      }
      const ev = await this.aiService.evaluateAnswer(courseId, userAnswer, '');
      await this.rdb.execute('UPDATE question_record SET ai_evaluation = ? WHERE id = ?', [ev, recordId]);
    } catch (e) { this.errorMessage = `AI 评价失败: ${this.fmt(e)}`; }
    finally { this.isLoading = false; }
  }
  async skipEvaluation(courseId: string, recordId: string): Promise<void> {
    this.isLoading = true; this.errorMessage = '';
    try {
      await this.rdb.execute('UPDATE question_record SET ai_evaluation = ? WHERE id = ?',
        ['AI评价失败，用户手动跳过', recordId]);
      await this.onQ2Completed(courseId);
    } catch (e) { this.errorMessage = `跳过评价失败: ${this.fmt(e)}`; }
    finally { this.isLoading = false; }
  }
  async onQ2Completed(courseId: string): Promise<void> {
    this.q2Completed = true;
    await this.courseService.updateCourseStatus(courseId, CourseStatus.Q3_ACTIVE);
    await this.courseService.updateCourseStep(courseId, 3, 66);
    Logger.getInstance().info(TAG, `Q2 completed: ${courseId}`);
  }
  // === Q3 ===
  async startQ3(courseId: string): Promise<void> {
    this.isLoading = true; this.errorMessage = '';
    try {
      if (!NetworkMonitor.getInstance().isNetworkAvailable()) {
        this.errorMessage = ErrorCode.NETWORK_DISCONNECTED;
        return;
      }
      this.currentStep = 3;
      await this.aiService.generateQuizQuestions(courseId, await this.collectParsedContents(courseId),
        this.nodes.map(n => n.id));
      await this.loadQuizQuestions(courseId);
      this.bloomRetryCount = 0;
    } catch (e) { await this.onBloomValidationFailed(courseId, String(e)); }
    finally { this.isLoading = false; }
  }
  async onBloomValidationFailed(courseId: string, err: string): Promise<void> {
    this.bloomRetryCount++;
    if (this.bloomRetryCount < this.BLOOM_MAX_RETRIES) {
      this.errorMessage = `题目生成校验未通过，正在重试 (${this.bloomRetryCount}/${this.BLOOM_MAX_RETRIES})...`;
      await this.startQ3(courseId);
    } else {
      this.errorMessage = 'AI 题目生成校验失败，请点击按钮手动重试';
      Logger.getInstance().error(TAG, `Bloom exhausted: ${err}`);
    }
  }
  async submitAnswer(courseId: string, questionId: string, userAnswer: string): Promise<QuestionRecord | null> {
    this.isLoading = true; this.errorMessage = '';
    try {
      const suspect = this.detectCheat(userAnswer);
      const q = this.questions.find(q => q.id === questionId);
      if (!q) { this.errorMessage = ErrorCode.QUIZ_NOT_FOUND; return null; }
      const isCorrect: CorrectStatus = (!q.options || q.options === '') ? CorrectStatus.SUBJECTIVE :
        (userAnswer.trim() === q.correct_answer.trim() ? CorrectStatus.TRUE : CorrectStatus.FALSE);
      const record: QuestionRecord = {
        id: this.uuid(), course_id: courseId, step: 3, quiz_question_id: questionId,
        controversy_id: null, question_content: q.question_text, user_original_answer: userAnswer,
        ai_evaluation: null, standard_answer: q.correct_answer,
        is_correct: isCorrect, is_suspect: suspect, create_time: Date.now()
      };
      await this.insertQuestionRecord(record);
      this.inputStartTime = 0;
      const c = await this.rdb.query(
        'SELECT COUNT(*) AS cnt FROM question_record WHERE course_id = ? AND step = 3', [courseId]);
      let ct = 0; if (c.goToFirstRow()) ct = c.getLong(c.getColumnIndex('cnt')).valueOf();
      c.close(); if (ct >= 9) await this.onQ3Completed(courseId);
      return record;
    } catch (e) { this.errorMessage = `提交答案失败: ${this.fmt(e)}`; return null; }
    finally { this.isLoading = false; }
  }
  async onQ3Completed(courseId: string): Promise<void> {
    this.q3Completed = true; this.isLoading = true;
    try {
      await this.evaluationService.generateReport(courseId);
      await this.courseService.updateCourseStatus(courseId, CourseStatus.COMPLETED);
      await this.courseService.updateCourseStep(courseId, 4, 100);
      Logger.getInstance().info(TAG, `Q3 completed: ${courseId}`);
    } catch (e) { this.errorMessage = `生成报告失败: ${this.fmt(e)}`; }
    finally { this.isLoading = false; }
  }
  // === 防呆 ===
  calcInputSpeed(len: number, st: number): number {
    if (st <= 0 || len <= 0) return 0;
    const em = (Date.now() - st) / 60000;
    return em > 0 ? Math.round(len / em) : 0;
  }
  recordInputStart(): void {
    if (this.inputStartTime === 0) this.inputStartTime = Date.now();
  }
  private detectCheat(a: string): boolean {
    if (a.length < 10) return false;
    if (this.inputStartTime > 0 && this.calcInputSpeed(a.length, this.inputStartTime) > ANTI_CHEAT_CONFIG.SPEED_THRESHOLD) {
      this.isSuspect = true; return true;
    }
    return false;
  }
  // === DB ===
  private mapNode(c: relationalStore.ResultSet): KnowledgeNode {
    try {
      return {
        id: c.getString(c.getColumnIndex('id')), course_id: c.getString(c.getColumnIndex('course_id')),
        label: c.getString(c.getColumnIndex('label')), type: c.getString(c.getColumnIndex('type')) as NodeType,
        description: c.getString(c.getColumnIndex('description')),
        is_activated: RdbHelper.boolFromDb(c.getLong(c.getColumnIndex('is_activated')).valueOf()),
        x_pos: c.getDouble(c.getColumnIndex('x_pos')), y_pos: c.getDouble(c.getColumnIndex('y_pos')),
        sort_order: c.getLong(c.getColumnIndex('sort_order')).valueOf()
      }
    } catch (e) {
      Logger.getInstance().error(TAG, 'mapNode failed', String(e))
      throw new Error(`mapNode failed: ${String(e)}`)
    }
  }
  private mapEdge(c: relationalStore.ResultSet): KnowledgeEdge {
    try {
      return {
        id: c.getString(c.getColumnIndex('id')), course_id: c.getString(c.getColumnIndex('course_id')),
        source: c.getString(c.getColumnIndex('source')), target: c.getString(c.getColumnIndex('target')),
        relation: c.getString(c.getColumnIndex('relation'))
      }
    } catch (e) {
      Logger.getInstance().error(TAG, 'mapEdge failed', String(e))
      throw new Error(`mapEdge failed: ${String(e)}`)
    }
  }
  private mapControversy(c: relationalStore.ResultSet): Controversy {
    try {
      return {
        id: c.getString(c.getColumnIndex('id')), course_id: c.getString(c.getColumnIndex('course_id')),
        title: c.getString(c.getColumnIndex('title')), view_a: c.getString(c.getColumnIndex('view_a')),
        evidence_a: c.getString(c.getColumnIndex('evidence_a')), view_b: c.getString(c.getColumnIndex('view_b')),
        evidence_b: c.getString(c.getColumnIndex('evidence_b')), conclusion: c.getString(c.getColumnIndex('conclusion')),
        is_selected: RdbHelper.boolFromDb(c.getLong(c.getColumnIndex('is_selected')).valueOf()),
        sort_order: c.getLong(c.getColumnIndex('sort_order')).valueOf()
      }
    } catch (e) {
      Logger.getInstance().error(TAG, 'mapControversy failed', String(e))
      throw new Error(`mapControversy failed: ${String(e)}`)
    }
  }
  private mapQuestion(c: relationalStore.ResultSet): QuizQuestion {
    try {
      return {
        id: c.getString(c.getColumnIndex('id')), course_id: c.getString(c.getColumnIndex('course_id')),
        bloom_level: c.getLong(c.getColumnIndex('bloom_level')).valueOf(),
        linked_node_ids: c.getString(c.getColumnIndex('linked_node_ids')),
        question_text: c.getString(c.getColumnIndex('question_text')), options: c.getString(c.getColumnIndex('options')),
        correct_answer: c.getString(c.getColumnIndex('correct_answer')),
        sort_order: c.getLong(c.getColumnIndex('sort_order')).valueOf()
      }
    } catch (e) {
      Logger.getInstance().error(TAG, 'mapQuestion failed', String(e))
      throw new Error(`mapQuestion failed: ${String(e)}`)
    }
  }
  private async loadAll<T>(sql: string, args: (string | number)[], mapper: (c: relationalStore.ResultSet) => T): Promise<T[]> {
    let c: relationalStore.ResultSet | null = null;
    try {
      c = await this.rdb.query(sql, args);
      const r: T[] = [];
      while (c.goToNextRow()) {
        try {
          r.push(mapper(c));
        } catch (e) {
          Logger.getInstance().error(TAG, 'loadAll: row mapping failed', String(e));
        }
      }
      return r;
    } catch (e) {
      Logger.getInstance().error(TAG, `loadAll failed: ${sql}`, String(e));
      return [];
    } finally {
      if (c) {
        try {
          c.close();
        } catch (_e) {
          // cursor 关闭失败静默处理
        }
      }
    }
  }
  private async loadNodesAndEdges(courseId: string): Promise<void> {
    this.nodes = await this.loadAll('SELECT * FROM knowledge_node WHERE course_id = ? ORDER BY sort_order ASC',
      [courseId], (c: relationalStore.ResultSet): KnowledgeNode => this.mapNode(c));
    this.edges = await this.loadAll('SELECT * FROM knowledge_edge WHERE course_id = ?',
      [courseId], (c: relationalStore.ResultSet): KnowledgeEdge => this.mapEdge(c));
  }
  private async loadControversies(courseId: string): Promise<void> {
    this.controversies = await this.loadAll(
      'SELECT * FROM controversy WHERE course_id = ? ORDER BY sort_order ASC', [courseId],
      (c: relationalStore.ResultSet): Controversy => this.mapControversy(c));
  }
  private async loadQuizQuestions(courseId: string): Promise<void> {
    this.questions = await this.loadAll(
      'SELECT * FROM quiz_question WHERE course_id = ? ORDER BY sort_order ASC', [courseId],
      (c: relationalStore.ResultSet): QuizQuestion => this.mapQuestion(c));
  }
  private async collectParsedContents(courseId: string): Promise<string[]> {
    let c: relationalStore.ResultSet | null = null;
    try {
      c = await this.rdb.query(
        'SELECT parsed_content FROM material WHERE course_id = ? AND status = ? AND parsed_content IS NOT NULL',
        [courseId, 'success']);
      const r: string[] = [];
      while (c.goToNextRow()) {
        try {
          const t = c.getString(c.getColumnIndex('parsed_content'));
          if (t) r.push(t);
        } catch (_e) {
          // 行读取失败跳过
        }
      }
      return r;
    } catch (e) {
      Logger.getInstance().error(TAG, `collectParsedContents failed: ${courseId}`, String(e));
      return [];
    } finally {
      if (c) {
        try {
          c.close();
        } catch (_e) {
          // cursor 关闭失败静默处理
        }
      }
    }
  }
  private async insertQuestionRecord(r: QuestionRecord): Promise<void> {
    await this.rdb.insert('question_record', {
      'id': r.id, 'course_id': r.course_id, 'step': r.step,
      'quiz_question_id': r.quiz_question_id, 'controversy_id': r.controversy_id,
      'question_content': r.question_content, 'user_original_answer': r.user_original_answer,
      'ai_evaluation': r.ai_evaluation, 'standard_answer': r.standard_answer,
      'is_correct': r.is_correct, 'is_suspect': RdbHelper.boolToDb(r.is_suspect), 'create_time': r.create_time
    });
  }
  private uuid(): string {
    const h = '0123456789abcdef'; let s = '';
    for (let i = 0; i < 36; i++) {
      if (i === 8 || i === 13 || i === 18 || i === 23) {
        s += '-';
      } else if (i === 14) {
        s += '4';
      } else if (i === 19) {
        const idx: number = (Math.random() * 4 | 0) + 8;
        s += h.charAt(idx);
      } else {
        const idx: number = Math.random() * 16 | 0;
        s += h.charAt(idx);
      }
    }
    return s;
  }
  private fmt(e: Object): string { return e instanceof Error ? e.message : String(e); }
}
