# DB Migration Log

## V1 → V2 (2026-06-09)

**[DB_MIGRATION] V1->V2: Add AI conversation tables**

### 新增表

#### `ai_conversation`
| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | TEXT | PRIMARY KEY | UUID v4 |
| course_id | TEXT | NOT NULL, FOREIGN KEY REFERENCES course(id) | 所属课程 |
| title | TEXT | NOT NULL | 会话标题（取首条消息前20字） |
| created_at | INTEGER | NOT NULL | 创建时间（毫秒） |
| updated_at | INTEGER | NOT NULL | 更新时间（毫秒） |

#### `ai_message`
| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | TEXT | PRIMARY KEY | UUID v4 |
| conversation_id | TEXT | NOT NULL, FOREIGN KEY REFERENCES ai_conversation(id) ON DELETE CASCADE | 所属会话 |
| role | TEXT | NOT NULL | 角色：user / assistant / system |
| content | TEXT | NOT NULL | 消息内容 |
| intent_type | TEXT | NULL | 意图类型：KNOWLEDGE_QA / LEARNING_ADVICE / OPERATION_ASSIST / COURSE_NAVIGATION |
| created_at | INTEGER | NOT NULL | 创建时间（毫秒） |

### 迁移脚本
位置：`entry/src/main/ets/db/RdbHelper.ets` → `migrateV1ToV2()`

### 级联删除适配
- `CourseService.deleteCourse()` 事务中新增删除 `ai_message`（通过 conversation_id 关联）和 `ai_conversation`（通过 course_id 关联）
- 删除顺序：question_record → controversy → quiz_question → knowledge_edge → knowledge_node → material → **ai_message** → **ai_conversation** → course

### 向后兼容性
- 新增字段均允许 NULL 或有默认值
- 未修改任何已有表结构
- 未使用 DROP TABLE
