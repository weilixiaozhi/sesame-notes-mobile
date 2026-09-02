// OpenAPI 枚举表达规范化脚本（确定性、幂等）。
//
// 背景：后端以 TypeBox Union([Literal(a), Literal(b)]) 表达枚举，生成 OpenAPI 为
//   anyOf: [{type:string,enum:[a]},{type:string,enum:[b]}]
// dart-dio 生成器无法把这种表达合成枚举类，字段退化为 dynamic，built_value 生成失败。
// 本脚本把所有「单值枚举分支」合并为标准 {type, enum:[...]}，语义不变（枚举值集合相同），
// 使 dart-dio 可正常消费。冻结契约文件（api/openapi/*.json）不被修改，规范化产物
// 输出到 build/（git 忽略），由 generate_api_client.ps1 在生成前调用。
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname } from 'node:path';

const [input, output] = process.argv.slice(2);
if (!input || !output) {
  console.error('usage: node normalize_openapi.mjs <input.json> <output.json>');
  process.exit(2);
}

/** 可合并为枚举的 JSON 类型 */
const ENUM_TYPES = new Set(['string', 'number', 'integer']);

/** 递归变换 schema 节点：展开嵌套 anyOf 并把单值枚举分支合并为 enum */
function transform(node) {
  if (Array.isArray(node)) return node.map(transform);
  if (node === null || typeof node !== 'object') return node;

  const out = {};
  for (const [key, value] of Object.entries(node)) {
    if (key === 'anyOf' && Array.isArray(value)) {
      // 分支先递归变换（展开内层嵌套 anyOf），再合并单值枚举；
      // 合并后只剩一个分支时直接塌缩为该分支，避免残留嵌套 anyOf；
      // nullableNormalize 会塌缩成对象（X + nullable:true），此时替换整个节点
      const merged = mergeEnumBranches(value.map(transform));
      let normalized = nullableNormalize(merged);
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
  return out;
}

/** anyOf: [X, {type:null}] 二分支形态 → X + nullable:true（dart-dio 对任何Of null 分支生成 ModelNull） */
function nullableNormalize(branches) {
  if (branches.length !== 2) return branches;
  const nullIdx = branches.findIndex((b) => b && typeof b === 'object' && !Array.isArray(b) && b.type === 'null');
  if (nullIdx < 0) return branches;
  const other = branches[nullIdx === 0 ? 1 : 0];
  if (!other || typeof other !== 'object' || Array.isArray(other)) return branches;
  return { ...other, nullable: true };
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
      branch.enum.length >= 1
    ) {
      if (!byType.has(branch.type)) byType.set(branch.type, { type: branch.type, enum: [] });
      byType.get(branch.type).enum.push(...branch.enum);
    } else if (branch && typeof branch === 'object' && !Array.isArray(branch) && branch.anyOf && typeof branch.anyOf === 'object' && !Array.isArray(branch.anyOf)) {
      // 分支自身是已塌缩的 {anyOf: <对象>}：展开该分支，避免残留嵌套
      others.push(branch.anyOf);
    } else {
      others.push(branch);
    }
  }
  const merged = [...byType.values()].map((e) => ({ type: e.type, enum: [...new Set(e.enum)] }));
  return [...merged, ...others];
}

mkdirSync(dirname(output), { recursive: true });
const spec = JSON.parse(readFileSync(input, 'utf8'));
writeFileSync(output, JSON.stringify(transform(spec), null, 2) + '\n');
console.log('normalized: ' + input + ' -> ' + output);
