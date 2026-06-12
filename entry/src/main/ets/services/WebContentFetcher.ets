/**
 * WebContentFetcher - 联网学习资料获取服务
 * 通过 MediaWiki 官方查询 API（中文维基百科）检索条目并抓取正文摘录，
 * 仅使用站点公开提供的 API 接口（符合 robots 协议），不做页面 HTML 抓取。
 * 网络不可用或站点不可达时由调用方降级为纯 AI 摘要。
 */
import { http } from '@kit.NetworkKit'
import { Logger } from '../common/Logger'

const TAG: string = 'WebContentFetcher'
const API_BASE: string = 'https://zh.wikipedia.org/w/api.php'
const TIMEOUT_MS: number = 10000
const CACHE_TTL_MS: number = 24 * 60 * 60 * 1000 // 24 小时
const MAX_RESULTS: number = 8
const MAX_EXTRACT_CHARS: number = 2400

/** 检索结果条目 */
export interface SearchResultItem {
  title: string
  snippet: string
}

interface SearchCacheEntry {
  items: SearchResultItem[]
  timestamp: number
}

interface ExtractCacheEntry {
  text: string
  timestamp: number
}

export class WebContentFetcher {
  private static instance: WebContentFetcher | null = null
  private logger: Logger = Logger.getInstance()
  private searchCache: Map<string, SearchCacheEntry> = new Map<string, SearchCacheEntry>()
  private extractCache: Map<string, ExtractCacheEntry> = new Map<string, ExtractCacheEntry>()

  private constructor() {}

  static getInstance(): WebContentFetcher {
    if (!WebContentFetcher.instance) {
      WebContentFetcher.instance = new WebContentFetcher()
    }
    return WebContentFetcher.instance
  }

  /**
   * 检索学习主题，返回候选条目列表（标题 + 摘要片段）
   * 失败时抛出 Error，由调用方降级处理
   */
  async search(keyword: string): Promise<SearchResultItem[]> {
    const trimmed: string = keyword.trim()
    if (trimmed.length === 0) {
      return []
    }

    const cached: SearchCacheEntry | undefined = this.searchCache.get(trimmed)
    if (cached && (Date.now() - cached.timestamp) <= CACHE_TTL_MS) {
      this.logger.info(TAG, `search cache hit: ${trimmed}`)
      return cached.items
    }

    const url: string = `${API_BASE}?action=query&list=search&srsearch=${encodeURIComponent(trimmed)}` +
      `&srlimit=${MAX_RESULTS}&format=json&utf8=1`
    const body: string = await this.httpGet(url)

    const items: SearchResultItem[] = []
    try {
      const root: Record<string, Object> = JSON.parse(body) as Record<string, Object>
      const query: Record<string, Object> = (root['query'] ?? {}) as Record<string, Object>
      const rawList: Array<Record<string, Object>> =
        (query['search'] ?? []) as Array<Record<string, Object>>
      for (const raw of rawList) {
        const title: string = (raw['title'] as string) ?? ''
        const snippetHtml: string = (raw['snippet'] as string) ?? ''
        if (title.length > 0) {
          items.push({ title: title, snippet: this.stripHtml(snippetHtml) })
        }
      }
    } catch (e) {
      this.logger.error(TAG, `search parse failed: ${String(e)}`)
      throw new Error('SEARCH_PARSE_FAILED')
    }

    this.searchCache.set(trimmed, { items: items, timestamp: Date.now() })
    this.logger.info(TAG, `search "${trimmed}" -> ${items.length} results`)
    return items
  }

  /**
   * 抓取指定条目的正文纯文本摘录（用于 AI 生成的参考资料）
   * 失败时抛出 Error，由调用方降级处理
   */
  async fetchExtract(title: string): Promise<string> {
    const trimmed: string = title.trim()
    if (trimmed.length === 0) {
      return ''
    }

    const cached: ExtractCacheEntry | undefined = this.extractCache.get(trimmed)
    if (cached && (Date.now() - cached.timestamp) <= CACHE_TTL_MS) {
      this.logger.info(TAG, `extract cache hit: ${trimmed}`)
      return cached.text
    }

    const url: string = `${API_BASE}?action=query&prop=extracts&explaintext=1` +
      `&exchars=${MAX_EXTRACT_CHARS}&titles=${encodeURIComponent(trimmed)}&format=json&utf8=1`
    const body: string = await this.httpGet(url)

    let extract: string = ''
    try {
      const root: Record<string, Object> = JSON.parse(body) as Record<string, Object>
      const query: Record<string, Object> = (root['query'] ?? {}) as Record<string, Object>
      const pages: Record<string, Object> = (query['pages'] ?? {}) as Record<string, Object>
      const pageKeys: string[] = Object.keys(pages)
      if (pageKeys.length > 0) {
        const page: Record<string, Object> = pages[pageKeys[0]] as Record<string, Object>
        extract = (page['extract'] as string) ?? ''
      }
    } catch (e) {
      this.logger.error(TAG, `extract parse failed: ${String(e)}`)
      throw new Error('EXTRACT_PARSE_FAILED')
    }

    if (extract.length > 0) {
      this.extractCache.set(trimmed, { text: extract, timestamp: Date.now() })
    }
    this.logger.info(TAG, `extract "${trimmed}" -> ${extract.length} chars`)
    return extract
  }

  /** 清空缓存（设置页可调用） */
  clearCache(): void {
    this.searchCache.clear()
    this.extractCache.clear()
  }

  /** 发起 GET 请求，统一超时与错误处理 */
  private async httpGet(url: string): Promise<string> {
    const httpRequest: http.HttpRequest = http.createHttp()
    const headers: Record<string, string> = {
      'User-Agent': 'sanwenLearning/1.0 (HarmonyOS learning app)',
      'Accept': 'application/json'
    }
    try {
      const response: http.HttpResponse = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: TIMEOUT_MS,
        readTimeout: TIMEOUT_MS,
        expectDataType: http.HttpDataType.STRING,
        header: headers
      })
      if (response.responseCode !== 200) {
        this.logger.error(TAG, `httpGet non-200: ${response.responseCode}`)
        throw new Error(`FETCH_HTTP_${response.responseCode}`)
      }
      return response.result as string
    } catch (e) {
      // 超时 / DNS / 连接失败统一归类，调用方据此降级
      this.logger.error(TAG, `httpGet failed: ${String(e)}`)
      throw new Error('FETCH_NETWORK_FAILED')
    } finally {
      httpRequest.destroy()
    }
  }

  /** 去除 API 返回片段中的 HTML 标签与常见实体 */
  private stripHtml(html: string): string {
    let text: string = html.replace(/<[^>]+>/g, '')
    text = text.replace(/&quot;/g, '"')
    text = text.replace(/&amp;/g, '&')
    text = text.replace(/&lt;/g, '<')
    text = text.replace(/&gt;/g, '>')
    text = text.replace(/&nbsp;/g, ' ')
    return text.trim()
  }
}
