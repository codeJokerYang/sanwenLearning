/**
 * 三问高效学习机 — 环境配置
 * 遵循 RELEASE_AND_UPDATE_CONVENTIONS.md
 */

/** 应用版本号（语义化） */
export const APP_VERSION: string = '1.0.0'

/** 整数版本码：major*10000 + minor*100 + patch */
export const APP_VERSION_CODE: number = 10000

/** 数据库 schema 版本号，每次 schema 变更递增 */
export const DB_VERSION: number = 3

/** 数据库文件名 */
export const DB_NAME: string = 'sanwen_learning.db'

/** 日志级别：DEBUG / ERROR */
export type LogLevel = 'DEBUG' | 'ERROR'

/** 当前日志级别 */
export const LOG_LEVEL: LogLevel = 'DEBUG'

/** AI 服务配置接口 */
interface AiConfig {
  CONNECT_TIMEOUT_MS: number;
  READ_TIMEOUT_MS: number;
  LOCK_TIMEOUT_MS: number;
  CROSS_PHASE_TIMEOUT_MS: number;
  JSON_BUFFER_MAX_LENGTH: number;
  RATE_LIMIT_PER_MINUTE: number;
}

/** 真人作答配置接口 */
interface AntiCheatConfig {
  SPEED_THRESHOLD: number;
  AI_FILL_THRESHOLD: number;
  SHORT_TEXT_EXEMPTION: number;
}

/** 力导向布局配置接口 */
interface ForceLayoutConfig {
  MAX_ITERATIONS: number;
  INITIAL_POS: number;
  POS_RANGE_MIN: number;
  POS_RANGE_MAX: number;
}

/** 文件上传配置接口 */
interface FileConfig {
  MAX_FILE_SIZE_BYTES: number;
  ALLOWED_EXTENSIONS: string[];
  PARSE_TIMEOUT_MS: number;
}

/** AI 服务端点配置接口 */
interface AiEndpointConfig {
  API_BASE_URL: string;
  CHAT_MODEL: string;
  API_KEY_ALIAS: string;
  DEFAULT_API_KEY: string;
  LAST_UPDATED: string;
}

/** AI 服务端点配置 */
export const AI_ENDPOINT_CONFIG: AiEndpointConfig = {
  /** DeepSeek API 端点 URL（不含 /v1 前缀，直接使用官方推荐地址） */
  API_BASE_URL: 'https://api.deepseek.com/chat/completions',
  /** 对话模型名称（DeepSeek V4 Flash，带连字符） */
  CHAT_MODEL: 'deepseek-v4-flash',
  /** API Key 存储别名（用于 HUKS 加密存取） */
  API_KEY_ALIAS: 'default',
  /**
   * 默认 API Key — 出于安全考虑保持空字符串，严禁在此硬编码真实密钥并提交到版本库。
   * 密钥由用户在「设置」页手动填写，经 HUKS AES-256 加密存储；
   * 未配置时首页会弹窗引导用户前往设置页。
   */
  DEFAULT_API_KEY: '',
  /** API 配置最后更新时间 */
  LAST_UPDATED: '2026-06-12T00:00:00+08:00',
}

/** AI 服务相关配置 */
export const AI_CONFIG: AiConfig = {
  /** HTTP 连接超时（毫秒） */
  CONNECT_TIMEOUT_MS: 15000,
  /** SSE 读取超时（毫秒） */
  READ_TIMEOUT_MS: 60000,
  /** 并发锁超时（毫秒） */
  LOCK_TIMEOUT_MS: 120000,
  /** 跨阶段等待超时（毫秒） */
  CROSS_PHASE_TIMEOUT_MS: 15000,
  /** JSON 缓冲上限（字符数） */
  JSON_BUFFER_MAX_LENGTH: 5242880,
  /** 全局限流：每分钟最大请求数 */
  RATE_LIMIT_PER_MINUTE: 10,
}

/** 真人作答相关配置 */
export const ANTI_CHEAT_CONFIG: AntiCheatConfig = {
  /** 速度阈值（字/分钟） */
  SPEED_THRESHOLD: 150,
  /** AI 自动填充高度可疑阈值（字/分钟） */
  AI_FILL_THRESHOLD: 300,
  /** 短文本豁免字数上限 */
  SHORT_TEXT_EXEMPTION: 5,
}

/** 力导向布局相关配置 */
export const FORCE_LAYOUT_CONFIG: ForceLayoutConfig = {
  /** 最大迭代次数 */
  MAX_ITERATIONS: 200,
  /** 坐标初始值（未计算标记） */
  INITIAL_POS: -1,
  /** 坐标随机范围下限 */
  POS_RANGE_MIN: 100,
  /** 坐标随机范围上限 */
  POS_RANGE_MAX: 500,
}

/** 文件上传相关配置 */
export const FILE_CONFIG: FileConfig = {
  /** 文件大小上限（字节） */
  MAX_FILE_SIZE_BYTES: 50 * 1024 * 1024,
  /** 支持的文件扩展名 */
  ALLOWED_EXTENSIONS: ['pdf', 'md', 'markdown'],
  /** 解析超时（毫秒） */
  PARSE_TIMEOUT_MS: 10000,
}

/** 布鲁姆 9 题分布规则 */
export const BLOOM_DISTRIBUTION: Record<number, number> = {
  1: 1,  // REMEMBER
  2: 2,  // UNDERSTAND
  3: 2,  // APPLY
  4: 2,  // ANALYZE
  5: 1,  // EVALUATE
  6: 1,  // CREATE
}

/** 布鲁姆校验重试上限 */
export const BLOOM_VALIDATION_MAX_RETRIES: number = 2
