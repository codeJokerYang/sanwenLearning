/**
 * 三问高效学习机 — RdbHelper 数据库封装
 * 严格对齐 DATA_CONTRACT.md v2.1 + RELEASE_AND_UPDATE_CONVENTIONS.md
 * 包含：数据库初始化、版本管理、8表+10索引建表、queryCourseById（含类型转换）
 *
 * 类型转换铁律：
 * 1. Long → number：cursor.getLong(idx).valueOf()，严禁直接赋值
 * 2. 0/1 → boolean：getLong(idx).valueOf() === 1
 * 3. NULL → 联合类型：isColumnNull(idx) 判空后赋 null
 */
import { relationalStore } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { Logger } from '../common/Logger'
import { Course } from '../models/Interfaces'
import { CourseStatus } from '../constants/Enums'

const TAG = 'RDB_HELPER'
const DB_NAME: string = 'sanwen_learning.db'
const DB_VERSION: number = 1

// ============================================================
// 建表 SQL（8 表 + 10 索引，与 init.sql 完全一致）
// ============================================================

const INIT_SQL: string = `
-- 1. 课程表
CREATE TABLE IF NOT EXISTS course (
  id                    TEXT    PRIMARY KEY NOT NULL,
  title                 TEXT    NOT NULL,
  status                INTEGER NOT NULL DEFAULT 0,
  current_step          INTEGER NOT NULL DEFAULT 0,
  progress              INTEGER NOT NULL DEFAULT 0,
  ai_summary_context    TEXT,
  q1_activated_count    INTEGER NOT NULL DEFAULT 0,
  q1_total_core_count   INTEGER NOT NULL DEFAULT 0,
  create_time           INTEGER NOT NULL
);

-- 2. 知识节点表
CREATE TABLE IF NOT EXISTS knowledge_node (
  id                    TEXT    PRIMARY KEY NOT NULL,
  course_id             TEXT    NOT NULL,
  label                 TEXT    NOT NULL,
  type                  TEXT    NOT NULL DEFAULT 'core',
  description           TEXT    NOT NULL DEFAULT '',
  is_activated          INTEGER NOT NULL DEFAULT 0,
  x_pos                 REAL    NOT NULL DEFAULT -1,
  y_pos                 REAL    NOT NULL DEFAULT -1,
  sort_order            INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (course_id) REFERENCES course(id)
);

-- 3. 知识边表
CREATE TABLE IF NOT EXISTS knowledge_edge (
  id                    TEXT    PRIMARY KEY NOT NULL,
  course_id             TEXT    NOT NULL,
  source                TEXT    NOT NULL,
  target                TEXT    NOT NULL,
  relation              TEXT    NOT NULL DEFAULT '',
  FOREIGN KEY (course_id) REFERENCES course(id),
  FOREIGN KEY (source) REFERENCES knowledge_node(id),
  FOREIGN KEY (target) REFERENCES knowledge_node(id)
);

-- 4. 测评题目表
CREATE TABLE IF NOT EXISTS quiz_question (
  id                    TEXT    PRIMARY KEY NOT NULL,
  course_id             TEXT    NOT NULL,
  bloom_level           INTEGER NOT NULL,
  linked_node_ids       TEXT    NOT NULL DEFAULT '[]',
  question_text         TEXT    NOT NULL,
  options               TEXT    NOT NULL DEFAULT '',
  correct_answer        TEXT    NOT NULL DEFAULT '',
  sort_order            INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (course_id) REFERENCES course(id)
);

-- 5. 争议表
CREATE TABLE IF NOT EXISTS controversy (
  id                    TEXT    PRIMARY KEY NOT NULL,
  course_id             TEXT    NOT NULL,
  title                 TEXT    NOT NULL,
  view_a                TEXT    NOT NULL DEFAULT '',
  evidence_a            TEXT    NOT NULL DEFAULT '',
  view_b                TEXT    NOT NULL DEFAULT '',
  evidence_b            TEXT    NOT NULL DEFAULT '',
  conclusion            TEXT    NOT NULL DEFAULT '',
  is_selected           INTEGER NOT NULL DEFAULT 0,
  sort_order            INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (course_id) REFERENCES course(id)
);

-- 6. 作答记录表
CREATE TABLE IF NOT EXISTS question_record (
  id                    TEXT    PRIMARY KEY NOT NULL,
  course_id             TEXT    NOT NULL,
  step                  INTEGER NOT NULL,
  quiz_question_id      TEXT,
  controversy_id        TEXT,
  question_content      TEXT    NOT NULL,
  user_original_answer  TEXT    NOT NULL DEFAULT '',
  ai_evaluation         TEXT,
  standard_answer       TEXT,
  is_correct            TEXT    NOT NULL DEFAULT 'pending',
  is_suspect            INTEGER NOT NULL DEFAULT 0,
  create_time           INTEGER NOT NULL,
  FOREIGN KEY (course_id) REFERENCES course(id),
  FOREIGN KEY (quiz_question_id) REFERENCES quiz_question(id) ON DELETE SET NULL,
  FOREIGN KEY (controversy_id) REFERENCES controversy(id) ON DELETE SET NULL
);

-- 7. 资料表
CREATE TABLE IF NOT EXISTS material (
  id                    TEXT    PRIMARY KEY NOT NULL,
  course_id             TEXT    NOT NULL,
  file_name             TEXT    NOT NULL,
  file_path             TEXT    NOT NULL,
  type                  TEXT    NOT NULL DEFAULT 'user_upload',
  status                TEXT    NOT NULL DEFAULT 'pending',
  parsed_content        TEXT,
  FOREIGN KEY (course_id) REFERENCES course(id)
);

-- 8. AI 请求日志表
CREATE TABLE IF NOT EXISTS ai_request_log (
  id                    TEXT    PRIMARY KEY NOT NULL,
  course_id             TEXT    NOT NULL,
  request_type          TEXT    NOT NULL,
  request_prompt        TEXT    NOT NULL DEFAULT '',
  response_body         TEXT    NOT NULL DEFAULT '',
  status                TEXT    NOT NULL DEFAULT 'failed',
  duration_ms           INTEGER NOT NULL DEFAULT 0,
  create_time           INTEGER NOT NULL,
  FOREIGN KEY (course_id) REFERENCES course(id)
);

-- 索引（10 个）
CREATE INDEX idx_material_course ON material(course_id);
CREATE INDEX idx_knode_course ON knowledge_node(course_id);
CREATE INDEX idx_kedge_course ON knowledge_edge(course_id);
CREATE INDEX idx_controversy_course ON controversy(course_id);
CREATE INDEX idx_quiz_course ON quiz_question(course_id);
CREATE INDEX idx_qrecord_course ON question_record(course_id);
CREATE INDEX idx_ailog_course ON ai_request_log(course_id);
CREATE INDEX idx_knode_activated ON knowledge_node(course_id, is_activated);
CREATE INDEX idx_qrecord_time ON question_record(create_time);
CREATE INDEX idx_qrecord_controversy ON question_record(controversy_id);
`

export class RdbHelper {
  private static instance: RdbHelper | null = null
  private store: relationalStore.RdbStore | null = null

  private constructor() {}

  static getInstance(): RdbHelper {
    if (!RdbHelper.instance) {
      RdbHelper.instance = new RdbHelper()
    }
    return RdbHelper.instance
  }

  /**
   * 初始化数据库
   * 仅在 version=0 时执行 init.sql；升级严禁执行 init.sql，必须走 ALTER TABLE
   */
  async init(context: common.Context): Promise<void> {
    this.store = await relationalStore.getRdbStore(context, {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    })

    const currentVersion = this.store.version
    if (currentVersion === 0) {
      // 全新安装：执行 init.sql
      await this.executeInitScript()
      this.store.version = DB_VERSION
      Logger.getInstance().info(TAG, `Database initialized at version ${DB_VERSION}`)
    } else if (currentVersion < DB_VERSION) {
      // 版本升级：走增量迁移
      await this.migrate(currentVersion, DB_VERSION)
    }
  }

  /**
   * 执行初始化建表脚本
   * 按分号分割逐条执行，单条失败记日志但不中断（表可能已存在）
   */
  private async executeInitScript(): Promise<void> {
    if (!this.store) {
      return
    }
    const statements = INIT_SQL
      .split(';')
      .map(s => s.trim())
      .filter(s => s.length > 0 && !s.startsWith('--'))
    for (const sql of statements) {
      try {
        await this.store.executeSql(sql)
      } catch (e) {
        Logger.getInstance().error(TAG, `Init SQL failed: ${sql.substring(0, 80)}`, String(e))
      }
    }
  }

  /**
   * 增量迁移入口
   * 严禁 DROP TABLE，必须向后兼容
   * 必须在代码中有 [DB_MIGRATION] Vx->Vy: 注释
   */
  private async migrate(fromVersion: number, toVersion: number): Promise<void> {
    if (!this.store) {
      return
    }
    for (let v = fromVersion + 1; v <= toVersion; v++) {
      await this.executeMigration(this.store, v)
    }
    this.store.version = toVersion
  }

  // [DB_MIGRATION] 预留：未来版本迁移入口
  private async executeMigration(store: relationalStore.RdbStore, targetVersion: number): Promise<void> {
    switch (targetVersion) {
      // case 2:
      //   [DB_MIGRATION] V1->V2: 迁移描述
      //   await this.migrateV2(store)
      //   break
      default:
        Logger.getInstance().warn(TAG, `No migration for version ${targetVersion}`)
    }
  }

  // ---- 通用 CRUD ----

  async insert(tableName: string, values: relationalStore.ValuesBucket): Promise<number> {
    if (!this.store) {
      return -1
    }
    return await this.store.insert(tableName, values)
  }

  async query(sql: string, args: Array<relationalStore.ValueType> = []): Promise<relationalStore.ResultSet> {
    if (!this.store) {
      throw new Error('RdbStore not initialized')
    }
    return await this.store.querySql(sql, args)
  }

  async update(tableName: string, values: relationalStore.ValuesBucket,
    predicates: relationalStore.RdbPredicates): Promise<number> {
    if (!this.store) {
      return -1
    }
    return await this.store.update(values, predicates)
  }

  async delete(tableName: string, predicates: relationalStore.RdbPredicates): Promise<number> {
    if (!this.store) {
      return -1
    }
    return await this.store.delete(predicates)
  }

  async execute(sql: string, args: Array<relationalStore.ValueType> = []): Promise<void> {
    if (!this.store) {
      return
    }
    await this.store.executeSql(sql, args)
  }

  // ---- 事务 ----

  /**
   * 在事务中执行操作，失败自动回滚
   * 级联删除必须使用此方法确保原子性
   */
  async executeInTransaction(operation: () => Promise<void>): Promise<void> {
    if (!this.store) {
      return
    }
    this.store.beginTransaction()
    try {
      await operation()
      this.store.commit()
    } catch (e) {
      this.store.rollBack()
      Logger.getInstance().error(TAG, 'Transaction failed, rolled back', String(e))
      throw e
    }
  }

  // ---- 类型转换工具（DATA_CONTRACT v2.1 铁律） ----

  /** 布尔值：INTEGER → boolean（0=false, 1=true） */
  static boolFromDb(value: relationalStore.ValueType): boolean {
    return value === 1
  }

  /** 布尔值：boolean → INTEGER */
  static boolToDb(value: boolean): number {
    return value ? 1 : 0
  }

  /**
   * 时间戳/数值：cursor.getLong → number
   * 严禁直接赋值 Long 给 number（ArkTS 严格类型校验报错或运行时精度丢失）
   * 严禁 getString + parseInt（精度丢失风险）
   */
  static longToNumber(cursor: relationalStore.ResultSet, columnIndex: number): number {
    return cursor.getLong(columnIndex).valueOf()
  }

  /**
   * 可空字符串字段读取
   * SQLite 中 NULL 与空字符串 "" 严格区分
   * isColumnNull 判空后赋 null，否则 getString
   */
  static getNullableString(cursor: relationalStore.ResultSet, columnIndex: number): string | null {
    if (cursor.isColumnNull(columnIndex)) {
      return null
    }
    return cursor.getString(columnIndex)
  }

  /**
   * 可空数值字段读取（Long → number）
   * 严禁将 null 存储为空字符串或字符串 "null"
   */
  static getNullableLong(cursor: relationalStore.ResultSet, columnIndex: number): number | null {
    if (cursor.isColumnNull(columnIndex)) {
      return null
    }
    return cursor.getLong(columnIndex).valueOf()
  }

  // ---- 业务查询方法 ----

  /**
   * 根据课程 ID 查询课程
   *
   * 严格落实 DATA_CONTRACT 类型转换规则：
   * - Long → number：getLong(idx).valueOf()
   * - 0/1 → boolean：getLong(idx).valueOf() === 1（Course 无布尔字段，但为模板预留）
   * - NULL → 联合类型：isColumnNull(idx) 判空
   *
   * @param courseId 课程 UUID
   * @returns Course 类型或 null（课程不存在时）
   */
  async queryCourseById(courseId: string): Promise<Course | null> {
    if (!this.store) {
      Logger.getInstance().error(TAG, 'queryCourseById: RdbStore not initialized')
      return null
    }

    let cursor: relationalStore.ResultSet | null = null
    try {
      const predicates = new relationalStore.RdbPredicates('course')
      predicates.equalTo('id', courseId)
      cursor = await this.store.querySql('SELECT * FROM course WHERE id = ?', [courseId])

      if (cursor.goToFirstRow()) {
        return this.mapCursorToCourse(cursor)
      }

      // 课程不存在
      return null
    } catch (e) {
      Logger.getInstance().error(TAG, `queryCourseById failed: ${courseId}`, String(e))
      return null
    } finally {
      if (cursor) {
        cursor.close()
      }
    }
  }

  /**
   * 将 ResultSet 当前行映射为 Course 对象
   * 严格落实 Long→number、0/1→boolean、NULL→联合类型 转换规则
   */
  private mapCursorToCourse(cursor: relationalStore.ResultSet): Course {
    // 获取列索引
    const idIdx = cursor.getColumnIndex('id')
    const titleIdx = cursor.getColumnIndex('title')
    const statusIdx = cursor.getColumnIndex('status')
    const stepIdx = cursor.getColumnIndex('current_step')
    const progressIdx = cursor.getColumnIndex('progress')
    const aiSummaryIdx = cursor.getColumnIndex('ai_summary_context')
    const q1ActivatedIdx = cursor.getColumnIndex('q1_activated_count')
    const q1TotalIdx = cursor.getColumnIndex('q1_total_core_count')
    const createTimeIdx = cursor.getColumnIndex('create_time')

    return {
      id: cursor.getString(idIdx),
      title: cursor.getString(titleIdx),
      // status: INTEGER → CourseStatus 枚举（数值一致，直接强转）
      status: RdbHelper.longToNumber(cursor, statusIdx) as CourseStatus,
      // Long → number 显式转换
      current_step: RdbHelper.longToNumber(cursor, stepIdx),
      progress: RdbHelper.longToNumber(cursor, progressIdx),
      // NULL → string | null 联合类型
      ai_summary_context: RdbHelper.getNullableString(cursor, aiSummaryIdx),
      q1_activated_count: RdbHelper.longToNumber(cursor, q1ActivatedIdx),
      q1_total_core_count: RdbHelper.longToNumber(cursor, q1TotalIdx),
      // 时间戳：Long → number，严禁直接赋值
      create_time: RdbHelper.longToNumber(cursor, createTimeIdx)
    }
  }

  getStore(): relationalStore.RdbStore | null {
    return this.store
  }
}
