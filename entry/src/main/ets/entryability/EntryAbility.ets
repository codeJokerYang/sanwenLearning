 import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AIConcurrencyLock } from '../services/AIConcurrencyLock';
import { AIService } from '../services/AIService';
import { NetworkMonitor } from '../services/NetworkMonitor';
import { AnalyticsService } from '../services/AnalyticsService';
import { RdbHelper } from '../db/RdbHelper';
import { Logger } from '../common/Logger';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private dbInitPromise: Promise<void> | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    // [冷启动初始化] 1. Logger 初始化（必须在最前面，后续组件依赖日志）
    try {
      Logger.getInstance().init(this.context);
      hilog.info(DOMAIN, 'ENTRY', 'Logger initialized');
    } catch (e) {
      hilog.warn(DOMAIN, 'ENTRY', `Logger init failed: ${JSON.stringify(e)}`);
    }

    // [冷启动初始化] 2. 数据库初始化（异步，必须在页面加载前完成）
    this.dbInitPromise = RdbHelper.getInstance().init(this.context);
    this.dbInitPromise.then(() => {
      hilog.info(DOMAIN, 'ENTRY', 'RdbHelper init completed');
    }).catch((e: Error) => {
      hilog.error(DOMAIN, 'ENTRY', `RdbHelper init failed: ${e.message}`);
    });

    // [冷启动初始化] 3. AIService 初始化（赋值 context，ensureApiKeyStored 异步不阻塞）
    try {
      AIService.getInstance().init(this.context);
      hilog.info(DOMAIN, 'ENTRY', 'AIService initialized');
    } catch (e) {
      hilog.warn(DOMAIN, 'ENTRY', `AIService init failed: ${JSON.stringify(e)}`);
    }

    // [冷启动初始化] 4. 清空 AI 并发残留锁（防止上次异常退出导致的脏锁）
    try {
      AIConcurrencyLock.getInstance().clearAllOnColdStart();
      hilog.info(DOMAIN, 'ENTRY', 'AI concurrency locks cleared on cold start');
    } catch (e) {
      hilog.warn(DOMAIN, 'ENTRY', `AIConcurrencyLock init failed: ${JSON.stringify(e)}`);
    }

    // [冷启动初始化] 4. 启动网络状态监听
    try {
      NetworkMonitor.getInstance().startMonitoring();
      hilog.info(DOMAIN, 'ENTRY', 'Network monitor started');
    } catch (e) {
      hilog.warn(DOMAIN, 'ENTRY', `NetworkMonitor init failed: ${JSON.stringify(e)}`);
    }

    // [冷启动初始化] 5. 冷启动 Analytics 清理（90天过期事件）
    try {
      AnalyticsService.getInstance().init();
      hilog.info(DOMAIN, 'ENTRY', 'Analytics service initialized');
    } catch (e) {
      hilog.warn(DOMAIN, 'ENTRY', `AnalyticsService init failed: ${JSON.stringify(e)}`);
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 等待数据库初始化完成后再加载页面，避免页面访问未初始化的 DB 导致闪退
    const loadPage = (): void => {
      windowStage.loadContent('pages/HomePage', (err) => {
        if (err.code) {
          hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
          return;
        }
        hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      });
    };

    if (this.dbInitPromise) {
      this.dbInitPromise.then(() => {
        loadPage();
      }).catch(() => {
        // 即使 DB 初始化失败，也要加载页面（页面有降级处理）
        loadPage();
      });
    } else {
      loadPage();
    }
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
