/**
 * 三问高效学习机 — RdbHelper 数据库封装
 * 遵循 DATA_CONTRACT.md v2.1 + RELEASE_AND_UPDATE_CONVENTIONS.md
 * 通用 CRUD + 事务 + 类型转换 + 迁移框架
 */
import { relationalStore } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { DB_NAME, DB_VERSION } from '../common/Config'
import { Logger } from '../common/Logger'
import { Course, AiConversation, AiMessage } from '../models/Models'

const TAG = 'RDB_HELPER'

const INIT_SQL: string = `
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
CREATE TABLE IF NOT EXISTS analytics_event (
  id                    TEXT    PRIMARY KEY NOT NULL,
  session_id            TEXT    NOT NULL,
  event_name            TEXT    NOT NULL,
  properties            TEXT    NOT NULL DEFAULT '{}',
  timestamp             INTEGER NOT NULL
);
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
CREATE TABLE IF NOT EXISTS ai_conversation (
  id                    TEXT    PRIMARY KEY NOT NULL,
  course_id             TEXT    NOT NULL,
  title                 TEXT    NOT NULL DEFAULT '',
  created_at            INTEGER NOT NULL,
  updated_at            INTEGER NOT NULL,
  FOREIGN KEY (course_id) REFERENCES course(id)
);
CREATE TABLE IF NOT EXISTS ai_message (
  id                    TEXT    PRIMARY KEY NOT NULL,
  conversation_id       TEXT    NOT NULL,
  role                  TEXT    NOT NULL,
  content               TEXT    NOT NULL DEFAULT '',
  intent_type           TEXT,
  created_at            INTEGER NOT NULL,
  FOREIGN KEY (conversation_id) REFERENCES ai_conversation(id) ON DELETE SET NULL
);
CREATE INDEX idx_aiconv_course ON ai_conversation(course_id);
CREATE INDEX idx_aimsg_conv ON ai_message(conversation_id);
CREATE INDEX idx_aimsg_time ON ai_message(created_at);
`

export class RdbHelper {
  private static instance: RdbHelper | null = null
  private store: relationalStore.RdbStore | null = null
  private initSql: string = ''

  private constructor() {}

  static getInstance(): RdbHelper {
    if (!RdbHelper.instance) {
      RdbHelper.instance = new RdbHelper()
    }
    return RdbHelper.instance
  }

  async init(context: common.Context, initSql?: string): Promise<void> {
    if (initSql && initSql.length > 0) {
      this.initSql = initSql
    } else {
      this.initSql = INIT_SQL
    }
    try {
      this.store = await relationalStore.getRdbStore(context, {
        name: DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      })
    } catch (e) {
      Logger.getInstance().error(TAG, 'Failed to get RdbStore', String(e))
      return
    }
    const currentVersion = this.store.version
    if (currentVersion === 0) {
      // 全新安装：执行 init.sql
      await this.executeInitScript()
      this.store.version = DB_VERSION
    } else if (currentVersion < DB_VERSION) {
      // 版本升级：走增量迁移
      await this.migrate(currentVersion, DB_VERSION)
    }
  }

  private async executeInitScript(): Promise<void> {
    if (!this.store || !this.initSql) {
      return
    }
    const statements = this.initSql
      .split(';')
      .map(s => s.trim())
      .filter(s => s.length > 0 && !s.startsWith('--'))
    for (const sql of statements) {
      try {
        await this.store.executeSql(sql)
      } catch (e) {
        Logger.getInstance().error(TAG, `Init SQL failed: ${sql}`, String(e))
      }
    }
  }

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
      case 2:
        await this.migrateV2(store)
        break
      default:
        Logger.getInstance().warn(TAG, `No migration for version ${targetVersion}`)
    }
  }

  // [DB_MIGRATION] V1->V2: 新增 ai_conversation / ai_message 表
  private async migrateV2(store: relationalStore.RdbStore): Promise<void> {
    Logger.getInstance().info(TAG, '[DB_MIGRATION] V1->V2: Adding ai_conversation and ai_message tables')
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS ai_conversation (
        id                    TEXT    PRIMARY KEY NOT NULL,
        course_id             TEXT    NOT NULL,
        title                 TEXT    NOT NULL DEFAULT '',
        created_at            INTEGER NOT NULL,
        updated_at            INTEGER NOT NULL,
        FOREIGN KEY (course_id) REFERENCES course(id)
      )
    `)
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS ai_message (
        id                    TEXT    PRIMARY KEY NOT NULL,
        conversation_id       TEXT    NOT NULL,
        role                  TEXT    NOT NULL,
        content               TEXT    NOT NULL DEFAULT '',
        intent_type           TEXT,
        created_at            INTEGER NOT NULL,
        FOREIGN KEY (conversation_id) REFERENCES ai_conversation(id) ON DELETE SET NULL
      )
    `)
    await store.executeSql('CREATE INDEX idx_aiconv_course ON ai_conversation(course_id)')
    await store.executeSql('CREATE INDEX idx_aimsg_conv ON ai_message(conversation_id)')
    await store.executeSql('CREATE INDEX idx_aimsg_time ON ai_message(created_at)')
  }

  // ---- 通用 CRUD ----

  async insert(tableName: string, values: relationalStore.ValuesBucket): Promise<number> {
    if (!this.store) {
      throw new Error('RdbStore not initialized')
    }
    const rowCount: number = await this.store.insert(tableName, values)
    if (rowCount === -1) {
      throw new Error(`Insert failed: ${tableName}`)
    }
    return rowCount
  }

  async query(sql: string, args: Array<relationalStore.ValueType> = []): Promise<relationalStore.ResultSet> {
    if (!this.store) {
      throw new Error('RdbStore not initialized')
    }
    try {
      return await this.store.querySql(sql, args)
    } catch (e) {
      Logger.getInstance().error(TAG, `Query failed: ${sql}`, String(e))
      throw new Error(`Query failed: ${String(e)}`)
    }
  }

  async update(tableName: string, values: relationalStore.ValuesBucket,
    predicates: relationalStore.RdbPredicates): Promise<number> {
    if (!this.store) {
      return -1
    }
    try {
      return await this.store.update(values, predicates)
    } catch (e) {
      Logger.getInstance().error(TAG, `Update failed: ${tableName}`, String(e))
      return -1
    }
  }

  async delete(tableName: string, predicates: relationalStore.RdbPredicates): Promise<number> {
    if (!this.store) {
      return -1
    }
    try {
      return await this.store.delete(predicates)
    } catch (e) {
      Logger.getInstance().error(TAG, `Delete failed: ${tableName}`, String(e))
      return -1
    }
  }

  async execute(sql: string, args: Array<relationalStore.ValueType> = []): Promise<void> {
    if (!this.store) {
      return
    }
    try {
      await this.store.executeSql(sql, args)
    } catch (e) {
      Logger.getInstance().error(TAG, `Execute failed: ${sql}`, String(e))
    }
  }

  // ---- 事务 ----

  async executeInTransaction(operation: () => Promise<void>): Promise<void> {
    if (!this.store) {
      return
    }
    try {
      this.store.beginTransaction()
    } catch (e) {
      Logger.getInstance().error(TAG, 'beginTransaction failed', String(e))
      return
    }
    try {
      await operation()
      this.store.commit()
    } catch (e) {
      try {
        this.store.rollBack()
      } catch (_re) {
        // rollBack 失败静默处理
      }
      Logger.getInstance().error(TAG, 'Transaction failed, rolled back', String(e))
      throw new Error(String(e))
    }
  }

  // ---- 类型转换工具 ----

  /** 布尔值：INTEGER → boolean */
  static boolFromDb(value: relationalStore.ValueType): boolean {
    return value === 1
  }

  /** 布尔值：boolean → INTEGER */
  static boolToDb(value: boolean): number {
    return value ? 1 : 0
  }

  /** 时间戳：cursor.getLong → number（严禁直接赋值 Long 给 number） */
  static longToNumber(cursor: relationalStore.ResultSet, columnIndex: number): number {
    try {
      return cursor.getLong(columnIndex).valueOf()
    } catch (e) {
      return 0
    }
  }

  /** 可空字符串字段读取 */
  static getNullableString(cursor: relationalStore.ResultSet, columnIndex: number): string | null {
    try {
      if (cursor.isColumnNull(columnIndex)) {
        return null
      }
      return cursor.getString(columnIndex)
    } catch (e) {
      return null
    }
  }

  /** 可空数字字段读取（Long → number） */
  static getNullableLong(cursor: relationalStore.ResultSet, columnIndex: number): number | null {
    try {
      if (cursor.isColumnNull(columnIndex)) {
        return null
      }
      return cursor.getLong(columnIndex).valueOf()
    } catch (e) {
      return null
    }
  }

  /** 安全解析 JSON 数组字段，失败降级返回 [] */
  static safeParseJsonArray(jsonStr: string | null): string[] {
    if (jsonStr === null || jsonStr === '' || jsonStr === undefined) {
      return []
    }
    try {
      const parsed: string[] = JSON.parse(jsonStr) as string[]
      if (Array.isArray(parsed)) {
        return parsed
      }
      Logger.getInstance().warn(TAG, `safeParseJsonArray: not array: ${jsonStr}`)
      return []
    } catch (e) {
      Logger.getInstance().error(TAG, `safeParseJsonArray: parse failed`, String(e))
      return []
    }
  }

  getStore(): relationalStore.RdbStore | null {
    return this.store
  }

  /**
   * 根据课程 ID 查询课程
   * 严格落实 Long→number、0/1→boolean、NULL→联合类型 转换规则
   */
  async queryCourseById(courseId: string): Promise<Course | null> {
    if (!this.store) {
      Logger.getInstance().error(TAG, 'queryCourseById: RdbStore not initialized')
      return null
    }
    let cursor: relationalStore.ResultSet | null = null
    try {
      cursor = await this.store.querySql('SELECT * FROM course WHERE id = ?', [courseId])
      if (cursor.goToFirstRow()) {
        return this.mapCursorToCourse(cursor)
      }
      return null
    } catch (e) {
      Logger.getInstance().error(TAG, `queryCourseById failed: ${courseId}`, String(e))
      return null
    } finally {
      if (cursor) {
        try {
          cursor.close()
        } catch (_e) {
          // cursor 关闭失败静默处理
        }
      }
    }
  }

  /** 将 ResultSet 当前行映射为 Course，严格落实类型转换铁律 */
  private mapCursorToCourse(cursor: relationalStore.ResultSet): Course {
    try {
      return {
        id: cursor.getString(cursor.getColumnIndex('id')),
        title: cursor.getString(cursor.getColumnIndex('title')),
        status: RdbHelper.longToNumber(cursor, cursor.getColumnIndex('status')) as number,
        current_step: RdbHelper.longToNumber(cursor, cursor.getColumnIndex('current_step')),
        progress: RdbHelper.longToNumber(cursor, cursor.getColumnIndex('progress')),
        ai_summary_context: RdbHelper.getNullableString(cursor, cursor.getColumnIndex('ai_summary_context')),
        q1_activated_count: RdbHelper.longToNumber(cursor, cursor.getColumnIndex('q1_activated_count')),
        q1_total_core_count: RdbHelper.longToNumber(cursor, cursor.getColumnIndex('q1_total_core_count')),
        create_time: RdbHelper.longToNumber(cursor, cursor.getColumnIndex('create_time'))
      }
    } catch (e) {
      Logger.getInstance().error(TAG, 'mapCursorToCourse failed', String(e))
      throw new Error(`mapCursorToCourse failed: ${String(e)}`)
    }
  }

  // ---- 对话 CRUD ----

  async insertConversation(conv: AiConversation): Promise<number> {
    return this.insert('ai_conversation', {
      'id': conv.id,
      'course_id': conv.course_id,
      'title': conv.title,
      'created_at': conv.created_at,
      'updated_at': conv.updated_at
    })
  }

  async insertMessage(msg: AiMessage): Promise<number> {
    return this.insert('ai_message', {
      'id': msg.id,
      'conversation_id': msg.conversation_id,
      'role': msg.role,
      'content': msg.content,
      'intent_type': msg.intent_type ?? null,
      'created_at': msg.created_at
    })
  }

  async getMessagesByConversationId(convId: string): Promise<AiMessage[]> {
    const messages: AiMessage[] = []
    let cursor: relationalStore.ResultSet | null = null
    try {
      cursor = await this.query(
        'SELECT * FROM ai_message WHERE conversation_id = ? ORDER BY created_at ASC',
        [convId]
      )
      while (cursor.goToNextRow()) {
        messages.push({
          id: cursor.getString(cursor.getColumnIndex('id')),
          conversation_id: cursor.getString(cursor.getColumnIndex('conversation_id')),
          role: cursor.getString(cursor.getColumnIndex('role')),
          content: cursor.getString(cursor.getColumnIndex('content')),
          intent_type: RdbHelper.getNullableString(cursor, cursor.getColumnIndex('intent_type')),
          created_at: RdbHelper.longToNumber(cursor, cursor.getColumnIndex('created_at'))
        })
      }
    } catch (e) {
      Logger.getInstance().error(TAG, `getMessagesByConversationId failed: ${convId}`, String(e))
    } finally {
      if (cursor) { try { cursor.close() } catch (_e) { /* ignore */ } }
    }
    return messages
  }

  async getLatestConversationByCourseId(courseId: string): Promise<AiConversation | null> {
    let cursor: relationalStore.ResultSet | null = null
    try {
      cursor = await this.query(
        'SELECT * FROM ai_conversation WHERE course_id = ? ORDER BY updated_at DESC LIMIT 1',
        [courseId]
      )
      if (cursor.goToFirstRow()) {
        return {
          id: cursor.getString(cursor.getColumnIndex('id')),
          course_id: cursor.getString(cursor.getColumnIndex('course_id')),
          title: cursor.getString(cursor.getColumnIndex('title')),
          created_at: RdbHelper.longToNumber(cursor, cursor.getColumnIndex('created_at')),
          updated_at: RdbHelper.longToNumber(cursor, cursor.getColumnIndex('updated_at'))
        }
      }
      return null
    } catch (e) {
      Logger.getInstance().error(TAG, `getLatestConversationByCourseId failed: ${courseId}`, String(e))
      return null
    } finally {
      if (cursor) { try { cursor.close() } catch (_e) { /* ignore */ } }
    }
  }

  async deleteConversationsByCourseId(courseId: string): Promise<number> {
    if (!this.store) { return -1 }
    try {
      const predicates = new relationalStore.RdbPredicates('ai_conversation')
      predicates.equalTo('course_id', courseId)
      return await this.store.delete(predicates)
    } catch (e) {
      Logger.getInstance().error(TAG, `deleteConversationsByCourseId failed: ${courseId}`, String(e))
      return -1
    }
  }

  async updateConversationTimestamp(convId: string, updatedAt: number): Promise<number> {
    if (!this.store) { return -1 }
    try {
      const predicates = new relationalStore.RdbPredicates('ai_conversation')
      predicates.equalTo('id', convId)
      return await this.store.update({ 'updated_at': updatedAt }, predicates)
    } catch (e) {
      Logger.getInstance().error(TAG, `updateConversationTimestamp failed: ${convId}`, String(e))
      return -1
    }
  }
}
