## 1. 冷启动初始化链修复

- [x] 1.1 在 EntryAbility.onCreate() 中添加 Logger.init(context) 调用（最优先）
- [x] 1.2 在 EntryAbility.onCreate() 中添加 RdbHelper.getInstance().init(context) 异步调用，保存 Promise
- [x] 1.3 修改 EntryAbility.onWindowStageCreate() 等待 dbInitPromise 完成后再 loadContent
- [ ] 1.4 验证冷启动后首页正常加载，不再闪退

## 2. RdbHelper 内联 INIT_SQL

- [x] 2.1 在 db/RdbHelper.ets 中添加 INIT_SQL 常量（9 表 + 10 索引，含 analytics_event）
- [x] 2.2 修改 init() 方法签名：initSql 参数改为可选，默认使用内联 INIT_SQL
- [ ] 2.3 验证首次启动时数据库建表成功

## 3. HUKS 加密流程修复

- [x] 3.1 修改 ApiKeyStore.ets：initSession 返回类型改为 HuksSessionHandle
- [x] 3.2 添加 generateRandomIv() 函数生成 16 字节随机 IV
- [x] 3.3 修改 hmacEncrypt()：IV 客户端生成，通过 HUKS_TAG_IV 传入
- [x] 3.4 修改 loadApiKey()：initSession 返回类型改为 HuksSessionHandle
- [x] 3.5 删除废弃的 encryptProperties() 函数
- [x] 3.6 替换 TextDecoder.decode() 为 decodeToString()（API 12+）
- [ ] 3.7 验证 API Key 加密存储和解密加载正常

## 4. ArkTS 类型安全修复

- [x] 4.1 修复 RdbHelper.ets: JSON.parse 结果添加显式类型 string[]
- [x] 4.2 修复 EvaluationService.ets: Map 构造器改为逐个 set() 调用
- [x] 4.3 修复 EvaluationService.ets: BLOOM_LABELS Map 改为逐个 set() 调用
- [x] 4.4 修复 KnowledgeGraph.ets: NodePosition 替换为导入的 LayoutPosition
- [x] 4.5 修复 KnowledgeGraph.ets: 删除 build() 中的 const 声明
- [x] 4.6 修复 KnowledgeGraph.ets: Map.get() 返回值添加显式类型 LayoutPosition | undefined
- [x] 4.7 修复 ForceLayoutUtil.ets: 导出 LayoutPosition 接口
- [x] 4.8 修复 Assessment.ets: JSON.parse 结果添加显式类型 string[]
- [x] 4.9 修复 ManualInputBox.ets: onPaste 回调参数从 PasteEvent 改为 string

## 5. 其他编译错误修复

- [x] 5.1 修复 Logger.ets: fileIo.openSync 返回 File 类型，使用 fd.fd
- [x] 5.2 修复 AIService.ets: TextDecoder.decode() 替换为 decodeToString()
- [x] 5.3 修复 HomeViewModel.ets: 添加 Logger 导入和 TAG 常量
- [x] 5.4 修复 module.json5: 添加 INTERNET 和 GET_NETWORK_INFO 权限
- [ ] 5.5 编译验证：0 ERROR，确认所有编译错误已修复

## 6. 运行时空指针防护（bug_ph4）

- [x] 6.1 修复 HomePage.ets: filteredCourses getter 添加空值保护
- [x] 6.2 修复 HomePage.ets: loadCourses/deleteCourse/createCourse 添加 try-catch + ?? []
- [x] 6.3 修复 HomeViewModel.ets: loadCourses 添加 ?? [] 兜底
- [x] 6.4 修复 Assessment.ets: aboutToAppear 添加 try-catch，startQ3 添加 try-catch/finally
- [x] 6.5 修复 Assessment.ets: syncState 添加 ?? [] 兜底
- [x] 6.6 修复 KnowledgeGraph.ets: aboutToAppear 添加 try-catch，startQ1 添加 try-catch/finally
- [x] 6.7 修复 KnowledgeGraph.ets: nodes/edges 赋值添加 ?? [] 兜底
- [x] 6.8 修复 KnowledgeGraph.ets: onNodeActivate 添加 .catch() + ?? []
- [x] 6.9 修复 LearningSpace.ets: startQ2 添加 try-catch/finally
- [x] 6.10 修复 LearningSpace.ets: syncState controversies 添加 ?? []
- [x] 6.11 修复 LearningSpace.ets: onInsightSubmit 添加 .catch() 处理

## 7. 集成验证

- [ ] 7.1 冷启动应用，确认首页正常显示
- [ ] 7.2 创建课程，确认数据库写入正常
- [ ] 7.3 删除课程，确认级联删除正常
- [ ] 7.4 检查日志文件正常写入
