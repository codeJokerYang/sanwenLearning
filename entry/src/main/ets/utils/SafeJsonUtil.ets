/**
 * 三问高效学习机 — JSON 安全解析工具
 * 严格对齐 DATA_CONTRACT.md v2.1 §4.2 防御性编程规则
 * 解析失败严禁抛出异常中断应用，必须降级返回空数组 []
 */
import { Logger } from '../common/Logger'

const TAG = 'SAFE_JSON_UTIL'

export class SafeJsonUtil {
  /**
   * 安全解析 JSON 数组字符串
   *
   * 适用场景：
   * - QuizQuestion.linked_node_ids：'["id1","id2"]'
   * - QuizQuestion.options：客观题 '["A.选项1","B.选项2"]'，主观题 ""（空字符串）
   *
   * 防御规则（DATA_CONTRACT §4.2 硬性约束）：
   * 1. 空字符串或 null 直接返回 []（主观题 options 场景）
   * 2. JSON.parse 失败：捕获异常，Logger.error 记录，降级返回 []
   * 3. 解析结果非数组：Logger.error 记录，降级返回 []
   * 4. 严禁抛出异常中断应用
   *
   * @param jsonStr JSON 数组字符串，可能为 null 或空字符串
   * @returns string[] 解析成功的数组，或降级后的空数组
   */
  static safeParseJsonArray(jsonStr: string | null): string[] {
    // 规则1：空字符串或 null 直接返回空数组（主观题 options 场景）
    if (jsonStr === null || jsonStr === '' || jsonStr === undefined) {
      return []
    }

    try {
      const parsed = JSON.parse(jsonStr)

      // 规则3：校验解析结果必须为数组
      if (Array.isArray(parsed)) {
        return parsed as string[]
      }

      // 非数组降级返回空数组
      Logger.getInstance().error(TAG, `safeParseJsonArray: parsed result is not array, input: ${jsonStr}`)
      return []
    } catch (e) {
      // 规则2：解析失败降级返回空数组，严禁抛出异常中断应用
      Logger.getInstance().error(TAG, `safeParseJsonArray: JSON.parse failed, input: ${jsonStr}`, String(e))
      return []
    }
  }
}
