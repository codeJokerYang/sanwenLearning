/**
 * ManualInputBox — 真人作答防呆输入框
 * FEATURE_RULES.md: 禁粘贴 / 禁长按菜单 / 速度检测
 * 架构：纯展示+回调组件，严禁导入 Services/RdbHelper
 */
import { ANTI_CHEAT_CONFIG } from '../common/Config';

@Component
export struct ManualInputBox {
  @State inputValue: string = '';
  private inputStartTime: number = 0;
  private hasStartedInput: boolean = false;
  onSubmit?: (value: string) => void;

  /**
   * 防呆：计算输入速度（字/分钟）
   * @returns true if suspect (超过150字/分钟阈值)
   */
  private detectCheat(textLength: number): boolean {
    if (textLength < ANTI_CHEAT_CONFIG.SHORT_TEXT_EXEMPTION) {
      return false;
    }
    if (this.inputStartTime > 0) {
      const elapsedMs: number = Date.now() - this.inputStartTime;
      const elapsedMin: number = elapsedMs / 60000;
      if (elapsedMin > 0) {
        const speed: number = Math.round(textLength / elapsedMin);
        return speed > ANTI_CHEAT_CONFIG.SPEED_THRESHOLD;
      }
    }
    return false;
  }

  build() {
    TextInput({ text: this.inputValue, placeholder: $r('app.string.manual_input_placeholder') })
      .type(InputType.Normal)
      .copyOption(CopyOptions.None)
      .onPaste((content: string) => {
        // FEATURE_RULES: 最佳努力拦截粘贴，直接 return
        return;
      })
      .onChange((value: string) => {
        this.inputValue = value;
        // FEATURE_RULES: 首次输入时记录开始时间
        if (!this.hasStartedInput && value.length > 0) {
          this.inputStartTime = Date.now();
          this.hasStartedInput = true;
        }
      })
      .onSubmit((enterKey: EnterKeyType) => {
        if (this.inputValue.length === 0) {
          return;
        }
        const isSuspect: boolean = this.detectCheat(this.inputValue.length);
        if (this.onSubmit) {
          this.onSubmit(this.inputValue);
        }
        // Reset state after submit
        this.inputValue = '';
        this.inputStartTime = 0;
        this.hasStartedInput = false;
      })
      .accessibilityText($r('app.string.manual_input_accessibility'))
      .accessibilityDescription($r('app.string.a11y_manual_input_desc'))
      .width('100%')
      .height(48)
      .fontSize(15)
      .padding({ left: 14, right: 14 })
      .borderRadius(14)
      .backgroundColor('rgba(255,255,255,0.06)')
      .placeholderColor('rgba(255,255,255,0.25)')
      .fontColor('#FFFFFF')
      .border({ width: 0.5, color: 'rgba(255,255,255,0.08)' })
  }
}
