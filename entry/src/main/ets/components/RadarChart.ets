/**
 * RadarChart — 布鲁姆6层级能力雷达图
 * Canvas-based 6-axis chart. Only redraws when @Prop changes.
 * 架构：纯展示组件，严禁导入 Services/RdbHelper
 */
import resourceManager from '@ohos.resourceManager';

interface Point {
  x: number;
  y: number;
}

@Component
export struct RadarChart {
  @Prop bloomScores: Map<number, number> = new Map();
  @State bloomLabels: string[] = ['', '记忆', '理解', '应用', '分析', '评价', '创造'];
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  aboutToAppear(): void {
    this.loadBloomLabels();
    this.ensureDefaultScores();
  }

  private loadBloomLabels(): void {
    try {
      const resMgr: resourceManager.ResourceManager = getContext(this).resourceManager;
      this.bloomLabels = [
        '',
        resMgr.getStringByNameSync('bloom_remember'),
        resMgr.getStringByNameSync('bloom_understand'),
        resMgr.getStringByNameSync('bloom_apply'),
        resMgr.getStringByNameSync('bloom_analyze'),
        resMgr.getStringByNameSync('bloom_evaluate'),
        resMgr.getStringByNameSync('bloom_create'),
      ];
    } catch (_e) {
      // Fallback to default Chinese labels
    }
  }

  /**
   * Ensure all 6 bloom levels have a score value (default 0)
   */
  private ensureDefaultScores(): void {
    for (let level: number = 1; level <= 6; level++) {
      if (this.bloomScores.get(level) === undefined) {
        this.bloomScores.set(level, 0);
      }
    }
  }

  build() {
    Canvas(this.context)
      .width('100%')
      .height('100%')
      .onReady(() => {
        this.drawRadar();
      })
      .accessibilityText($r('app.string.radar_chart_accessibility'))
  }

  /**
   * Draw the 6-axis radar chart
   * Axes at 60° intervals, starting from top (-90°)
   */
  private drawRadar(): void {
    const ctx: CanvasRenderingContext2D = this.context;
    const w: number = ctx.width;
    const h: number = ctx.height;
    const cx: number = w / 2;
    const cy: number = h / 2;
    const maxRadius: number = Math.min(cx, cy) * 0.7;
    const levels: number = 6;
    const labelOffset: number = maxRadius + 28;

    ctx.clearRect(0, 0, w, h);

    // Draw concentric grid circles (background rings)
    for (let ring: number = 1; ring <= 5; ring++) {
      const radius: number = (maxRadius / 5) * ring;
      ctx.beginPath();
      ctx.strokeStyle = '#E0E0E0';
      ctx.lineWidth = 1;
      for (let i: number = 0; i < levels; i++) {
        const angle: number = (Math.PI * 2 / levels) * i - Math.PI / 2;
        const px: number = cx + radius * Math.cos(angle);
        const py: number = cy + radius * Math.sin(angle);
        if (i === 0) {
          ctx.moveTo(px, py);
        } else {
          ctx.lineTo(px, py);
        }
      }
      ctx.closePath();
      ctx.stroke();
    }

    // Draw 6 axis lines from center to edge
    const vertices: Point[] = [];
    for (let i: number = 0; i < levels; i++) {
      const angle: number = (Math.PI * 2 / levels) * i - Math.PI / 2;
      const ex: number = cx + maxRadius * Math.cos(angle);
      const ey: number = cy + maxRadius * Math.sin(angle);
      vertices.push({ x: ex, y: ey });

      ctx.beginPath();
      ctx.strokeStyle = '#BDBDBD';
      ctx.lineWidth = 1.5;
      ctx.moveTo(cx, cy);
      ctx.lineTo(ex, ey);
      ctx.stroke();

      // Draw axis labels
      const lx: number = cx + labelOffset * Math.cos(angle);
      const ly: number = cy + labelOffset * Math.sin(angle);
      ctx.font = '12px sans-serif';
      ctx.fillStyle = '#333333';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      const level: number = i + 1;
      ctx.fillText(this.bloomLabels[level], lx, ly);
    }

    // Plot data polygon
    const dataPoints: Point[] = [];
    for (let i: number = 0; i < levels; i++) {
      const level: number = i + 1;
      const score: number = Math.max(0, Math.min(100, this.bloomScores.get(level) ?? 0));
      const scaledRadius: number = (maxRadius * score) / 100;
      const angle: number = (Math.PI * 2 / levels) * i - Math.PI / 2;
      dataPoints.push({
        x: cx + scaledRadius * Math.cos(angle),
        y: cy + scaledRadius * Math.sin(angle)
      });
    }

    // Fill polygon with semi-transparent color
    ctx.beginPath();
    ctx.fillStyle = 'rgba(103, 58, 183, 0.2)';
    ctx.strokeStyle = 'rgba(103, 58, 183, 0.8)';
    ctx.lineWidth = 2;
    for (let i: number = 0; i < dataPoints.length; i++) {
      if (i === 0) {
        ctx.moveTo(dataPoints[i].x, dataPoints[i].y);
      } else {
        ctx.lineTo(dataPoints[i].x, dataPoints[i].y);
      }
    }
    ctx.closePath();
    ctx.fill();
    ctx.stroke();

    // Draw data point dots
    for (let i: number = 0; i < dataPoints.length; i++) {
      ctx.beginPath();
      ctx.fillStyle = '#673AB7';
      ctx.arc(dataPoints[i].x, dataPoints[i].y, 4, 0, Math.PI * 2);
      ctx.fill();
    }
  }
}
