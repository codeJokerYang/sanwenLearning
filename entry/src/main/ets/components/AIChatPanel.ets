/**
 * AIChatPanel - AI 对话面板容器组件
 * 半屏浮层，包含消息列表 + 输入栏 + 工具栏
 * 使用 ChatViewModel 单例，跨页面共享对话状态
 */
import { ChatViewModel, ChatDisplayMessage } from '../viewmodels/ChatViewModel'
import { AIActionBar } from './AIActionBar'
import { ContentPreviewCard } from './ContentPreviewCard'
import { Logger } from '../common/Logger'
import { FilePoolService } from '../services/FilePoolService'
import { picker } from '@kit.CoreFileKit'

@Component
export struct AIChatPanel {
  @Link isOpen: boolean
  private viewModel: ChatViewModel = ChatViewModel.getInstance()
  private scroller: Scroller = new Scroller()
  private logger: Logger = Logger.getInstance()
  private static readonly TAG: string = 'AIChatPanel'

  /**
   * 安全发送消息（带异常保护和日志）
   * 修复：原 onClick 直接调用 viewModel.sendMessage 无 try-catch 保护
   */
  private safeSend(): void {
    try {
      this.logger.info(AIChatPanel.TAG, 'User clicked send button')
      this.viewModel.sendMessage(this.viewModel.inputText)
    } catch (e) {
      this.logger.error(AIChatPanel.TAG, `safeSend error: ${String(e)}`)
      this.viewModel.errorMessage = '发送失败，请重试'
      this.viewModel.canRetry = true
    }
  }

  /**
   * 附件按钮：打开文件选择器并附加文件到对话
   */
  private async pickAndAttachFile(): Promise<void> {
    try {
      this.logger.info(AIChatPanel.TAG, 'User clicked attachment button')
      const filePool: FilePoolService = FilePoolService.getInstance()
      const uris: string[] = await filePool.selectFileByPicker()
      if (!uris || uris.length === 0) {
        this.logger.info(AIChatPanel.TAG, 'User cancelled file selection')
        return
      }
      // 将文件 URI 作为消息发送给 AI 分析
      const fileMsg: string = `[附件文件] ${uris[0]}`
      this.viewModel.sendMessage(fileMsg)
    } catch (e) {
      this.logger.error(AIChatPanel.TAG, `pickAndAttachFile error: ${String(e)}`)
      this.viewModel.errorMessage = '文件选择失败，请重试'
    }
  }

  /** 根据当前模式返回输入框占位符 */
  private getInputPlaceholder(): string {
    const placeholders: Record<string, string> = {
      'chat': '\u8F93\u5165\u4F60\u7684\u95EE\u9898...',
      'retrieve': '\u8F93\u5165\u8981\u68C0\u7D22\u7684\u5B66\u4E60\u4E3B\u9898...',
      'mindmap': '\u8F93\u5165\u4E3B\u9898\uFF0CAI \u5C06\u4E3A\u4F60\u751F\u6210\u601D\u7EF4\u5BFC\u56FE...',
      'studydoc': '\u8F93\u5165\u4E3B\u9898\uFF0CAI \u5C06\u4E3A\u4F60\u751F\u6210\u5B66\u4E60\u6587\u6863...',
      'framework': '\u8F93\u5165\u5B66\u79D1\u540D\u79F0\uFF0CAI \u5C06\u4E3A\u4F60\u6784\u5EFA\u77E5\u8BC6\u4F53\u7CFB...'
    }
    return placeholders[this.viewModel.currentMode] ?? '\u8F93\u5165\u6D88\u606F...'
  }

  build() {
    if (this.isOpen) {
      Column() {
        // 标题栏
        Row() {
          Text('AI 学习伙伴')
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)

          Blank()

          Button() {
            Text('清空')
              .fontSize(12)
              .fontColor('rgba(255,255,255,0.6)')
          }
          .backgroundColor(Color.Transparent)
          .padding({ left: 8, right: 8 })
          .onClick(() => {
            this.viewModel.clearConversation()
          })

          Button() {
            Text('✕')
              .fontSize(18)
              .fontColor('rgba(255,255,255,0.6)')
          }
          .backgroundColor(Color.Transparent)
          .width(32)
          .height(32)
          .onClick(() => {
            this.isOpen = false
          })
        }
        .width('100%')
        .padding({ left: 16, right: 8, top: 12, bottom: 8 })
        .alignItems(VerticalAlign.Center)

        Divider()
          .color('rgba(124,140,255,0.15)')
          .width('100%')

        // 功能模式切换栏
        AIActionBar({
          currentMode: this.viewModel.currentMode,
          onModeChange: (mode: string): void => { this.viewModel.switchMode(mode) }
        })

        Divider()
          .color('rgba(124,140,255,0.10)')
          .width('100%')

        // 无课程引导提示
        if (this.viewModel.messages.length === 0) {
          // 空状态：根据是否有课程显示不同引导
          Column() {
            Text('👋')
              .fontSize(36)
              .margin({ bottom: 12 })
            if (!this.viewModel.hasActiveCourse) {
              Text('欢迎使用 AI 学习伙伴')
                .fontSize(16)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 8 })
              Text('请先创建或选择一个课程，我将为您提供针对性的学习建议和知识导航。')
                .fontSize(13)
                .fontColor('rgba(255,255,255,0.5)')
                .textAlign(TextAlign.Center)
                .lineHeight(20)
            } else {
              Text('AI 学习伙伴已就绪')
                .fontSize(16)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 8 })
              Text('选择下方功能模式，或直接输入问题开始学习。')
                .fontSize(13)
                .fontColor('rgba(255,255,255,0.5)')
                .textAlign(TextAlign.Center)
                .lineHeight(20)
            }
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .padding({ left: 32, right: 32 })
        } else {
          // 消息列表
          List({ scroller: this.scroller }) {
            ForEach(this.viewModel.messages, (msg: ChatDisplayMessage) => {
              ListItem() {
                this.MessageItem(msg)
              }
            }, (msg: ChatDisplayMessage) => msg.id)
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        }

        // 错误提示 + 重试
        if (this.viewModel.errorMessage.length > 0) {
          Row() {
            Text(this.viewModel.errorMessage)
              .fontSize(12)
              .fontColor('#FF6B6B')
              .layoutWeight(1)
            if (this.viewModel.canRetry) {
              Button('重试')
                .fontSize(12)
                .fontColor('#5C6BC0')
                .backgroundColor('rgba(92,107,192,0.12)')
                .height(28)
                .padding({ left: 12, right: 12 })
                .onClick(() => {
                  this.safeSend()
                })
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 4, bottom: 4 })
        }

        // 输入栏
        this.InputBar()
      }
      .width('100%')
      .height('70%')
      .backgroundColor('rgba(18,18,36,0.98)')
      .borderRadius({ topLeft: 16, topRight: 16 })
      .shadow({ radius: 16, color: 'rgba(0,0,0,0.5)', offsetY: -4 })
    }
  }

  @Builder
  MessageItem(msg: ChatDisplayMessage) {
    if (msg.role === 'user') {
      Row() {
        Column() {
          Text(msg.content)
            .fontSize(14)
            .fontColor(Color.White)
            .lineHeight(21)
        }
        .padding(12)
        .borderRadius({ topLeft: 14, topRight: 4, bottomLeft: 14, bottomRight: 14 })
        .backgroundColor('rgba(124,140,255,0.35)')
        .constraintSize({ maxWidth: '80%' })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .padding({ top: 4, bottom: 4 })
    } else if (msg.role === 'assistant') {
      Row() {
        Column() {
          // 纯文本内容或流式输出
          if (msg.content && msg.content.length > 0) {
            Text(msg.content)
              .fontSize(14)
              .fontColor('rgba(255,255,255,0.85)')
              .lineHeight(21)
          }

          // 流式光标
          if (msg.isStreaming) {
            Text(' |')
              .fontSize(14)
              .fontColor('#7C8CFF')
          }

          // 结构化内容预览卡片
          if (msg.contentType && msg.contentData) {
            Blank().height(8)
            ContentPreviewCard({
              contentType: msg.contentType,
              contentData: msg.contentData,
              isExpanded: false,
              onToggleExpand: (): void => {},
              onRegenerate: (): void => { this.viewModel.retryContentGeneration() },
              onSaveToMaterial: (): void => {
                // 7.1-7.3: 保存到 material 表（异步，静默执行）
                const title: string = msg.content.substring(0, 50) || 'AI\u{751F}\u{6210}\u{5185}\u{5BB9}'
                const cType: string = msg.contentType ?? 'knowledge'
                const cData: object = msg.contentData ?? new Object()
                this.viewModel.saveGeneratedMaterial(title, cType, cData)
              },
              onContinueChat: (): void => {
                // 切换回对话模式并预填提示文本
                this.viewModel.switchMode('chat')
                this.viewModel.inputText = '请基于以上' +
                  (msg.contentType === 'mindmap' ? '思维导图' :
                   msg.contentType === 'studydoc' ? '学习文档' :
                   msg.contentType === 'framework' ? '知识框架' : '知识摘要') + '继续讲解'
              }
            })
          }
        }
        .padding(12)
        .borderRadius({ topLeft: 4, topRight: 14, bottomLeft: 14, bottomRight: 14 })
        .backgroundColor('rgba(92,107,192,0.10)')
        .border({ width: 0.5, color: 'rgba(124,140,255,0.15)' })
        .constraintSize({ maxWidth: '85%' })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .padding({ top: 4, bottom: 4 })
    } else {
      Row() {
        Text(msg.content)
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.5)')
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 8, bottom: 8 })
    }
  }

  @Builder
  InputBar() {
    Column() {
      // 错误提示
      if (this.viewModel.errorMessage.length > 0) {
        Row() {
          Text(this.viewModel.errorMessage)
            .fontSize(12)
            .fontColor('#FF6B6B')
          if (this.viewModel.canRetry) {
            Button('重试')
              .fontSize(12)
              .fontColor('#7C8CFF')
              .backgroundColor(Color.Transparent)
              .padding({ left: 8, right: 8 })
              .onClick(() => {
                this.viewModel.retryLastMessage()
              })
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 4, bottom: 4 })
      }

      // 离线提示
      if (!this.viewModel.isNetworkAvailable) {
        Row() {
          Text('当前无网络连接')
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.5)')
        }
        .width('100%')
        .padding({ left: 16, top: 4, bottom: 4 })
      }

      // 输入区域
      Row() {
        // 左侧附件按钮（文件选择）
        Button() {
          Text('\uD83D\uDCC4')
            .fontSize(18)
            .fontColor('rgba(255,255,255,0.6)')
        }
        .width(36)
        .height(36)
        .borderRadius(18)
        .backgroundColor(Color.Transparent)
        .border({ width: 0.5, color: 'rgba(255,255,255,0.15)' })
        .onClick(() => {
          this.pickAndAttachFile()
        })

        TextInput({ placeholder: this.getInputPlaceholder() })
          .layoutWeight(1)
          .fontSize(14)
          .fontColor(Color.White)
          .placeholderColor('rgba(255,255,255,0.35)')
          .backgroundColor('rgba(255,255,255,0.06)')
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .height(40)
          .margin({ left: 8 })
          .onChange((value: string) => {
            this.viewModel.inputText = value
          })
          .onSubmit(() => {
            this.safeSend()
          })

        Button() {
          Text(this.viewModel.currentMode === 'chat' ? '\u2191' : '\u751F\u6210')
            .fontSize(this.viewModel.currentMode === 'chat' ? 18 : 13)
            .fontColor(Color.White)
        }
        .width(36)
        .height(36)
        .borderRadius(18)
        .backgroundColor(this.viewModel.isStreaming ? 'rgba(124,140,255,0.3)' : '#7C8CFF')
        .margin({ left: 8 })
        .opacity(this.viewModel.isStreaming ? 0.4 : 1)
        .enabled(!this.viewModel.isStreaming)
        .onClick(() => {
          this.safeSend()
        })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .backgroundColor('rgba(18,18,36,0.95)')
  }
}
