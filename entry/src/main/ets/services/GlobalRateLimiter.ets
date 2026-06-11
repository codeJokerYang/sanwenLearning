/**
 * GlobalRateLimiter - 全局网络请求限流器
 * 滑动窗口：每分钟最多 10 次请求
 * API_SECURITY_CONVENTIONS.md §3
 */

const MAX_REQUESTS_PER_MINUTE: number = 10;
const WINDOW_MS: number = 60000;

export class GlobalRateLimiter {
  private static instance: GlobalRateLimiter;
  private requestTimestamps: number[] = [];

  public static getInstance(): GlobalRateLimiter {
    if (!GlobalRateLimiter.instance) {
      GlobalRateLimiter.instance = new GlobalRateLimiter();
    }
    return GlobalRateLimiter.instance;
  }

  private cleanExpired(): void {
    const cutoff: number = Date.now() - WINDOW_MS;
    this.requestTimestamps = this.requestTimestamps.filter((ts: number) => ts > cutoff);
  }

  public canRequest(): boolean {
    this.cleanExpired();
    return this.requestTimestamps.length < MAX_REQUESTS_PER_MINUTE;
  }

  public recordRequest(): void {
    this.requestTimestamps.push(Date.now());
  }

  public getRemainingCount(): number {
    this.cleanExpired();
    return MAX_REQUESTS_PER_MINUTE - this.requestTimestamps.length;
  }
}
