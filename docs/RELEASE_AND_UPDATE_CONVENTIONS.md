# 三问高效学习机 — 发布与更新策略

> 版本：v1.0 | 日期：2026-06-05 | 版本管理、数据库迁移与兼容性必须遵循本规范

---

## 1. 版本号规则

### 1.1 语义化版本（Semantic Versioning）

版本号格式：`major.minor.patch`

| 位 | 含义 | 递增条件 | 示例 |
|---|------|---------|------|
| `major` | 主版本 | 不兼容的 API 变更 | 1.x.x → 2.0.0 |
| `minor` | 次版本 | 向后兼容的功能新增 | 1.0.x → 1.1.0 |
| `patch` | 修订号 | 向后兼容的 Bug 修复 | 1.0.0 → 1.0.1 |

### 1.2 版本号存储

```typescript
// Config.ets
export const APP_VERSION = '1.0.0'
export const APP_VERSION_CODE = 10000  // major*10000 + minor*100 + patch
export const DB_VERSION = 1            // 数据库版本号，每次 schema 变更递增
```

- `APP_VERSION`：面向用户的版本号字符串
- `APP_VERSION_CODE`：整数版本码，用于版本比较
- `DB_VERSION`：数据库 schema 版本号，与 `APP_VERSION` 独立递增

---

## 2. 数据库迁移策略

### 2.1 迁移触发

`RdbHelper` 初始化时检测 `DB_VERSION`，若与数据库中存储的版本不一致，触发迁移：

```typescript
class RdbHelper {
  private static readonly CURRENT_DB_VERSION: number = 1

  async getRdbStore(context: Context): import('@ohos.data.relationalStore').RdbStore {
    const store = await relationalStore.getRdbStore(context, {
      name: 'sanwen_learning.db',
      securityLevel: relationalStore.SecurityLevel.S1
    })

    const currentVersion = store.version
    if (currentVersion < RdbHelper.CURRENT_DB_VERSION) {
      await this.migrate(store, currentVersion, RdbHelper.CURRENT_DB_VERSION)
    }

    return store
  }

  private async migrate(store: RdbStore, fromVersion: number, toVersion: number): Promise<void> {
    for (let v = fromVersion + 1; v <= toVersion; v++) {
      await this.executeMigration(store, v)
    }
    store.version = toVersion
  }

  private async executeMigration(store: RdbStore, targetVersion: number): Promise<void> {
    switch (targetVersion) {
      case 1:
        // 初始建表（执行 init.sql），仅在 version=0（新安装）时触发
        await this.executeInitScript(store)
        break
      // case 2: 未来迁移脚本
      //   await this.migrateV2(store)
      //   break
      default:
        Logger.error(`Unknown DB migration version: ${targetVersion}`)
    }
  }
}
```

**硬性约束**：`init.sql` 仅在 `currentVersion === 0`（全新安装）时执行。版本升级（如 1→2）严禁执行 `init.sql`，必须走 `ALTER TABLE` 增量迁移。

### 2.2 迁移脚本规范

每个数据库版本变更必须编写独立的迁移方法：

```typescript
// 示例：V1 → V2 新增字段
// [DB_MIGRATION] V1->V2: question_record 新增 controversy_id，新增索引
private async migrateV2(store: RdbStore): Promise<void> {
  // 1. 新增字段
  await store.executeSql('ALTER TABLE question_record ADD COLUMN controversy_id TEXT')

  // 2. 数据回填
  await store.executeSql('UPDATE question_record SET controversy_id = NULL WHERE step != 2')

  // 3. 新增索引
  await store.executeSql('CREATE INDEX IF NOT EXISTS idx_qrecord_controversy ON question_record(controversy_id)')
}
```

**迁移脚本红线**：

| 规则 | 说明 |
|------|------|
| **严禁 DROP TABLE** | 迁移必须保留数据，使用 ALTER TABLE 增量变更 |
| **必须向后兼容** | 新增字段必须有默认值或允许 NULL |
| **必须记录变更日志** | 每个版本迁移在 `docs/DB_MIGRATION_LOG.md` 中记录 |
| **必须可回滚** | 每个迁移方法提供对应的回滚方法（降级场景） |

**注释红线**：每个迁移方法上方**必须**有以 `[DB_MIGRATION] Vx->Vy:` 开头的注释，摘要记录变更内容，作为代码级的迁移日志，严禁仅依赖外部 Markdown 记录。

### 2.3 迁移日志模板

```markdown
# DB Migration Log

## V1 → V2
- 日期：2026-06-XX
- 变更：
  - question_record 新增 controversy_id TEXT 字段
  - 新增索引 idx_qrecord_controversy
- 回滚：
  - DROP INDEX idx_qrecord_controversy
  - ALTER TABLE question_record DROP COLUMN controversy_id（SQLite 不支持，需重建表）
```

---

## 3. 兼容性策略

### 3.1 API 版本

| 配置项 | 值 | 说明 |
|--------|---|------|
| `compileSdkVersion` | API 12 | 编译时 SDK 版本 |
| `compatibleSdkVersion` | API 12 | 最低兼容 API 版本 |
| `targetSdkVersion` | API 12 | 目标 API 版本 |

- 最低兼容 API 12，不支持更低版本
- 使用新 API 前必须检查 `canIUse()` 或版本号判断

### 3.2 数据兼容性

| 场景 | 处理策略 |
|------|---------|
| 新版本读取旧数据 | 新字段有默认值，旧数据自动填充默认值 |
| 旧版本读取新数据 | 旧版本忽略不认识的字段（SQLite 动态列特性） |
| 降级安装 | 数据库版本回退时，执行回滚迁移或重置数据库 |

### 3.3 不兼容变更公告

当 `major` 版本升级涉及不兼容变更时，必须：

1. 在 `docs/CHANGELOG.md` 中记录变更内容
2. 提供数据迁移工具（设置页入口）
3. 迁移前自动备份旧数据库文件

---

## 4. 构建与发布

### 4.1 构建配置

| 配置项 | 开发环境 | 生产环境 |
|--------|---------|---------|
| AI API Base URL | `https://dev-api.example.com` | `https://api.example.com` |
| 日志级别 | DEBUG | ERROR |
| 调试模式 | 开启 | 关闭 |

### 4.2 发布前检查清单

| 检查项 | 检查方式 | 违规等级 |
|--------|---------|---------|
| API Key 未硬编码 | 全局搜索 `sk-` | P0 阻塞 |
| 日志脱敏 | 检查 ai_request_log | P0 阻塞 |
| 版本号已更新 | 检查 Config.ets | P0 阻塞 |
| 数据库迁移脚本已编写 | 检查 DB_VERSION 递增 | P1 |
| 无障碍描述已设置 | 关键组件代码审查 | P1 |
| 硬编码文案已外提 | 全局搜索 .ets 中文字面量 | P1 |
| 性能达标 | 知识图谱 50 节点 ≥30fps | P1 |
| 冷启动数据完整 | 关闭重开后数据不丢失 | P0 阻塞 |

### 4.3 热修复策略

- HarmonyOS NEXT 支持 OTA 应用更新
- 紧急 Bug 修复：递增 `patch` 版本号，发布修订版
- 数据修复：通过数据库迁移脚本修复异常数据
- **严禁**在应用内执行远程代码下载和执行

---

## 5. 版本历史

| 版本 | 日期 | 变更摘要 |
|------|------|---------|
| 1.0.0 | 2026-06-XX | 初始版本：三问认知引擎完整闭环 |
