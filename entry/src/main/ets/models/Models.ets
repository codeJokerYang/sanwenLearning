/**
 * 三问高效学习机 — 数据模型定义
 * 与 DATA_CONTRACT.md v2.1 一一对应
 * 纯类型定义，严禁包含方法实现
 */

// ============================================================
// 枚举定义（7 个）
// ============================================================

/** 课程状态 */
export enum CourseStatus {
  DRAFT = 0,
  GENERATING = 1,
  Q1_ACTIVE = 2,
  Q2_ACTIVE = 3,
  Q3_ACTIVE = 4,
  COMPLETED = 5
}

/** 布鲁姆认知层级 */
export enum BloomLevel {
  REMEMBER = 1,
  UNDERSTAND = 2,
  APPLY = 3,
  ANALYZE = 4,
  EVALUATE = 5,
  CREATE = 6
}

/** 知识节点类型 */
export enum NodeType {
  CORE = 'core',
  SECONDARY = 'secondary'
}

/** 资料来源类型 */
export enum MaterialType {
  USER_UPLOAD = 'user_upload',
  AI_CRAWL = 'ai_crawl'
}

/** 资料状态 */
export enum MaterialStatus {
  PENDING = 'pending',
  PARSING = 'parsing',
  SUCCESS = 'success',
  FAILED = 'failed'
}

/** AI 请求状态 */
export enum AiRequestStatus {
  SUCCESS = 'success',
  FAILED = 'failed',
  TIMEOUT = 'timeout'
}

/** 作答正确状态 */
export enum CorrectStatus {
  TRUE = 'true',
  FALSE = 'false',
  PENDING = 'pending',
  SUBJECTIVE = 'subjective'
}

// ============================================================
// 核心接口定义（8 个）
// ============================================================

/** 课程 */
export interface Course {
  id: string
  title: string
  status: CourseStatus
  current_step: number
  progress: number
  ai_summary_context: string | null
  q1_activated_count: number
  q1_total_core_count: number
  create_time: number
}

/** 知识节点 */
export interface KnowledgeNode {
  id: string
  course_id: string
  label: string
  type: NodeType
  description: string
  is_activated: boolean
  x_pos: number
  y_pos: number
  sort_order: number
}

/** 知识边 */
export interface KnowledgeEdge {
  id: string
  course_id: string
  source: string
  target: string
  relation: string
}

/** 测评题目 */
export interface QuizQuestion {
  id: string
  course_id: string
  bloom_level: BloomLevel
  linked_node_ids: string
  question_text: string
  options: string
  correct_answer: string
  sort_order: number
}

/** 争议 */
export interface Controversy {
  id: string
  course_id: string
  title: string
  view_a: string
  evidence_a: string
  view_b: string
  evidence_b: string
  conclusion: string
  is_selected: boolean
  sort_order: number
}

/** 作答记录 */
export interface QuestionRecord {
  id: string
  course_id: string
  step: number
  quiz_question_id: string | null
  controversy_id: string | null
  question_content: string
  user_original_answer: string
  ai_evaluation: string | null
  standard_answer: string | null
  is_correct: CorrectStatus
  is_suspect: boolean
  create_time: number
}

/** 资料 */
export interface Material {
  id: string
  course_id: string
  file_name: string
  file_path: string
  type: MaterialType
  status: MaterialStatus
  parsed_content: string | null
}

/** AI 请求日志 */
export interface AiRequestLog {
  id: string
  course_id: string
  request_type: string
  request_prompt: string
  response_body: string
  status: AiRequestStatus
  duration_ms: number
  create_time: number
}

/** AI 对话会话 */
export interface AiConversation {
  id: string
  course_id: string
  title: string
  created_at: number
  updated_at: number
}

/** AI 对话消息 */
export interface AiMessage {
  id: string
  conversation_id: string
  role: string
  content: string
  intent_type: string | null
  created_at: number
}

// ============================================================
// 评估相关接口
// ============================================================

/** 评价报告 */
export interface EvaluationReport {
  course_id: string
  course_title: string
  /** Q1 得分（满分20） */
  q1_score: number
  /** Q2 得分（满分40） */
  q2_score: number
  /** Q3 得分（满分40） */
  q3_score: number
  /** 总分 */
  total_score: number
  /** 布鲁姆6层级得分 */
  bloom_scores: Map<number, number>
  /** 雷达图PNG路径 */
  radar_chart_path: string
  /** 弱项节点列表 */
  weak_nodes: string[]
  /** 是否存在诚信可疑记录 */
  has_suspect_records: boolean
  /** 公告正文 */
  content: string
  /** 生成时间戳 */
  create_time: number
}

/** 资料解析结果 */
export interface ParsedResult {
  /** 是否解析成功 */
  success: boolean
  /** 解析后的文本内容 */
  content: string
  /** 是否检测为扫描型PDF */
  isScanned: boolean
  /** 错误信息 */
  error: string
}
