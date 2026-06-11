-- ============================================================
-- 三问高效学习机 — 数据库初始化脚本
-- 版本：V1 | 日期：2026-06-05
-- 仅在 DB_VERSION === 0（全新安装）时执行
-- 严禁在版本升级时执行此脚本，升级必须走 ALTER TABLE 增量迁移
-- ============================================================

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

-- ============================================================
-- 索引（9 个）
-- ============================================================

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

-- 9. 埋点事件表
CREATE TABLE IF NOT EXISTS analytics_event (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  event_name  TEXT    NOT NULL,
  timestamp   INTEGER NOT NULL,
  session_id  TEXT    NOT NULL,
  course_id   TEXT,
  payload     TEXT    NOT NULL,
  synced      INTEGER DEFAULT 0
);

CREATE INDEX idx_analytics_event_name ON analytics_event(event_name);
CREATE INDEX idx_analytics_event_time ON analytics_event(timestamp);
CREATE INDEX idx_analytics_event_course ON analytics_event(course_id);
