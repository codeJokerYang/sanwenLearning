/**
 * MindBadgeAnim — 心智塑成勋章动画
 * Full-screen badge overlay with particle effects on visible trigger.
 * 架构：纯展示组件，严禁导入 Services/RdbHelper
 */

interface Particle {
  x: number;
  y: number;
  size: number;
  delay: number;
}

@Component
export struct MindBadgeAnim {
  @Prop visible: boolean = false;
  @State showBadge: boolean = false;
  @State badgeScale: number = 0;
  @State badgeOpacity: number = 0;
  @State particles: Particle[] = [];
  @State particleScale: number = 1.0;
  @State particleOpacity: number = 0;

  private readonly PARTICLE_COUNT: number = 12;
  private viewWidth: number = 0;
  private viewHeight: number = 0;

  aboutToAppear(): void {
    if (this.visible) {
      this.triggerAnimation();
    }
  }

  build() {
    if (!this.visible && !this.showBadge) {
      // Nothing to render — component hidden
      Column()
        .width(0)
        .height(0)
    } else {
      Stack() {
        // Full-screen semi-transparent overlay
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.6)')
          .onClick(() => {
            // Prevent click-through
          })

        // Particles
        ForEach(this.particles, (p: Particle, index: number) => {
          Circle()
            .width(p.size)
            .height(p.size)
            .fill('#FFD54F')
            .position({ x: p.x, y: p.y })
            .opacity(this.particleOpacity)
            .scale({ x: this.particleScale, y: this.particleScale })
        }, (p: Particle, index: number) => `${index}_${p.x}_${p.y}`)

        // Badge icon
        Column() {
          Column() {
            Text('\u2605')
              .fontSize(48)
              .fontColor('#FFD54F')
              .fontWeight(FontWeight.Bold)
          }
          .width(100)
          .height(100)
          .borderRadius(50)
          .backgroundColor($r('app.color.color_fragment_selected'))
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .shadow({ radius: 16, color: 'rgba(255, 213, 79, 0.5)', offsetY: 4 })

          Blank().height(12)

          Text($r('app.string.mind_badge_title'))
            .fontSize($r('app.float.font_size_title'))
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)

          Blank().height(6)

          Text($r('app.string.mind_badge_subtitle'))
            .fontSize($r('app.float.font_size_body'))
            .fontColor('rgba(255, 255, 255, 0.8)')
            .textAlign(TextAlign.Center)
        }
        .scale({ x: this.badgeScale, y: this.badgeScale })
        .opacity(this.badgeOpacity)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .onAreaChange((_oldArea: Area, newArea: Area) => {
        this.viewWidth = newArea.width as number;
        this.viewHeight = newArea.height as number;
      })
      .accessibilityText($r('app.string.mind_badge_accessibility'))
    }
  }

  /**
   * Generate random particle positions within a spread radius
   */
  private generateParticles(): void {
    this.particles = [];
    const spreadRadius: number = 120;
    const cx: number = this.viewWidth / 2;
    const cy: number = this.viewHeight / 2;
    for (let i: number = 0; i < this.PARTICLE_COUNT; i++) {
      const angle: number = (Math.PI * 2 / this.PARTICLE_COUNT) * i + (Math.random() - 0.5) * 0.5;
      const dist: number = spreadRadius * (0.4 + Math.random() * 0.6);
      this.particles.push({
        x: cx + dist * Math.cos(angle),
        y: cy + dist * Math.sin(angle),
        size: 4 + Math.random() * 4,
        delay: Math.random() * 0.3 * 1000
      });
    }
  }

  /**
   * Trigger badge animation sequence
   * Fallback: on animation failure, display static badge
   */
  private triggerAnimation(): void {
    this.showBadge = true;
    this.generateParticles();

    try {
      // Stage 1: Badge scale up
      animateTo({
        duration: 500,
        curve: Curve.FastOutSlowIn,
        onFinish: () => {
          // Stage 2: Particle spread
          animateTo({
            duration: 500,
            curve: Curve.EaseOut,
            onFinish: () => {
              // Stage 3: Fade out particles
              animateTo({
                duration: 300,
                curve: Curve.EaseIn,
                onFinish: () => {
                  // Animation complete — badge remains visible
                }
              }, () => {
                this.particleOpacity = 0;
              });
            }
          }, () => {
            this.particleScale = 2.0;
            this.particleOpacity = 1.0;
          });
        }
      }, () => {
        this.badgeScale = 1.0;
        this.badgeOpacity = 1.0;
      });
    } catch (e) {
      // Fallback: static badge display without animation
      this.badgeScale = 1.0;
      this.badgeOpacity = 1.0;
      this.particleScale = 1.0;
    }
  }
}
