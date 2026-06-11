/**
 * KnowledgeRetriever - 知识检索服务（AI 增强检索）
 * 通过 AI 生成结构化知识摘要，模拟网络检索效果
 * 缓存机制避免重复 Token 消耗
 */
import { AIService } from './AIService'

const TAG: string = 'KnowledgeRetriever'
const CACHE_TTL_MS: number = 24 * 60 * 60 * 1000 // 24 小时

/** 核心概念项 */
interface KeyConceptItem {
  term: string
  definition: string
}

/** 资源项 */
interface ResourceItem {
  title: string
  url: string
  summary: string
}

/** 知识摘要接口 */
export interface KnowledgeSummary {
  type: string
  title: string
  keyConcepts: KeyConceptItem[]
  corePoints: string[]
  resources: ResourceItem[]
  relatedTerms: string[]
}

/** 缓存条目 */
interface CacheEntry {
  data: KnowledgeSummary
  timestamp: number
}

export class KnowledgeRetriever {
  private static instance: KnowledgeRetriever | null = null
  private cache: Map<string, CacheEntry> = new Map<string, CacheEntry>()
  private aiService: AIService = AIService.getInstance()

  private constructor() {}

  static getInstance(): KnowledgeRetriever {
    if (!KnowledgeRetriever.instance) {
      KnowledgeRetriever.instance = new KnowledgeRetriever()
    }
    return KnowledgeRetriever.instance
  }

  /**
   * 获取知识摘要（优先缓存，未命中则调用 AI 生成）
   * @param topic 学习主题
   * @param onTextChunk 流式文本回调
   * @param onJsonData 结构化数据回调
   */
  async getSummary(topic: string, onTextChunk: (text: string) => void,
    onJsonData: (data: object) => void): Promise<KnowledgeSummary | null> {
    if (!topic || topic.trim().length === 0) {
      onTextChunk('请输入要检索的学习主题')
      return null
    }

    const key: string = this.hashTopic(topic.trim())
    
    // 检查缓存
    const cached: CacheEntry | undefined = this.cache.get(key)
    if (cached && !this.isExpired(cached)) {
      onTextChunk(`已加载「${topic}」的知识摘要（缓存）`)
      if (onJsonData) { onJsonData(cached.data) }
      return cached.data
    }

    // 缓存未命中，调用 AI 生成
    try {
      let receivedData: KnowledgeSummary | null = null
      
      await this.aiService.generateContent(
        'knowledge_summary',
        topic.trim(),
        onTextChunk,
        (data: object): void => {
          // 尝试解析为 KnowledgeSummary 并缓存
          const parsed: KnowledgeSummary | null = this.parseAsSummary(data)
          if (parsed) {
            receivedData = parsed
            this.cache.set(key, { data: parsed, timestamp: Date.now() })
          }
          if (onJsonData) { onJsonData(data) }
        }
      )
      
      return receivedData
    } catch (e) {
      onTextChunk(`检索失败：${String(e)}`)
      return null
    }
  }

  /**
   * 清除所有缓存
   */
  clearCache(): void {
    this.cache.clear()
  }

  /**
   * 获取缓存大小
   */
  getCacheSize(): number {
    return this.cache.size
  }

  /** 主题哈希（简单实现） */
  private hashTopic(topic: string): string {
    let hash: number = 0
    for (let i: number = 0; i < topic.length; i++) {
      const char: number = topic.charCodeAt(i)
      hash = ((hash << 5) - hash) + char
      hash = hash & hash // Convert to 32bit integer
    }
    return `kr_${Math.abs(hash).toString(16)}`
  }

  /** 判断缓存是否过期 */
  private isExpired(entry: CacheEntry): boolean {
    return (Date.now() - entry.timestamp) > CACHE_TTL_MS
  }

  /** 将任意对象尝试解析为 KnowledgeSummary */
  private parseAsSummary(data: object): KnowledgeSummary | null {
    try {
      const record: Record<string, Object> = data as Record<string, Object>
      if (record['type'] !== 'knowledge') {
        return null
      }
      const summary: KnowledgeSummary = {
        type: 'knowledge',
        title: (record['title'] as string) ?? '',
        keyConcepts: [],
        corePoints: [],
        resources: [],
        relatedTerms: []
      }
      
      // 解析 keyConcepts
      const concepts: Array<Record<string, Object>> = 
        (record['keyConcepts'] as Array<Record<string, Object>>) ?? []
      for (const c of concepts) {
        const conceptItem: KeyConceptItem = {
          term: (c['term'] as string) ?? '',
          definition: (c['definition'] as string) ?? ''
        }
        summary.keyConcepts.push(conceptItem)
      }
      
      // 解析 corePoints
      const points: Array<string> = (record['corePoints'] as Array<string>) ?? []
      for (const p of points) { summary.corePoints.push(p) }
      
      // 解析 resources
      const resArray: Array<Record<string, Object>> = 
        (record['resources'] as Array<Record<string, Object>>) ?? []
      for (const r of resArray) {
        const resourceItem: ResourceItem = {
          title: (r['title'] as string) ?? '',
          url: (r['url'] as string) ?? '',
          summary: (r['summary'] as string) ?? ''
        }
        summary.resources.push(resourceItem)
      }
      
      // 解析 relatedTerms
      const terms: Array<string> = (record['relatedTerms'] as Array<string>) ?? []
      for (const t of terms) { summary.relatedTerms.push(t) }
      
      return summary
    } catch (_e) {
      return null
    }
  }
}
