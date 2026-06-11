/**
 * 三问高效学习机 — 文件池服务
 * 遵循 FEATURE_RULES.md §6
 *
 * 核心职责：
 * - 使用 DocumentViewPicker 选择文件（仅 PDF/.md/.markdown）
 * - 将选中文件复制到应用沙箱（重名加时间戳后缀）
 * - 级联删除时清理沙箱物理文件
 */
import { picker } from '@kit.CoreFileKit'
import { fileIo } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'
import { Logger } from '../common/Logger'
import { FILE_CONFIG } from '../common/Config'

const TAG = 'FILE_POOL'

export class FilePoolService {
  private static instance: FilePoolService | null = null
  private context: common.Context | null = null

  private constructor() {}

  static getInstance(): FilePoolService {
    if (!FilePoolService.instance) {
      FilePoolService.instance = new FilePoolService()
    }
    return FilePoolService.instance
  }

  init(context: common.Context): void {
    this.context = context
  }

  /**
   * 使用 DocumentViewPicker 选择文件
   * 仅允许 PDF（.pdf）和 Markdown（.md / .markdown）格式
   * @returns 选中的文件 URI 数组，用户取消或失败时返回空数组
   */
  async selectFileByPicker(): Promise<string[]> {
    try {
      const documentPicker = new picker.DocumentViewPicker()
      const uris = await documentPicker.select({
        maxSelectNumber: 1,
        fileSuffixFilters: FILE_CONFIG.ALLOWED_EXTENSIONS
      })
      if (!uris || uris.length === 0) {
        return []
      }
      Logger.getInstance().info(TAG, `File selected: ${uris[0]}`)
      return uris
    } catch (err) {
      const msg = (err as Error).message ?? String(err)
      Logger.getInstance().error(TAG, 'selectFileByPicker failed', msg)
      return []
    }
  }

  /**
   * 将文件从 sourceUri 复制到应用沙箱 course 子目录
   * 重名处理：已存在同名文件时追加时间戳后缀 "_HHmmssSSS"
   * 大小校验：超过 50MB 直接拒绝
   * @param sourceUri 源文件 URI（来自 picker 选择结果）
   * @param courseId 课程 ID，用于创建课程专属子目录
   * @returns 沙箱中目标文件的完整路径，失败返回空字符串
   */
  async copyToSandbox(sourceUri: string, courseId: string): Promise<string> {
    if (!this.context) {
      Logger.getInstance().error(TAG, 'copyToSandbox: context not initialized')
      return ''
    }
    if (!sourceUri || !courseId) {
      Logger.getInstance().warn(TAG, 'copyToSandbox: empty sourceUri or courseId')
      return ''
    }

    try {
      // 1. 确保课程子目录存在
      const courseDir = `${this.context.filesDir}/courses/${courseId}`
      if (!fileIo.accessSync(courseDir)) {
        fileIo.mkdirSync(courseDir, true)
      }

      // 2. 读取源文件基本信息
      const stat = fileIo.statSync(sourceUri)
      if (stat.size > FILE_CONFIG.MAX_FILE_SIZE_BYTES) {
        Logger.getInstance().warn(TAG,
          `File size ${stat.size} exceeds limit ${FILE_CONFIG.MAX_FILE_SIZE_BYTES}`)
        return ''
      }

      // 3. 从 URI 中提取文件名
      const segments = sourceUri.split('/')
      const rawFileName = segments[segments.length - 1]
      if (!rawFileName) {
        Logger.getInstance().error(TAG, 'copyToSandbox: cannot extract filename from URI')
        return ''
      }

      // 4. 重名处理：追加时间戳后缀
      let fileName = rawFileName
      const destPath = `${courseDir}/${fileName}`
      if (fileIo.accessSync(destPath)) {
        const dotIndex = rawFileName.lastIndexOf('.')
        const namePart = dotIndex > 0 ? rawFileName.substring(0, dotIndex) : rawFileName
        const extPart = dotIndex > 0 ? rawFileName.substring(dotIndex) : ''
        const now = new Date()
        const pad = (n: number) => n.toString().padStart(2, '0')
        const ts = `${pad(now.getHours())}${pad(now.getMinutes())}${pad(now.getSeconds())}${
          (now.getMilliseconds()).toString().padStart(3, '0')}`
        fileName = `${namePart}_${ts}${extPart}`
      }

      // 5. 复制文件到沙箱
      const finalPath = `${courseDir}/${fileName}`
      fileIo.copyFileSync(sourceUri, finalPath)
      Logger.getInstance().info(TAG, `File copied to sandbox: ${finalPath}`)
      return finalPath

    } catch (err) {
      const msg = (err as Error).message ?? String(err)
      Logger.getInstance().error(TAG, `copyToSandbox failed for ${sourceUri}`, msg)
      return ''
    }
  }

  /**
   * 删除课程的所有沙箱物理文件
   * 在事务提交后调用，删除失败不影响课程记录删除结果
   * 若课程目录存在则递归删除整个目录
   * @param courseId 课程 ID
   */
  async deleteCourseFiles(courseId: string): Promise<void> {
    if (!this.context) {
      Logger.getInstance().error(TAG, 'deleteCourseFiles: context not initialized')
      return
    }
    if (!courseId) {
      return
    }

    try {
      const courseDir = `${this.context.filesDir}/courses/${courseId}`
      if (!fileIo.accessSync(courseDir)) {
        return
      }

      // 递归删除目录下所有文件后删除目录
      this.deleteDirRecursive(courseDir)
      Logger.getInstance().info(TAG, `Course files deleted: ${courseId}`)
    } catch (err) {
      const msg = (err as Error).message ?? String(err)
      Logger.getInstance().error(TAG, `deleteCourseFiles failed for ${courseId}`, msg)
      // 删除物理文件失败不抛异常，仅记录日志
    }
  }

  /**
   * 递归删除目录及其所有内容
   */
  private deleteDirRecursive(dirPath: string): void {
    try {
      const files = fileIo.listFileSync(dirPath)
      for (const file of files) {
        const filePath = `${dirPath}/${file}`
        const stat = fileIo.statSync(filePath)
        if (stat.isDirectory()) {
          this.deleteDirRecursive(filePath)
        } else {
          fileIo.unlinkSync(filePath)
        }
      }
      fileIo.rmdirSync(dirPath)
    } catch (err) {
      const msg = (err as Error).message ?? String(err)
      Logger.getInstance().error(TAG, `deleteDirRecursive failed for ${dirPath}`, msg)
    }
  }

  /**
   * 获取课程沙箱目录路径
   */
  getCourseDir(courseId: string): string {
    if (!this.context) {
      return ''
    }
    return `${this.context.filesDir}/courses/${courseId}`
  }
}
