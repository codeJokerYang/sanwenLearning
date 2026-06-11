/**
 * BottomTabBar — 底部导航栏组件
 * 4个Tab：首页/学习/测评/我的
 */
import { router } from '@kit.ArkUI';

@Component
export struct BottomTabBar {
  @Prop activeTab: string = 'home';

  build() {
    Row() {
      // Tab: Home
      Column() {
        Text('\u{1F3E0}')
          .fontSize(22)
        Text('首页')
          .fontSize(10)
          .fontColor(this.activeTab === 'home' ? '#5C6BC0' : 'rgba(255,255,255,0.4)')
          .fontWeight(this.activeTab === 'home' ? FontWeight.Bold : FontWeight.Normal)
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .height(56)
      .onClick(() => {
        if (this.activeTab !== 'home') {
          router.back();
        }
      })
      .accessibilityText('首页标签')

      // Tab: Learn
      Column() {
        Text('\u{1F4D6}')
          .fontSize(22)
        Text('学习')
          .fontSize(10)
          .fontColor(this.activeTab === 'learning' ? '#5C6BC0' : 'rgba(255,255,255,0.4)')
          .fontWeight(this.activeTab === 'learning' ? FontWeight.Bold : FontWeight.Normal)
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .height(56)
      .onClick(() => {
        if (this.activeTab !== 'learning') {
          router.pushUrl({ url: 'pages/LearningHome' });
        }
      })
      .accessibilityText('学习标签')

      // Tab: Assess
      Column() {
        Text('\u{1F4CA}')
          .fontSize(22)
        Text('测评')
          .fontSize(10)
          .fontColor(this.activeTab === 'assessment' ? '#5C6BC0' : 'rgba(255,255,255,0.4)')
          .fontWeight(this.activeTab === 'assessment' ? FontWeight.Bold : FontWeight.Normal)
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .height(56)
      .onClick(() => {
        if (this.activeTab !== 'assessment') {
          router.pushUrl({ url: 'pages/AssessmentResult' });
        }
      })
      .accessibilityText('测评标签')

      // Tab: Profile
      Column() {
        Text('\u{1F464}')
          .fontSize(22)
        Text('我的')
          .fontSize(10)
          .fontColor(this.activeTab === 'profile' ? '#5C6BC0' : 'rgba(255,255,255,0.4)')
          .fontWeight(this.activeTab === 'profile' ? FontWeight.Bold : FontWeight.Normal)
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .height(56)
      .onClick(() => {
        if (this.activeTab !== 'profile') {
          router.pushUrl({ url: 'pages/ProfilePage' });
        }
      })
      .accessibilityText('我的标签')
    }
    .width('100%')
    .height(56)
    .backgroundColor('rgba(13,17,46,0.95)')
    .border({ width: 0.5, color: 'rgba(255,255,255,0.06)' })
  }
}
