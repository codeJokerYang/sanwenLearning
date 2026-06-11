# 三问高效学习机 — API 安全约定

> 版本：v1.0 | 日期：2026-06-05 | 所有安全相关逻辑必须严格遵循本约定

---

## 1. API Key 存储红线

### 1.1 严禁事项

| 严禁行为 | 原因 |
|---------|------|
| 硬编码 API Key 在源码中 | 反编译即可提取，等于明文暴露 |
| 明文存储在 SharedPreferences / 文件中 | Root 设备可直接读取 |
| 通过 URL Query 参数传递 API Key | 代理/网关日志会记录完整 URL |
| 将 API Key 写入日志文件 | 日志导出后泄露 |

### 1.2 合规存储方案

**方案 A（推荐）：HUKS 密钥保险箱**

```typescript
import { huks } from '@ohos.security.huks'

// 加密存储 API Key
async function saveApiKey(alias: string, apiKey: string): Promise<void> {
  // 1. 通过 HUKS 生成非对称密钥对（或使用安全世界密钥）
  const keyProperties: huks.HuksOptions = {
    properties: [
      { tag: huks.HuksTag.HUKS_TAG_ALGORITHM, value: huks.HuksKeyAlg.HUKS_ALG_AES },
      { tag: huks.HuksTag.HUKS_TAG_KEY_SIZE, value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_256 },
      { tag: huks.HuksTag.HUKS_TAG_PURPOSE, value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT |
                                                     huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT },
    ],
    inData: new Uint8Array([])
  }
  await huks.generateKeyItem(alias, keyProperties)

  // 2. 使用 HUKS 密钥加密 API Key
  const encrypted = await huks.initSession(alias, encryptOptions)
  // ... finishSession 获取密文

  // 3. 密文存入 @ohos.data.preferences
  const prefs = await preferences.getPreferences(context, 'secure_store')
  await prefs.put('api_key_encrypted', base64Encode(encryptedData))
  await prefs.flush()
}
```

**方案 B（最低要求）：@ohos.data.preferences + 应用级混淆**

```typescript
import { preferences } from '@ohos.data.preferences'

// 最低要求：使用 preferences 存储，但必须加密后再存
async function saveApiKeyMinimal(context: Context, apiKey: string): Promise<void> {
  const prefs = await preferences.getPreferences(context, 'secure_store')
  // 必须先加密再存储，严禁明文
  const encrypted = simpleEncrypt(apiKey)  // 应用内对称加密
  await prefs.put('api_key_encrypted', encrypted)
  await prefs.flush()
}
```

**硬性约束**：
- **严禁**选择方案 B 时不加密直接存储明文
- 方案 A 为推荐方案，新项目必须采用
- 无论哪种方案，存储的值必须是密文

---

## 2. API Key 的 UI 配置与解密调用流程

### 2.1 完整流程

```
┌─────────────────────────────────────────────────────┐
│                    设置页 UI                          │
│  [API Key 输入框]  (type=Password, 不可见)           │
│  [保存按钮]                                          │
└──────────────────────┬──────────────────────────────┘
                       │ 用户输入 API Key
                       ▼
              ┌─────────────────┐
              │  加密 API Key    │
              │  (HUKS / 对称)  │
              └────────┬────────┘
                       │ 密文
                       ▼
              ┌─────────────────────┐
              │  存入 preferences   │
              │  key=api_key_enc    │
              └─────────────────────┘

                       │ 发起 AI 请求时
                       ▼
              ┌─────────────────────┐
              │  从 preferences 读取 │
              │  密文               │
              └────────┬────────────┘
                       │
                       ▼
              ┌─────────────────────┐
              │  解密 API Key       │
              │  (HUKS / 对称)      │
              └────────┬────────────┘
                       │ 明文（仅内存中）
                       ▼
              ┌─────────────────────┐
              │  放入 HTTP Header   │
              │  Authorization:     │
              │  Bearer sk-xxx      │
              └────────┬────────────┘
                       │
                       ▼
              ┌─────────────────────┐
              │  发送请求           │
              │  请求完成后清除     │
              │  内存中的明文 Key   │
              └─────────────────────┘
```

### 2.2 设置页 UI 硬性约束

```typescript
// API Key 输入框必须为密码模式
TextInput({ placeholder: '请输入 API Key' })
  .type(InputType.Password)          // 不可见输入
  .copyOption(CopyOptions.None)      // 禁止复制
  .pasteOption(PasteOptions.NONE)    // 禁止粘贴（可选，视安全要求）
```

- 输入框**必须**使用 `InputType.Password`，严禁明文显示
- 保存成功后，输入框清空，显示"已配置"状态
- **严禁**在 UI 上提供"查看已保存 Key"功能

### 2.3 解密调用硬性约束

1. **明文 Key 仅存在于请求发起的函数作用域内**：

```typescript
// ✅ 正确：请求完成后明文变量随作用域销毁
async function callAiService(prompt: string): Promise<string> {
  const encryptedKey = await getEncryptedKey()
  const apiKey = await decryptKey(encryptedKey)  // 明文仅在此次调用中存在
  try {
    const response = await http.request(url, {
      header: { 'Authorization': `Bearer ${apiKey}` }
    })
    return response.result
  } finally {
    // apiKey 变量随函数结束自动销毁，无需额外清理
  }
}
```

2. **严禁将解密后的 API Key 赋值给任何 @State 或全局变量**
3. **严禁将 API Key 拼接到 URL 参数中**

### 2.4 日志脱敏

所有日志中涉及 API Key 的位置必须脱敏：

```typescript
// ❌ 严禁
Logger.info(`AI request sent with key: ${apiKey}`)

// ✅ 正确
Logger.info(`AI request sent with key: ${maskApiKey(apiKey)}`)

function maskApiKey(key: string): string {
  if (key.length <= 8) return '***'
  return key.substring(0, 3) + '***' + key.substring(key.length - 4)
}
// 示例：sk-proj-abc123xyz789 → sk-***yz789
```

**脱敏规则**：
- 保留前 3 位和后 4 位，中间替换为 `***`
- 长度 ≤ 8 的 Key 全部替换为 `***`
- HTTP 请求日志中的 Header 值同样需要脱敏

---

## 3. 网络熔断机制

### 3.1 应用级请求频率限制

**规则：每分钟最多 10 次 AI 请求**

```typescript
class NetworkCircuitBreaker {
  private requestTimestamps: number[] = []
  private readonly MAX_REQUESTS_PER_MINUTE = 10
  private readonly WINDOW_MS = 60_000  // 1 分钟窗口

  async acquire(): Promise<boolean> {
    const now = Date.now()

    // 清理超过 1 分钟的时间戳
    this.requestTimestamps = this.requestTimestamps.filter(ts => now - ts < this.WINDOW_MS)

    // 检查是否超过限制
    if (this.requestTimestamps.length >= this.MAX_REQUESTS_PER_MINUTE) {
      Logger.warn('[NETWORK]', '请求频率熔断', `近1分钟已请求${this.requestTimestamps.length}次`)
      return false
    }

    // 记录本次请求时间戳
    this.requestTimestamps.push(now)
    return true
  }
}
```

### 3.2 熔断触发处理

```
AI 请求发起前
      │
      ▼
检查网络熔断器
      │
      ├── acquire() 返回 true → 正常发起请求
      │
      └── acquire() 返回 false（频率超限）
              │
              ▼
         Toast 提示："请求过于频繁，请稍后再试"
         本次请求不发出，不计入 AI 请求日志
```

### 3.3 离线状态强拦截

```typescript
import { connection } from '@ohos.net.connection'

async function checkNetworkBeforeRequest(): Promise<boolean> {
  const netHandle = await connection.getDefaultNet()
  if (!netHandle || netHandle.netId === 0) {
    // 离线状态：强拦截
    AlertDialog.show({
      message: '当前无网络连接，请检查网络设置后重试',
      autoCancel: false,
      primaryButton: { value: '我知道了', action: () => {} }
    })
    return false
  }
  return true
}
```

**离线拦截硬性约束**：
- 离线状态下，**严禁**发起任何 AI 请求
- **严禁**将请求静默排队等待网络恢复（可能导致请求雪崩）
- 必须弹出明确提示告知用户当前无网络
- 网络恢复后不自动重试，需用户手动触发

### 3.4 熔断与重试的关系

```
用户触发 AI 操作
      │
      ▼
网络状态检查
      │
      ├── 离线 → 弹窗拦截，流程终止
      │
      └── 在线 → 熔断器频率检查
                    │
                    ├── 频率超限 → Toast 提示，流程终止
                    │
                    └── 频率正常 → 发起请求
                                    │
                                    ├── 成功 → 返回结果
                                    │
                                    └── 失败 → 遵循 FEATURE_RULES 重试逻辑
                                               （重试同样受熔断器约束）
```

**注意**：FEATURE_RULES 中的布鲁姆 9 题自动重试（2 次）同样受熔断器频率限制约束。若自动重试触发熔断，按熔断规则处理，不继续重试。
