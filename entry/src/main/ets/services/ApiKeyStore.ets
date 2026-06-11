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

async function ensureKeyExists(keyAlias: string): Promise<void> {
  try {
    const emptyOptions: huks.HuksOptions = { properties: [], inData: new Uint8Array([]) }
    const exists: boolean = await huks.isKeyItemExist(keyAlias, emptyOptions)
    if (exists) {
      return
    }
    await huks.generateKeyItem(keyAlias, KEY_GEN_PROPERTIES)
    Logger.getInstance().info('[SECURITY]', `HUKS 密钥已生成: ${keyAlias}`)
  } catch (e) {
    Logger.getInstance().error('[SECURITY]', `HUKS ensureKeyExists failed: ${keyAlias}`, String(e))
    throw new Error(`HUKS ensureKeyExists failed: ${String(e)}`)
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
  const updateOptions: huks.HuksOptions = { properties: [], inData: plainData }
  try {
    await huks.updateSession(handle, updateOptions)
  } catch (e) {
    throw new Error(`HUKS updateSession failed: ${String(e)}`)
  }

  const finishOptions: huks.HuksOptions = { properties: [], inData: new Uint8Array([]) }
  let finishResult: huks.HuksReturnResult
  try {
    finishResult = await huks.finishSession(handle, finishOptions)
  } catch (e) {
    throw new Error(`HUKS finishSession failed: ${String(e)}`)
  }
  const cipherData: Uint8Array = finishResult.outData ?? new Uint8Array([])

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
      Logger.getInstance().error(ApiKeyStore.TAG, `saveApiKey failed: alias=${alias}`, String(e))
      throw new Error(`saveApiKey failed: ${String(e)}`)
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

      const cipherData: Uint8Array = base64ToUint8(cipherB64)
      const updateOptions: huks.HuksOptions = { properties: [], inData: cipherData }
      await huks.updateSession(handle, updateOptions)

      const finishOptions: huks.HuksOptions = { properties: [], inData: new Uint8Array([]) }
      const finishResult: huks.HuksReturnResult = await huks.finishSession(handle, finishOptions)
      const plainData: Uint8Array = finishResult.outData ?? new Uint8Array([])

      Logger.getInstance().info(ApiKeyStore.TAG, `API Key 已解密加载: alias=${alias}`)
      return uint8ToStr(plainData)
    } catch (e) {
      Logger.getInstance().error(ApiKeyStore.TAG, `loadApiKey failed: alias=${alias}`, String(e))
      throw new Error(`loadApiKey failed: ${String(e)}`)
    }
  }
}
