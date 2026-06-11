/**
 * 三问高效学习机 — 核心枚举定义
 * 严格对齐 DATA_CONTRACT.md v2.1 §1
 * 严禁任何枚举值偏离文档定义
 */

/** 课程状态 — 严禁跳步流转 */
export enum CourseStatus {
  /** 已创建，未开始三问 */
  DRAFT = 0,
  /** AI 正在生成知识图谱 */
  GENERATING = 1,
  /** 第一问进行中 */
  Q1_ACTIVE = 2,
  /** 第二问进行中 */
  Q2_ACTIVE = 3,
  /** 第三问进行中 */
  Q3_ACTIVE = 4,
  /** 三问全部完成 */
  COMPLETED = 5
}

/** 布鲁姆认知层级 — 9题分布：记1/理2/应2/分2/评1/创1 */
export enum BloomLevel {
  /** 记忆 — 提取、识别、回忆事实性知识 */
  REMEMBER = 1,
  /** 理解 — 从信息中建构意义、解释 */
  UNDERSTAND = 2,
  /** 应用 — 在给定情境中执行或使用程序 */
  APPLY = 3,
  /** 分析 — 分解并确定各部分间关系 */
  ANALYZE = 4,
  /** 评价 — 基于标准和准则做出判断 */
  EVALUATE = 5,
  /** 创造 — 将要素重组为新的整体 */
  CREATE = 6
}

/** 知识节点类型 — CORE 点亮才完成Q1，SECONDARY 不阻塞 */
export enum NodeType {
  /** 核心节点：必须点亮才能完成 Q1 */
  CORE = 'core',
  /** 辅助节点：补充说明，不阻塞 Q1 完成 */
  SECONDARY = 'secondary'
}

/** 资料来源类型 */
export enum MaterialType {
  /** 用户上传 */
  USER_UPLOAD = 'user_upload',
  /** AI 爬取 */
  AI_CRAWL = 'ai_crawl'
}

/** 资料解析状态 */
export enum MaterialStatus {
  /** 尚未解析 */
  PENDING = 'pending',
  /** 正在解析 */
  PARSING = 'parsing',
  /** 解析成功 */
  SUCCESS = 'success',
  /** 解析失败（如扫描型PDF） */
  FAILED = 'failed'
}

/** AI 请求执行状态 */
export enum AiRequestStatus {
  /** 执行成功 */
  SUCCESS = 'success',
  /** 执行失败 */
  FAILED = 'failed',
  /** 执行超时 */
  TIMEOUT = 'timeout'
}

/** 作答正确状态 — Q3客观题判true/false，主观题判subjective，未评价为pending */
export enum CorrectStatus {
  /** 正确 */
  TRUE = 'true',
  /** 错误 */
  FALSE = 'false',
  /** 待评价 */
  PENDING = 'pending',
  /** 主观题（无标准对错） */
  SUBJECTIVE = 'subjective'
}
