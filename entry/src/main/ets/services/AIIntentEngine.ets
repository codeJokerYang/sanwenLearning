/**
 * AIIntentEngine - 自然语言意图识别引擎
 * 纯函数实现，无副作用，无网络请求
 * 单次识别耗时 <5ms
 */

/** 意图类型枚举 */
export enum IntentType {
  /** 知识问答：什么是/为什么/解释一下 */
  KNOWLEDGE_QA = 'KNOWLEDGE_QA',
  /** 学习建议：怎么学/如何提高/建议 */
  LEARNING_ADVICE = 'LEARNING_ADVICE',
  /** 操作辅助：帮我创建/生成/删除 */
  OPERATION_ASSIST = 'OPERATION_ASSIST',
  /** 课程导航：回到/跳转/进入 */
  COURSE_NAVIGATION = 'COURSE_NAVIGATION',
  /** 知识检索：检索/搜索/查找 */
  KNOWLEDGE_RETRIEVAL = 'KNOWLEDGE_RETRIEVAL',
  /** 思维导图生成：导图/思维导图/图谱 */
  MIND_MAP_GEN = 'MIND_MAP_GEN',
  /** 学习文档生成：文档/学习资料/笔记 */
  STUDY_DOC_GEN = 'STUDY_DOC_GEN',
  /** 知识框架生成：框架/体系/大纲/知识树 */
  FRAMEWORK_GEN = 'FRAMEWORK_GEN'
}

/** 意图规则：关键词正则数组 → 意图类型 */
interface IntentRule {
  type: IntentType
  patterns: RegExp[]
}

/** 意图规则匹配表 */
const INTENT_RULES: IntentRule[] = [
  {
    type: IntentType.KNOWLEDGE_QA,
    patterns: [
      /什么是/, /是什么/, /为什么/, /解释一下/, /的意思是/, /怎么理解/,
      /含义/, /定义/, /概念/, /指的是/, /区别/, /联系/,
      /介绍一下/, /说明/, /阐述/, /阐述一下/
    ]
  },
  {
    type: IntentType.LEARNING_ADVICE,
    patterns: [
      /怎么学/, /如何学习/, /如何提高/, /建议/, /帮我想想/, /下一步/,
      /薄弱/, /重点/, /复习/, /提升/, /改进/, /优化/,
      /学习计划/, /学习策略/, /学习方法/, /我的情况/
    ]
  },
  {
    type: IntentType.OPERATION_ASSIST,
    patterns: [
      /帮我创建/, /帮我生成/, /帮我删除/, /帮我开启/, /帮我导出/,
      /帮我重新/, /创建一个/, /生成一个/, /删除/, /导出/,
      /重新生成/, /重新开始/, /开启/, /添加/
    ]
  },
  {
    type: IntentType.COURSE_NAVIGATION,
    patterns: [
      /回到/, /跳转/, /进入/, /去Q1/, /去Q2/, /去Q3/,
      /回到首页/, /回首页/, /去首页/, /进入Q1/, /进入Q2/, /进入Q3/,
      /是什么阶段/, /为什么阶段/, /怎么用阶段/,
      /设置页/, /去设置/, /导航/
    ]
  },
  {
    type: IntentType.KNOWLEDGE_RETRIEVAL,
    patterns: [
      /检索/, /搜索/, /查找/, /搜一下/, /查一下/,
      /\/search/, /相关知识/, /资料查询/
    ]
  },
  {
    type: IntentType.MIND_MAP_GEN,
    patterns: [
      /导图/, /思维导图/, /图谱/, /知识图谱/, / mind.?map/i,
      /画个图/, /生成导图/, /整理成图/
    ]
  },
  {
    type: IntentType.STUDY_DOC_GEN,
    patterns: [
      /文档/, /学习资料/, /笔记/, /学习笔记/, /整理文档/,
      /\/doc/, /生成文档/, /写个文档/, /学习指南/
    ]
  },
  {
    type: IntentType.FRAMEWORK_GEN,
    patterns: [
      /框架/, /体系/, /大纲/, /知识树/, /知识体系/,
      /\/framework/, /学习路径/, /整体框架/, /知识架构/
    ]
  }
]

/**
 * 对用户输入进行意图分类
 * 纯函数，无副作用，耗时 <5ms
 * @param input 用户输入文本
 * @returns 意图类型，无法匹配时返回 null
 */
export function classify(input: string): IntentType | null {
  if (!input || input.trim().length === 0) {
    return null
  }
  for (const rule of INTENT_RULES) {
    for (const pattern of rule.patterns) {
      if (pattern.test(input)) {
        return rule.type
      }
    }
  }
  return null
}
