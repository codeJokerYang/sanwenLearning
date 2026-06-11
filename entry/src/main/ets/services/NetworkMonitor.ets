/**
 * NetworkMonitor — 网络状态监控单例
 * 使用 @ohos.net.connection 监听网络变化
 */
import connection from '@ohos.net.connection'

export class NetworkMonitor {
  private static instance: NetworkMonitor
  private isConnected: boolean = true
  private netConnection: connection.NetConnection | null = null

  private constructor() {}

  static getInstance(): NetworkMonitor {
    if (!NetworkMonitor.instance) {
      NetworkMonitor.instance = new NetworkMonitor()
    }
    return NetworkMonitor.instance
  }

  startMonitoring(): void {
    try {
      this.netConnection = connection.createNetConnection()
      this.netConnection.on('netAvailable', () => {
        this.isConnected = true
      })
      this.netConnection.on('netLost', () => {
        this.isConnected = false
      })
      this.netConnection.register(() => {})
    } catch (e) {
      // If monitoring fails, assume connected
      this.isConnected = true
    }
  }

  stopMonitoring(): void {
    try {
      if (this.netConnection) {
        this.netConnection.unregister(() => {})
        this.netConnection = null
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  isNetworkAvailable(): boolean {
    return this.isConnected
  }
}
