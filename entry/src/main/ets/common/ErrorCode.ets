/**
 * ErrorCode — 错误码枚举与资源映射
 * ViewModel 层使用错误码，Page 层通过 errorCodeToResource() 转为 $r() 资源引用
 */
export enum ErrorCode {
  COURSE_TITLE_EMPTY = 'ERR_COURSE_TITLE_EMPTY',
  COURSE_NOT_FOUND = 'ERR_COURSE_NOT_FOUND',
  COURSE_LOAD_FAILED = 'ERR_COURSE_LOAD_FAILED',
  COURSE_DELETE_FAILED = 'ERR_COURSE_DELETE_FAILED',
  COURSE_CREATE_FAILED = 'ERR_COURSE_CREATE_FAILED',
  KNOWLEDGE_LOAD_FAILED = 'ERR_KNOWLEDGE_LOAD_FAILED',
  NODE_ACTIVATE_FAILED = 'ERR_NODE_ACTIVATE_FAILED',
  LEARNING_LOAD_FAILED = 'ERR_LEARNING_LOAD_FAILED',
  INSIGHT_SUBMIT_FAILED = 'ERR_INSIGHT_SUBMIT_FAILED',
  ASSESSMENT_LOAD_FAILED = 'ERR_ASSESSMENT_LOAD_FAILED',
  QUIZ_NOT_FOUND = 'ERR_QUIZ_NOT_FOUND',
  REPORT_NO_DATA = 'ERR_REPORT_NO_DATA',
  REPORT_NO_EXPORT = 'ERR_REPORT_NO_EXPORT',
  NETWORK_DISCONNECTED = 'ERR_NETWORK_DISCONNECTED',
  AI_TIMEOUT = 'ERR_AI_TIMEOUT',
  AI_FAILED = 'ERR_AI_FAILED',
  API_KEY_MISSING = 'ERR_API_KEY_MISSING',
  NO_VALID_MATERIAL = 'ERR_NO_VALID_MATERIAL',
}

const ERROR_RESOURCE_MAP: Record<string, string> = {
  [ErrorCode.COURSE_TITLE_EMPTY]: 'app.string.err_course_title_empty',
  [ErrorCode.COURSE_NOT_FOUND]: 'app.string.err_course_not_found',
  [ErrorCode.COURSE_LOAD_FAILED]: 'app.string.err_course_load_failed',
  [ErrorCode.COURSE_DELETE_FAILED]: 'app.string.err_course_delete_failed',
  [ErrorCode.COURSE_CREATE_FAILED]: 'app.string.err_course_create_failed',
  [ErrorCode.KNOWLEDGE_LOAD_FAILED]: 'app.string.err_knowledge_load_failed',
  [ErrorCode.NODE_ACTIVATE_FAILED]: 'app.string.err_node_activate_failed',
  [ErrorCode.LEARNING_LOAD_FAILED]: 'app.string.err_learning_load_failed',
  [ErrorCode.INSIGHT_SUBMIT_FAILED]: 'app.string.err_insight_submit_failed',
  [ErrorCode.ASSESSMENT_LOAD_FAILED]: 'app.string.err_assessment_load_failed',
  [ErrorCode.QUIZ_NOT_FOUND]: 'app.string.err_quiz_not_found',
  [ErrorCode.REPORT_NO_DATA]: 'app.string.err_report_no_data',
  [ErrorCode.REPORT_NO_EXPORT]: 'app.string.err_report_no_export',
  [ErrorCode.NETWORK_DISCONNECTED]: 'app.string.err_network_disconnected',
  [ErrorCode.AI_TIMEOUT]: 'app.string.err_ai_timeout',
  [ErrorCode.AI_FAILED]: 'app.string.err_ai_failed',
  [ErrorCode.API_KEY_MISSING]: 'app.string.err_api_key_missing',
  [ErrorCode.NO_VALID_MATERIAL]: 'app.string.err_no_valid_material',
}

export function errorCodeToResource(code: string): Resource {
  const key = ERROR_RESOURCE_MAP[code]
  if (key) {
    return $r(key)
  }
  return $r('app.string.err_unknown')
}
