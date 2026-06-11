/**
 * 三问高效学习机 — 资料解析服务
 * 遵循 FEATURE_RULES.md §6
 *
 * 核心职责：
 * - Markdown 文件文本提取
 * - PDF 文件（当前版本不解析文本，返回失败）
 * - 文件大小校验（≤50MB）
 * - 扫描型 PDF 检测（预留能力）
 */
import { fileIo } from '@kit.CoreFileKit'
import { Logger } from '../common/Logger'
import { ParsedResult } from '../models/Models'
import { FILE_CONFIG } from '../common/Config'

const TAG = 'MATERIAL_PARSER'

export class MaterialParser {
  private static instance: MaterialParser | null = null

  private constructor() {}

  static getInstance(): MaterialParser {
    if (!MaterialParser.instance) {
      MaterialParser.instance = new MaterialParser()
    }
    return MaterialParser.instance
  }

  /**
   * 解析资料文件文本内容
   * PDF 当前版本不解析文本，仅 Markdown 文件支持
   * @param filePath 沙箱中的文件路径
   * @param fileName 原始文件名（用于扩展名判断）
   * @returns ParsedResult 解析结果
   */
  async parseMaterial(filePath: string, fileName: string): Promise<ParsedResult> {
    // 1. 扩展名校验
    const ext = this.getExtension(fileName)
    if (!ext || !FILE_CONFIG.ALLOWED_EXTENSIONS.includes(ext)) {
      Logger.getInstance().warn(TAG, `Unsupported file extension: ${ext}`)
      return {
        success: false,
        content: '',
        isScanned: false,
        error: `不支持的文件格式: ${ext}，仅支持 PDF 和 Markdown`
      }
    }

    // 2. 文件大小校验（≤50MB）
    try {
      const stat = fileIo.statSync(filePath)
      if (stat.size > FILE_CONFIG.MAX_FILE_SIZE_BYTES) {
        Logger.getInstance().warn(TAG,
          `File size ${stat.size} exceeds limit ${FILE_CONFIG.MAX_FILE_SIZE_BYTES}`)
        return {
          success: false,
          content: '',
          isScanned: false,
          error: '文件大小超过 50MB 限制'
        }
      }
    } catch (err) {
      const msg = (err as Error).message ?? String(err)
      Logger.getInstance().error(TAG, `statSync failed for ${filePath}`, msg)
      return {
        success: false,
        content: '',
        isScanned: false,
        error: '无法读取文件信息'
      }
    }

    // 3. PDF：当前版本不解析文本
    if (ext === 'pdf') {
      Logger.getInstance().info(TAG, 'PDF parsing not supported in current version')
      return {
        success: false,
        content: '',
        isScanned: false,
        error: '暂不支持PDF内容解析'
      }
    }

    // 4. Markdown：读取文件文本内容
    if (ext === 'md' || ext === 'markdown') {
      return this.parseMarkdown(filePath)
    }

    // 不应到达此处
    return {
      success: false,
      content: '',
      isScanned: false,
      error: '未知文件格式'
    }
  }

  /**
   * 解析 Markdown 文件
   * 带超时保护（10s），超时后中断并返回失败
   */
  private async parseMarkdown(filePath: string): Promise<ParsedResult> {
    const timeoutMs = FILE_CONFIG.PARSE_TIMEOUT_MS

    try {
      const result = await this.readWithTimeout(filePath, timeoutMs)
      if (result === null) {
        return {
          success: false,
          content: '',
          isScanned: false,
          error: '文件解析超时（10s）'
        }
      }

      const content = result as string
      Logger.getInstance().info(TAG, `Markdown parsed: ${content.length} chars`)
      return {
        success: true,
        content: content,
        isScanned: false,
        error: ''
      }
    } catch (err) {
      const msg = (err as Error).message ?? String(err)
      Logger.getInstance().error(TAG, `parseMarkdown failed for ${filePath}`, msg)
      return {
        success: false,
        content: '',
        isScanned: false,
        error: `文件读取失败: ${msg}`
      }
    }
  }

  /**
   * 带超时的文件读取
   * 使用 Promise.race 实现超时控制
   * @returns 文件内容字符串，超时返回 null
   */
  private async readWithTimeout(filePath: string, timeoutMs: number): Promise<string | null> {
    let timeoutId: number = 0

    const readPromise = new Promise<string>((resolve, reject) => {
      try {
        const content = fileIo.readTextSync(filePath)
        resolve(content)
      } catch (err) {
        reject(err)
      }
    })

    const timeoutPromise = new Promise<string | null>((resolve) => {
      timeoutId = setTimeout(() => {
        resolve(null)
      }, timeoutMs)
    })

    try {
      const result = await Promise.race([readPromise, timeoutPromise])
      clearTimeout(timeoutId)
      return result
    } catch (err) {
      clearTimeout(timeoutId)
      throw err
    }
  }

  /**
   * 提取文件扩展名（不含点号，小写）
   */
  private getExtension(fileName: string): string {
    const dotIndex = fileName.lastIndexOf('.')
    if (dotIndex < 0 || dotIndex === fileName.length - 1) {
      return ''
    }
    return fileName.substring(dotIndex + 1).toLowerCase()
  }

  /**
   * 扫描型 PDF 检测（预留能力）
   * 当 PDF 文本长度 < pageCount * 50 时判定为扫描型 PDF
   * 当前版本不解析 PDF，此方法仅在将来 PDF 解析启用后使用
   */
  static detectScannedPdf(textContent: string, pageCount: number): boolean {
    if (pageCount <= 0) {
      return false
    }
    return textContent.length < pageCount * 50
  }
}
