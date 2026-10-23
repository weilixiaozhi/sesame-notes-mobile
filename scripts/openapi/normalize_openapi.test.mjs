import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import test from 'node:test';
import { normalizeOpenApi } from './normalize_openapi.mjs';

test('规范化保留约束、合并纯枚举，源对象不变且完整契约幂等', () => {
  assert.deepEqual(normalizeOpenApi({ anyOf: [
    { type: 'string', enum: ['a'] }, { type: 'string', enum: ['b', 'a'] },
    { type: 'string', enum: ['c'], maxLength: 0, description: '必须保留约束' },
  ] }), { anyOf: [
    { type: 'string', enum: ['a', 'b'] },
    { type: 'string', enum: ['c'], maxLength: 0, description: '必须保留约束' },
  ] });
  assert.deepEqual(normalizeOpenApi({ anyOf: [{ type: 'integer' }, { type: 'null' }] }),
    { type: 'integer', nullable: true });
  const adapted = normalizeOpenApi({ properties: {
    protocol_version: { type: 'number', enum: [1] },
    level: { anyOf: [{ type: 'number', enum: [1] }, { type: 'number', enum: [2] }] },
    category_id: { anyOf: [{ type: 'string', pattern: '^[0-9a-f-]+$', examples: ['abc'] }, { type: 'string', enum: ['uncategorized'] }] },
  } }).properties;
  assert.deepEqual(adapted.protocol_version, { type: 'integer', minimum: 1, maximum: 1 });
  assert.deepEqual(adapted.level, { type: 'number', enum: [1, 2] });
  assert.equal(new RegExp(adapted.category_id.pattern).test('uncategorized'), true);
  assert.equal(new RegExp(adapted.category_id.pattern).test('ABC'), false);
  // 分类特殊值与 UUID 的联合须完整匹配，枚举字面量中的正则字符不能扩大取值范围。
  const stringUnion = normalizeOpenApi({ anyOf: [
    { type: 'string', pattern: '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', examples: ['056cf10d-2d59-599c-9d97-6749e866aa52'] },
    { type: 'string', enum: ['uncategorized', 'literal.+'] },
  ] });
  assert.equal(stringUnion.type, 'string');
  assert.equal(stringUnion.anyOf, undefined);
  const unionPattern = new RegExp(stringUnion.pattern);
  for (const valid of ['056cf10d-2d59-599c-9d97-6749e866aa52', 'uncategorized', 'literal.+']) assert.equal(unionPattern.test(valid), true);
  for (const invalid of ['xuncategorized', 'uncategorizedx', 'literalXX', 'not-a-uuid']) assert.equal(unionPattern.test(invalid), false);
  const artifact = resolve(import.meta.dirname, '../../api/openapi/sesame-notes-api-v1.0.0.json');
  const bytes = readFileSync(artifact);
  const source = JSON.parse(bytes);
  const normalized = normalizeOpenApi(source);
  assert.deepEqual(normalizeOpenApi(normalized), normalized);
  assert.deepEqual(JSON.parse(bytes), source);
  assert.deepEqual(readFileSync(artifact), bytes);
});

test('普通用户响应模型不含管理员标记，冻结契约和其他接口字段保持完整', () => {
  const artifact = resolve(import.meta.dirname, '../../api/openapi/sesame-notes-api-v1.0.0.json');
  const source = JSON.parse(readFileSync(artifact, 'utf8'));
  const before = structuredClone(source);
  const normalized = normalizeOpenApi(source);
  const targets = [
    ['/api/v1/auth/register', 'post', '201', 'user'],
    ['/api/v1/auth/login', 'post', '200', 'user'],
    ['/api/v1/auth/refresh', 'post', '200', 'user'],
    ['/api/v1/auth/browser/register', 'post', '201', 'user'],
    ['/api/v1/auth/browser/login', 'post', '200', 'user'],
    ['/api/v1/auth/browser/refresh', 'post', '200', 'user'],
    ['/api/v1/profile/me', 'get', '200'],
    ['/api/v1/profile/me', 'patch', '200'],
    ['/api/v1/admin/users', 'get', '200', 'items'],
    ['/api/v1/admin/users/{user_id}', 'get', '200'],
  ];
  for (const [path, method, status, field] of targets) {
    let schema = normalized.paths[path][method].responses[status].content['application/json'].schema;
    if (field) schema = schema.properties[field];
    if (schema.type === 'array') schema = schema.items;
    assert.equal(Object.hasOwn(schema.properties, 'is_admin'), false, path);
    assert.equal(schema.required.includes('is_admin'), false, path);
    assert.equal(schema.required.includes('phone'), true, path);
    assert.equal(schema.properties.phone.type, 'string', path);
  }
  assert.deepEqual(source, before);
  assert.deepEqual(normalizeOpenApi(normalized), normalized);

  // 同名字段只在明确的普通用户响应范围内收敛，其他身份和请求字段保留。
  const flag = { type: 'object', required: ['is_admin'], properties: { is_admin: { type: 'boolean' } } };
  const input = { paths: {
    '/api/v1/auth/login': { post: { requestBody: { content: { 'application/json': { schema: flag } } } } },
    '/api/v1/admin/auth/me': { get: { responses: { 200: { content: { 'application/json': { schema: flag } } } } } },
    '/api/v1/other': { get: { responses: { 200: { content: { 'application/json': { schema: flag } } } } } },
  } };
  assert.deepEqual(normalizeOpenApi(input), input);
});

test('数字常量按schema处理且不影响分类及分页多值枚举', () => {
  try {
    const source = {
      properties: {
        schema_version: { type: 'number', enum: [1], description: '正式数字版本' },
        differently_named: { type: 'number', enum: [7] },
        decimal: { type: 'number', enum: [1.5] },
        constrained: { type: 'integer', enum: [1], minimum: 2, maximum: 3 },
        level: { anyOf: [{ type: 'number', enum: [1] }, { type: 'number', enum: [2] }] },
        page_size: { anyOf: [10, 20, 50, 100].map((value) => ({ type: 'number', enum: [value] })) },
      },
    };
    const before = structuredClone(source);
    const normalized = normalizeOpenApi(source);
    assert.deepEqual(normalized.properties.schema_version, { type: 'integer', description: '正式数字版本', minimum: 1, maximum: 1 });
    assert.deepEqual(normalized.properties.differently_named, { type: 'integer', minimum: 7, maximum: 7 });
    assert.deepEqual(normalized.properties.decimal, { type: 'number', minimum: 1.5, maximum: 1.5 });
    assert.deepEqual(normalized.properties.constrained, { type: 'integer', minimum: 2, maximum: 1 });
    assert.deepEqual(normalized.properties.level, { type: 'number', enum: [1, 2] });
    assert.deepEqual(normalized.properties.page_size, { type: 'number', enum: [10, 20, 50, 100] });
    assert.deepEqual(normalizeOpenApi(normalized), normalized);
    assert.deepEqual(source, before);
    const artifact = JSON.parse(readFileSync(resolve(import.meta.dirname, '../../api/openapi/sesame-notes-api-v1.0.0.json'), 'utf8'));
    const catalog = normalizeOpenApi(artifact).paths['/api/v1/fitness/catalog'].get.responses['200'].content['application/json'].schema;
    assert.deepEqual(catalog.properties.schema_version, { type: 'integer', minimum: 1, maximum: 1 });
  } catch (error) {
    throw new Error('数字常量生成边界回归失败', { cause: error });
  }
});

const branch = (entity = 'category', action = 'delete', payload = {}) => ({
  type: 'object', properties: {
    entity_type: {type:'string',enum:[entity]}, action:{type:'string',enum:[action]},
    payload: {type:'object', properties:{base_token:{type:'string',pattern:'^[a-f0-9]{64}$'}}, ...payload},
  },
});
const wrap = (value, path = '/api/v1/sync/push') => ({paths:{[path]:{post:{requestBody:{content:{'application/json':{schema:{properties:{changes:{items:{anyOf:[value]}}}}}}}}}}});
const payloadAt = (spec, path = '/api/v1/sync/push') => spec.paths[path].post.requestBody.content['application/json'].schema.properties.changes.items.properties.payload;

test('只保留唯一分类删除开放载荷，正式源base约束不变', () => {
  const source = wrap(branch());
  assert.deepEqual(payloadAt(normalizeOpenApi(source)), {type:'object'});
  assert.equal(source.paths['/api/v1/sync/push'].post.requestBody.content['application/json'].schema.properties.changes.items.anyOf[0].properties.payload.properties.base_token.pattern, '^[a-f0-9]{64}$');
});

for (const [name, value, path] of [
  ['其他实体', branch('member'), '/api/v1/sync/push'],
  ['分类写入', branch('category','upsert'), '/api/v1/sync/push'],
  ['封闭载荷', branch('category','delete',{additionalProperties:false}), '/api/v1/sync/push'],
  ['必填基线', branch('category','delete',{required:['base_token']}), '/api/v1/sync/push'],
  ['额外字段类型约束', branch('category','delete',{additionalProperties:{type:'string'}}), '/api/v1/sync/push'],
  ['对象大小约束', branch('category','delete',{maxProperties:1}), '/api/v1/sync/push'],
  ['新增字段', branch('category','delete',{properties:{other:{type:'number'}}}), '/api/v1/sync/push'],
  ['其他端点', branch(), '/api/v1/other'],
]) {
  test(`保留非目标约束：${name}`, () => {
    const actual = payloadAt(normalizeOpenApi(wrap(value,path)),path);
    assert.deepEqual(actual, value.properties.payload);
  });
}
