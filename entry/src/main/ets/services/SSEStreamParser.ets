/**
 * 三问高效学习机 — SSE 流解析器
 * 遵循 AI_SERVICE_PROTOCOL.md §2-3
 *
 * 核心职责：
 * - 维护 string buffer，仅遇 \n\n 截取解析
 * - 兼容两种 SSE 格式：
 *   1) 自定义两阶段格式：type="text" → onTextChunk / type="json" → onJsonData
 *   2) OpenAI/DeepSeek Chat Completions 格式：choices[0].delta.content → onTextChunk
 * - 跨阶段等待超时（15s）与 JSON 体积上限（5M 字符数）防护
 * - JSON 解析失败丢弃 + 记日志，不中断 SSE 流
 */
import { Logger } from '../common/Logger'

const TAG = 'SSEStreamParser'

/**
 * SSE 流回调接口
 * 业务层通过注册回调感知阶段切换和数据到达
 */
export interface SSEStreamCallbacks {
  /** 阶段1：文本片段逐字回调 */
  onTextChunk?: (text: string) => void

  /** 阶段2：结构化 JSON 数据到达回调 */
  onJsonData?: (json: object) => void

  /** 错误回调：超时 / 溢出 / 严重解析错误时触发 */
  onError?: (err: string) => void

  /** 结束回调：收到 [DONE] 标志时触发 */
  onDone?: () => void
}

/**
 * SSE 流解析器
 *
 * 使用方式：
 * 1. 实例化 SSEStreamParser，传入 SSEStreamCallbacks
 * 2. 在 httpRequest.on('dataReceive') 中调用 onChunkReceived(rawChunk)
 * 3. 在 httpRequest.on('dataEnd') 中调用 onStreamEnd()
 */
export class SSEStreamParser {
  /** 缓冲区：仅遇 \n\n 截取解析，处理粘包/半包 */
  private buffer: string = ''

  /** 最后一次收到 text 事件的时间戳（跨阶段超时判定） */
  private lastTextChunkTime: number = 0

  /** 跨阶段等待超时：text 流结束后 15 秒内未收到 json 事件即超时 */
  static readonly CROSS_PHASE_TIMEOUT_MS: number = 15000

  /** JSON 数据字符数上限：5M（5242880）字符 */
  static readonly JSON_BUFFER_MAX_LENGTH: number = 5242880

  private callbacks: SSEStreamCallbacks

  constructor(callbacks: SSEStreamCallbacks) {
    this.callbacks = callbacks
  }

  /**
   * 收到原始数据块时的入口
   * 由 httpRequest.on('dataReceive') 调用
   */
  onChunkReceived(rawChunk: string): void {
    // 跨阶段等待超时检测：text 流结束后长时间未收到 json 事件
    if (this.lastTextChunkTime > 0 &&
      Date.now() - this.lastTextChunkTime > SSEStreamParser.CROSS_PHASE_TIMEOUT_MS) {
      this.buffer = ''
      this.lastTextChunkTime = 0
      this.callbacks.onError?.('Cross-phase timeout: no JSON received after text stream')
      return
    }

    this.buffer += rawChunk

    // 仅遇 \n\n 截取解析，处理粘包/半包
    while (this.buffer.includes('\n\n')) {
      const endIndex = this.buffer.indexOf('\n\n')
      const eventStr = this.buffer.substring(0, endIndex)
      this.buffer = this.buffer.substring(endIndex + 2)

      // 跳过空行和注释行（以 ':' 开头）
      if (eventStr.trim() === '' || eventStr.startsWith(':')) {
        continue
      }

      this.parseEvent(eventStr)
    }
  }

  /**
   * 解析单个完整 SSE 事件
   */
  private parseEvent(eventStr: string): void {
    const lines = eventStr.split('\n')
    for (const line of lines) {
      if (!line.startsWith('data: ')) {
        continue
      }
      const data = line.substring(6) // 去除 "data: " 前缀（6 字符）

      // 结束标志
      if (data === '[DONE]') {
        this.callbacks.onDone?.()
        return
      }

      // JSON 解析：失败丢弃 + 记日志，不中断 SSE 流
      try {
        const parsed: Record<string, Object> = JSON.parse(data)
        this.handleParsedData(parsed)
      } catch (e) {
        Logger.getInstance().error(TAG, 'SSE JSON parse failed', String(e))
      }
    }
  }

  /**
   * 根据 SSE 数据格式分发回调
   * 兼容两种格式：
   * 1) 自定义两阶段格式：{type: "text", content: "..."} / {type: "json", data: {...}}
   * 2) OpenAI/DeepSeek Chat Completions 格式：{choices: [{delta: {content: "..."}}]}
   */
  private handleParsedData(parsed: Record<string, Object>): void {
    const type = parsed['type'] as string | undefined

    // 格式1：自定义两阶段格式
    if (type === 'text') {
      // 阶段1：文本片段 → 逐字渲染
      const content = parsed['content'] as string
      this.lastTextChunkTime = Date.now()
      this.callbacks.onTextChunk?.(content)
      return

    } else if (type === 'json') {
      // 阶段2：结构化数据 → 防护校验
      const dataStr = JSON.stringify(parsed['data'])

      // 单次 JSON 体积检测（5M 字符数上限）
      if (dataStr.length > SSEStreamParser.JSON_BUFFER_MAX_LENGTH) {
        this.buffer = ''
        this.lastTextChunkTime = 0
        this.callbacks.onError?.('JSON buffer overflow: exceeded 5M characters')
        return
      }

      // 校验通过，回调业务层
      this.callbacks.onJsonData?.(parsed['data'] as object)

      // 重置防护状态（单次 json 事件处理完毕）
      this.lastTextChunkTime = 0
      return
    }

    // 格式2：OpenAI/DeepSeek Chat Completions 流式格式
    // 数据结构：{id, object: "chat.completion.chunk", choices: [{index, delta: {content?: string}, finish_reason?: string}]}
    const objectField = parsed['object'] as string | undefined
    if (objectField === 'chat.completion.chunk') {
      const choices = parsed['choices'] as Array<Record<string, Object>> | undefined
      if (choices && choices.length > 0) {
        const firstChoice = choices[0]
        const delta = firstChoice['delta'] as Record<string, Object> | undefined
        if (delta) {
          const content = delta['content'] as string | undefined
          if (content !== undefined && content !== null) {
            this.lastTextChunkTime = Date.now()
            this.callbacks.onTextChunk?.(content)
          }
        }
        // finish_reason: "stop" 表示流结束
        const finishReason = firstChoice['finish_reason'] as string | undefined
        if (finishReason === 'stop') {
          this.callbacks.onDone?.()
        }
      }
      return
    }

    // 无法识别的格式，静默忽略
  }

  /**
   * 流结束回调
   * 由 httpRequest.on('dataEnd') 触发
   */
  onStreamEnd(): void {
    // buffer 中还有残留非空内容，尝试最后一次解析
    if (this.buffer.trim().length > 0) {
      this.parseEvent(this.buffer)
      this.buffer = ''
    }
  }

  /**
   * 重置解析器状态（用于重试 / 冷启动清理）
   */
  reset(): void {
    this.buffer = ''
    this.lastTextChunkTime = 0
  }
}
