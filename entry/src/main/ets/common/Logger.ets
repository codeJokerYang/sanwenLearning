/**
 * 三问高效学习机 — 统一日志工具
 * 遵循 ERROR_LOG_CONVENTIONS.md
 * 严禁使用 console.log
 */
import { fileIo as fs } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'

export class Logger {
  private static instance: Logger | null = null
  private logDir: string = ''
  private static readonly MAX_LOG_DAYS: number = 7

  private constructor() {}

  static getInstance(): Logger {
    if (!Logger.instance) {
      Logger.instance = new Logger()
    }
    return Logger.instance
  }

  init(context: common.Context): void {
    this.logDir = context.filesDir + '/logs'
    try {
      if (!fs.accessSync(this.logDir)) {
        fs.mkdirSync(this.logDir)
      }
    } catch (_e) {
      // 目录创建失败时静默处理
    }
    this.cleanOldLogs()
  }

  info(tag: string, message: string): void {
    this.writeLog('INFO', tag, message)
  }

  warn(tag: string, message: string): void {
    this.writeLog('WARN', tag, message)
  }

  error(tag: string, message: string, detail?: string): void {
    const fullMessage = detail ? `${message} | ${detail}` : message
    this.writeLog('ERROR', tag, fullMessage)
  }

  private writeLog(level: string, tag: string, message: string): void {
    const timestamp = this.formatTime(Date.now())
    const line = `${timestamp} | [${level}] | [${tag}] | ${message}\n`

    try {
      const fileName = `log_${this.getDateStr(Date.now())}.md`
      const filePath = this.logDir + '/' + fileName
      // 必须带 WRITE_ONLY：缺省是 READ_ONLY，CREATE|APPEND 只会建出 0 字节文件且写入失败
      const fd = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.APPEND | fs.OpenMode.WRITE_ONLY)
      fs.writeSync(fd.fd, line)
      fs.closeSync(fd)
    } catch (_e) {
      // 日志写入失败时静默处理，严禁中断应用
    }
  }

  private formatTime(ms: number): string {
    const d = new Date(ms)
    const pad = (n: number): string => n.toString().padStart(2, '0')
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ` +
      `${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}.${(ms % 1000).toString().padStart(3, '0')}`
  }

  private getDateStr(ms: number): string {
    const d = new Date(ms)
    const pad = (n: number): string => n.toString().padStart(2, '0')
    return `${d.getFullYear()}${pad(d.getMonth() + 1)}${pad(d.getDate())}`
  }

  private cleanOldLogs(): void {
    const now = Date.now()
    const maxAge = Logger.MAX_LOG_DAYS * 24 * 60 * 60 * 1000
    try {
      const files = fs.listFileSync(this.logDir)
      for (const file of files) {
        const filePath = this.logDir + '/' + file
        const stat = fs.statSync(filePath)
        if (now - stat.mtime * 1000 > maxAge) {
          fs.unlinkSync(filePath)
        }
      }
    } catch (_e) {
      // 清理失败静默处理
    }
  }
}
