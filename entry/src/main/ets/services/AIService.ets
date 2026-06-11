/**
 * AIService - AI 请求核心服务
 * 遵循 AI_SERVICE_PROTOCOL.md §1-8
 * 依赖: SSEStreamParser / AIConcurrencyLock / GlobalRateLimiter / NetworkMonitor / ApiKeyStore
 */
import { http } from '@kit.NetworkKit'
import { util } from '@kit.ArkTS'
import { common } from '@kit.AbilityKit'
import { relationalStore } from '@kit.ArkData'
import { RdbHelper } from '../db/RdbHelper'
import { Logger } from '../common/Logger'
import { SSEStreamParser, SSEStreamCallbacks } from './SSEStreamParser'
import { AIConcurrencyLock } from './AIConcurrencyLock'
import { GlobalRateLimiter } from './GlobalRateLimiter'
import { NetworkMonitor } from './NetworkMonitor'
import { ApiKeyStore } from './ApiKeyStore'
import { BloomLevel, AiRequestStatus, QuizQuestion, AiMessage } from '../models/Models'
import { AI_CONFIG, AI_ENDPOINT_CONFIG, BLOOM_DISTRIBUTION, BLOOM_VALIDATION_MAX_RETRIES } from '../common/Config'
import { ErrorCode } from '../common/ErrorCode'

const TAG: string = 'AIService'
const API_URL: string = AI_ENDPOINT_CONFIG.API_BASE_URL
const API_KEY_ALIAS: string = AI_ENDPOINT_CONFIG.API_KEY_ALIAS
const MODEL: string = AI_ENDPOINT_CONFIG.CHAT_MODEL

interface SSEResult {
  textContent: string
  jsonData: object | null
}

interface ChatMessage {
  role: string
  content: string
}

interface RequestBody {
  model: string
  messages: ChatMessage[]
  stream: boolean
}

interface RequestHeader {
  'Content-Type': string
  'Authorization': string
}

function generateUUID(): string {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c: string) => {
    const r: number = Math.random() * 16 | 0
    const v: number = c === 'x' ? r : (r & 0x3 | 0x8)
    return v.toString(16)
  })
}

export class AIService {
  private static instance: AIService | null = null
  private context: common.Context | null = null
  private rdb: RdbHelper = RdbHelper.getInstance()
  private logger: Logger = Logger.getInstance()

  private constructor() {}

  static getInstance(): AIService {
    if (!AIService.instance) {
      AIService.instance = new AIService()
    }
    return AIService.instance
  }

  init(context: common.Context): void {
    this.context = context
    this.ensureApiKeyStored(context)
  }

  /**
   * 确保 API Key 已安全存储至 HUKS 加密存储
   * 首次启动时自动加密写入默认 Key，无需用户手动配置
   * 密钥明文仅在此函数作用域内短暂存在，绝不赋值给 @State 或全局变量
   */
  private async ensureApiKeyStored(context: common.Context): Promise<void> {
    try {
      // 尝试加载，若已存储则直接返回
      await ApiKeyStore.loadApiKey(context, API_KEY_ALIAS)
      this.logger.info(TAG, 'API Key 已存在，无需重新存储')
    } catch (_e) {
      // Key 尚未存储，自动加密写入默认 Key
      const defaultKey: string = AI_ENDPOINT_CONFIG.DEFAULT_API_KEY
      if (defaultKey && defaultKey.length > 0) {
        try {
          await ApiKeyStore.saveApiKey(context, API_KEY_ALIAS, defaultKey)
          this.logger.info(TAG, 'API Key 已自动加密存储')
        } catch (saveErr) {
          this.logger.error(TAG, 'API Key 自动存储失败', String(saveErr))
        }
      } else {
        this.logger.info(TAG, 'API Key 未存储，等待用户通过设置页配置')
      }
    }
  }

  /**
   * 安全存储 API Key（供设置页调用）
   * 明文 Key 仅在参数传递过程中存在，存储后立即由 HUKS 加密
   */
  async saveApiKey(apiKey: string): Promise<void> {
    if (!this.context) {
      throw new Error('AIService not initialized')
    }
    await ApiKeyStore.saveApiKey(this.context, API_KEY_ALIAS, apiKey)
    this.logger.info(TAG, `API Key 已安全存储: ${this.maskApiKey(apiKey)}`)
  }

  async generateKnowledgeGraph(courseId: string, parsedContents: string[]): Promise<void> {
    const prompt: string = this.buildPrompt(
      '你是一位严谨的学术导师。请根据以下学习资料，提取核心知识概念并构建知识图谱。\n\n' +
      '任务要求：\n1. 识别核心概念节点（type="core"）和辅助概念节点（type="secondary"）\n' +
      '2. 为相关节点建立边（relation 描述关系）\n3. 为每个节点提供简要描述\n' +
      '输出格式：严格的 JSON，字段为 nodes 和 edges 数组',
      parsedContents, {}
    )
    const result: SSEResult = await this.sendAIRequest(courseId, prompt, 'knowledge_graph')
    await this.processKnowledgeGraph(courseId, result)
  }

  async generateControversies(courseId: string, parsedContents: string[]): Promise<void> {
    const prompt: string = this.buildPrompt(
      '你是一位严谨的学术导师。请根据以下学习资料，识别其中存在的学术争议或不同观点。\n\n' +
      '任务要求：\n1. 为每个争议提供标题、观点A+证据、观点B+证据、结论\n' +
      '2. 每个争议需基于资料内容，不可编造\n' +
      '输出格式：严格的 JSON，字段为 controversies 数组',
      parsedContents, {}
    )
    const result: SSEResult = await this.sendAIRequest(courseId, prompt, 'controversy')
    await this.processControversies(courseId, result)
  }

  async generateQuizQuestions(courseId: string, parsedContents: string[],
    nodeIds: string[]): Promise<void> {
    const extraContext: Record<string, string> = {
      'knowledge_nodes': JSON.stringify(nodeIds)
    }
    const prompt: string = this.buildPrompt(
      '你是一位严谨的学术导师。请根据以下学习资料，生成 9 道测评题目。\n\n' +
      '任务要求：\n1. 布鲁姆认知层级分布：记忆1题、理解2题、应用2题、分析2题、评价1题、创造1题\n' +
      '2. 每题必须关联知识点节点 ID（linked_node_ids），仅限提供的节点 ID 列表\n' +
      '3. 客观题提供选项（options 为字符串数组），主观题 options 为空字符串\n' +
      '输出格式：严格的 JSON，字段为 questions 数组，每题包含 bloom_level/linked_node_ids/question_text/options/correct_answer/sort_order',
      parsedContents, extraContext
    )

    let lastError: string = ''
    for (let attempt: number = 0; attempt <= BLOOM_VALIDATION_MAX_RETRIES; attempt++) {
      try {
        const result: SSEResult = await this.sendAIRequest(courseId, prompt, 'quiz')
        const questions: QuizQuestion[] = this.parseQuizQuestions(courseId, result, nodeIds)
        if (this.validateBloomDistribution(questions)) {
          await this.processQuizQuestions(questions)
          return
        }
        lastError = 'Bloom distribution validation failed'
        this.logger.warn(TAG, `Quiz retry ${attempt + 1}/${BLOOM_VALIDATION_MAX_RETRIES}: ${lastError}`)
      } catch (e) {
        lastError = String(e)
        this.logger.warn(TAG, `Quiz retry ${attempt + 1}/${BLOOM_VALIDATION_MAX_RETRIES}: ${lastError}`)
      }
    }
    throw new Error(`Quiz generation failed after ${BLOOM_VALIDATION_MAX_RETRIES + 1} attempts: ${lastError}`)
  }

  async evaluateAnswer(courseId: string, userAnswer: string, context: string): Promise<string> {
    const prompt: string = this.buildPrompt(
      '你是一位严谨的学术导师。请评价学员的作答，指出优点、不足和改进建议。\n' +
      '重要约束：禁止替代学员作答，仅做评价和补充。\n\n' +
      `学员作答：${userAnswer}`,
      [context], {}
    )
    const result: SSEResult = await this.sendAIRequest(courseId, prompt, 'evaluation')
    return result.textContent
  }

  /**
   * 通用对话方法 — 仅消费 SSE Phase1(text)，忽略 Phase2(json)
   * 复用 sendAIRequest 基础设施（锁/限流/网络检查/日志）
   */
  async chat(courseId: string, userMessage: string, contextMessages: AiMessage[],
    onTextChunk: (text: string) => void): Promise<void> {
    const courseContext: string = await this.buildCourseContext(courseId)
    const prompt: string = this.buildChatPrompt(userMessage, courseContext, contextMessages)
    return new Promise<void>(async (resolve, reject) => {
      if (!this.context) {
        reject(new Error('AIService not initialized'))
        return
      }
      if (!NetworkMonitor.getInstance().isNetworkAvailable()) {
        reject(new Error(ErrorCode.NETWORK_DISCONNECTED))
        return
      }
      if (!GlobalRateLimiter.getInstance().canRequest()) {
        reject(new Error(ErrorCode.AI_FAILED))
        return
      }
      const lock: AIConcurrencyLock = AIConcurrencyLock.getInstance()
      if (!lock.acquireLock(courseId)) {
        reject(new Error(ErrorCode.AI_FAILED))
        return
      }

      const startTime: number = Date.now()
      let apiKey: string = ''
      let settled: boolean = false
      let timeoutId: number = -1
      let httpRequest: http.HttpRequest | null = null

      const finalize = (status: AiRequestStatus): void => {
        const duration: number = Date.now() - startTime
        lock.releaseLock(courseId)
        GlobalRateLimiter.getInstance().recordRequest()
        this.logRequest(courseId, 'chat', prompt, '', status, duration)
        apiKey = ''
        if (timeoutId !== -1) {
          clearTimeout(timeoutId)
          timeoutId = -1
        }
      }

      try {
        apiKey = await ApiKeyStore.loadApiKey(this.context!, API_KEY_ALIAS)
      } catch (e) {
        lock.releaseLock(courseId)
        reject(new Error(ErrorCode.AI_FAILED))
        return
      }

      const chatCallbacks: SSEStreamCallbacks = {
        onTextChunk: onTextChunk,
        onError: (err: string): void => { this.logger.error(TAG, `Chat SSE error: ${err}`) },
        onDone: (): void => { /* [DONE] received */ }
      }
      const sseParser: SSEStreamParser = new SSEStreamParser(chatCallbacks)

      try {
        httpRequest = http.createHttp()
        httpRequest.on('dataReceive', (data: ArrayBuffer): void => {
          sseParser.onChunkReceived(this.arrayBufferToString(data))
        })
        httpRequest.on('dataEnd', (): void => {
          sseParser.onStreamEnd()
          if (!settled) {
            settled = true
            finalize(AiRequestStatus.SUCCESS)
            resolve()
          }
        })
        const sysMsg: ChatMessage = { role: 'system', content: '你是三问高效学习机的智能学习伙伴。帮助学员理解知识、提供学习建议，禁止代替学员作答。' }
        const chatMsg: ChatMessage = { role: 'user', content: prompt }
        const msgArray: ChatMessage[] = [sysMsg, chatMsg]
        const reqBody: RequestBody = {
          model: MODEL,
          messages: msgArray,
          stream: true
        }
        const reqHeader: RequestHeader = {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`
        }
        httpRequest.request(API_URL, {
          method: http.RequestMethod.POST,
          header: reqHeader,
          extraData: JSON.stringify(reqBody),
          expectDataType: http.HttpDataType.STRING,
          connectTimeout: AI_CONFIG.CONNECT_TIMEOUT_MS,
          readTimeout: AI_CONFIG.READ_TIMEOUT_MS
        })

        timeoutId = setTimeout(() => {
          if (!settled) {
            settled = true
            sseParser.reset()
            if (httpRequest) {
              try { httpRequest.destroy() } catch (_e) { /* ignore */ }
              httpRequest = null
            }
            finalize(AiRequestStatus.FAILED)
            reject(new Error(ErrorCode.AI_TIMEOUT))
          }
        }, 120000)
      } catch (e) {
        if (!settled) {
          settled = true
          sseParser.reset()
          finalize(AiRequestStatus.FAILED)
          reject(new Error(ErrorCode.AI_FAILED))
        }
      }
    })
  }

  /**
   * 构建通用对话 Prompt
   * 结构：系统角色 → 课程上下文 → 对话历史（最近8轮）→ 用户输入 → 系统约束
   * 总长度 ≤2000 字符
   */
  buildChatPrompt(userMessage: string, courseContext: string,
    historyMessages: AiMessage[]): string {
    let prompt: string = '你是三问高效学习机的智能学习伙伴。你的职责是帮助学员理解知识、提供学习建议，' +
      '但绝不替代学员作答。请基于课程资料和上下文进行回答。\n\n'

    if (courseContext.length > 0) {
      prompt += `--- 课程上下文 ---\n${courseContext}\n--- 课程上下文结束 ---\n\n`
    }

    // 滑动窗口：最近 8 轮（16 条消息）
    const maxRounds: number = 8
    const historySlice: AiMessage[] = historyMessages.slice(-maxRounds * 2)
    if (historySlice.length > 0) {
      prompt += '--- 对话历史 ---\n'
      for (const msg of historySlice) {
        const roleLabel: string = msg.role === 'user' ? '学员' : 'AI助手'
        prompt += `${roleLabel}：${msg.content}\n`
      }
      prompt += '--- 对话历史结束 ---\n\n'
    }

    prompt += `学员提问：${userMessage}\n\n`
    prompt += '【系统约束 - 必须严格遵守】\n'
    prompt += '1. 严格基于课程资料和上下文回答，不得编造内容\n'
    prompt += '2. 禁止替代学员作答\n'
    prompt += '3. 如果不确定，请诚实说明\n'

    // 截断至 2000 字符
    if (prompt.length > 2000) {
      prompt = prompt.substring(0, 1997) + '...'
    }
    return prompt
  }

  /**
   * 构建课程上下文摘要
   * 从 DB 查询当前课程状态、已激活节点名列表、争议标题等
   */
  private async buildCourseContext(courseId: string): Promise<string> {
    if (!courseId) {
      return ''
    }
    try {
      const course = await this.rdb.queryCourseById(courseId)
      if (!course) {
        return ''
      }
      const parts: string[] = []
      parts.push(`课程：${course.title}`)

      // 当前三问阶段
      const stepNames: string[] = ['', '是什么（Q1）', '为什么（Q2）', '怎么用（Q3）']
      const stepName: string = stepNames[course.current_step] ?? '未知阶段'
      parts.push(`当前阶段：${stepName}`)

      // 已激活节点名列表（最多 15 个）
      let cursor: relationalStore.ResultSet | null = null
      try {
        cursor = await this.rdb.query(
          'SELECT label FROM knowledge_node WHERE course_id = ? AND is_activated = 1 LIMIT 15',
          [courseId]
        )
        const nodeLabels: string[] = []
        while (cursor.goToNextRow()) {
          nodeLabels.push(cursor.getString(0))
        }
        if (nodeLabels.length > 0) {
          parts.push(`已激活知识点：${nodeLabels.join('、')}`)
        }
      } catch (_e) { /* ignore */ }
      finally { if (cursor) { try { cursor.close() } catch (_e) { /* ignore */ } } }

      // 争议标题（最多 5 个）
      try {
        cursor = await this.rdb.query(
          'SELECT title FROM controversy WHERE course_id = ? LIMIT 5',
          [courseId]
        )
        const titles: string[] = []
        while (cursor.goToNextRow()) {
          titles.push(cursor.getString(0))
        }
        if (titles.length > 0) {
          parts.push(`争议话题：${titles.join('、')}`)
        }
      } catch (_e) { /* ignore */ }
      finally { if (cursor) { try { cursor.close() } catch (_e) { /* ignore */ } } }

      return parts.join('\n')
    } catch (e) {
      this.logger.error(TAG, `buildCourseContext failed: ${courseId}`, String(e))
      return ''
    }
  }

  buildPrompt(template: string, parsedContents: string[], extraContext: Record<string, string>): string {
    let prompt: string = `${template}\n\n`
    prompt += '--- 参考资料 ---\n'
    for (let i: number = 0; i < parsedContents.length; i++) {
      prompt += `[资料${i + 1}]\n${parsedContents[i]}\n\n`
    }
    prompt += '--- 参考资料结束 ---\n\n'
    for (const key of Object.keys(extraContext)) {
      prompt += `--- ${key} ---\n${extraContext[key]}\n\n`
    }
    prompt += '【系统约束 - 必须严格遵守】\n'
    prompt += '1. 严格基于上述参考资料回答问题，不得编造内容\n'
    prompt += '2. 禁止编造知识节点 ID，仅限提供的节点 ID 列表\n'
    prompt += '3. 禁止替代学员作答\n'
    prompt += '4. JSON 禁止分片输出，必须一次性完整输出\n'
    return prompt
  }

  private sendAIRequest(courseId: string, prompt: string, requestType: string): Promise<SSEResult> {
    return new Promise<SSEResult>(async (resolve, reject) => {
      if (!this.context) {
        reject(new Error('AIService not initialized: call init(context) first'))
        return
      }
      if (!NetworkMonitor.getInstance().isNetworkAvailable()) {
        reject(new Error(ErrorCode.NETWORK_DISCONNECTED))
        return
      }
      if (!GlobalRateLimiter.getInstance().canRequest()) {
        reject(new Error(ErrorCode.AI_FAILED))
        return
      }
      const lock: AIConcurrencyLock = AIConcurrencyLock.getInstance()
      if (!lock.acquireLock(courseId)) {
        reject(new Error(ErrorCode.AI_FAILED))
        return
      }

      const startTime: number = Date.now()
      let apiKey: string = ''
      let responseBody: string = ''
      const result: SSEResult = { textContent: '', jsonData: null }
      let settled: boolean = false
      let timeoutId: number = -1
      let httpRequest: http.HttpRequest | null = null

      const finalize = (status: AiRequestStatus): void => {
        const duration: number = Date.now() - startTime
        lock.releaseLock(courseId)
        GlobalRateLimiter.getInstance().recordRequest()
        this.logRequest(courseId, requestType, prompt, responseBody, status, duration)
        apiKey = ''
        if (timeoutId !== -1) {
          clearTimeout(timeoutId)
          timeoutId = -1
        }
      }

      try {
        apiKey = await ApiKeyStore.loadApiKey(this.context!, API_KEY_ALIAS)
      } catch (e) {
        lock.releaseLock(courseId)
        reject(new Error(ErrorCode.AI_FAILED))
        return
      }

      const aiCallbacks: SSEStreamCallbacks = {
        onTextChunk: (text: string): void => { result.textContent += text },
        onJsonData: (json: object): void => { result.jsonData = json; responseBody = JSON.stringify(json) },
        onError: (err: string): void => { this.logger.error(TAG, `SSE error: ${err}`) },
        onDone: (): void => { /* [DONE] received */ }
      }
      const sseParser: SSEStreamParser = new SSEStreamParser(aiCallbacks)

      try {
        httpRequest = http.createHttp()
        httpRequest.on('dataReceive', (data: ArrayBuffer): void => {
          sseParser.onChunkReceived(this.arrayBufferToString(data))
        })
        httpRequest.on('dataEnd', (): void => {
          sseParser.onStreamEnd()
          if (!settled) {
            settled = true
            finalize(AiRequestStatus.SUCCESS)
            resolve(result)
          }
        })
        const reqHeader2: RequestHeader = {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`
        }
        httpRequest.request(API_URL, {
          method: http.RequestMethod.POST,
          header: reqHeader2,
          extraData: ((): string => {
            const sysMsg: ChatMessage = { role: 'system', content: '你是三问高效学习机的AI助手，帮助学员深入理解知识。' }
            const userMsg: ChatMessage = { role: 'user', content: prompt }
            const messages: ChatMessage[] = [sysMsg, userMsg]
            const body: RequestBody = { model: MODEL, messages: messages, stream: true }
            return JSON.stringify(body)
          })(),
          expectDataType: http.HttpDataType.STRING,
          connectTimeout: AI_CONFIG.CONNECT_TIMEOUT_MS,
          readTimeout: AI_CONFIG.READ_TIMEOUT_MS
        })

        // 120s overall timeout per AI_SERVICE_PROTOCOL.md
        timeoutId = setTimeout(() => {
          if (!settled) {
            settled = true
            sseParser.reset()
            if (httpRequest) {
              try { httpRequest.destroy() } catch (_e) { /* ignore */ }
              httpRequest = null
            }
            finalize(AiRequestStatus.FAILED)
            reject(new Error(ErrorCode.AI_TIMEOUT))
          }
        }, 120000)
      } catch (e) {
        if (!settled) {
          settled = true
          sseParser.reset()
          finalize(AiRequestStatus.FAILED)
          reject(new Error(ErrorCode.AI_FAILED))
        }
      }
    })
  }

  private async processKnowledgeGraph(courseId: string, result: SSEResult): Promise<void> {
    if (!result.jsonData) {
      throw new Error('No knowledge graph data received from AI')
    }
    const data: Record<string, Object> = result.jsonData as Record<string, Object>
    const aiNodes: Array<Record<string, Object>> = (data['nodes'] as Array<Record<string, Object>>) ?? []
    const aiEdges: Array<Record<string, Object>> = (data['edges'] as Array<Record<string, Object>>) ?? []

    // 替换 AI 生成的节点 ID 为系统 UUID
    const idMap: Map<string, string> = new Map()
    for (const node of aiNodes) {
      idMap.set(node['id'] as string, generateUUID())
    }

    await this.rdb.executeInTransaction(async (): Promise<void> => {
      for (let i: number = 0; i < aiNodes.length; i++) {
        const node: Record<string, Object> = aiNodes[i]
        const values: relationalStore.ValuesBucket = {
          'id': idMap.get(node['id'] as string) ?? generateUUID(),
          'course_id': courseId,
          'label': (node['label'] as string) ?? '',
          'type': (node['type'] as string) ?? 'core',
          'description': (node['description'] as string) ?? '',
          'is_activated': RdbHelper.boolToDb(false),
          'x_pos': -1, 'y_pos': -1, 'sort_order': i
        }
        await this.rdb.insert('knowledge_node', values)
      }
      for (let i: number = 0; i < aiEdges.length; i++) {
        const edge: Record<string, Object> = aiEdges[i]
        const values: relationalStore.ValuesBucket = {
          'id': generateUUID(),
          'course_id': courseId,
          'source': idMap.get(edge['source'] as string) ?? (edge['source'] as string),
          'target': idMap.get(edge['target'] as string) ?? (edge['target'] as string),
          'relation': (edge['relation'] as string) ?? ''
        }
        await this.rdb.insert('knowledge_edge', values)
      }
    })
  }

  private async processControversies(courseId: string, result: SSEResult): Promise<void> {
    if (!result.jsonData) {
      throw new Error('No controversy data received from AI')
    }
    const data: Record<string, Object> = result.jsonData as Record<string, Object>
    const controversies: Array<Record<string, Object>> =
      (data['controversies'] as Array<Record<string, Object>>) ?? []

    await this.rdb.executeInTransaction(async (): Promise<void> => {
      for (let i: number = 0; i < controversies.length; i++) {
        const c: Record<string, Object> = controversies[i]
        const values: relationalStore.ValuesBucket = {
          'id': generateUUID(),
          'course_id': courseId,
          'title': (c['title'] as string) ?? '',
          'view_a': (c['view_a'] as string) ?? '',
          'evidence_a': (c['evidence_a'] as string) ?? '',
          'view_b': (c['view_b'] as string) ?? '',
          'evidence_b': (c['evidence_b'] as string) ?? '',
          'conclusion': (c['conclusion'] as string) ?? '',
          'is_selected': RdbHelper.boolToDb(false),
          'sort_order': i
        }
        await this.rdb.insert('controversy', values)
      }
    })
  }

  private parseQuizQuestions(courseId: string, result: SSEResult,
    validNodeIds: string[]): QuizQuestion[] {
    if (!result.jsonData) {
      throw new Error('No quiz data received from AI')
    }
    const data: Record<string, Object> = result.jsonData as Record<string, Object>
    const rawQuestions: Array<Record<string, Object>> =
      (data['questions'] as Array<Record<string, Object>>) ?? []
    const questions: QuizQuestion[] = []

    for (let i: number = 0; i < rawQuestions.length; i++) {
      const q: Record<string, Object> = rawQuestions[i]
      let linkedNodeIds: string[] = RdbHelper.safeParseJsonArray(
        (q['linked_node_ids'] as string) ?? '')
      linkedNodeIds = linkedNodeIds.filter((id: string) => validNodeIds.includes(id))
      questions.push({
        id: generateUUID(),
        course_id: courseId,
        bloom_level: (q['bloom_level'] as number) ?? BloomLevel.REMEMBER,
        linked_node_ids: JSON.stringify(linkedNodeIds),
        question_text: (q['question_text'] as string) ?? '',
        options: (q['options'] as string) ?? '',
        correct_answer: (q['correct_answer'] as string) ?? '',
        sort_order: (q['sort_order'] as number) ?? i
      })
    }
    return questions
  }

  private async processQuizQuestions(questions: QuizQuestion[]): Promise<void> {
    await this.rdb.executeInTransaction(async (): Promise<void> => {
      for (const q of questions) {
        const values: relationalStore.ValuesBucket = {
          'id': q.id, 'course_id': q.course_id, 'bloom_level': q.bloom_level,
          'linked_node_ids': q.linked_node_ids, 'question_text': q.question_text,
          'options': q.options, 'correct_answer': q.correct_answer, 'sort_order': q.sort_order
        }
        await this.rdb.insert('quiz_question', values)
      }
    })
  }

  private validateBloomDistribution(questions: QuizQuestion[]): boolean {
    if (questions.length !== 9) {
      this.logger.warn(TAG, `Expected 9 questions, got ${questions.length}`)
      return false
    }
    const dist: Record<number, number> = {}
    for (const q of questions) {
      dist[q.bloom_level] = (dist[q.bloom_level] ?? 0) + 1
    }
    for (let level: number = 1; level <= 6; level++) {
      if ((dist[level] ?? 0) !== (BLOOM_DISTRIBUTION[level] ?? 0)) {
        return false
      }
    }
    return true
  }

  async logRequest(courseId: string, requestType: string, requestPrompt: string,
    responseBody: string, status: AiRequestStatus, durationMs: number): Promise<void> {
    try {
      const values: relationalStore.ValuesBucket = {
        'id': generateUUID(),
        'course_id': courseId,
        'request_type': requestType,
        'request_prompt': this.maskApiKey(requestPrompt),
        'response_body': responseBody,
        'status': status,
        'duration_ms': durationMs,
        'create_time': Date.now()
      }
      await this.rdb.insert('ai_request_log', values)
    } catch (e) {
      this.logger.error(TAG, 'Failed to log AI request', String(e))
    }
  }

  private maskApiKey(text: string): string {
    let masked: string = text.replace(/Bearer [\w\-]+/g, (match: string) => {
      const token: string = match.substring(7)
      if (token.length <= 7) {
        return 'Bearer ***'
      }
      return `Bearer ${token.substring(0, 3)}***${token.substring(token.length - 4)}`
    })
    masked = masked.replace(/"(api_?key)"\s*:\s*"([^"]+)"/gi,
      (_: string, key: string, value: string): string => {
        if (value.length <= 7) {
          return `"${key}": "***"`
        }
        return `"${key}": "${value.substring(0, 3)}***${value.substring(value.length - 4)}"`
      })
    return masked
  }

  /**
   * 上下文感知对话 — 注入课程上下文的多轮对话
   * 复用 sendAIRequest 基础设施，支持 onJsonData 回调用于结构化内容
   */
  async chatWithContext(courseId: string, userMessage: string,
    onTextChunk: (text: string) => void,
    onJsonData?: (data: object) => void): Promise<void> {
    const courseContext: string = await this.buildCourseContext(courseId)
    const systemPrompt: string = this.buildLearningAssistantPrompt(courseContext)

    return new Promise<void>(async (resolve, reject) => {
      if (!this.context) {
        reject(new Error('AIService not initialized'))
        return
      }
      if (!NetworkMonitor.getInstance().isNetworkAvailable()) {
        reject(new Error(ErrorCode.NETWORK_DISCONNECTED))
        return
      }
      if (!GlobalRateLimiter.getInstance().canRequest()) {
        reject(new Error(ErrorCode.AI_FAILED))
        return
      }
      const lock: AIConcurrencyLock = AIConcurrencyLock.getInstance()
      if (!lock.acquireLock(courseId)) {
        reject(new Error(ErrorCode.AI_FAILED))
        return
      }

      const startTime: number = Date.now()
      let apiKey: string = ''
      let responseBody: string = ''
      let settled: boolean = false
      let timeoutId: number = -1
      let httpRequest: http.HttpRequest | null = null

      const finalize = (status: AiRequestStatus): void => {
        const duration: number = Date.now() - startTime
        lock.releaseLock(courseId)
        GlobalRateLimiter.getInstance().recordRequest()
        this.logRequest(courseId, 'chat_with_context', this.maskApiKey(systemPrompt + userMessage), responseBody, status, duration)
        apiKey = ''
        if (timeoutId !== -1) { clearTimeout(timeoutId); timeoutId = -1 }
      }

      try {
        apiKey = await ApiKeyStore.loadApiKey(this.context!, API_KEY_ALIAS)
      } catch (e) {
        lock.releaseLock(courseId); reject(new Error(ErrorCode.AI_FAILED)); return
      }

      const callbacks: SSEStreamCallbacks = {
        onTextChunk: onTextChunk,
        onJsonData: onJsonData ?? ((_data: object): void => {}),
        onError: (err: string): void => { this.logger.error(TAG, `chatWithContext SSE error: ${err}`) },
        onDone: (): void => {}
      }
      const sseParser: SSEStreamParser = new SSEStreamParser(callbacks)

      try {
        httpRequest = http.createHttp()
        httpRequest.on('dataReceive', (data: ArrayBuffer): void => {
          sseParser.onChunkReceived(this.arrayBufferToString(data))
        })
        httpRequest.on('dataEnd', (): void => {
          sseParser.onStreamEnd()
          if (!settled) { settled = true; finalize(AiRequestStatus.SUCCESS); resolve() }
        })

        // 构造消息：system prompt 作为首条消息，用户消息作为第二条
        const sysMsg: ChatMessage = { role: 'system', content: systemPrompt }
        const userMsg: ChatMessage = { role: 'user', content: userMessage }
        const reqBody: RequestBody = { model: MODEL, messages: [sysMsg, userMsg], stream: true }
        const reqHeader: RequestHeader = {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`
        }
        httpRequest.request(API_URL, {
          method: http.RequestMethod.POST, header: reqHeader,
          extraData: JSON.stringify(reqBody),
          expectDataType: http.HttpDataType.STRING,
          connectTimeout: AI_CONFIG.CONNECT_TIMEOUT_MS,
          readTimeout: AI_CONFIG.READ_TIMEOUT_MS
        })

        timeoutId = setTimeout(() => {
          if (!settled) {
            settled = true; sseParser.reset()
            if (httpRequest) { try { httpRequest.destroy() } catch (_e) {} httpRequest = null }
            finalize(AiRequestStatus.FAILED); reject(new Error(ErrorCode.AI_TIMEOUT))
          }
        }, 120000)
      } catch (e) {
        if (!settled) {
          settled = true; sseParser.reset(); finalize(AiRequestStatus.FAILED); reject(new Error(ErrorCode.AI_FAILED))
        }
      }
    })
  }

  /**
   * 构建学习助手专属 system prompt 模板
   * 包含角色定义、防幻觉指令、输出格式约束
   */
  buildLearningAssistantPrompt(courseContext: string): string {
    let prompt: string = `你是"三问高效学习机"的智能学习伙伴。你的职责是帮助学员深入理解知识、探索不同观点、培养批判性思维。

【核心原则】
1. 你是辅助者而非替代者 — 绝不代替学员作答或思考
2. 回答必须基于提供的课程资料和上下文，不得编造内容
3. 如果不确定某个信息，必须诚实说明"我不确定"
4. 鼓励学员多角度思考，但不要强加观点

【输出要求】
- 使用清晰、易懂的语言
- 必要时使用类比帮助理解
- 可以在回复末尾追加 1-2 个引导性问题以促进深度思考`

    if (courseContext.length > 0) {
      prompt += `\n\n【课程上下文】\n${courseContext}`
    }
    return prompt
  }

  /**
   * 通用内容生成方法 — 支持思维导图/学习文档/知识框架/知识摘要
   * 复用 SSE 两阶段协议：Phase1 text → 提示语 | Phase2 json → 结构化数据
   */
  async generateContent(requestType: string, topic: string,
    onTextChunk: (text: string) => void,
    onJsonData: (data: object) => void): Promise<void> {
    const typePrompts: Record<string, string> = {
      'knowledge_summary':
        `请为"${topic}"生成结构化知识摘要。严格输出JSON：` +
        `{"type":"knowledge","title":"${topic}","keyConcepts":[{"term":"术语","definition":"定义"}],"corePoints":["要点"],"resources":[{"title":"","url":"","summary":""}],"relatedTerms":["术语"]}`,
      'mindmap':
        `请为"${topic}"生成思维导图数据。严格输出JSON：` +
        `{"type":"mindmap","title":"${topic}","nodes":[{"id":"n1","label":"标签","x":100,"y":100,"nodeType":"core"}],"edges":[{"source":"n1","target":"n2","weight":1}]}` +
        `约束：8-20个节点，节点ID唯一，坐标范围100-800`,
      'study_doc':
        `请为"${topic}"生成详细学习文档。严格输出JSON：` +
        `{"type":"study_doc","title":"${topic}","subject":"学科","sections":[{"heading":"H1标题","content":"Markdown正文","bulletPoints":["列表项"],"codeBlock":{"language":"语言","code":"代码"}}],"summary":"全文摘要","keyTerms":[{"term":"术语","definition":"定义"}]}`,
      'framework':
        `请为"${topic}"学科构建完整知识体系框架。严格输出JSON：` +
        `{"type":"framework","subject":"${topic}","tree":[{"id":"t1","label":"章节","level":0,"children":["t2"],"description":"描述","estimatedHours":2}],"learningPath":["t1","t2"]}` +
        `约束：至少3层深度（章→节→点），推荐学习路径`
    }

    const basePrompt: string = typePrompts[requestType] ?? ''
    if (!basePrompt) {
      onTextChunk('不支持的内容生成类型')
      return
    }

    const fullPrompt: string = basePrompt +
      '\n\n【系统约束】\n' +
      '1. 禁止编造内容，不确定的信息标注"[需核实]"\n' +
      '2. JSON 必须完整一次性输出，禁止分片\n' +
      '3. 所有字段必须符合上述 schema'

    // 复用 sendAIRequest 基础设施（不需要 courseId 的全局锁，使用特殊标识）
    await this.sendAIRequest('__global__', fullPrompt, requestType === 'knowledge_summary' ? 'knowledge_retrieval' : `content_gen_${requestType}`)
      .then((result: SSEResult) => {
        if (result.textContent) { onTextChunk(result.textContent) }
        if (result.jsonData && onJsonData) { onJsonData(result.jsonData) }
      })
      .catch((e: Error) => { throw e })
  }

  private arrayBufferToString(buffer: ArrayBuffer): string {
    return util.TextDecoder.create('utf-8').decodeToString(new Uint8Array(buffer))
  }
}
