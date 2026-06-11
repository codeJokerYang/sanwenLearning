/**
 * AIConcurrencyLock - AI 请求并发锁
 * 基于 courseId 的互斥锁，防止同一课程并发发起多个 AI 请求
 * AI_SERVICE_PROTOCOL.md §5
 */
import { Logger } from '../common/Logger';

const TAG: string = 'AIConcurrencyLock';
const LOCK_TIMEOUT_MS: number = 120000;

interface LockEntry {
  locked: boolean;
  acquireTime: number;
}

export class AIConcurrencyLock {
  private static instance: AIConcurrencyLock;
  private lockMap: Map<string, LockEntry> = new Map();

  public static getInstance(): AIConcurrencyLock {
    if (!AIConcurrencyLock.instance) {
      AIConcurrencyLock.instance = new AIConcurrencyLock();
    }
    return AIConcurrencyLock.instance;
  }

  /**
   * 获取锁。每次调用先强制释放超时锁，再检查并加锁。
   * @returns true 表示加锁成功，false 表示已被锁定或加锁失败
   */
  public acquireLock(courseId: string): boolean {
    if (!courseId) {
      return false;
    }

    this.forceReleaseTimeout();

    const existing: LockEntry | undefined = this.lockMap.get(courseId);
    if (existing && existing.locked) {
      return false;
    }

    this.lockMap.set(courseId, { locked: true, acquireTime: Date.now() });
    return true;
  }

  /**
   * 释放指定课程的锁。
   */
  public releaseLock(courseId: string): void {
    if (!courseId) {
      return;
    }
    this.lockMap.delete(courseId);
  }

  /**
   * 强制释放超时锁。遍历所有条目，若锁定且 now - acquireTime > 120000ms，强制删除并记录警告。
   */
  public forceReleaseTimeout(): void {
    const now: number = Date.now();
    const expired: string[] = [];

    this.lockMap.forEach((entry: LockEntry, courseId: string) => {
      if (entry.locked && (now - entry.acquireTime) > LOCK_TIMEOUT_MS) {
        expired.push(courseId);
      }
    });

    for (const courseId of expired) {
      this.lockMap.delete(courseId);
      Logger.getInstance().warn(TAG, `Force released timed-out lock for course: ${courseId}`);
    }
  }

  /**
   * 冷启动时清空所有锁，仅在应用冷启动时调用。
   */
  public clearAllOnColdStart(): void {
    const count: number = this.lockMap.size;
    this.lockMap.clear();
    if (count > 0) {
      Logger.getInstance().warn(TAG, `Cold start: cleared ${count} stale lock(s)`);
    }
  }

  /**
   * 查询指定课程是否被锁定（供调试/诊断使用）。
   */
  public isLocked(courseId: string): boolean {
    if (!courseId) {
      return false;
    }
    const entry: LockEntry | undefined = this.lockMap.get(courseId);
    return entry ? entry.locked : false;
  }
}
