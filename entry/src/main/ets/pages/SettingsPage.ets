/**
 * SettingsPage - 设置页面
 * 提供 API Key 安全配置入口
 * 遵循 API_SECURITY_CONVENTIONS.md §2.2
 */
import { AIService } from '../services/AIService'
import { ApiKeyStore } from '../services/ApiKeyStore'
import { DynamicBackground } from '../components/DynamicBackground'
import { AI_ENDPOINT_CONFIG } from '../common/Config'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct SettingsPage {
  @State apiKeyInput: string = ''
  @State isKeyConfigured: boolean = false
  @State isSaving: boolean = false
  @State saveResult: string = ''
  @State maskedKey: string = ''
  private aiService: AIService = AIService.getInstance()

  aboutToAppear(): void {
    this.checkKeyStatus()
  }

  build() {
    Stack() {
      DynamicBackground()

      Scroll() {
        Column() {
          // 标题栏
          Row() {
            Button() {
              Text('←')
                .fontSize(22)
                .fontColor(Color.White)
            }
            .backgroundColor(Color.Transparent)
            .width(44)
            .height(44)
            .onClick(() => {
              router.back()
            })

            Text('设置')
              .fontSize(20)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .margin({ left: 12 })
          }
          .width('100%')
          .padding({ left: 8, top: 12, bottom: 12 })

          // AI 服务配置区域
          Column() {
            Text('AI 服务配置')
              .fontSize(16)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 16 })

            // 当前状态
            Row() {
              Text('API Key 状态：')
                .fontSize(14)
                .fontColor('rgba(255,255,255,0.7)')
              Text(this.isKeyConfigured ? '已配置' : '未配置')
                .fontSize(14)
                .fontColor(this.isKeyConfigured ? '#4CAF50' : '#FF6B6B')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .margin({ bottom: 8 })

            // 已配置时显示脱敏 Key
            if (this.isKeyConfigured) {
              Text(`当前 Key：${this.maskedKey}`)
                .fontSize(12)
                .fontColor('rgba(255,255,255,0.5)')
                .width('100%')
                .margin({ bottom: 16 })
            }

            // 模型信息
            Row() {
              Text('对话模型：')
                .fontSize(14)
                .fontColor('rgba(255,255,255,0.7)')
              Text(AI_ENDPOINT_CONFIG.CHAT_MODEL)
                .fontSize(14)
                .fontColor('#7C8CFF')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .margin({ bottom: 8 })

            // API 端点
            Row() {
              Text('API 端点：')
                .fontSize(14)
                .fontColor('rgba(255,255,255,0.7)')
            }
            .width('100%')
            .margin({ bottom: 4 })
            Text(AI_ENDPOINT_CONFIG.API_BASE_URL)
              .fontSize(11)
              .fontColor('rgba(255,255,255,0.4)')
              .width('100%')
              .margin({ bottom: 16 })

            // 更新时间
            Text(`配置更新时间：${AI_ENDPOINT_CONFIG.LAST_UPDATED}`)
              .fontSize(11)
              .fontColor('rgba(255,255,255,0.35)')
              .width('100%')
              .margin({ bottom: 24 })

            // API Key 输入区域
            Text(this.isKeyConfigured ? '更新 API Key' : '配置 API Key')
              .fontSize(14)
              .fontColor('rgba(255,255,255,0.7)')
              .width('100%')
              .margin({ bottom: 8 })

            TextInput({ placeholder: '请输入 API Key', text: this.apiKeyInput })
              .type(InputType.Password)
              .copyOption(CopyOptions.None)
              .fontSize(14)
              .fontColor(Color.White)
              .placeholderColor('rgba(255,255,255,0.35)')
              .backgroundColor('rgba(255,255,255,0.06)')
              .borderRadius(10)
              .padding({ left: 16, right: 16 })
              .height(44)
              .width('100%')
              .onChange((value: string) => {
                this.apiKeyInput = value
                this.saveResult = ''
              })

            // 保存按钮
            Button(this.isSaving ? '保存中...' : '保存')
              .width('100%')
              .height(44)
              .borderRadius(10)
              .backgroundColor(this.canSave() ? '#7C8CFF' : 'rgba(124,140,255,0.3)')
              .fontColor(Color.White)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .margin({ top: 12 })
              .enabled(this.canSave())
              .onClick(() => {
                this.saveApiKey()
              })

            // 保存结果
            if (this.saveResult.length > 0) {
              Text(this.saveResult)
                .fontSize(13)
                .fontColor(this.saveResult.includes('成功') ? '#4CAF50' : '#FF6B6B')
                .margin({ top: 8 })
            }

            // 安全提示
            Column() {
              Text('安全说明')
                .fontSize(12)
                .fontColor('rgba(255,255,255,0.5)')
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 4 })
              Text('• API Key 使用 HUKS AES-256-CBC 加密存储')
                .fontSize(11)
                .fontColor('rgba(255,255,255,0.35)')
              Text('• 密钥明文仅在请求发起时短暂解密')
                .fontSize(11)
                .fontColor('rgba(255,255,255,0.35)')
              Text('• 日志中 Key 自动脱敏（前3后4，中间***）')
                .fontSize(11)
                .fontColor('rgba(255,255,255,0.35)')
              Text('• 请求频率限制：10次/分钟')
                .fontSize(11)
                .fontColor('rgba(255,255,255,0.35)')
            }
            .width('100%')
            .padding(12)
            .borderRadius(10)
            .backgroundColor('rgba(255,255,255,0.03)')
            .margin({ top: 24 })
          }
          .width('100%')
          .padding(20)
          .borderRadius(16)
          .backgroundColor('rgba(20,20,50,0.6)')
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
  }

  private canSave(): boolean {
    return this.apiKeyInput.trim().length > 0 && !this.isSaving
  }

  private async saveApiKey(): Promise<void> {
    this.isSaving = true
    this.saveResult = ''
    try {
      await this.aiService.saveApiKey(this.apiKeyInput.trim())
      this.saveResult = 'API Key 配置成功'
      this.apiKeyInput = ''
      await this.checkKeyStatus()
    } catch (e) {
      this.saveResult = `配置失败：${String(e)}`
    } finally {
      this.isSaving = false
    }
  }

  private async checkKeyStatus(): Promise<void> {
    try {
      const key: string = await ApiKeyStore.loadApiKey(
        getContext(this), AI_ENDPOINT_CONFIG.API_KEY_ALIAS)
      this.isKeyConfigured = key.length > 0
      this.maskedKey = this.maskApiKey(key)
    } catch (_e) {
      this.isKeyConfigured = false
      this.maskedKey = ''
    }
  }

  private maskApiKey(key: string): string {
    if (key.length <= 8) {
      return '***'
    }
    return key.substring(0, 3) + '***' + key.substring(key.length - 4)
  }
}

export { SettingsPage }
