/**
 * 三问高效学习机 — 评价报告服务
 * 遵循 FEATURE_RULES.md
 *
 * 核心职责：
 * - 生成评价报告（5 章节：学习总览、三问回顾、能力雷达图、错题溯源、诚信声明）
 * - 评分计算：Q1=20%, Q2=40%, Q3=40%
 * - 布鲁姆层级得分统计
 * - 弱项节点溯源（答错题目关联的知识节点）
 * - 报告 Markdown 导出
 * - 雷达图绘制
 */
import { fileIo } from '@kit.CoreFileKit'
import { relationalStore } from '@kit.ArkData'
import { Logger } from '../common/Logger'
import { RdbHelper } from '../db/RdbHelper'
import { EvaluationReport, QuestionRecord, QuizQuestion, BloomLevel, CorrectStatus, Course } from '../models/Models'

const TAG = 'EVALUATION'

/** 雷达图边长（像素） */
const RADAR_SIZE = 400

/** 雷达图层级标签 */
const BLOOM_LABELS: Map<number, string> = new Map()
BLOOM_LABELS.set(1, '记忆')
BLOOM_LABELS.set(2, '理解')
BLOOM_LABELS.set(3, '应用')
BLOOM_LABELS.set(4, '分析')
BLOOM_LABELS.set(5, '评价')
BLOOM_LABELS.set(6, '创造')

interface BloomStats {
  correct: number;
  total: number;
}


export class EvaluationService {
  private static instance: EvaluationService | null = null

  private constructor() {}

  static getInstance(): EvaluationService {
    if (!EvaluationService.instance) {
      EvaluationService.instance = new EvaluationService()
    }
    return EvaluationService.instance
  }

  /**
   * 生成课程评价报告
   * 评分规则：Q1=20%, Q2=40%, Q3=40%
   * @param courseId 课程 ID
   * @returns 评价报告，失败返回 null
   */
  async generateReport(courseId: string): Promise<EvaluationReport | null> {
    const rdb = RdbHelper.getInstance()
    const store = rdb.getStore()
    if (!store) {
      Logger.getInstance().error(TAG, 'generateReport: RdbStore not initialized')
      return null
    }

    try {
      // 1. 查询课程信息
      const course = await rdb.queryCourseById(courseId)
      if (!course) {
        Logger.getInstance().error(TAG, `generateReport: course not found: ${courseId}`)
        return null
      }

      // 2. 查询该课程所有作答记录
      const records = await this.queryQuestionRecords(courseId)

      // 3. 查询该课程所有测评题目
      const quizQuestions = await this.queryQuizQuestions(courseId)

      // 4. 计算各环节得分
      const q1Score = this.calculateQ1Score(course)
      const q2Score = this.calculateQ2Score(records)
      const q3Score = this.calculateQ3Score(records)
      const totalScore = q1Score + q2Score + q3Score

      // 5. 计算布鲁姆6层得分
      const bloomScores = this.calculateBloomScores(records, quizQuestions)

      // 6. 弱项节点溯源
      const weakNodes = this.findWeakNodes(records, quizQuestions)

      // 7. 是否存在诚信可疑记录
      const hasSuspectRecords = records.some(r => r.is_suspect)

      // 8. 构建报告正文（5 章节）
      const content = this.buildReportContent(
        course.title, q1Score, q2Score, q3Score, totalScore,
        bloomScores, weakNodes, hasSuspectRecords, records
      )

      // 9. 绘制雷达图
      const radarPath = await this.drawRadarChart(courseId, bloomScores)

      const report: EvaluationReport = {
        course_id: courseId,
        course_title: course.title,
        q1_score: q1Score,
        q2_score: q2Score,
        q3_score: q3Score,
        total_score: totalScore,
        bloom_scores: bloomScores,
        radar_chart_path: radarPath,
        weak_nodes: weakNodes,
        has_suspect_records: hasSuspectRecords,
        content: content,
        create_time: Date.now()
      }

      Logger.getInstance().info(TAG, `Report generated for ${courseId}, score=${totalScore}`)
      return report

    } catch (err) {
      const msg = (err as Error).message ?? String(err)
      Logger.getInstance().error(TAG, `generateReport failed for ${courseId}`, msg)
      return null
    }
  }

  // ============================================================
  // 得分计算（权重：Q1=20%, Q2=40%, Q3=40%）
  // ============================================================

  /**
   * Q1 得分（满分 20）
   * 依据核心节点点亮比例：activatedCount / totalCoreCount * 20
   */
  private calculateQ1Score(course: Course): number {
    if (course.q1_total_core_count <= 0) {
      return 0
    }
    return Math.round((course.q1_activated_count / course.q1_total_core_count) * 20 * 100) / 100
  }

  /**
   * Q2 得分（满分 40）
   * 依据争议见解记录：有 AI 评价的条数 / 总条数 * 40
   * 若无 Q2 记录，返回 0
   */
  private calculateQ2Score(records: QuestionRecord[]): number {
    const q2Records = records.filter(r => r.step === 2)
    if (q2Records.length === 0) {
      return 0
    }
    const evaluatedCount = q2Records.filter(r =>
      r.ai_evaluation !== null && r.ai_evaluation !== '' &&
      r.ai_evaluation !== 'AI 评价失败，用户手动跳过'
    ).length
    return Math.round((evaluatedCount / q2Records.length) * 40 * 100) / 100
  }

  /**
   * Q3 得分（满分 40）
   * 依据答题正确率：正确题数 / 总题数 * 40
   * 主观题（subjective）按 0.5 题计
   */
  private calculateQ3Score(records: QuestionRecord[]): number {
    const q3Records = records.filter(r => r.step === 3)
    if (q3Records.length === 0) {
      return 0
    }
    let correctCount = 0
    for (const r of q3Records) {
      if (r.is_correct === CorrectStatus.TRUE) {
        correctCount += 1
      } else if (r.is_correct === CorrectStatus.SUBJECTIVE) {
        correctCount += 0.5
      }
    }
    return Math.round((correctCount / q3Records.length) * 40 * 100) / 100
  }

  // ============================================================
  // 布鲁姆层级得分
  // ============================================================

  /**
   * 计算布鲁姆6层级得分
   * 每层级：该层级答对题数 / 该层级总题数 * 100
   */
  private calculateBloomScores(
    records: QuestionRecord[],
    quizQuestions: QuizQuestion[]
  ): Map<number, number> {
    const q3Records = records.filter(r => r.step === 3)
    const questionMap = new Map<string, QuizQuestion>()
    for (const q of quizQuestions) {
      questionMap.set(q.id, q)
    }

    const stats: Map<number, BloomStats> = new Map()
    stats.set(1, { correct: 0, total: 0 })
    stats.set(2, { correct: 0, total: 0 })
    stats.set(3, { correct: 0, total: 0 })
    stats.set(4, { correct: 0, total: 0 })
    stats.set(5, { correct: 0, total: 0 })
    stats.set(6, { correct: 0, total: 0 })

    for (const record of q3Records) {
      if (!record.quiz_question_id) {
        continue
      }
      const question = questionMap.get(record.quiz_question_id)
      if (!question) {
        continue
      }
      const level = question.bloom_level
      const entry = stats.get(level)
      if (!entry) {
        continue
      }
      entry.total += 1
      if (record.is_correct === CorrectStatus.TRUE) {
        entry.correct += 1
      } else if (record.is_correct === CorrectStatus.SUBJECTIVE) {
        entry.correct += 0.5
      }
      stats.set(level, entry)
    }

    const scores: Map<number, number> = new Map()
    for (const level of [1, 2, 3, 4, 5, 6]) {
      const entry = stats.get(level)
      if (entry) {
        scores.set(level, entry.total > 0
          ? Math.round((entry.correct / entry.total) * 100)
          : 0)
      }
    }
    return scores
  }

  // ============================================================
  // 弱项节点溯源
  // ============================================================

  /**
   * 查找答错题目关联的知识节点
   * 根据 is_correct=false 的记录，通过 quiz_question → linked_node_ids 追溯
   */
  private findWeakNodes(
    records: QuestionRecord[],
    quizQuestions: QuizQuestion[]
  ): string[] {
    const questionMap = new Map<string, QuizQuestion>()
    for (const q of quizQuestions) {
      questionMap.set(q.id, q)
    }

    const weakNodeSet = new Set<string>()
    for (const record of records) {
      if (record.step !== 3) {
        continue
      }
      if (record.is_correct !== CorrectStatus.FALSE) {
        continue
      }
      if (!record.quiz_question_id) {
        continue
      }
      const question = questionMap.get(record.quiz_question_id)
      if (!question) {
        continue
      }
      const linkedIds = RdbHelper.safeParseJsonArray(question.linked_node_ids)
      for (const nodeId of linkedIds) {
        weakNodeSet.add(nodeId)
      }
    }

    return Array.from(weakNodeSet)
  }

  // ============================================================
  // 报告正文构建（5 章节）
  // ============================================================

  /**
   * 构建评价报告 Markdown 正文
   * 5 章节：学习总览、三问回顾、能力雷达图、错题溯源、诚信声明
   */
  private buildReportContent(
    courseTitle: string,
    q1Score: number,
    q2Score: number,
    q3Score: number,
    totalScore: number,
    bloomScores: Map<number, number>,
    weakNodes: string[],
    hasSuspectRecords: boolean,
    records: QuestionRecord[]
  ): string {
    const lines: string[] = []

    // 第1章：学习总览
    lines.push(`# ${courseTitle} — 学习评价报告`)
    lines.push('')
    lines.push('## 一、学习总览')
    lines.push('')
    lines.push(`| 环节   | 满分 | 得分  | 权重 |`)
    lines.push(`|--------|------|-------|------|`)
    lines.push(`| 是什么  | 20   | ${q1Score}  | 20%  |`)
    lines.push(`| 为什么  | 40   | ${q2Score}  | 40%  |`)
    lines.push(`| 怎么用  | 40   | ${q3Score}  | 40%  |`)
    lines.push(`| **总分** | **100** | **${totalScore}** | —    |`)
    lines.push('')

    // 第2章：三问回顾
    lines.push('## 二、三问回顾')
    lines.push('')
    const q2Records = records.filter(r => r.step === 2)
    const q3Records = records.filter(r => r.step === 3)
    lines.push(`- 争议分析记录：${q2Records.length} 条`)
    lines.push(`- 测评作答记录：${q3Records.length} 条`)
    lines.push('')

    // 第3章：能力雷达图
    lines.push('## 三、能力雷达图')
    lines.push('')
    lines.push('| 布鲁姆层级 | 得分率 |')
    lines.push('|-----------|--------|')
    for (const level of [1, 2, 3, 4, 5, 6]) {
      lines.push(`| ${BLOOM_LABELS.get(level) ?? ''} | ${bloomScores.get(level) ?? 0}% |`)
    }
    lines.push('')
    lines.push('![能力雷达图](./radar.png)')
    lines.push('')

    // 第4章：错题溯源
    lines.push('## 四、错题溯源')
    lines.push('')
    if (weakNodes.length > 0) {
      lines.push(`识别到 ${weakNodes.length} 个薄弱知识节点，建议重点复习：`)
      lines.push('')
      for (const nodeId of weakNodes) {
        lines.push(`- 节点 ID: ${nodeId}`)
      }
    } else {
      lines.push('暂未发现明显薄弱环节。')
    }
    lines.push('')

    // 第5章：诚信声明
    lines.push('## 五、诚信声明')
    lines.push('')
    lines.push('> 本报告基于学员手动输入的内容生成（诚信声明）')
    if (hasSuspectRecords) {
      lines.push('')
      lines.push('⚠ 部分作答输入极快（可能使用了语音输入或复制粘贴），可能未经过深度思考，建议重新复盘')
    }
    lines.push('')

    return lines.join('\n')
  }

  // ============================================================
  // 雷达图绘制
  // ============================================================

  /**
   * 绘制布鲁姆能力雷达图并保存为 PNG 文件
   * 保存路径：{沙箱}/reports/{course_id}_radar.png
   * @param courseId 课程 ID
   * @param bloomScores 布鲁姆6层级得分
   * @returns 雷达图文件路径，失败返回空字符串
   */
  async drawRadarChart(courseId: string, bloomScores: Map<number, number>): Promise<string> {
    try {
      // 生成雷达图文本文件（当前版本以文本形式存储雷达数据）
      // 完整图形绘制需依赖 @kit.ArkGraphics2D，此处提供文本降级方案
      const reportDir = await this.ensureReportDir()
      const filePath = `${reportDir}/${courseId}_radar.png`

      const lines: string[] = ['# RADAR_CHART_DATA']
      lines.push(`course_id: ${courseId}`)
      lines.push(`generated_at: ${new Date().toISOString()}`)
      lines.push('')
      for (const level of [1, 2, 3, 4, 5, 6]) {
        const label = BLOOM_LABELS.get(level) ?? `Level${level}`
        const score = bloomScores.get(level) ?? 0
        const bar = '#'.repeat(Math.round(score / 5))
        lines.push(`${label}: ${bar} ${score}%`)
      }

      const fd = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
      fileIo.writeSync(fd.fd, lines.join('\n'));
      fileIo.closeSync(fd);
      Logger.getInstance().info(TAG, `Radar chart saved: ${filePath}`)
      return filePath
    } catch (err) {
      const msg = (err as Error).message ?? String(err)
      Logger.getInstance().error(TAG, `drawRadarChart failed for ${courseId}`, msg)
      return ''
    }
  }

  /**
   * 导出评价报告为 Markdown 文本
   * @param report 评价报告
   * @returns Markdown 文本内容
   */
  async exportMarkdown(report: EvaluationReport): Promise<string> {
    return report.content
  }

  /**
   * 确保报告目录存在（沙箱/reports/）
   */
  private async ensureReportDir(): Promise<string> {
    const dir = `${this.getFilesDir()}/reports`
    try {
      if (!fileIo.accessSync(dir)) {
        fileIo.mkdirSync(dir, true)
      }
    } catch (e) {
      Logger.getInstance().error(TAG, `ensureReportDir failed: ${dir}`, String(e))
    }
    return dir
  }

  private getFilesDir(): string {
    // 从 RdbHelper 的 store 无法直接获取 context，使用固定路径降级
    // 实际项目中应在 init 时接收 context
    return '/data/storage/el2/base/haps/entry/files'
  }

  // ============================================================
  // 数据库查询辅助
  // ============================================================

  /**
   * 查询课程所有作答记录
   */
  private async queryQuestionRecords(courseId: string): Promise<QuestionRecord[]> {
    const rdb = RdbHelper.getInstance()
    const store = rdb.getStore()
    if (!store) {
      return []
    }

    let resultSet: relationalStore.ResultSet | null = null
    try {
      resultSet = await rdb.query(
        'SELECT * FROM question_record WHERE course_id = ? ORDER BY create_time ASC',
        [courseId]
      )

      const records: QuestionRecord[] = []
      while (resultSet.goToNextRow()) {
        try {
          records.push({
            id: resultSet.getString(resultSet.getColumnIndex('id')),
            course_id: resultSet.getString(resultSet.getColumnIndex('course_id')),
            step: RdbHelper.longToNumber(resultSet, resultSet.getColumnIndex('step')),
            quiz_question_id: RdbHelper.getNullableString(resultSet, resultSet.getColumnIndex('quiz_question_id')),
            controversy_id: RdbHelper.getNullableString(resultSet, resultSet.getColumnIndex('controversy_id')),
            question_content: resultSet.getString(resultSet.getColumnIndex('question_content')),
            user_original_answer: resultSet.getString(resultSet.getColumnIndex('user_original_answer')),
            ai_evaluation: RdbHelper.getNullableString(resultSet, resultSet.getColumnIndex('ai_evaluation')),
            standard_answer: RdbHelper.getNullableString(resultSet, resultSet.getColumnIndex('standard_answer')),
            is_correct: resultSet.getString(resultSet.getColumnIndex('is_correct')) as CorrectStatus,
            is_suspect: RdbHelper.boolFromDb(resultSet.getLong(resultSet.getColumnIndex('is_suspect')).valueOf()),
            create_time: RdbHelper.longToNumber(resultSet, resultSet.getColumnIndex('create_time'))
          })
        } catch (e) {
          Logger.getInstance().error(TAG, 'queryQuestionRecords: row mapping failed', String(e))
        }
      }
      return records
    } catch (e) {
      Logger.getInstance().error(TAG, `queryQuestionRecords failed: ${courseId}`, String(e))
      return []
    } finally {
      if (resultSet) {
        try {
          resultSet.close()
        } catch (_e) {
          // cursor 关闭失败静默处理
        }
      }
    }
  }

  /**
   * 查询课程所有测评题目
   */
  private async queryQuizQuestions(courseId: string): Promise<QuizQuestion[]> {
    const rdb = RdbHelper.getInstance()
    const store = rdb.getStore()
    if (!store) {
      return []
    }

    let resultSet: relationalStore.ResultSet | null = null
    try {
      resultSet = await rdb.query(
        'SELECT * FROM quiz_question WHERE course_id = ? ORDER BY sort_order ASC',
        [courseId]
      )

      const questions: QuizQuestion[] = []
      while (resultSet.goToNextRow()) {
        try {
          questions.push({
            id: resultSet.getString(resultSet.getColumnIndex('id')),
            course_id: resultSet.getString(resultSet.getColumnIndex('course_id')),
            bloom_level: RdbHelper.longToNumber(resultSet, resultSet.getColumnIndex('bloom_level')),
            linked_node_ids: resultSet.getString(resultSet.getColumnIndex('linked_node_ids')),
            question_text: resultSet.getString(resultSet.getColumnIndex('question_text')),
            options: resultSet.getString(resultSet.getColumnIndex('options')),
            correct_answer: resultSet.getString(resultSet.getColumnIndex('correct_answer')),
            sort_order: RdbHelper.longToNumber(resultSet, resultSet.getColumnIndex('sort_order'))
          })
        } catch (e) {
          Logger.getInstance().error(TAG, 'queryQuizQuestions: row mapping failed', String(e))
        }
      }
      return questions
    } catch (e) {
      Logger.getInstance().error(TAG, `queryQuizQuestions failed: ${courseId}`, String(e))
      return []
    } finally {
      if (resultSet) {
        try {
          resultSet.close()
        } catch (_e) {
          // cursor 关闭失败静默处理
        }
      }
    }
  }
}
