/**
 * ProfilePage — 我的个人中心
 * Scrollable page: ProfileHeader → StatsRow → BadgeSection → SettingList
 * 白色主题：浅灰背景 + 白色卡片 + 深色文字
 */
import { ProfileHeader } from '../components/ProfileHeader';
import { StatsCard } from '../components/StatsCard';
import { BadgeItem } from '../components/BadgeItem';
import { SettingRow } from '../components/SettingRow';
import { BottomTabBar } from '../components/BottomTabBar';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

interface BadgeData {
  icon: string;
  name: string;
  desc: string;
  unlocked: boolean;
}

@Entry
@Component
struct ProfilePage {
  @State courseCount: number = 0;
  @State completedCount: number = 0;
  @State studyDays: number = 0;
  @State avgScore: string = '--';
  @State badges: BadgeData[] = [];

  aboutToAppear(): void {
    this.courseCount = 3;
    this.completedCount = 1;
    this.studyDays = 7;
    this.avgScore = '85';
    this.badges = [
      { icon: '\u2B50', name: '初学者', desc: '创建第一个课程', unlocked: true },
      { icon: '\u{1F3C6}', name: '三问达人', desc: '完成三问全流程', unlocked: false },
      { icon: '\u{1F525}', name: '学习先锋', desc: '累计学习7天', unlocked: true },
    ];
  }

  build() {
    Stack() {
      // Background
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#F5F7FA')

      // Foreground scrollable content
      Scroll() {
        Column() {
          // 1. Profile Header
          ProfileHeader({
            userName: '三问智学员',
            userBio: '用三问法，深度理解每一个知识',
            onAvatarClick: () => {
              promptAction.showToast({ message: '功能开发中' });
            }
          })

          Blank().height(16)

          // 2. Stats Row
          Row() {
            StatsCard({ icon: '\u{1F4DA}', value: `${this.courseCount}`, label: '课程数' })
            StatsCard({ icon: '\u2705', value: `${this.completedCount}`, label: '已完成' })
            StatsCard({ icon: '\u{1F4C5}', value: `${this.studyDays}`, label: '学习天数' })
            StatsCard({ icon: '\u{1F3AF}', value: this.avgScore, label: '平均分' })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .justifyContent(FlexAlign.SpaceBetween)

          Blank().height(16)

          // 3. Badge Section
          Column() {
            Row() {
              Text('\u{1F3C6}')
                .fontSize(18)
                .margin({ right: 8 })
              Text('成就勋章')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A2E')
            }
            .width('100%')
            .margin({ bottom: 12 })

            Row() {
              ForEach(this.badges, (badge: BadgeData, index: number) => {
                BadgeItem({
                  icon: badge.icon,
                  name: badge.name,
                  desc: badge.desc,
                  unlocked: badge.unlocked,
                  marginL: index > 0 ? 12 : 0
                })
              }, (badge: BadgeData, index: number) => `badge_${index}`)
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
          }
          .width('100%')
          .padding(16)
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .shadow({
            radius: 8,
            color: 'rgba(0, 0, 0, 0.04)',
            offsetX: 0,
            offsetY: 2
          })
          .shadow({
            radius: 16,
            color: 'rgba(0, 0, 0, 0.02)',
            offsetX: 0,
            offsetY: 4
          })
          .margin({ left: 16, right: 16 })

          Blank().height(16)

          // 4. Settings Section
          Column() {
            Row() {
              Text('\u2699')
                .fontSize(18)
                .margin({ right: 8 })
              Text('设置')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A2E')
            }
            .width('100%')
            .margin({ bottom: 4 })

            SettingRow({
              icon: '\u{1F3A8}',
              title: '主题皮肤',
              value: '宇宙蓝',
              showDivider: true,
              onRowClick: () => {
                promptAction.showToast({ message: '功能开发中' });
              }
            })

            SettingRow({
              icon: '\u{1F510}',
              title: 'API 配置',
              value: '已配置',
              showDivider: true,
              onRowClick: () => {
                router.pushUrl({ url: 'pages/SettingsPage' });
              }
            })

            SettingRow({
              icon: '\u2139',
              title: '关于三问智学',
              value: 'v1.0.0',
              showDivider: false,
              onRowClick: () => {
                AlertDialog.show({
                  title: '关于三问智学',
                  message: '三问高效学习机 v1.0.0\n基于苏格拉底提问法与布鲁姆分类学\n\u00A9 2026 三问智学团队',
                  autoCancel: true,
                  buttons: [{
                    value: '确定',
                    action: () => {}
                  }]
                });
              }
            })
          }
          .width('100%')
          .padding(16)
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .shadow({
            radius: 8,
            color: 'rgba(0, 0, 0, 0.04)',
            offsetX: 0,
            offsetY: 2
          })
          .shadow({
            radius: 16,
            color: 'rgba(0, 0, 0, 0.02)',
            offsetX: 0,
            offsetY: 4
          })
          .margin({ left: 16, right: 16 })

          // Bottom safe area
          Blank().height(32)
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      // Bottom TabBar
      BottomTabBar({ activeTab: 'profile' })
        .position({ bottom: 0, left: 0 })
    }
    .width('100%')
    .height('100%')
  }
}

export { ProfilePage };
