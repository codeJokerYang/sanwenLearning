/**
 * 三问高效学习机 — 核心接口定义
 * 严格对齐 DATA_CONTRACT.md v2.1 §2
 * 字段名称、类型（含 string | null 联合类型）、可选性必须与契约完全一致
 * 严禁任何字段偏离文档定义
 */
import { CourseStatus, BloomLevel, NodeType, MaterialType, MaterialStatus, AiRequestStatus, CorrectStatus } from '../constants/Enums'

/**
 * 课程 — 项目核心实体
 * 进度映射：step0→0%, step1→0%, step2→0~33%, step3→33%, step4→66%, step5→100%
 * Q1进度计算：q1_total_core_count===0 时强制0%，严禁除零
 */
export interface Course {
  /** UUID v4，主键 */
  id: string
  /** 课程标题，最大200字符 */
  title: string
  /** 课程状态，遵循 CourseStatus 严禁跳步流转 */
  status: CourseStatus
  /** 当前步骤（0-5，与 CourseStatus 对应） */
  current_step: number
  /** 进度百分比 0-100 */
  progress: number
  /** AI 摘要上下文，异步生成未完成时为 null */
  ai_summary_context: string | null
  /** Q1 已点亮核心节点数 */
  q1_activated_count: number
  /** Q1 核心节点总数，为0时Q1无法完成 */
  q1_total_core_count: number
  /** 创建时间戳（毫秒） */
  create_time: number
}

/**
 * 知识节点 — 图谱核心元素
 * 坐标规则：x_pos/y_pos 初始值 -1（严禁用0），力导向初始化时在 100~500 随机
 * 已激活节点坐标锁定，不再参与力导向迭代
 */
export interface KnowledgeNode {
  /** UUID v4，主键 */
  id: string
  /** 所属课程 ID（FK → course.id） */
  course_id: string
  /** 节点标签，最大100字符 */
  label: string
  /** 节点类型：CORE 点亮才完成Q1，SECONDARY 不阻塞 */
  type: NodeType
  /** 节点描述 */
  description: string
  /** 是否已点亮（false=碎片态, true=点亮态） */
  is_activated: boolean
  /** 力导向布局 X 坐标，-1=未计算 */
  x_pos: number
  /** 力导向布局 Y 坐标，-1=未计算 */
  y_pos: number
  /** 排序序号 */
  sort_order: number
}

/**
 * 知识边 — 节点间关系
 * source/target 必须指向已存在的 knowledge_node.id
 */
export interface KnowledgeEdge {
  /** UUID v4，主键 */
  id: string
  /** 所属课程 ID（FK → course.id） */
  course_id: string
  /** 起始节点 ID（FK → knowledge_node.id） */
  source: string
  /** 终止节点 ID（FK → knowledge_node.id） */
  target: string
  /** 关系描述，最大200字符 */
  relation: string
}

/**
 * 测评题目 — Q3 布鲁姆9题
 * linked_node_ids：JSON 数组字符串，解析用 safeParseJsonArray
 * options：客观题为 JSON 数组字符串，主观题为空字符串 ""（严禁 null）
 */
export interface QuizQuestion {
  /** UUID v4，主键 */
  id: string
  /** 所属课程 ID（FK → course.id） */
  course_id: string
  /** 布鲁姆认知层级（1-6） */
  bloom_level: BloomLevel
  /** 关联知识节点 ID，JSON 数组字符串，如 '["id1","id2"]' */
  linked_node_ids: string
  /** 题目文本 */
  question_text: string
  /** 选项：客观题 JSON 数组字符串，主观题空字符串 "" */
  options: string
  /** 标准答案 */
  correct_answer: string
  /** 排序序号 */
  sort_order: number
}

/**
 * 争议 — Q2 争议分析核心数据
 * 逻辑链：争议标题 → 观点A+证据A ↔ 观点B+证据B → 结论
 */
export interface Controversy {
  /** UUID v4，主键 */
  id: string
  /** 所属课程 ID（FK → course.id） */
  course_id: string
  /** 争议标题，最大200字符 */
  title: string
  /** 观点 A */
  view_a: string
  /** 观点 A 证据 */
  evidence_a: string
  /** 观点 B */
  view_b: string
  /** 观点 B 证据 */
  evidence_b: string
  /** 结论 */
  conclusion: string
  /** 是否被学习者选中 */
  is_selected: boolean
  /** 排序序号 */
  sort_order: number
}

/**
 * 作答记录 — 三问全过程留痕
 * Q1/Q2 时 quiz_question_id 和 standard_answer 为 null
 * Q2 时 controversy_id 必填，Q3 时 quiz_question_id 必填
 * is_suspect：输入速度 >150 字/分钟时为 true
 */
export interface QuestionRecord {
  /** UUID v4，主键 */
  id: string
  /** 所属课程 ID（FK → course.id） */
  course_id: string
  /** 三问步骤（1/2/3） */
  step: number
  /** 关联测评题目 ID，Q3时必填，Q1/Q2时为 null */
  quiz_question_id: string | null
  /** 关联争议 ID，Q2时必填，Q1/Q3时为 null */
  controversy_id: string | null
  /** 题目/争议点原文 */
  question_content: string
  /** 用户真实作答原文 */
  user_original_answer: string
  /** AI 评价反馈原文，未返回或手动跳过时为 null */
  ai_evaluation: string | null
  /** 标准答案，Q3时必填，Q1/Q2时为 null */
  standard_answer: string | null
  /** 作答是否正确 */
  is_correct: CorrectStatus
  /** 诚信审计标记，输入速度 >150 字/分钟时为 true */
  is_suspect: boolean
  /** 创建时间戳（毫秒） */
  create_time: number
}

/**
 * 资料 — 文件池核心实体
 * parsed_content：解析失败或未解析时为 null
 * PDF 当前版本不解析文本，parsed_content=null, status=FAILED
 */
export interface Material {
  /** UUID v4，主键 */
  id: string
  /** 所属课程 ID（FK → course.id） */
  course_id: string
  /** 文件名，最大255字符 */
  file_name: string
  /** 沙箱存储路径，最大500字符 */
  file_path: string
  /** 来源类型 */
  type: MaterialType
  /** 资料状态 */
  status: MaterialStatus
  /** 解析后纯文本，解析失败或未解析时为 null */
  parsed_content: string | null
}

/**
 * AI 请求日志 — 全量留痕
 * 严禁遗漏日志记录，即使请求失败也必须记录
 * API Key 在日志中必须脱敏（保留前3后4，中间 ***）
 */
export interface AiRequestLog {
  /** UUID v4，主键 */
  id: string
  /** 关联课程 ID（FK → course.id） */
  course_id: string
  /** 请求类型：knowledge_graph / controversy / quiz / evaluation */
  request_type: string
  /** 请求 Prompt 内容（含上下文注入的完整文本） */
  request_prompt: string
  /** 响应内容（阶段2 JSON 原文） */
  response_body: string
  /** 执行状态 */
  status: AiRequestStatus
  /** 耗时毫秒数（从 acquireLock 到 releaseLock 的时间差） */
  duration_ms: number
  /** 创建时间戳（毫秒） */
  create_time: number
}
