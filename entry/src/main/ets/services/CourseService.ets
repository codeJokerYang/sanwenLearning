/**
 * 三问高效学习机 — CourseService 课程 CRUD 服务
 * 遵循 FEATURE_RULES.md + DATA_CONTRACT.md
 * 所有 SQL 使用参数化 ? 占位符
 */
import { RdbHelper } from '../db/RdbHelper';
import { Course, KnowledgeNode, CourseStatus, BloomLevel, NodeType } from '../models/Models';
import { Logger } from '../common/Logger';
import { relationalStore } from '@kit.ArkData';
import { fileIo as fs } from '@kit.CoreFileKit';

const TAG = 'COURSE_SERVICE';

/**
 * 生成 UUID v4
 * 严格遵循 RFC 4122 格式：xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
 */
function generateUUID(): string {
  const hex = '0123456789abcdef';
  let uuid = '';
  for (let i = 0; i < 36; i++) {
    if (i === 8 || i === 13 || i === 18 || i === 23) {
      uuid += '-';
    } else if (i === 14) {
      uuid += '4';
    } else if (i === 19) {
      const idx: number = (Math.random() * 4 | 0) + 8;
      uuid += hex.charAt(idx);
    } else {
      const idx: number = Math.random() * 16 | 0;
      uuid += hex.charAt(idx);
    }
  }
  return uuid;
}

export class CourseService {
  private rdbHelper: RdbHelper;

  constructor() {
    this.rdbHelper = RdbHelper.getInstance();
  }

  /**
   * 创建新课程
   * @param title 课程标题
   * @returns 完整的 Course 对象
   */
  async createCourse(title: string): Promise<Course> {
    const id = generateUUID();
    const createTime = Date.now();

    const course: Course = {
      id: id,
      title: title,
      status: CourseStatus.DRAFT,
      current_step: 0,
      progress: 0,
      ai_summary_context: null,
      q1_activated_count: 0,
      q1_total_core_count: 0,
      create_time: createTime
    };

    const values: relationalStore.ValuesBucket = {
      id: id,
      title: title,
      status: CourseStatus.DRAFT,
      current_step: 0,
      progress: 0,
      ai_summary_context: null,
      q1_activated_count: 0,
      q1_total_core_count: 0,
      create_time: createTime
    };

    const rowCount: number = await this.rdbHelper.insert('course', values);
    if (rowCount <= 0) {
      throw new Error('Course insert returned 0 rows affected');
    }
    Logger.getInstance().info(TAG, `Course created: ${id}`);
    return course;
  }

  /**
   * 获取所有课程，按创建时间倒序排列
   * @returns Course 数组
   */
  async getAllCourses(): Promise<Course[]> {
    let cursor: relationalStore.ResultSet | null = null;
    try {
      cursor = await this.rdbHelper.query(
        'SELECT * FROM course ORDER BY create_time DESC'
      );
      const courses: Course[] = [];
      while (cursor.goToNextRow()) {
        courses.push({
          id: cursor.getString(cursor.getColumnIndex('id')),
          title: cursor.getString(cursor.getColumnIndex('title')),
          status: RdbHelper.longToNumber(cursor, cursor.getColumnIndex('status')),
          current_step: RdbHelper.longToNumber(cursor, cursor.getColumnIndex('current_step')),
          progress: RdbHelper.longToNumber(cursor, cursor.getColumnIndex('progress')),
          ai_summary_context: RdbHelper.getNullableString(cursor, cursor.getColumnIndex('ai_summary_context')),
          q1_activated_count: RdbHelper.longToNumber(cursor, cursor.getColumnIndex('q1_activated_count')),
          q1_total_core_count: RdbHelper.longToNumber(cursor, cursor.getColumnIndex('q1_total_core_count')),
          create_time: RdbHelper.longToNumber(cursor, cursor.getColumnIndex('create_time'))
        });
      }
      return courses;
    } catch (e) {
      Logger.getInstance().error(TAG, 'getAllCourses failed', String(e));
      return [];
    } finally {
      if (cursor) {
        try {
          cursor.close();
        } catch (_e) {
          // cursor 关闭失败静默处理
        }
      }
    }
  }

  /**
   * 根据课程 ID 查询课程
   * @param courseId 课程 UUID
   * @returns Course 或 null
   */
  async getCourseById(courseId: string): Promise<Course | null> {
    return await this.rdbHelper.queryCourseById(courseId);
  }

  /**
   * 更新课程步骤与进度
   * 进度映射：step1→0, step2→0~33, step3→33, step4→66, step5→100
   * @param courseId 课程 ID
   * @param step 当前步骤
   * @param progress 进度百分比
   */
  async updateCourseStep(courseId: string, step: number, progress: number): Promise<void> {
    await this.rdbHelper.execute(
      'UPDATE course SET current_step = ?, progress = ? WHERE id = ?',
      [step, progress, courseId]
    );
    Logger.getInstance().info(TAG, `Course step updated: ${courseId} step=${step} progress=${progress}`);
  }

  /**
   * 更新 Q1 点亮计数
   * @param courseId 课程 ID
   * @param activatedCount 已点亮核心节点数
   * @param totalCoreCount 核心节点总数
   */
  async updateQ1Counts(courseId: string, activatedCount: number, totalCoreCount: number): Promise<void> {
    await this.rdbHelper.execute(
      'UPDATE course SET q1_activated_count = ?, q1_total_core_count = ? WHERE id = ?',
      [activatedCount, totalCoreCount, courseId]
    );
  }

  /**
   * 更新课程状态
   * @param courseId 课程 ID
   * @param status 新状态（遵循 CourseStatus 枚举，严禁跳步）
   */
  async updateCourseStatus(courseId: string, status: CourseStatus): Promise<void> {
    await this.rdbHelper.execute(
      'UPDATE course SET status = ? WHERE id = ?',
      [status, courseId]
    );
    Logger.getInstance().info(TAG, `Course status updated: ${courseId} status=${status}`);
  }

  /**
   * 更新 AI 摘要上下文
   * @param courseId 课程 ID
   * @param context AI 摘要文本
   */
  async updateAiSummaryContext(courseId: string, context: string): Promise<void> {
    await this.rdbHelper.execute(
      'UPDATE course SET ai_summary_context = ? WHERE id = ?',
      [context, courseId]
    );
  }

  /**
   * 级联删除课程及其所有关联数据
   * 严格按照 8 表顺序在事务中删除，物理文件删除在事务提交后执行
   * 删除顺序：ai_request_log → question_record → quiz_question → controversy
   *         → knowledge_edge → knowledge_node → material → course
   * @param courseId 课程 ID
   */
  async cascadeDeleteCourse(courseId: string): Promise<void> {
    // 事务前：查询资料文件路径，供事务提交后物理删除
    let materialPaths: string[] = [];
    try {
      const materialCursor = await this.rdbHelper.query(
        'SELECT file_path FROM material WHERE course_id = ?',
        [courseId]
      );
      while (materialCursor.goToNextRow()) {
        const path = materialCursor.getString(materialCursor.getColumnIndex('file_path'));
        if (path) {
          materialPaths.push(path);
        }
      }
      materialCursor.close();
    } catch (e) {
      Logger.getInstance().warn(TAG, `Failed to query material paths for course: ${courseId}, file cleanup will be skipped`);
    }

    // 事务内级联删除（严格按 8 表顺序、参数化 SQL、严禁 ON DELETE CASCADE）
    await this.rdbHelper.executeInTransaction(async () => {
      // 1. ai_request_log
      await this.rdbHelper.execute(
        'DELETE FROM ai_request_log WHERE course_id = ?',
        [courseId]
      );

      // 2. question_record
      await this.rdbHelper.execute(
        'DELETE FROM question_record WHERE course_id = ?',
        [courseId]
      );

      // 3. quiz_question
      await this.rdbHelper.execute(
        'DELETE FROM quiz_question WHERE course_id = ?',
        [courseId]
      );

      // 4. controversy
      await this.rdbHelper.execute(
        'DELETE FROM controversy WHERE course_id = ?',
        [courseId]
      );

      // 5. knowledge_edge
      await this.rdbHelper.execute(
        'DELETE FROM knowledge_edge WHERE course_id = ?',
        [courseId]
      );

      // 6. knowledge_node
      await this.rdbHelper.execute(
        'DELETE FROM knowledge_node WHERE course_id = ?',
        [courseId]
      );

      // 7. material
      await this.rdbHelper.execute(
        'DELETE FROM material WHERE course_id = ?',
        [courseId]
      );

      // 8. ai_message (ON DELETE CASCADE from ai_conversation, but explicit for safety)
      await this.rdbHelper.execute(
        'DELETE FROM ai_message WHERE conversation_id IN (SELECT id FROM ai_conversation WHERE course_id = ?)',
        [courseId]
      );

      // 9. ai_conversation
      await this.rdbHelper.execute(
        'DELETE FROM ai_conversation WHERE course_id = ?',
        [courseId]
      );

      // 10. course
      await this.rdbHelper.execute(
        'DELETE FROM course WHERE id = ?',
        [courseId]
      );
    });

    // 事务提交成功后：删除物理文件
    if (materialPaths.length > 0) {
      for (const filePath of materialPaths) {
        try {
          if (fs.accessSync(filePath)) {
            fs.unlinkSync(filePath);
            Logger.getInstance().info(TAG, `Physical file deleted: ${filePath}`);
          }
        } catch (e) {
          Logger.getInstance().warn(TAG, `Failed to delete physical file: ${filePath}`);
        }
      }
    }

    Logger.getInstance().info(TAG, `Course cascade deleted: ${courseId}`);
  }

  /**
   * 计算 Q1 进度（0~33）
   * 严禁除零：q1_total_core_count === 0 时返回 0
   * @param course 课程对象
   * @returns Q1 进度 0~33
   */
  calcQ1Progress(course: Course): number {
    if (course.q1_total_core_count === 0) {
      return 0;
    }
    return Math.round((course.q1_activated_count / course.q1_total_core_count) * 33);
  }
}
