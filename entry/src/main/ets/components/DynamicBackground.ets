/**
 * DynamicBackground — 沉浸式渐变背景 + 装饰元素
 * 灵感：不背单词 / Duolingo 首页风格
 * 
 * 设计决策：弃用 Canvas（设备兼容性差），改用 ArkUI 原生能力：
 *   - Column.linearGradient() 多层渐变背景
 *   - Stack 定位装饰性圆形/光斑
 *   - animateTo 实现呼吸动画
 * 架构：纯展示组件，零依赖
 */
@Component
export struct DynamicBackground {
  @State glow1Scale: number = 1.0
  @State glow2Scale: number = 1.0
  @State floatY1: number = 0
  @State floatY2: number = 0
  private animTimer: number = 0

  aboutToAppear(): void {
    // Gentle breathing animation for glow spots
    this.animTimer = setInterval(() => {
      const t = Date.now() * 0.001
      this.glow1Scale = 0.95 + 0.08 * Math.sin(t * 0.6)
      this.glow2Scale = 0.92 + 0.10 * Math.sin(t * 0.4 + 1.5)
      this.floatY1 = Math.sin(t * 0.3) * 8
      this.floatY2 = Math.sin(t * 0.25 + 2) * 12
    }, 16)
  }

  aboutToDisappear(): void {
    if (this.animTimer !== 0) {
      clearInterval(this.animTimer)
      this.animTimer = 0
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // === Layer 0: Main gradient background ===
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 160,
          colors: [
            ['#0D1B3E', 0],     // deep navy top-left
            ['#162B5A', 0.25],   // navy blue
            ['#1A3A6E', 0.5],    // medium blue
            ['#242954', 0.75],   // purple-blue
            ['#14142B', 1]       // very dark bottom
          ]
        })

      // === Layer 1: Ambient glow spot — top left (warm violet) ===
      Column()
        .width(280)
        .height(280)
        .borderRadius(140)
        .position({ x: -80, y: -60 + this.floatY1 })
        .scale({ x: this.glow1Scale, y: this.glow1Scale })
        .linearGradient({
          angle: 135,
          colors: [
            ['rgba(124,77,255,0.22)', 0],
            ['rgba(124,77,255,0.08)', 0.5],
            ['rgba(124,77,255,0)', 1]
          ]
        })

      // === Layer 2: Ambient glow spot — right side (cyan/teal) ===
      Column()
        .width(240)
        .height(240)
        .borderRadius(120)
        .position({ x: '65%', y: '35%' })
        .translate({ y: this.floatY2 })
        .scale({ x: this.glow2Scale, y: this.glow2Scale })
        .linearGradient({
          angle: 180,
          colors: [
            ['rgba(0,188,212,0.18)', 0],
            ['rgba(0,188,212,0.05)', 0.55],
            ['rgba(0,188,212,0)', 1]
          ]
        })

      // === Layer 3: Small accent dots (stars) ===
      Circle({ width: 6, height: 6 }).fill('rgba(220,225,255,0.25)').position({ x: '15%', y: '20%' })
      Circle({ width: 5, height: 5 }).fill('rgba(220,225,255,0.18)').position({ x: '75%', y: '15%' })
      Circle({ width: 4, height: 4 }).fill('rgba(220,225,255,0.22)').position({ x: '85%', y: '45%' })
      Circle({ width: 5, height: 5 }).fill('rgba(220,225,255,0.15)').position({ x: '8%', y: '55%' })
      Circle({ width: 6, height: 6 }).fill('rgba(220,225,255,0.12)').position({ x: '55%', y: '70%' })
      Circle({ width: 4, height: 4 }).fill('rgba(220,225,255,0.20)').position({ x: '30%', y: '78%' })
      Circle({ width: 5, height: 5 }).fill('rgba(220,225,255,0.16)').position({ x: '68%', y: '82%' })

      // === Layer 4: Bottom wave accent (subtle gradient band) ===
      Row()
        .width('100%')
        .height(200)
        .position({ bottom: 0, left: 0 })
        .linearGradient({
          angle: 180,
          colors: [
            ['transparent', 0],
            ['rgba(26,58,110,0.15)', 0.4],
            ['rgba(13,27,62,0.35)', 1]
          ]
        })
    }
    .width('100%')
    .height('100%')
    .clip(true)
  }
}
