/**
 * ChatViewModel - AI 对话状态管理（单例）
 * 独立于 ThreeAskViewModel，管理对话面板的全部业务逻辑
 */
import { AiMessage, AiConversation } from '../models/Models'
import { AIService } from '../services/AIService'
import { IntentType, classify } from '../services/AIIntentEngine'
import { RdbHelper } from '../db/RdbHelper'
import { relationalStore } from '@kit.ArkData'
import { Logger } from '../common/Logger'

const TAG: string = 'ChatViewModel'
const MAX_INPUT_LENGTH: number = 500

/** UI 层消息展示模型 */
export interface ChatDisplayMessage {
  id: string
  role: string
  content: string
  intentType: string | null
  isStreaming: boolean
  isError: boolean
  contentType: string | null    // 'mindmap' | 'studydoc' | 'framework' | 'knowledge' | null
  contentData: object | null   // 结构化内容数据对象
}

/** 输入校验结果 */
interface ValidationResult {
  valid: boolean
  hint: string
}

function generateUUID(): string {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c: string) => {
    const r: number = Math.random() * 16 | 0
    const v: number = c === 'x' ? r : (r & 0x3 | 0x8)
    return v.toString(16)
  })
}

function createDisplayMessage(id: string, role: string, content: string,
  intentType: string | null, isStreaming: boolean, isError: boolean,
  contentType: string | null = null, contentData: object | null = null): ChatDisplayMessage {
  return { id: id, role: role, content: content, intentType: intentType,
    isStreaming: isStreaming, isError: isError,
    contentType: contentType, contentData: contentData }
}

/** 复制数组并追加元素 */
function appendItem<T>(list: T[], item: T): T[] {
  const result: T[] = []
  for (let i: number = 0; i < list.length; i++) {
    result.push(list[i])
  }
  result.push(item)
  return result
}

export class ChatViewModel {
  private static instance: ChatViewModel | null = null

  static getInstance(): ChatViewModel {
    if (!ChatViewModel.instance) {
      ChatViewModel.instance = new ChatViewModel()
    }
    return ChatViewModel.instance
  }

  private rdb: RdbHelper = RdbHelper.getInstance()
  private aiService: AIService = AIService.getInstance()
  private logger: Logger = Logger.getInstance()

  /** 当前课程 ID */
  currentCourseId: string = ''
  /** 当前功能模式 */
  currentMode: string = 'chat' // 'chat' | 'retrieve' | 'mindmap' | 'studydoc' | 'framework'
  /** 当前会话 ID */
  currentConversationId: string = ''
  /** 是否正在流式输出 */
  isStreaming: boolean = false
  /** 网络是否可用 */
  isNetworkAvailable: boolean = true
  /** 错误提示信息 */
  errorMessage: string = ''
  /** 是否可重试 */
  canRetry: boolean = false
  /** 输入文本 */
  inputText: string = ''
  /** 消息列表（用于 UI 渲染） */
  messages: ChatDisplayMessage[] = []
  /** 是否有活跃课程 */
  hasActiveCourse: boolean = false

  /** 持久化的消息列表（用于构建 Prompt 上下文） */
  private persistedMessages: AiMessage[] = []

  /** 切换课程时调用 */
  async switchCourse(courseId: string): Promise<void> {
    if (this.currentCourseId === courseId && this.messages.length > 0) {
      return
    }
    this.currentCourseId = courseId
    this.hasActiveCourse = courseId.length > 0
    this.messages = []
    this.persistedMessages = []
    this.currentConversationId = ''
    this.errorMessage = ''
    this.canRetry = false

    if (courseId.length > 0) {
      await this.loadHistory(courseId)
    }
  }

  /** 加载历史对话 */
  async loadHistory(courseId: string): Promise<void> {
    if (!courseId) {
      return
    }
    try {
      const conv: AiConversation | null = await this.rdb.getLatestConversationByCourseId(courseId)
      if (conv) {
        this.currentConversationId = conv.id
        const dbMessages: AiMessage[] = await this.rdb.getMessagesByConversationId(conv.id)
        this.persistedMessages = dbMessages
        const displayMsgs: ChatDisplayMessage[] = []
        for (const m of dbMessages) {
          displayMsgs.push(createDisplayMessage(m.id, m.role, m.content, m.intent_type, false, false))
        }
        this.messages = displayMsgs
      }
    } catch (e) {
      this.logger.error(TAG, `loadHistory failed: ${courseId}`, String(e))
    }
  }

  /**
   * 切换功能模式
   * @param mode 目标模式: chat / retrieve / mindmap / studydoc / framework
   */
  switchMode(mode: string): void {
    this.currentMode = mode
  }

  /** 发送消息 */
  async sendMessage(text: string): Promise<void> {
    const trimmed: string = text.trim()
    this.logger.info(TAG, `sendMessage invoked: text="${trimmed}", mode=${this.currentMode}, hasCourse=${this.hasActiveCourse}, streaming=${this.isStreaming}`)

    if (!trimmed || this.isStreaming) {
      this.logger.warn(TAG, `sendMessage early return: empty=${!trimmed}, streaming=${this.isStreaming}`)
      return
    }
    if (trimmed.length > MAX_INPUT_LENGTH) {
      return
    }

    // 无课程时提示
    if (!this.hasActiveCourse) {
      this.logger.warn(TAG, `sendMessage blocked: no active course (courseId="${this.currentCourseId}")`)
      const guideMsg: ChatDisplayMessage = createDisplayMessage(
        generateUUID(), 'system',
        '请先创建或选择一个课程，AI 学习伙伴才能为您提供针对性的学习建议。',
        null, false, false)
      this.messages = appendItem(this.messages, guideMsg)
      return
    }

    // 处理斜杠指令
    if (trimmed.startsWith('/')) {
      this.handleSlashCommand(trimmed)
      return
    }

    // 意图识别
    const intent: IntentType | null = classify(trimmed)
    const intentStr: string | null = intent !== null ? intent as string : null

    // 创建用户消息
    const userMsgId: string = generateUUID()
    const userDisplayMsg: ChatDisplayMessage = createDisplayMessage(
      userMsgId, 'user', trimmed, intentStr, false, false)

    this.messages = appendItem(this.messages, userDisplayMsg)
    this.inputText = ''
    this.errorMessage = ''
    this.canRetry = false

    // 确保有会话
    if (!this.currentConversationId) {
      await this.createConversation(trimmed)
    }

    // 持久化用户消息
    const userAiMsg: AiMessage = {
      id: userMsgId,
      conversation_id: this.currentConversationId,
      role: 'user',
      content: trimmed,
      intent_type: intentStr,
      created_at: Date.now()
    }
    await this.rdb.insertMessage(userAiMsg)
    this.persistedMessages = appendItem(this.persistedMessages, userAiMsg)

    // 创建 AI 消息占位
    const aiMsgId: string = generateUUID()
    const aiDisplayMsg: ChatDisplayMessage = createDisplayMessage(
      aiMsgId, 'assistant', '', intentStr, true, false)

    this.messages = appendItem(this.messages, aiDisplayMsg)
    this.isStreaming = true

    try {
      let aiContent: string = ''
      let receivedContentData: object | null = null

      if (this.currentMode === 'chat') {
        // 普通对话模式 — 使用原有 chat 方法
        await this.aiService.chat(
          this.currentCourseId,
          trimmed,
          this.persistedMessages.slice(0, this.persistedMessages.length - 1),
          (chunk: string): void => {
            aiContent += chunk
            this.messages = this.updateMessageContent(this.messages, aiMsgId, aiContent)
          }
        )
      } else if (this.currentMode === 'retrieve') {
        // 知识检索模式 — 动态导入（避免解构赋值）
        const KnowledgeRetrieverModule = await import('../services/KnowledgeRetriever')
        const KnowledgeRetriever = KnowledgeRetrieverModule.KnowledgeRetriever
        await KnowledgeRetriever.getInstance().getSummary(
          trimmed,
          (chunk: string): void => {
            aiContent += chunk
            this.messages = this.updateMessageContent(this.messages, aiMsgId, aiContent)
          },
          (data: object): void => {
            receivedContentData = data
          }
        )
      } else {
        // 内容生成模式：mindmap / studydoc / framework
        const modeToType: Record<string, string> = {
          'mindmap': 'mindmap',
          'studydoc': 'study_doc',
          'framework': 'framework'
        }
        const reqType: string = modeToType[this.currentMode] ?? 'mindmap'

        await this.aiService.generateContent(
          reqType,
          trimmed,
          (chunk: string): void => {
            aiContent += chunk
            this.messages = this.updateMessageContent(this.messages, aiMsgId, aiContent)
          },
          (data: object): void => {
            receivedContentData = data
          }
        )
      }

      // 流式完成 — 如果有结构化数据，标记消息类型
      if (receivedContentData) {
        const typeMap: Record<string, string> = {
          'retrieve': 'knowledge', 'mindmap': 'mindmap',
          'studydoc': 'studydoc', 'framework': 'framework'
        }
        this.messages = this.updateMessageWithContent(
          this.messages, aiMsgId, false, typeMap[this.currentMode] ?? null, receivedContentData)
      } else {
        this.messages = this.updateMessageStreaming(this.messages, aiMsgId, false)
      }
      this.isStreaming = false

      // 持久化 AI 消息
      const aiAiMsg: AiMessage = {
        id: aiMsgId,
        conversation_id: this.currentConversationId,
        role: 'assistant',
        content: aiContent,
        intent_type: intentStr,
        created_at: Date.now()
      }
      await this.rdb.insertMessage(aiAiMsg)
      this.persistedMessages = appendItem(this.persistedMessages, aiAiMsg)

      // 持久化生成内容到 material 表（7.1-7.3）
      if (receivedContentData) {
        const typeMap2: Record<string, string> = {
          'retrieve': 'knowledge', 'mindmap': 'mindmap',
          'studydoc': 'studydoc', 'framework': 'framework'
        }
        const matType: string = typeMap2[this.currentMode] ?? 'knowledge'
        await this.saveGeneratedMaterial(trimmed, matType, receivedContentData)
      }

      // 更新会话时间戳
      await this.rdb.updateConversationTimestamp(this.currentConversationId, Date.now())
    } catch (e) {
      this.isStreaming = false
      const errMsg: string = String(e)
      this.messages = this.updateMessageError(this.messages, aiMsgId)

      if (errMsg.includes('NETWORK_DISCONNECTED')) {
        this.errorMessage = '当前无网络连接，请检查网络后重试'
      } else if (errMsg.includes('AI_FAILED')) {
        this.errorMessage = 'AI 正在处理其他任务，请稍后再试'
      } else if (errMsg.includes('AI_TIMEOUT')) {
        this.errorMessage = 'AI 响应超时，请稍后重试'
      } else {
        this.errorMessage = '请求失败，请稍后重试'
      }
      this.canRetry = true
    }
  }

  /** 重试最后一条消息 */
  async retryLastMessage(): Promise<void> {
    let lastUserMsg: ChatDisplayMessage | null = null
    for (let i: number = this.messages.length - 1; i >= 0; i--) {
      if (this.messages[i].role === 'user') {
        lastUserMsg = this.messages[i]
        break
      }
    }
    if (lastUserMsg) {
      const filtered: ChatDisplayMessage[] = []
      for (const m of this.messages) {
        if (!m.isError) {
          filtered.push(m)
        }
      }
      this.messages = filtered
      this.errorMessage = ''
      this.canRetry = false
      await this.sendMessage(lastUserMsg.content)
    }
  }

  /** 重试内容生成请求 */
  async retryContentGeneration(): Promise<void> {
    // 找到最后一条 assistant 消息且包含结构化内容的
    let lastAssistantIdx: number = -1
    for (let i: number = this.messages.length - 1; i >= 0; i--) {
      if (this.messages[i].role === 'assistant' && this.messages[i].contentType) {
        lastAssistantIdx = i
        break
      }
    }
    if (lastAssistantIdx < 0) return

    // 找到对应的用户消息
    let lastUserMsg: ChatDisplayMessage | null = null
    for (let i: number = lastAssistantIdx - 1; i >= 0; i--) {
      if (this.messages[i].role === 'user') {
        lastUserMsg = this.messages[i]
        break
      }
    }
    if (!lastUserMsg) return

    // 移除旧的 AI 响应消息
    const filtered: ChatDisplayMessage[] = []
    for (const m of this.messages) {
      if (m.id !== this.messages[lastAssistantIdx].id) {
        filtered.push(m)
      }
    }
    this.messages = filtered
    this.errorMessage = ''
    this.canRetry = false

    // 重新发送
    await this.sendMessage(lastUserMsg.content)
  }

  /**
   * 保存 AI 生成的内容到 material 表（7.1-7.3）
   * @param title 内容标题（用户输入的主题）
   * @param matType 素材类型：mindmap / studydoc / framework / knowledge
   * @param data 结构化内容数据对象
   */
  async saveGeneratedMaterial(title: string, matType: string,
    data: object): Promise<void> {
    try {
      const contentJson: string = JSON.stringify(data) // 7.2: JSON 序列化
      const values: relationalStore.ValuesBucket = {
        'id': generateUUID(),
        'course_id': this.currentCourseId,
        'file_name': `[AI] ${title}`,
        'file_path': '', // AI 生成内容无物理文件路径
        'type': matType, // mindmap / studydoc / framework / knowledge
        'status': 'success',     // MaterialStatus.SUCCESS
        'parsed_content': contentJson
      }
      await this.rdb.insert('material', values)
      this.logger.info(TAG, `Material saved: type=${matType}, title=${title}`)
    } catch (e) {
      this.logger.error(TAG, `saveGeneratedMaterial failed`, String(e))
    }
  }

  /** 清空当前对话 */
  async clearConversation(): Promise<void> {
    this.messages = []
    this.persistedMessages = []
    this.currentConversationId = ''
    this.errorMessage = ''
    this.canRetry = false
    this.isStreaming = false
  }

  /**
   * 预加载已有素材到消息列表
   * 从 material 表读取当前课程的已缓存素材，转为 ChatDisplayMessage 渲染
   */
  async preloadContent(courseId: string): Promise<void> {
    if (!courseId) {
      return
    }
    try {
      // material 表无 created_at 列，按 rowid 降序（最近插入优先）
      const sql: string = 'SELECT * FROM material WHERE course_id = ? AND status = ? ORDER BY rowid DESC'
      const resultSet: relationalStore.ResultSet = await this.rdb.query(sql, [courseId, 'success'])
      const count: number = resultSet.rowCount
      if (count <= 0) {
        resultSet.close()
        return
      }

      const preloadedMsgs: ChatDisplayMessage[] = []
      resultSet.goToFirstRow()
      for (let i = 0; i < count; i++) {
        const fileName: string = resultSet.getString(resultSet.getColumnIndex('file_name'))
        const parsedContent: string = resultSet.getString(resultSet.getColumnIndex('parsed_content'))

        // 解析 parsed_content JSON → 摘要文本
        let summary: string = fileName
        if (parsedContent && parsedContent.length > 0) {
          try {
            const contentObj: Record<string, Object> = JSON.parse(parsedContent) as Record<string, Object>
            // 尝试提取标题或摘要
            const title = contentObj['title'] as string | undefined
            if (title) {
              summary = `[${title}]`
            }
          } catch (_e) {
            this.logger.warn(TAG, `preloadContent: skip invalid JSON for material "${fileName}"`)
          }
        }

        const msg: ChatDisplayMessage = createDisplayMessage(
          generateUUID(), 'assistant', summary, null, false, false)
        preloadedMsgs.push(msg)

        if (!resultSet.goToNextRow()) {
          break
        }
      }
      resultSet.close()

      // 追加到消息列表（不使用 spread）
      if (preloadedMsgs.length > 0) {
        for (const m of preloadedMsgs) {
          this.messages = appendItem(this.messages, m)
        }
        this.logger.info(TAG, `preloadContent: loaded ${preloadedMsgs.length} materials for course ${courseId}`)
      }
    } catch (e) {
      this.logger.error(TAG, `preloadContent failed: ${courseId}`, String(e))
    }
  }

  /** 输入校验 */
  validateInput(text: string): ValidationResult {
    if (!text || text.trim().length === 0) {
      const result: ValidationResult = { valid: false, hint: '' }
      return result
    }
    if (text.length > MAX_INPUT_LENGTH) {
      const result: ValidationResult = { valid: false, hint: '已超出字数限制' }
      return result
    }
    if (this.isStreaming) {
      const result: ValidationResult = { valid: false, hint: 'AI 正在回复中' }
      return result
    }
    const result: ValidationResult = { valid: true, hint: '' }
    return result
  }

  /** 更新网络状态 */
  updateNetworkStatus(available: boolean): void {
    this.isNetworkAvailable = available
  }

  /** 处理斜杠指令 */
  private async handleSlashCommand(command: string): Promise<void> {
    this.inputText = ''
    const cmd: string = command.toLowerCase().trim()

    if (cmd === '/help') {
      const helpMsg: ChatDisplayMessage = createDisplayMessage(
        generateUUID(), 'system',
        '可用指令：\n/help - 显示帮助\n/clear - 清空对话\n/q1 - 询问"是什么"阶段要点\n/q2 - 询问"为什么"阶段要点\n/q3 - 询问"怎么用"阶段要点\n/search <主题> - 检索知识摘要\n/mindmap <主题> - 生成思维导图\n/doc <主题> - 生成学习文档\n/framework <学科> - 生成知识框架',
        null, false, false)
      this.messages = appendItem(this.messages, helpMsg)
    } else if (cmd === '/clear') {
      await this.clearConversation()
      const clearMsg: ChatDisplayMessage = createDisplayMessage(
        generateUUID(), 'system', '对话已清空', null, false, false)
      const clearMsgs: ChatDisplayMessage[] = []
      clearMsgs.push(clearMsg)
      this.messages = clearMsgs
    } else if (cmd === '/q1') {
      await this.sendMessage('请总结一下我在"是什么"阶段的学习要点和建议')
    } else if (cmd === '/q2') {
      await this.sendMessage('请总结一下我在"为什么"阶段的学习要点和建议')
    } else if (cmd === '/q3') {
      await this.sendMessage('请总结一下我在"怎么用"阶段的学习要点和建议')
    } else if (cmd.startsWith('/search ')) {
      const topic: string = cmd.substring(8).trim()
      this.switchMode('retrieve')
      if (topic) { await this.sendMessage(topic) }
    } else if (cmd.startsWith('/mindmap ')) {
      const topic: string = cmd.substring(9).trim()
      this.switchMode('mindmap')
      if (topic) { await this.sendMessage(topic) }
    } else if (cmd.startsWith('/doc ')) {
      const topic: string = cmd.substring(5).trim()
      this.switchMode('studydoc')
      if (topic) { await this.sendMessage(topic) }
    } else if (cmd.startsWith('/framework ')) {
      const topic: string = cmd.substring(11).trim()
      this.switchMode('framework')
      if (topic) { await this.sendMessage(topic) }
    } else if (cmd === '/search' || cmd === '/mindmap' || cmd === '/doc' || cmd === '/framework') {
      // 无参数时仅切换模式
      const modeMap: Record<string, string> = { '/search': 'retrieve', '/mindmap': 'mindmap', '/doc': 'studydoc', '/framework': 'framework' }
      this.switchMode(modeMap[cmd] ?? 'chat')
      const hintMsg: ChatDisplayMessage = createDisplayMessage(
        generateUUID(), 'system',
        `已切换到${cmd}模式，请输入主题开始${cmd === '/search' ? '检索' : cmd === '/mindmap' ? '生成思维导图' : cmd === '/doc' ? '生成文档' : '生成知识框架'}`,
        null, false, false)
      this.messages = appendItem(this.messages, hintMsg)
    } else {
      const unknownMsg: ChatDisplayMessage = createDisplayMessage(
        generateUUID(), 'system', '未知指令，输入 /help 查看可用指令', null, false, false)
      this.messages = appendItem(this.messages, unknownMsg)
    }
  }

  /** 创建新会话 */
  private async createConversation(firstMessage: string): Promise<void> {
    const convId: string = generateUUID()
    const now: number = Date.now()
    const conv: AiConversation = {
      id: convId,
      course_id: this.currentCourseId,
      title: firstMessage.substring(0, 20),
      created_at: now,
      updated_at: now
    }
    await this.rdb.insertConversation(conv)
    this.currentConversationId = convId
  }

  /** 更新消息内容 */
  private updateMessageContent(list: ChatDisplayMessage[], targetId: string,
    content: string): ChatDisplayMessage[] {
    const result: ChatDisplayMessage[] = []
    for (let i: number = 0; i < list.length; i++) {
      if (list[i].id === targetId) {
        result.push(createDisplayMessage(list[i].id, list[i].role, content,
          list[i].intentType, list[i].isStreaming, list[i].isError))
      } else {
        result.push(list[i])
      }
    }
    return result
  }

  /** 更新消息流式状态 */
  private updateMessageStreaming(list: ChatDisplayMessage[], targetId: string,
    streaming: boolean): ChatDisplayMessage[] {
    const result: ChatDisplayMessage[] = []
    for (let i: number = 0; i < list.length; i++) {
      if (list[i].id === targetId) {
        result.push(createDisplayMessage(list[i].id, list[i].role, list[i].content,
          list[i].intentType, streaming, list[i].isError))
      } else {
        result.push(list[i])
      }
    }
    return result
  }

  /** 标记消息为错误 */
  private updateMessageError(list: ChatDisplayMessage[], targetId: string): ChatDisplayMessage[] {
    const result: ChatDisplayMessage[] = []
    for (let i: number = 0; i < list.length; i++) {
      if (list[i].id === targetId) {
        result.push(createDisplayMessage(list[i].id, list[i].role, '',
          list[i].intentType, false, true))
      } else {
        result.push(list[i])
      }
    }
    return result
  }

  /** 更新消息并附加结构化内容数据 */
  private updateMessageWithContent(list: ChatDisplayMessage[], targetId: string,
    streaming: boolean, contentType: string | null, contentData: object | null): ChatDisplayMessage[] {
    const result: ChatDisplayMessage[] = []
    for (let i: number = 0; i < list.length; i++) {
      if (list[i].id === targetId) {
        result.push(createDisplayMessage(list[i].id, list[i].role, list[i].content,
          list[i].intentType, streaming, list[i].isError, contentType, contentData))
      } else {
        result.push(list[i])
      }
    }
    return result
  }
}
