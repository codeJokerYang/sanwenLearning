/**
 * ApiKeyStore - API Key HUKS 加密存储服务
 * 遵循 API_SECURITY_CONVENTIONS.md §1.2 方案A
 * 使用 @ohos.security.huks AES-256-CBC 加密
 * 密文存储于 @ohos.data.preferences
 */
import huks from '@ohos.security.huks'
import preferences from '@ohos.data.preferences'
import { common } from '@kit.AbilityKit'
import { util } from '@kit.ArkTS'
import { Logger } from '../common/Logger'

const PREF_STORE_NAME: string = 'api_key_secure_store'
const PREF_KEY_IV: string = '_iv'
const PREF_KEY_CIPHER: string = '_cipher'
const HUKS_KEY_ALIAS_PREFIX: string = 'sanwen_apikey_'

interface HmacResult {
  iv: string
  cipher: string
}

const KEY_GEN_PROPERTIES: huks.HuksOptions = {
  properties: [
    { tag: huks.HuksTag.HUKS_TAG_ALGORITHM, value: huks.HuksKeyAlg.HUKS_ALG_AES },
    { tag: huks.HuksTag.HUKS_TAG_KEY_SIZE, value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_256 },
    { tag: huks.HuksTag.HUKS_TAG_PURPOSE, value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT |
      huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT },
    { tag: huks.HuksTag.HUKS_TAG_DIGEST, value: huks.HuksKeyDigest.HUKS_DIGEST_NONE },
    { tag: huks.HuksTag.HUKS_TAG_PADDING, value: huks.HuksKeyPadding.HUKS_PADDING_PKCS7 },
    { tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE, value: huks.HuksCipherMode.HUKS_MODE_CBC },
  ],
  inData: new Uint8Array([])
}

function strToUint8(str: string): Uint8Array {
  return new Uint8Array(new util.TextEncoder().encodeInto(str))
}

function uint8ToStr(data: Uint8Array): string {
  return util.TextDecoder.create('utf-8').decodeToString(data)
}

function uint8ToBase64(data: Uint8Array): string {
  const helper: util.Base64Helper = new util.Base64Helper()
  return helper.encodeToStringSync(data)
}

function base64ToUint8(b64: string): Uint8Array {
  const helper: util.Base64Helper = new util.Base64Helper()
  return helper.decodeSync(b64)
}

function concatUint8(a: Uint8Array, b: Uint8Array): Uint8Array {
  const result: Uint8Array = new Uint8Array(a.length + b.length)
  result.set(a, 0)
  result.set(b, a.length)
  return result
}

/** 提取 HUKS/系统错误的 code 与 message（直接 String() 会得到 [object Object]） */
function describeError(e: object): string {
  try {
    const rec: Record<string, Object> = e as Record<string, Object>
    const code: Object = rec['code'] ?? ''
    const msg: Object = rec['message'] ?? ''
    if (code !== '' || msg !== '') {
      return `code=${code} message=${msg}`
    }
    return JSON.stringify(e)
  } catch (_ignored) {
    return String(e)
  }
}

async function ensureKeyExists(keyAlias: string): Promise<void> {
  const emptyOptions: huks.HuksOptions = { properties: [], inData: new Uint8Array([]) }
  let exists: boolean = false
  try {
    exists = await huks.isKeyItemExist(keyAlias, emptyOptions)
  } catch (_notExist) {
    // API 11+ 行为：密钥不存在时 isKeyItemExist 以异常（12000011）返回而非 resolve(false)
    exists = false
  }
  if (exists) {
    return
  }
  try {
    await huks.generateKeyItem(keyAlias, KEY_GEN_PROPERTIES)
    Logger.getInstance().info('[SECURITY]', `HUKS 密钥已生成: ${keyAlias}`)
  } catch (e) {
    const detail: string = describeError(e as object)
    Logger.getInstance().error('[SECURITY]', `HUKS generateKeyItem failed: ${keyAlias}`, detail)
    throw new Error(`HUKS generateKeyItem failed: ${detail}`)
  }
}

function generateRandomIv(): Uint8Array {
  const iv: Uint8Array = new Uint8Array(16)
  for (let i = 0; i < 16; i++) {
    iv[i] = Math.floor(Math.random() * 256)
  }
  return iv
}

async function hmacEncrypt(keyAlias: string, plaintext: string): Promise<HmacResult> {
  await ensureKeyExists(keyAlias)

  const iv: Uint8Array = generateRandomIv()
  const encryptOptions: huks.HuksOptions = {
    properties: [
      { tag: huks.HuksTag.HUKS_TAG_ALGORITHM, value: huks.HuksKeyAlg.HUKS_ALG_AES },
      { tag: huks.HuksTag.HUKS_TAG_KEY_SIZE, value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_256 },
      { tag: huks.HuksTag.HUKS_TAG_PURPOSE, value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT },
      { tag: huks.HuksTag.HUKS_TAG_DIGEST, value: huks.HuksKeyDigest.HUKS_DIGEST_NONE },
      { tag: huks.HuksTag.HUKS_TAG_PADDING, value: huks.HuksKeyPadding.HUKS_PADDING_PKCS7 },
      { tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE, value: huks.HuksCipherMode.HUKS_MODE_CBC },
      { tag: huks.HuksTag.HUKS_TAG_IV, value: iv },
    ],
    inData: new Uint8Array([])
  }

  let initResult: huks.HuksSessionHandle
  try {
    initResult = await huks.initSession(keyAlias, encryptOptions)
  } catch (e) {
    throw new Error(`HUKS initSession failed: ${String(e)}`)
  }
  const handle: number = initResult.handle

  const plainData: Uint8Array = strToUint8(plaintext)
  // 分段密码学操作：updateSession 与 finishSession 的 outData 都可能携带密文，
  // 必须拼接两段输出。只取 finish 的输出会得到残缺密文，解密必然失败。
  const updateOptions: huks.HuksOptions = { properties: [], inData: plainData }
  let updateResult: huks.HuksReturnResult
  try {
    updateResult = await huks.updateSession(handle, updateOptions)
  } catch (e) {
    throw new Error(`HUKS updateSession failed: ${describeError(e as object)}`)
  }

  const finishOptions: huks.HuksOptions = { properties: [], inData: new Uint8Array([]) }
  let finishResult: huks.HuksReturnResult
  try {
    finishResult = await huks.finishSession(handle, finishOptions)
  } catch (e) {
    throw new Error(`HUKS finishSession failed: ${describeError(e as object)}`)
  }
  const cipherData: Uint8Array = concatUint8(
    updateResult.outData ?? new Uint8Array([]),
    finishResult.outData ?? new Uint8Array([]))

  const result: HmacResult = { iv: uint8ToBase64(iv), cipher: uint8ToBase64(cipherData) }
  return result
}

export class ApiKeyStore {
  private static readonly TAG: string = '[SECURITY]'

  static async saveApiKey(context: common.Context, alias: string, apiKey: string): Promise<void> {
    try {
      const keyAlias: string = HUKS_KEY_ALIAS_PREFIX + alias
      const encResult: HmacResult = await hmacEncrypt(keyAlias, apiKey)
      const iv: string = encResult.iv
      const cipher: string = encResult.cipher

      const prefs: preferences.Preferences = await preferences.getPreferences(context, PREF_STORE_NAME)
      await prefs.put(alias + PREF_KEY_IV, iv)
      await prefs.put(alias + PREF_KEY_CIPHER, cipher)
      await prefs.flush()
      Logger.getInstance().info(ApiKeyStore.TAG, `API Key 已加密存储: alias=${alias}`)
    } catch (e) {
      const detail: string = describeError(e as object)
      Logger.getInstance().error(ApiKeyStore.TAG, `saveApiKey failed: alias=${alias}`, detail)
      throw new Error(`saveApiKey failed: ${detail}`)
    }
  }

  static async loadApiKey(context: common.Context, alias: string): Promise<string> {
    try {
      const prefs: preferences.Preferences = await preferences.getPreferences(context, PREF_STORE_NAME)
      const ivB64: string = prefs.getSync(alias + PREF_KEY_IV, '') as string
      const cipherB64: string = prefs.getSync(alias + PREF_KEY_CIPHER, '') as string

      if (!ivB64 || !cipherB64) {
        throw new Error(`未找到 API Key: alias=${alias}`)
      }

      const keyAlias: string = HUKS_KEY_ALIAS_PREFIX + alias
      await ensureKeyExists(keyAlias)

      const decryptProps: huks.HuksOptions = {
        properties: [
          { tag: huks.HuksTag.HUKS_TAG_ALGORITHM, value: huks.HuksKeyAlg.HUKS_ALG_AES },
          { tag: huks.HuksTag.HUKS_TAG_KEY_SIZE, value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_256 },
          { tag: huks.HuksTag.HUKS_TAG_PURPOSE, value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT },
          { tag: huks.HuksTag.HUKS_TAG_DIGEST, value: huks.HuksKeyDigest.HUKS_DIGEST_NONE },
          { tag: huks.HuksTag.HUKS_TAG_PADDING, value: huks.HuksKeyPadding.HUKS_PADDING_PKCS7 },
          { tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE, value: huks.HuksCipherMode.HUKS_MODE_CBC },
          { tag: huks.HuksTag.HUKS_TAG_IV, value: base64ToUint8(ivB64) },
        ],
        inData: new Uint8Array([])
      }

      const initResult: huks.HuksSessionHandle = await huks.initSession(keyAlias, decryptProps)
      const handle: number = initResult.handle

      // 与加密侧对称：update 与 finish 的 outData 拼接才是完整明文
      const cipherData: Uint8Array = base64ToUint8(cipherB64)
      const updateOptions: huks.HuksOptions = { properties: [], inData: cipherData }
      const updateResult: huks.HuksReturnResult = await huks.updateSession(handle, updateOptions)

      const finishOptions: huks.HuksOptions = { properties: [], inData: new Uint8Array([]) }
      const finishResult: huks.HuksReturnResult = await huks.finishSession(handle, finishOptions)
      const plainData: Uint8Array = concatUint8(
        updateResult.outData ?? new Uint8Array([]),
        finishResult.outData ?? new Uint8Array([]))

      Logger.getInstance().info(ApiKeyStore.TAG, `API Key 已解密加载: alias=${alias}`)
      return uint8ToStr(plainData)
    } catch (e) {
      const detail: string = describeError(e as object)
      Logger.getInstance().error(ApiKeyStore.TAG, `loadApiKey failed: alias=${alias}`, detail)
      throw new Error(`loadApiKey failed: ${detail}`)
    }
  }
}
