// OpenAPI 枚举表达规范化（确定性、幂等）。
//
// 背景：后端以 TypeBox Union([Literal(a), Literal(b)]) 表达枚举，生成 OpenAPI 为
//   anyOf: [{type:string,enum:[a]},{type:string,enum:[b]}]
// dart-dio 生成器无法把这种表达合成枚举类，字段退化为 dynamic，built_value 生成失败。
// 本脚本把所有「单值枚举分支」合并为标准 {type, enum:[...]}，语义不变（枚举值集合相同），
// 使 dart-dio 可正常消费。
// 冻结契约文件（api/openapi/*.json）不被修改，规范化产物
// 输出到本轮 Temp/openapi-generation，由正式生成脚本校验路径。
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

/** 可合并为枚举的 JSON 类型 */
const ENUM_TYPES = new Set(['string', 'number', 'integer']);

/** 递归变换 schema 节点：展开嵌套 anyOf 并把单值枚举分支合并为 enum */
function transform(node, preserveEnumBranch = false) {
  if (Array.isArray(node)) return node.map((value) => transform(value));
  if (node === null || typeof node !== 'object') return node;

  const out = {};
  for (const [key, value] of Object.entries(node)) {
    if (key === 'anyOf' && Array.isArray(value)) {
      // 分支先递归变换（展开内层嵌套 anyOf），再合并单值枚举；
      // 合并后只剩一个分支时直接塌缩为该分支，避免残留嵌套 anyOf；
      // nullableNormalize 会塌缩成对象（X + nullable:true），此时替换整个节点
      const merged = mergeEnumBranches(value.map((branch) => transform(branch, true)));
      let normalized = stringUnionNormalize(merged) ?? nullableNormalize(patternEnumNormalize(merged));
      if (Array.isArray(normalized) && normalized.length === 1) normalized = normalized[0];
      if (Array.isArray(normalized)) {
        out[key] = normalized;
      } else {
        Object.assign(out, normalized);
      }
    } else if (typeof value === 'object' && value !== null) {
      if (typeof value.type === 'string' && value.type === 'null') {
        // 属性级纯 {type:null}（后端对 user-global 实体 ledger_id 的表达）：
        // dart-dio 会引用不存在的 model_null.dart 导致生成失败；
        // 收敛为 nullable string，与 pull 端同一字段的 anyOf[UUID,null] 表达语义一致
        out[key] = { type: 'string', nullable: true };
      } else {
        // 任意深度的 schema（components.schemas、paths 内联 schema、嵌套属性）都递归
        out[key] = transform(value);
      }
    } else {
      out[key] = value;
    }
  }
  return preserveEnumBranch ? out : normalizeNumericConstant(out);
}

/** 固定数值以等值上下界生成数字字段，联合分支在合并后才处理，保留多值枚举身份。 */
function normalizeNumericConstant(schema) {
  try {
    if (!['number', 'integer'].includes(schema.type) || !Array.isArray(schema.enum) ||
        schema.enum.length !== 1 || !Number.isFinite(schema.enum[0])) return schema;
    const constant = schema.enum[0];
    const { enum: ignoredEnum, ...other } = schema;
    // 保留原有更严的约束；矛盾约束仍为空集，不能被常量适配意外放宽。
    return {
      ...other,
      type: Number.isInteger(constant) ? 'integer' : schema.type,
      minimum: Math.max(schema.minimum ?? constant, constant),
      maximum: Math.min(schema.maximum ?? constant, constant),
    };
  } catch (error) {
    throw new Error('固定数字契约规范化失败', { cause: error });
  }
}

/** UUID 与字面字符串的联合保持字符串传输，用等价模式避免 dart-dio 生成不存在的 AnyOf 枚举。 */
function stringUnionNormalize(branches) {
  if (branches.length < 2 || !branches.some((branch) => branch?.format === 'uuid' || branch?.pattern)) return null;
  const patterns = [];
  for (const branch of branches) {
    if (branch?.type !== 'string' || Object.keys(branch).some((key) => !['type', 'format', 'enum', 'pattern', 'examples', 'description'].includes(key))) return null;
    if (branch.pattern && !branch.format && !branch.enum && branch.pattern.startsWith('^') && branch.pattern.endsWith('$')) {
      patterns.push(branch.pattern.slice(1, -1));
    } else if (branch.format === 'uuid' && !branch.enum) {
      patterns.push('[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}');
    } else if (!branch.format && Array.isArray(branch.enum) && branch.enum.every((value) => typeof value === 'string')) {
      patterns.push(...branch.enum.map((value) => value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')));
    } else return null;
  }
  return { type: 'string', pattern: `^(?:${patterns.join('|')})$` };
}

/** anyOf: [X, {type:null}] 二分支形态 → X + nullable:true（dart-dio 对任何Of null 分支生成 ModelNull） */
function nullableNormalize(branches) {
  if (!Array.isArray(branches)) return branches;
  if (branches.length !== 2) return branches;
  const nullIdx = branches.findIndex((b) => b && typeof b === 'object' && !Array.isArray(b) && b.type === 'null');
  if (nullIdx < 0) return branches;
  const other = branches[nullIdx === 0 ? 1 : 0];
  if (!other || typeof other !== 'object' || Array.isArray(other)) return branches;
  return { ...other, nullable: true };
}

/** 同一字符串的正则或枚举联合保持为等价正则，避免生成器构造不存在的匿名枚举类型。 */
function patternEnumNormalize(branches) {
  if (branches.length !== 2) return branches;
  const patternBranch = branches.find((branch) => branch?.type === 'string' &&
    typeof branch.pattern === 'string' &&
    Object.keys(branch).every((key) => ['type', 'pattern', 'examples'].includes(key)));
  const enumBranch = branches.find((branch) => branch?.type === 'string' &&
    Array.isArray(branch.enum) && branch.enum.length > 0 && branch.enum.every((value) => typeof value === 'string') &&
    Object.keys(branch).every((key) => ['type', 'enum'].includes(key)));
  if (!patternBranch || !enumBranch) return branches;
  const literals = enumBranch.enum.map((value) => value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'));
  return { ...patternBranch, pattern: `(?:${patternBranch.pattern})|^(?:${literals.join('|')})$` };
}

/** 把同类型的单值枚举分支合并成一个标准 enum 分支，其余分支原样保留 */
function mergeEnumBranches(branches) {
  const others = [];
  const byType = new Map();
  for (const branch of branches) {
    if (
      branch &&
      typeof branch === 'object' &&
      !Array.isArray(branch) &&
      typeof branch.type === 'string' &&
      ENUM_TYPES.has(branch.type) &&
      Array.isArray(branch.enum) &&
      branch.enum.length >= 1 &&
      // 带其他约束或描述的分支不能丢掉这些字段后合并。
      Object.keys(branch).every((key) => key === 'type' || key === 'enum')
    ) {
      if (!byType.has(branch.type)) byType.set(branch.type, { type: branch.type, enum: [] });
      byType.get(branch.type).enum.push(...branch.enum);
    } else {
      others.push(branch);
    }
  }
  const merged = [...byType.values()].map((e) => ({ type: e.type, enum: [...new Set(e.enum)] }));
  return [...merged, ...others];
}

/**
 * 分类删除的完整 JSON 参与请求指纹；该开放载荷保留 JsonObject，
 * 保证冻结请求按原文重放，不丢失未知字段；服务端验证 base_token。
 */
function preserveOpenCategoryDelete(spec) {
  const item = spec.paths?.['/api/v1/sync/push']?.post?.requestBody?.content?.['application/json']?.schema?.properties?.changes?.items;
  function visit(node) {
    if (!node || typeof node !== 'object') return;
    if (Array.isArray(node.anyOf)) node.anyOf.forEach(visit);
    const props = node.properties;
    const only = (schema, value) => schema?.enum?.length === 1 && schema.enum[0] === value;
    const payload = props?.payload;
    if (!only(props?.entity_type, 'category') || !only(props?.action, 'delete') ||
        payload?.type !== 'object' ||
        (payload.additionalProperties !== undefined && payload.additionalProperties !== true) ||
        Object.keys(payload).some((key) => !['type', 'properties', 'required', 'additionalProperties', 'description', 'examples'].includes(key)) ||
        (payload.required?.length ?? 0) !== 0 ||
        Object.keys(payload.properties ?? {}).some((key) => key !== 'base_token')) return;
    // 已规范化的空开放对象再次经过此处保持不变。
    props.payload = { type: 'object' };
  }
  visit(item);
  return spec;
}

/** 纯转换供固定回归直接验证，不创建临时目录或删除文件。 */
export function normalizeOpenApi(spec) {
  try {
    return preserveOpenCategoryDelete(transform(spec));
  } catch (error) {
    throw new Error('客户端 OpenAPI 生成输入转换失败', { cause: error });
  }
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const [input, output] = process.argv.slice(2);
  if (!input || !output) {
    console.error('usage: node normalize_openapi.mjs <input.json> <output.json>');
    process.exit(2);
  }
  try {
    mkdirSync(dirname(output), { recursive: true });
    const spec = JSON.parse(readFileSync(input, 'utf8'));
    writeFileSync(output, JSON.stringify(normalizeOpenApi(spec), null, 2) + '\n');
    console.log('normalized: ' + input + ' -> ' + output);
  } catch (error) {
    console.error('客户端 OpenAPI 输入处理失败，请查看下方错误详情。');
    console.error(error);
    process.exitCode = 1;
  }
}
