/**
 * FrameworkTree - 可折叠知识框架树形列表
 * 展示学科/主题的层级知识结构，支持展开/折叠动画
 */
@Component
export struct FrameworkTree {
  frameworkData: object | null = null

  @State private expandedIds: Set<string> = new Set<string>()
  @State private treeNodes: TreeNode[] = []

  /** 树节点接口 */
  interface TreeNode {
    id: string
    label: string
    level: number
    children: string[]       // 子节点 ID 列表
    description: string
    estimatedHours: number
    isPathNode: boolean      // 是否在推荐路径上
  }

  aboutToAppear(): void {
    this.parseFrameworkData()
    // 默认展开根节点
    if (this.treeNodes.length > 0) {
      this.expandedIds.add(this.treeNodes[0].id)
    }
  }

  /** 解析框架数据 */
  private parseFrameworkData(): void {
    this.treeNodes = []
    if (!this.frameworkData) { return }
    try {
      const data: Record<string, Object> = this.frameworkData as Record<string, Object>
      const rawTree: Array<Record<string, Object>> =
        (data['tree'] as Array<Record<string, Object>>) ?? []
      const pathList: Array<string> = (data['learningPath'] as Array<string>) ?? []
      const pathSet: Set<string> = new Set<string>(pathList)

      for (const node of rawTree) {
        const treeNode: TreeNode = {
          id: (node['id'] as string) ?? '',
          label: (node['label'] as string) ?? '',
          level: (node['level'] as number) ?? 0,
          children: (node['children'] as string[]) ?? [],
          description: (node['description'] as string) ?? '',
          estimatedHours: (node['estimatedHours'] as number) ?? 0,
          isPathNode: pathSet.has(node['id'] as string)
        }
        this.treeNodes.push(treeNode)
      }
    } catch (_e) { /* ignore */ }
  }

  /** 根据 ID 查找节点 */
  private findNode(id: string): TreeNode | null {
    for (let i: number = 0; i < this.treeNodes.length; i++) {
      if (this.treeNodes[i].id === id) { return this.treeNodes[i] }
    }
    return null
  }

  /** 判断节点是否展开 */
  private isExpanded(id: string): boolean {
    return this.expandedIds.has(id)
  }

  /** 切换展开/折叠状态 */
  private toggleExpand(id: string): void {
    if (this.expandedIds.has(id)) {
      this.expandedIds.delete(id)
    } else {
      this.expandedIds.add(id)
    }
  }

  /** 获取节点的直接子节点 ID 列表 */
  private getChildIds(parentId: string): string[] {
    const parent: TreeNode | null = this.findNode(parentId)
    return parent ? parent.children : []
  }

  /**
   * 递归构建树的扁平化渲染列表
   * 返回 [nodeId, depth] 数组，仅包含可见节点（父节点折叠时隐藏子节点）
   */
  private getVisibleNodes(): Array<{ node: TreeNode; depth: number }> {
    const result: Array<{ node: TreeNode; depth: number }> = []

    // 找出所有根节点（level=0 或没有被任何节点引用为子节点的）
    const childIdSet: Set<string> = new Set<string>()
    for (const n of this.treeNodes) {
      for (const cid of n.children) { childIdSet.add(cid) }
    }

    // 收集根节点
    const rootNodes: TreeNode[] = []
    for (const n of this.treeNodes) {
      if (n.level === 0 || !childIdSet.has(n.id)) {
        rootNodes.push(n)
      }
    }

    // BFS 构建可见列表
    const visitQueue: Array<{ node: TreeNode; depth: number }> = []
    for (const r of rootNodes) {
      visitQueue.push({ node: r, depth: 0 })
    }

    while (visitQueue.length > 0) {
      const item: { node: TreeNode; depth: number } = visitQueue.shift()!
      result.push(item)

      if (this.isExpanded(item.node.id)) {
        const childIds: string[] = this.getChildIds(item.node.id)
        for (const cid of childIds) {
          const child: TreeNode | null = this.findNode(cid)
          if (child) {
            visitQueue.push({ node: child, depth: item.depth + 1 })
          }
        }
      }
    }

    return result
  }

  build() {
    Column() {
      // 头部：学科名称 + 推荐路径说明
      if (this.frameworkData) {
        try {
          const data: Record<string, Object> = this.frameworkData as Record<string, Object>
          if (data['subject']) {
            Row() {
              Text('\u{1F3E0}').fontSize(18).margin({ right: 8 })
              Text(data['subject'] as string)
                .fontSize(18).fontWeight(FontStyle.Bold).fontColor('#FFFFFF')
            }
            .width('100%').margin({ bottom: 6 })
          }

          // 推荐路径提示
          Text('\u{1F4CD} \u63A8\u8350\u5B66\u4E60\u8DEF\u5F84\uFF08\u9AD8\u4EAE\u8282\u70B9\uFF09')
            .fontSize(12).fontColor('rgba(255,255,255,0.45)')
            .width('100%').margin({ bottom: 14 })
        } catch (_e) { /* ignore */ }
      }

      // 树形列表
      List() {
        ForEach(this.getVisibleNodes(), (item: { node: TreeNode; depth: number }, _index: number) => {
          ListItem() {
            this.buildTreeNodeItem(item.node, item.depth)
          }
        }, (item: { node: TreeNode; depth: number }) => item.node.id)
      }
      .width('100%').listDirection(Axis.Vertical).divider({ strokeWidth: 0 })
      .scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
    }
    .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })
  }

  /** 构建单个树节点项 */
  @Builder buildTreeNodeItem(node: TreeNode, depth: number): void {
    Column() {
      Row() {
        // 左侧：缩进 + 展开/折叠箭头 + 路径指示条
        Row() {
          // 缩进
          if (depth > 0) {
            Text('').width(depth * 16)
          }

          // 展开/折叠箭头（仅当有子节点时显示）
          if (node.children.length > 0) {
            Text(this.isExpanded(node.id) ? '\u25BC' : '\u25B6')
              .fontSize(10).fontColor('rgba(255,255,255,0.4)')
              .width(16).height(16)
              .onClick(() => { this.toggleExpand(node.id) })
          } else {
            Text('').width(16).height(16)
          }

          // 推荐路径左侧竖线
          if (node.isPathNode) {
            Text('').width(3).height(20)
              .backgroundColor('#5C6BC0')
              .borderRadius(1.5)
              .margin({ right: 8 })
          } else {
            Text('').width(3).height(0).margin({ right: 8 })
          }
        }

        // 右侧：标签 + 描述 + 时长
        Column() {
          Row() {
            Text(node.label)
              .fontSize(node.level === 0 ? 15 : 13)
              .fontWeight(node.level === 0 ? FontStyle.Bold : FontStyle.Normal)
              .fontColor(node.isPathNode ? '#B388FF' : 'rgba(255,255,255,0.85)')

            if (node.estimatedHours > 0) {
              Text(`${node.estimatedHours}h`)
                .fontSize(10).fontColor('rgba(255,255,255,0.35)')
                .margin({ left: 6 })
            }
          }
          .width('100%')

          if (node.description && node.description.length > 0 && this.isExpanded(node.id)) {
            Text(node.description)
              .fontSize(11).fontColor('rgba(255,255,255,0.45)')
              .width('100%').maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ top: 3 })
          }
        }
        .layoutWeight(1).alignItems(HorizontalAlign.Start)
      }
      .width('100%').height('auto').padding({ top: 8, bottom: 8 })
      .onClick(() => {
        if (node.children.length > 0) {
          this.toggleExpand(node.id)
        }
      })
    }
    .width('100%')
  }
}
