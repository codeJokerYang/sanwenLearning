/**
 * LearningHome — 学习页（课程列表）
 * 原 HomePage 课程列表内容迁移至此
 * 遵循 MVVM: Pages→ViewModels ONLY
 */
import { HomeViewModel } from '../viewmodels/HomeViewModel';
import { CourseCard } from '../components/CourseCard';
import { DeleteConfirmDialog } from '../components/DeleteConfirmDialog';
import { CreateCourseDialog } from '../components/CreateCourseDialog';
import { Course } from '../models/Models';
import { router } from '@kit.ArkUI';
import { ErrorCode, errorCodeToResource } from '../common/ErrorCode';
import { DynamicBackground } from '../components/DynamicBackground';
import { AIChatFab } from '../components/AIChatFab';
import { AIChatPanel } from '../components/AIChatPanel';
import { BottomTabBar } from '../components/BottomTabBar';

@Entry
@Component
struct LearningHome {
  @State courseList: Course[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: ResourceStr = '';
  @State pageStatus: 'loading' | 'empty' | 'error' | 'content' = 'loading';
  @State searchQuery: string = '';
  @State deleteTargetId: string = '';
  @State newCourseTitle: string = '';
  @State chatOpen: boolean = false;
  private viewModel: HomeViewModel = new HomeViewModel();
  private isDestroyed: boolean = false;

  private deleteDialogController: CustomDialogController = new CustomDialogController({
    builder: DeleteConfirmDialog({
      onConfirm: () => {
        this.onDeleteConfirm();
      },
      onCancel: () => {}
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: false
  });

  private createDialogController: CustomDialogController = new CustomDialogController({
    builder: CreateCourseDialog({
      onTitleChange: (value: string) => {
        this.newCourseTitle = value;
      },
      onConfirm: () => {
        this.onCreateCourse();
      },
      onCancel: () => {}
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: false
  });

  aboutToAppear(): void {
    this.isLoading = true;
    this.loadCourses();
  }

  aboutToDisappear(): void {
    this.isDestroyed = true;
  }

  private async loadCourses(): Promise<void> {
    this.isLoading = true;
    this.pageStatus = 'loading';
    this.errorMessage = '';
    try {
      await this.viewModel.loadCourses();
      if (this.isDestroyed) return;
      this.courseList = this.viewModel.courseList ?? [];
      if (this.courseList.length === 0) {
        this.pageStatus = 'empty';
      } else {
        this.pageStatus = 'content';
      }
    } catch (e) {
      if (this.isDestroyed) return;
      this.courseList = [];
      const errCode = (e instanceof Error) ? e.message : '';
      if (errCode === ErrorCode.NETWORK_DISCONNECTED) {
        AlertDialog.show({
          message: errorCodeToResource(ErrorCode.NETWORK_DISCONNECTED),
          autoCancel: false,
          buttons: [{
            value: $r('app.string.home_delete_confirm_cancel'),
            action: () => {}
          }]
        });
        this.errorMessage = errorCodeToResource(ErrorCode.NETWORK_DISCONNECTED);
        this.pageStatus = 'error';
      } else {
        this.errorMessage = errorCodeToResource(ErrorCode.COURSE_LOAD_FAILED);
        this.pageStatus = 'error';
      }
    } finally {
      if (!this.isDestroyed) {
        this.isLoading = false;
      }
    }
  }

  private getFilteredCourses(): Course[] {
    const list: Course[] = this.courseList ?? [];
    if (!this.searchQuery || this.searchQuery.trim().length === 0) {
      return list;
    }
    const q: string = this.searchQuery.trim().toLowerCase();
    return list.filter((c: Course) => c.title.toLowerCase().includes(q));
  }

  private onCardClick(courseId: string): void {
    try {
      router.pushUrl({
        url: 'pages/LearningSpace',
        params: { courseId: courseId }
      });
    } catch (e) {
      this.errorMessage = $r('app.string.err_course_load_failed');
    }
  }

  private onDeleteClick(courseId: string): void {
    this.deleteTargetId = courseId;
    this.deleteDialogController.open();
  }

  private onDeleteConfirm(): void {
    this.deleteCourse(this.deleteTargetId);
  }

  private async deleteCourse(courseId: string): Promise<void> {
    this.isLoading = true;
    try {
      await this.viewModel.deleteCourse(courseId);
      if (this.isDestroyed) return;
      this.courseList = this.viewModel.courseList ?? [];
    } catch (e) {
      if (this.isDestroyed) return;
      this.errorMessage = errorCodeToResource(ErrorCode.COURSE_DELETE_FAILED);
    } finally {
      if (!this.isDestroyed) {
        this.isLoading = false;
      }
    }
  }

  private onFabClick(): void {
    this.newCourseTitle = '';
    this.createDialogController.open();
  }

  private async onCreateCourse(): Promise<void> {
    if (!this.newCourseTitle || this.newCourseTitle.trim().length === 0) {
      return;
    }
    this.isLoading = true;
    try {
      const result: Course | null = await this.viewModel.createCourse(this.newCourseTitle.trim());
      if (this.isDestroyed) return;
      if (result === null) {
        // ViewModel 内部 catch 了异常，检查 errorMessage
        const vmError: ResourceStr = this.viewModel.errorMessage;
        this.errorMessage = vmError || errorCodeToResource(ErrorCode.COURSE_CREATE_FAILED);
      } else {
        this.courseList = this.viewModel.courseList ?? [];
      }
    } catch (e) {
      if (this.isDestroyed) return;
      this.errorMessage = errorCodeToResource(ErrorCode.COURSE_CREATE_FAILED);
    } finally {
      if (!this.isDestroyed) {
        this.isLoading = false;
      }
    }
  }

  build() {
    Stack() {
      // Layer 1: Dynamic gradient background
      DynamicBackground()
        .width('100%')
        .height('100%')

      // Layer 2: Scrim
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(8,12,30,0.35)')

      // Layer 3: Scrollable content
      Scroll() {
        Column() {
          // Top safe area for fixed header
          Blank().height(120)

          // Section Title
          Row() {
            Text($r('app.string.home_my_courses'))
              .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF').layoutWeight(1)
            if (this.courseList.length > 0) {
              Text(`${this.courseList.length}\u95E8`)
                .fontSize(11).fontColor('rgba(255,255,255,0.55)')
                .backgroundColor('rgba(255,255,255,0.08)')
                .padding({ left: 10, right: 10, top: 3, bottom: 3 }).borderRadius(12)
            }
          }
          .width('100%').padding({ left: 20, right: 20, top: 8, bottom: 10 })

          // Course List / Empty / Error
          if (this.pageStatus === 'loading' && this.courseList.length === 0) {
            ForEach([0, 1, 2], (skeletonIdx: number, index: number) => {
              Column()
                .width('100%').height(96)
                .margin({ left: 20, right: 20, top: 6, bottom: 6 })
                .borderRadius(16).backgroundColor('rgba(255,255,255,0.05)')
            }, (index: number) => `skeleton_${index}`)
          } else if (this.pageStatus === 'empty' || this.courseList.length === 0) {
            Column() {
              Blank().height(40)
              Stack() {
                Circle({ width: 90, height: 90 }).fill('rgba(124,77,255,0.08)')
                Circle({ width: 64, height: 64 }).fill('rgba(124,77,255,0.12)')
                Text('?').fontSize(32).fontWeight(FontWeight.Bold).fontColor('#B388FF')
              }.width(90).height(90)
              Blank().height(20)
              Text($r('app.string.home_empty_message')).fontSize(16).fontColor('rgba(255,255,255,0.7)').textAlign(TextAlign.Center)
              Blank().height(8)
              Text('\u521B\u5EFA\u4F60\u7684\u7B2C\u4E00\u95E8\u8BFE\u7A0B\uFF0C\u5F00\u59CB\u4E09\u95EE\u63A2\u7D22\u4E4B\u65C5')
                .fontSize(13).fontColor('rgba(255,255,255,0.4)').textAlign(TextAlign.Center)
              Blank().height(28)
              Button($r('app.string.home_empty_action'))
                .fontSize(15).fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
                .backgroundColor('#5C6BC0').borderRadius(22).width(160).height(44)
                .shadow({ radius: 14, color: '#40000000', offsetX: 0, offsetY: 6 })
                .onClick(() => { this.onFabClick(); })
              Blank().height(60)
            }
            .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).padding({ left: 32, right: 32 })
          } else if (this.pageStatus === 'error') {
            Column() {
              Blank().height(50)
              Stack() {
                Circle({ width: 64, height: 64 }).fill('rgba(255,59,48,0.08)')
                Text('!').fontSize(28).fontWeight(FontWeight.Bold).fontColor('#FF6B6B')
              }.width(64).height(64)
              Blank().height(16)
              Text(this.errorMessage as string || '\u52A0\u8F7D\u5931\u8D25\uFF0C\u8BF7\u91CD\u8BD5')
                .fontSize(15).fontColor('rgba(255,255,255,0.65)').textAlign(TextAlign.Center)
              Blank().height(20)
              Button($r('app.string.assessment_retry'))
                .fontSize(14).fontColor('#FFFFFF')
                .backgroundColor('rgba(255,255,255,0.12)').borderRadius(18).height(38)
                .padding({ left: 20, right: 20 }).onClick(() => { this.loadCourses(); })
              Blank().height(80)
            }
            .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          } else {
            List() {
              ForEach(this.getFilteredCourses(), (course: Course, index: number) => {
                ListItem() {
                  CourseCard({
                    course: course, isDarkMode: true,
                    onCardClick: () => { this.onCardClick(course.id); },
                    onDeleteClick: () => { this.onDeleteClick(course.id); }
                  })
                }.margin({ left: 20, right: 20, top: 6, bottom: 6 })
              }, (course: Course) => course.id)
            }
            .width('100%').listDirection(Axis.Vertical).divider({ strokeWidth: 0 })
          }

          Blank().height(88)
        }
        .width('100%')
      }
      .width('100%').height('100%').scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)

      // Layer 4: Fixed top header (Header + SearchBar)
      Column() {
        // Header Row: Brand + Count + Settings + New
        Row() {
          Column() {
            Text('三问智学')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text('提问 · 探索 · 成长')
              .fontSize(13)
              .fontColor('rgba(255,255,255,0.5)')
              .margin({ top: 3 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          if (this.courseList.length > 0) {
            Stack() {
              Circle({ width: 36, height: 36 })
                .fill('rgba(255,255,255,0.10)')
              Text(`${this.courseList.length}`)
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
            }
            .width(36).height(36)
          } else {
            Stack() {
              Circle({ width: 36, height: 36 })
                .fill('rgba(124,77,255,0.15)')
              Text('?').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#B388FF')
            }
            .width(36).height(36)
          }

          // Settings button
          Button() {
            Text('\u2699').fontSize(20).fontColor('rgba(255,255,255,0.7)')
          }
          .width(36).height(36)
          .backgroundColor('rgba(255,255,255,0.10)').borderRadius(18)
          .margin({ left: 8 })
          .onClick(() => { router.pushUrl({ url: 'pages/SettingsPage' }); })

          // New course button (moved from FAB)
          Button() {
            Text('+').fontSize(20).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
          }
          .width(36).height(36)
          .linearGradient({ angle: 135, colors: [['#5C6BC0', 0], ['#3949AB', 1]] })
          .borderRadius(18)
          .margin({ left: 8 })
          .onClick(() => { this.onFabClick(); })
          .accessibilityText($r('app.string.home_create_course'))
        }
        .width('100%').justifyContent(FlexAlign.SpaceBetween)

        Blank().height(16)

        // SearchBar (sticky)
        Row() {
          Text('\u{1F50D}').fontSize(15).margin({ right: 10 }).fontColor('rgba(255,255,255,0.4)')
          TextInput({ text: this.searchQuery, placeholder: '\u641C\u7D22\u8BFE\u7A0B...' })
            .onChange((value: string) => { this.searchQuery = value; })
            .layoutWeight(1).height(42).fontSize(15)
            .padding({ left: 6, right: 14 }).borderRadius(21)
            .backgroundColor('rgba(255,255,255,0.09)')
            .placeholderColor('rgba(255,255,255,0.3)').fontColor('#FFFFFF')
            .border({ width: 1, color: 'rgba(255,255,255,0.08)' })
            .accessibilityText($r('app.string.a11y_search_input'))
        }.width('100%')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 24, bottom: 12 })
      .linearGradient({
        angle: 180,
        colors: [
          ['rgba(13,27,62,0.98)', 0],
          ['rgba(13,27,62,0.95)', 0.7],
          ['rgba(13,27,62,0.85)', 1]
        ]
      })
      .position({ top: 0, left: 0 })

      // Error toast
      if (this.errorMessage && this.pageStatus !== 'error') {
        Text(this.errorMessage)
          .fontSize(13).fontColor('#FFB3BA')
          .width('100%').padding(12).textAlign(TextAlign.Center)
          .backgroundColor('rgba(20,10,40,0.88)')
          .position({ bottom: 84, left: 16, right: 16 }).borderRadius(14)
          .shadow({ radius: 10, color: '#20000000', offsetY: 3 })
      }

      // AI Chat FAB (repositioned to avoid overlap)
      AIChatFab({ isOpen: this.chatOpen, hasActiveCourse: this.courseList.length > 0 })
        .position({ right: 16, bottom: 88 })
      AIChatPanel({ isOpen: this.chatOpen })
        .position({ x: 0, y: this.chatOpen ? '30%' : '100%' }).width('100%')

      // Bottom TabBar - learning tab active
      BottomTabBar({ activeTab: 'learning' })
        .position({ bottom: 0, left: 0 })
    }
    .width('100%').height('100%')
  }
}

export { LearningHome };
