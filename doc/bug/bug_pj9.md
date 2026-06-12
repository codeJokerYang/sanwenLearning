# BUG-PJ9：API Key 自动存储失败（HUKS 误判）+ 文件日志全盲（句柄只读）

> 日期：2026-06-12 | 严重度：高（AI 功能全部不可用 + 故障不可观测） | 状态：已修复
> 关联：BUG-PJ7 / BUG-PJ8 修复后，依靠修好的日志才定位到本缺陷

## 一、现象

1. 应用启动后设置页始终显示「API Key 状态：未配置」，内置默认密钥的自动加密存储从未生效，所有 AI 请求无密钥可用；
2. 应用沙箱日志文件每天都生成，但**始终 0 字节**，任何错误都无处可查。

## 二、根本原因

**缺陷 A（Logger.ets）—— 文件句柄只读：**

```ts
// 错误：缺少 WRITE_ONLY，OpenMode 缺省为 READ_ONLY
fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.APPEND)
```

`CREATE|APPEND` 不含写权限位，文件被创建（0 字节）但 `writeSync` 永远失败，且失败被 catch 静默——日志系统自身失明。

**缺陷 B（ApiKeyStore.ets）—— HUKS API 行为误判：**

API 11+ 中 `huks.isKeyItemExist()` 在密钥**不存在**时不是 `resolve(false)`，而是**以异常返回**（错误码 12000011）。原代码把该异常当作失败直接抛出：

```
isKeyItemExist 抛"密钥不存在" → ensureKeyExists 抛错 → saveApiKey 失败
→ 密钥永远无法生成 → AI 全链路无密钥
```

次生问题：错误对象用 `String(e)` 序列化得到 `[object Object]`，关键错误码丢失。

## 三、修复方案

| 文件 | 修改 |
|------|------|
| `common/Logger.ets` | `openSync` 增加 `fs.OpenMode.WRITE_ONLY` |
| `services/ApiKeyStore.ets` | `isKeyItemExist` 的异常视为"密钥不存在"，继续走 `generateKeyItem`；新增 `describeError()` 提取 `code`/`message` |

## 四、验证

- 修复 Logger 后日志立即可写，HUKS 错误链完整呈现（定位本缺陷正是依靠它）；
- 修复 HUKS 后启动日志出现「HUKS 密钥已生成」「API Key 已自动加密存储」，设置页状态变「已配置」，对话链路端到端可用（见测试报告）。

## 五、预防措施

1. **日志系统自检**：Logger init 后写一条启动标记并读回校验，写入失败时降级到 hilog 并以 toast 提示开发版本；
2. **系统 API 行为核实**：HUKS、文件、网络等系统 API 的"不存在/未找到"语义（返回值 vs 异常）必须以当前 SDK 文档为准，在封装层写明语义注释；
3. **错误序列化规约**：捕获系统错误必须提取 `code` + `message`（BusinessError），禁止裸 `String(e)`。
