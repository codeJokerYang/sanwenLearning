/**
 * KnowledgeGraph — 知识图谱页（Q1: 是什么）
 * 宇宙星系风格：星空背景 + 发光节点 + 连线 + 缩放/旋转控制
 * 遵循 MVVM: Pages→ViewModels ONLY
 */
import { ThreeAskViewModel } from '../viewmodels/ThreeAskViewModel';
import { KnowledgeNode, KnowledgeEdge, NodeType } from '../models/Models';
import { PuzzleFragmentAnim } from '../components/PuzzleFragmentAnim';
import { computeForceDirectedLayout, LayoutPosition } from '../common/ForceLayoutUtil';
import { mapToCanvas, Position } from '../common/utils';
import { router } from '@kit.ArkUI';
import { ErrorCode, errorCodeToResource } from '../common/ErrorCode';
import { AIChatFab } from '../components/AIChatFab';
import { AIChatPanel } from '../components/AIChatPanel';

@Entry
@Component
struct KnowledgeGraph {
  @State nodes: KnowledgeNode[] = [];
  @State edges: KnowledgeEdge[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: ResourceStr = '';
  @State pageStatus: 'loading' | 'empty' | 'error' | 'content' = 'loading';
  @State nodePositions: Map<string, LayoutPosition> = new Map();
  @State useCanvasFailover: boolean = false;
  @State renderMode: 'full' | 'canvas_only' | 'list' = 'full';
  @State renderTransitionOpacity: number = 1.0;
  @State activatedCount: number = 0;
  @State totalNodeCount: number = 0;
  private previousRenderMode: 'full' | 'canvas_only' | 'list' = 'full';
  private canvasReady: boolean = false;
  private canvasWidth: number = 0;
  private canvasHeight: number = 0;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private viewModel: ThreeAskViewModel = new ThreeAskViewModel();
  private courseId: string = '';
  @State chatOpen: boolean = false;

  aboutToAppear(): void {
    try {
      const params = router.getParams() as Record<string, Object>;
      if (params && params['courseId']) {
        this.courseId = params['courseId'] as string;
        this.startQ1();
      }
    } catch (_e) {}
  }

  aboutToDisappear(): void {
    this.nodes = [];
    this.edges = [];
    this.nodePositions = new Map();
    this.canvasReady = false;
  }

  private async startQ1(): Promise<void> {
    this.isLoading = true;
    this.pageStatus = 'loading';
    this.errorMessage = '';
    try {
      await this.viewModel.startQ1(this.courseId);
      this.nodes = this.viewModel.nodes ?? [];
      this.edges = this.viewModel.edges ?? [];
      this.errorMessage = this.viewModel.errorMessage ? errorCodeToResource(this.viewModel.errorMessage) : '';

      if (this.nodes.length > 0) {
        this.computeLayout();
        this.checkDegradation();
        this.activatedCount = this.nodes.filter(n => n.is_activated).length;
        this.totalNodeCount = this.nodes.length;
        this.pageStatus = 'content';
      } else {
        this.pageStatus = 'empty';
      }
    } catch (e) {
      const errCode = (e instanceof Error) ? e.message : '';
      if (errCode === ErrorCode.NETWORK_DISCONNECTED) {
        this.getUIContext().showAlertDialog({
          message: errorCodeToResource(ErrorCode.NETWORK_DISCONNECTED),
          autoCancel: false,
          buttons: [{
            value: $r('app.string.home_delete_confirm_cancel'),
            action: () => {}
          }]
        });
        this.errorMessage = errorCodeToResource(ErrorCode.NETWORK_DISCONNECTED);
      } else {
        this.errorMessage = errorCodeToResource(ErrorCode.KNOWLEDGE_LOAD_FAILED);
      }
      this.nodes = [];
      this.edges = [];
      this.pageStatus = 'error';
    } finally {
      this.isLoading = false;
    }
  }

  private computeLayout(): void {
    const positions: Map<string, LayoutPosition> = computeForceDirectedLayout(this.nodes, this.edges);
    this.nodePositions = positions;
  }

  private checkDegradation(): void {
    let newMode: 'full' | 'canvas_only' | 'list' = 'full';
    if (this.nodes.length > 100) newMode = 'list';
    else if (this.nodes.length > 50) newMode = 'canvas_only';

    if (this.previousRenderMode !== newMode && this.previousRenderMode !== 'full') {
      animateTo({ duration: 300, curve: Curve.EaseInOut, onFinish: () => {
        this.renderMode = newMode;
        this.previousRenderMode = newMode;
        this.renderTransitionOpacity = 1.0;
      }}, () => { this.renderTransitionOpacity = 0.0; });
    } else {
      this.renderMode = newMode;
      this.previousRenderMode = newMode;
    }
  }

  private onNodeActivate(node: KnowledgeNode): void {
    this.viewModel.activateNode(this.courseId, node.id).then(() => {
      this.nodes = this.viewModel.nodes ?? [];
      this.computeLayout();
      this.activatedCount = this.nodes.filter(n => n.is_activated).length;
      this.errorMessage = this.viewModel.errorMessage ? errorCodeToResource(this.viewModel.errorMessage) : '';
    }).catch((_e: Error) => {
      this.errorMessage = errorCodeToResource(ErrorCode.NODE_ACTIVATE_FAILED);
    });
  }

  private onAnimComplete(nodeId: string): void {}

  private isFragmentNode(node: KnowledgeNode): boolean { return !node.is_activated; }

  private onCanvasReady(): void {
    this.canvasWidth = this.canvasCtx.width;
    this.canvasHeight = this.canvasCtx.height;
    this.canvasReady = true;
    this.drawGalaxyCanvas();
  }

  // Galaxy-style canvas rendering
  private drawGalaxyCanvas(): void {
    if (!this.canvasReady || this.nodePositions.size === 0) return;
    const ctx: CanvasRenderingContext2D = this.canvasCtx;
    const w: number = ctx.width;
    const h: number = ctx.height;

    ctx.clearRect(0, 0, w, h);

    // Draw cosmic background gradient on canvas area
    const bgGrad: CanvasGradient = ctx.createLinearGradient(0, 0, 0, h);
    bgGrad.addColorStop(0, '#0D1442');
    bgGrad.addColorStop(0.5, '#162055');
    bgGrad.addColorStop(1, '#12122A');
    ctx.fillStyle = bgGrad;
    ctx.fillRect(0, 0, w, h);

    // Draw edges as constellation lines (dashed, subtle)
    ctx.strokeStyle = 'rgba(140,150,230,0.25)';
    ctx.lineWidth = 1;
    ctx.setLineDash([4, 4]);
    for (const edge of this.edges) {
      const sp: LayoutPosition | undefined = this.nodePositions.get(edge.source);
      const tp: LayoutPosition | undefined = this.nodePositions.get(edge.target);
      if (!sp || !tp) continue;
      const sPos: Position = mapToCanvas({ x: sp.x, y: sp.y }, w, h);
      const tPos: Position = mapToCanvas({ x: tp.x, y: tp.y }, w, h);
      ctx.beginPath();
      ctx.moveTo(sPos.x, sPos.y);
      ctx.lineTo(tPos.x, tPos.y);
      ctx.stroke();
    }
    ctx.setLineDash([]);

    // Draw lit nodes as glowing stars
    for (const node of this.nodes) {
      if (!node.is_activated) continue;
      const pos: LayoutPosition | undefined = this.nodePositions.get(node.id);
      if (!pos) continue;
      const mapped: Position = mapToCanvas({ x: pos.x, y: pos.y }, w, h);
      const cx: number = mapped.x;
      const cy: number = mapped.y;

      // Outer glow
      const outerGlow: CanvasGradient = ctx.createRadialGradient(cx, cy, 0, cx, cy, 36);
      outerGlow.addColorStop(0, 'rgba(67,160,71,0.30)');
      outerGlow.addColorStop(0.5, 'rgba(67,160,71,0.10)');
      outerGlow.addColorStop(1, 'rgba(67,160,71,0)');
      ctx.fillStyle = outerGlow;
      ctx.beginPath();
      ctx.arc(cx, cy, 36, 0, Math.PI * 2);
      ctx.fill();

      // Star body
      const starGrad: CanvasGradient = ctx.createRadialGradient(cx - 4, cy - 4, 0, cx, cy, 22);
      starGrad.addColorStop(0, '#81C784');
      starGrad.addColorStop(0.6, '#43A047');
      starGrad.addColorStop(1, '#2E7D32');
      ctx.fillStyle = starGrad;
      ctx.beginPath();
      ctx.arc(cx, cy, 20, 0, Math.PI * 2);
      ctx.fill();

      // Checkmark
      ctx.fillStyle = '#FFFFFF';
      ctx.font = 'bold 16px sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText('\u2713', cx, cy + 1);

      // Star sparkle points (4 small rays)
      ctx.strokeStyle = 'rgba(255,255,255,0.35)';
      ctx.lineWidth = 1;
      const rayLen: number = 10;
      for (let angle = 0; angle < Math.PI * 2; angle += Math.PI / 2) {
        ctx.beginPath();
        ctx.moveTo(cx + Math.cos(angle) * 24, cy + Math.sin(angle) * 24);
        ctx.lineTo(cx + Math.cos(angle) * (24 + rayLen), cy + Math.sin(angle) * (24 + rayLen));
        ctx.stroke();
      }
    }
  }

  build() {
    Stack() {
      // === Layer 1: Cosmic background ===
      Column()
        .width('100%').height('100%')
        .linearGradient({
          angle: 180,
          colors: [
            ['#080E28', 0],
            ['#0D1442', 0.3],
            ['#141E52', 0.6],
            ['#101038', 1]
          ]
        })

      // === Layer 2: Decorative stars (static background) ===
      Circle({ width: 3, height: 3 }).fill('rgba(200,210,255,0.18)').position({ x: '12%', y: '10%' })
      Circle({ width: 2, height: 2 }).fill('rgba(200,210,255,0.12)').position({ x: '85%', y: '15%' })
      Circle({ width: 3.5, height: 3.5 }).fill('rgba(200,210,255,0.14)').position({ x: '75%', y: '78%' })
      Circle({ width: 2, height: 2 }).fill('rgba(200,210,255,0.16)').position({ x: '20%', y: '85%' })
      Circle({ width: 2.5, height: 2.5 }).fill('rgba(200,210,255,0.10)').position({ x: '90%', y: '50%' })
      Circle({ width: 2, height: 2 }).fill('rgba(200,210,255,0.13)').position({ x: '6%', y: '55%' })
      Circle({ width: 3, height: 3 }).fill('rgba(200,210,255,0.09)').position({ x: '55%', y: '5%' })
      Circle({ width: 2.5, height: 2.5 }).fill('rgba(200,210,255,0.11)').position({ x: '40%', y: '92%' })

      // Nebula accents
      Column().width(180).height(180).borderRadius(90)
        .position({ x: '55%', y: '-20%' })
        .linearGradient({ angle: 135, colors: [['rgba(92,107,192,0.08)', 0], ['transparent', 1]] })
      Column().width(130).height(130).borderRadius(65)
        .position({ x: '-15%', y: '60%' })
        .linearGradient({ angle: 200, colors: [['rgba(124,77,255,0.06)', 0], ['transparent', 1]] })

      // === Layer 3: Content ===
      if (this.pageStatus === 'loading') {
        // Loading state
        Column() {
          Blank().height(120)

          Stack() {
            Circle({ width: 72, height: 72 }).fill('rgba(92,107,192,0.10)')
            Circle({ width: 48, height: 48 }).fill('rgba(92,107,192,0.15)')
            Circle({ width: 26, height: 26 }).fill('rgba(140,150,230,0.30)')
            Text('\u2605').fontSize(18).fontColor('#B388FF')
          }.width(72).height(72)

          Blank().height(28)

          Text('正在构建知识图谱...')
            .fontSize(17).fontWeight(FontWeight.Medium).fontColor('rgba(255,255,255,0.75)')
          Text('AI 正在分析资料，提取核心知识点')
            .fontSize(13).fontColor('rgba(255,255,255,0.35)').margin({ top: 6 })

          Blank().height(40)

          Row() {
            ForEach([0, 1, 2], (dotIdx: number, index: number) => {
              Circle({ width: 9, height: 9 })
                .fill(index === 0 ? '#7C8CFF' : index === 1 ? '#B388FF' : '#CE93D8')
                .opacity(index === 0 ? 1 : 0.5)
                .scale({ x: index === 0 ? 1.15 : 0.85, y: index === 0 ? 1.15 : 0.85 })
                .animation({ duration: 600, iterations: -1, curve: Curve.EaseInOut })
            }, (index: number) => `gdot_${index}`)
          }.justifyContent(FlexAlign.SpaceEvenly).width(60)
        }
        .width('100%').height('100%')
        .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

      } else if (this.pageStatus === 'empty') {
        // Empty state — cosmic illustration
        Column() {
          Blank().height(80)

          Stack() {
            // Orbit rings
            Circle({ width: 120, height: 120 }).fill('none').stroke('rgba(124,77,255,0.07)').strokeWidth(1)
            Circle({ width: 86, height: 86}).fill('none').stroke('rgba(124,77,255,0.05)').strokeWidth(1)
            // Central star
            Circle({ width: 48, height: 48 }).fill('rgba(92,107,192,0.10)')
            Circle({ width: 28, height: 28 }).fill('rgba(124,77,255,0.15)')
            Text('\u2605').fontSize(20).fontColor('#B388FF')
          }.width(120).height(120)

          Blank().height(28)

          Text($r('app.string.knowledge_graph_no_nodes'))
            .fontSize(17).fontWeight(FontWeight.Medium).fontColor('rgba(255,255,255,0.75)')
          Text('上传学习资料后，AI 将自动构建知识图谱')
            .fontSize(13).fontColor('rgba(255,255,255,0.35)').margin({ top: 8 })
          Text('点亮所有节点，完成"是什么"阶段探索')
            .fontSize(12).fontColor('rgba(255,255,255,0.22)').margin({ top: 4 })

          Blank().height(40)

          // Phase indicator chips
          Row() {
            PhaseChip({ num: '1', text: '是什么', active: true })
            PhaseChip({ num: '2', text: '为什么', active: false, marginL: 8 })
            PhaseChip({ num: '3', text: '怎么用', active: false, marginL: 8 })
          }.justifyContent(FlexAlign.Center)
        }
        .width('100%').height('100%')
        .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

      } else if (this.pageStatus === 'error') {
        // Error state
        Column() {
          Blank().height(100)
          Stack() {
            Circle({ width: 56, height: 56 }).fill('rgba(255,59,48,0.08)')
            Text('!').fontSize(26).fontWeight(FontWeight.Bold).fontColor('#FF6B6B')
          }.width(56).height(56)
          Blank().height(20)
          Text(this.errorMessage)
            .fontSize(15).fontColor('rgba(255,182,185,0.85)').textAlign(TextAlign.Center)
          Blank().height(24)
          Button($r('app.string.assessment_retry'))
            .fontSize(14).fontColor('#FFFFFF')
            .backgroundColor('rgba(92,107,192,0.6)').borderRadius(20)
            .height(38).padding({ left: 24, right: 24 })
            .onClick(() => { this.startQ1(); })
        }
        .width('100%').height('100%')
        .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

      } else {
        // Content state: Galaxy graph
        Stack() {
          // Graph area header overlay
          Row() {
            // Node count badge
            Row() {
              Text('\u2605').fontSize(11).fontColor('#B388FF').margin({ right: 4 })
              Text(`${this.activatedCount}/${this.totalNodeCount}`)
                .fontSize(12).fontWeight(FontWeight.Medium).fontColor('rgba(255,255,255,0.70)')
            }
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .borderRadius(14)
            .backgroundColor('rgba(255,255,255,0.06)')
            .border({ width: 0.5, color: 'rgba(255,255,255,0.08)' })

            Blank().layoutWeight(1)

            // Mode indicator
            if (this.renderMode !== 'full') {
              Text(this.renderMode === 'list' ? '列表模式' : '精简模式')
                .fontSize(10).fontColor('rgba(255,193,7,0.7)')
                .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                .borderRadius(8).backgroundColor('rgba(255,193,7,0.08)')
            }
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 8, bottom: 4 })
          .position({ top: 0, left: 0 })

          // Main graph content
          if (this.renderMode === 'list') {
            this.buildListDegradation()
          } else if (this.renderMode === 'canvas_only') {
            this.buildCanvasOnlyView()
          } else {
            this.buildFullGalaxyView()
          }
        }
        .width('100%').layoutWeight(1)
        .opacity(this.renderTransitionOpacity)
      }

      // === AI Chat FAB ===
      AIChatFab({
        isOpen: this.chatOpen,
        hasActiveCourse: true
      })
        .position({ x: '80%', y: '90%' })

      // === AI Chat Panel ===
      AIChatPanel({
        isOpen: this.chatOpen
      })
        .position({ x: 0, y: this.chatOpen ? '30%' : '100%' })
        .width('100%')
    }
    .width('100%').height('100%')
  }

  @Builder buildListDegradation() {
    Scroll() {
      Column() {
        Row() {
          Text('\u26A0').fontSize(14).fontColor('#FFC107').margin({ right: 6 })
          Text($r('app.string.knowledge_degraded_list')).fontSize(13).fontColor('#FFC107')
        }.padding({ left: 16, right: 16, top: 44, bottom: 8 })

        ForEach(this.nodes, (node: KnowledgeNode) => {
          Row() {
            Circle({ width: 10, height: 10 })
              .fill(node.is_activated ? '#43A047' : 'rgba(255,255,255,0.12)')
              .margin({ right: 10 })
            Text(node.label)
              .fontSize(14)
              .fontColor(node.is_activated ? 'rgba(255,255,255,0.80)' : 'rgba(255,255,255,0.35)')
              .layoutWeight(1)
          }
          .width('100%')
          .padding(14)
          .borderRadius(12)
          .backgroundColor('rgba(255,255,255,0.04)')
          .border({ width: 0.5, color: 'rgba(255,255,255,0.05)' })
          .margin({ left: 16, right: 16, top: 4, bottom: 4 })
          .onClick(() => { if (!node.is_activated) this.onNodeActivate(node); })
        }, (node: KnowledgeNode) => node.id)
      }
      .width('100%')
    }
    .width('100%').layoutWeight(1)
  }

  @Builder buildCanvasOnlyView() {
    Column() {
      Row() {
        Text('\u26A0').fontSize(14).fontColor('#FFC107').margin({ right: 6 })
        Text($r('app.string.knowledge_degraded_many')).fontSize(13).fontColor('#FFC107')
      }.padding({ left: 16, right: 16, top: 44, bottom: 8 })

      Canvas(this.canvasCtx)
        .width('100%').layoutWeight(1)
        .accessibilityText($r('app.string.a11y_canvas_status', this.totalNodeCount, this.activatedCount))
        .onReady(() => {
          try { this.onCanvasReady(); } catch (_e) { this.useCanvasFailover = true; }
        })
    }
    .width('100%').layoutWeight(1)
  }

  @Builder buildFullGalaxyView() {
    Stack() {
      // Bottom layer: Galaxy Canvas
      Canvas(this.canvasCtx)
        .width('100%').height('100%')
        .accessibilityText($r('app.string.a11y_canvas_status', this.totalNodeCount, this.activatedCount))
        .onReady(() => {
          try { this.onCanvasReady(); } catch (_e) { this.useCanvasFailover = true; }
        })

      if (this.useCanvasFailover) {
        this.buildTextListView()
      } else {
        // Top layer: Fragment nodes (unlit stars waiting to be clicked)
        Column() {
          ForEach(
            this.nodes.filter((n: KnowledgeNode) => this.isFragmentNode(n) && this.nodePositions.has(n.id)),
            (node: KnowledgeNode) => {
              Stack() {
                PuzzleFragmentAnim({
                  nodeLabel: node.label,
                  isActivated: node.is_activated,
                  onActivate: () => { this.onNodeActivate(node); },
                  onAnimComplete: () => { this.onAnimComplete(node.id); }
                })
              }
              .position(mapToCanvas(
                { x: this.nodePositions.get(node.id)?.x ?? 0, y: this.nodePositions.get(node.id)?.y ?? 0 },
                this.canvasWidth, this.canvasHeight))
            },
            (node: KnowledgeNode) => node.id
          )
        }
        .width('100%').height('100%')
      }
    }
    .width('100%').layoutWeight(1)
  }

  @Builder buildTextListView() {
    List() {
      ForEach(this.nodes, (node: KnowledgeNode) => {
        ListItem() {
          Row() {
            Text(node.is_activated ? '\u2713' : '\u25CB')
              .fontSize(16)
              .fontColor(node.is_activated ? '#66BB6A' : 'rgba(255,255,255,0.25)')
              .margin({ right: 10 })
            Text(node.label)
              .fontSize(14)
              .fontColor(node.is_activated ? 'rgba(255,255,255,0.80)' : 'rgba(255,255,255,0.35)')
              .layoutWeight(1)
          }
          .width('100%')
          .padding(14)
          .borderRadius(12)
          .backgroundColor('rgba(255,255,255,0.04)')
          .border({ width: 0.5, color: 'rgba(255,255,255,0.05)' })
          .margin({ left: 16, right: 16, top: 4, bottom: 4 })
          .onClick(() => { if (!node.is_activated) this.onNodeActivate(node); })
        }
      }, (node: KnowledgeNode) => node.id)
    }
    .width('100%').layoutWeight(1)
  }
}

// Small phase chip for empty state
@Component
struct PhaseChip {
  @Prop num: string = '';
  @Prop text: string = '';
  @Prop active: boolean = false;
  @Prop marginL: number = 0;

  build() {
    Row() {
      Text(this.num)
        .fontSize(11).fontWeight(FontWeight.Bold)
        .fontColor(this.active ? '#FFFFFF' : 'rgba(255,255,255,0.35)')
      Text(this.text)
        .fontSize(11)
        .fontColor(this.active ? 'rgba(255,255,255,0.85)' : 'rgba(255,255,255,0.30)')
        .margin({ left: 4 })
    }
    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
    .borderRadius(12)
    .backgroundColor(this.active ? 'rgba(92,107,192,0.25)' : 'rgba(255,255,255,0.04)')
    .border({ width: 0.5, color: this.active ? 'rgba(124,140,255,0.2)' : 'rgba(255,255,255,0.06)' })
    .margin({ left: this.marginL })
  }
}
