/**
 * 三问高效学习机 — 埋点与统计分析服务
 * 遵循 ANALYTICS_CONVENTIONS.md
 *
 * 核心职责：
 * - 会话管理（冷启动生成 sessionId）
 * - 事件落盘至 analytics_event 表
 * - 90 天过期数据自动清理
 * - 边界规则：AI 失败 → analytics + ai_request_log（不写 error_log）
 *              UI/DB 错误 → error_log（不写 analytics）
 *              业务关键节点 → analytics（不写 error_log）
 */
import { relationalStore } from '@kit.ArkData'
import { Logger } from '../common/Logger'
import { RdbHelper } from '../db/RdbHelper'

const TAG = 'ANALYTICS'

/** 数据保留天数 */
const RETENTION_DAYS = 90
/** 毫秒换算 */
const MS_PER_DAY = 24 * 60 * 60 * 1000

export class AnalyticsService {
  private static instance: AnalyticsService | null = null
  private sessionId: string = ''

  private constructor() {
    this.sessionId = this.generateSessionId()
  }

  static getInstance(): AnalyticsService {
    if (!AnalyticsService.instance) {
      AnalyticsService.instance = new AnalyticsService()
    }
    return AnalyticsService.instance
  }

  /**
   * 初始化：清理 90 天前的过期事件
   * 在应用冷启动时调用
   */
  async init(): Promise<void> {
    const rdb = RdbHelper.getInstance()
    const store = rdb.getStore()
    if (!store) {
      Logger.getInstance().warn(TAG, 'init: RdbStore not initialized, skip cleanup')
      return
    }

    try {
      const cutoff = Date.now() - RETENTION_DAYS * MS_PER_DAY
      await rdb.execute(
        'DELETE FROM analytics_event WHERE timestamp < ?',
        [cutoff]
      )
      Logger.getInstance().info(TAG,
        `Cleanup complete: deleted events older than ${RETENTION_DAYS} days`)
    } catch (err) {
      const msg = (err as Error).message ?? String(err)
      Logger.getInstance().error(TAG, 'Cleanup failed', msg)
    }
  }

  /**
   * 记录埋点事件
   * 公共字段（event_name / timestamp / session_id / app_version）自动注入
   *
   * @param eventName 事件名称（见 ANALYTICS_CONVENTIONS.md §2）
   * @param payload 事件特有字段（JSON 对象）
   */
  logEvent(eventName: string, payload: Record<string, Object>): void {
    const rdb = RdbHelper.getInstance()
    const store = rdb.getStore()
    if (!store) {
      Logger.getInstance().warn(TAG, `logEvent: store not initialized, drop event: ${eventName}`)
      return
    }

    try {
      const values: relationalStore.ValuesBucket = {
        event_name: eventName,
        timestamp: Date.now(),
        session_id: this.sessionId,
        course_id: (payload['course_id'] as string) ?? '',
        payload: JSON.stringify(payload),
        synced: 0
      }

      rdb.insert('analytics_event', values)
      Logger.getInstance().info(TAG, `Event logged: ${eventName}`)
    } catch (err) {
      const msg = (err as Error).message ?? String(err)
      Logger.getInstance().error(TAG, `logEvent failed: ${eventName}`, msg)
    }
  }

  /**
   * 获取当前会话 ID
   */
  getSessionId(): string {
    return this.sessionId
  }

  /**
   * 生成会话 ID
   * 格式：timestamp_random6（冷启动时生成）
   */
  private generateSessionId(): string {
    const ts = Date.now().toString(36)
    const rand = Math.floor(Math.random() * 1000000).toString().padStart(6, '0')
    return `s_${ts}_${rand}`
  }
}
