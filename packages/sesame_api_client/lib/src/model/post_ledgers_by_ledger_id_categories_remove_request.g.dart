// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_categories_remove_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum
    _$postLedgersByLedgerIdCategoriesRemoveRequestModeEnum_migrate =
    const PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum._('migrate');
const PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum
    _$postLedgersByLedgerIdCategoriesRemoveRequestModeEnum_delete =
    const PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum._('delete');
const PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum
    _$postLedgersByLedgerIdCategoriesRemoveRequestModeEnum_promote =
    const PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum._('promote');

PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum
    _$postLedgersByLedgerIdCategoriesRemoveRequestModeEnumValueOf(String name) {
  switch (name) {
    case 'migrate':
      return _$postLedgersByLedgerIdCategoriesRemoveRequestModeEnum_migrate;
    case 'delete':
      return _$postLedgersByLedgerIdCategoriesRemoveRequestModeEnum_delete;
    case 'promote':
      return _$postLedgersByLedgerIdCategoriesRemoveRequestModeEnum_promote;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum>
    _$postLedgersByLedgerIdCategoriesRemoveRequestModeEnumValues = BuiltSet<
        PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum>(const <PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum>[
  _$postLedgersByLedgerIdCategoriesRemoveRequestModeEnum_migrate,
  _$postLedgersByLedgerIdCategoriesRemoveRequestModeEnum_delete,
  _$postLedgersByLedgerIdCategoriesRemoveRequestModeEnum_promote,
]);

Serializer<PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum>
    _$postLedgersByLedgerIdCategoriesRemoveRequestModeEnumSerializer =
    _$PostLedgersByLedgerIdCategoriesRemoveRequestModeEnumSerializer();

class _$PostLedgersByLedgerIdCategoriesRemoveRequestModeEnumSerializer
    implements
        PrimitiveSerializer<
            PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'migrate': 'migrate',
    'delete': 'delete',
    'promote': 'promote',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'migrate': 'migrate',
    'delete': 'delete',
    'promote': 'promote',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum
  ];
  @override
  final String wireName =
      'PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum';

  @override
  Object serialize(Serializers serializers,
          PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostLedgersByLedgerIdCategoriesRemoveRequest
    extends PostLedgersByLedgerIdCategoriesRemoveRequest {
  @override
  final BuiltSet<String> categoryIds;
  @override
  final PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum mode;
  @override
  final String? targetCategoryId;
  @override
  final DateTime? expectedTargetUpdatedAt;
  @override
  final String previewToken;

  factory _$PostLedgersByLedgerIdCategoriesRemoveRequest(
          [void Function(PostLedgersByLedgerIdCategoriesRemoveRequestBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdCategoriesRemoveRequestBuilder()..update(updates))
          ._build();

  _$PostLedgersByLedgerIdCategoriesRemoveRequest._(
      {required this.categoryIds,
      required this.mode,
      this.targetCategoryId,
      this.expectedTargetUpdatedAt,
      required this.previewToken})
      : super._();
  @override
  PostLedgersByLedgerIdCategoriesRemoveRequest rebuild(
          void Function(PostLedgersByLedgerIdCategoriesRemoveRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdCategoriesRemoveRequestBuilder toBuilder() =>
      PostLedgersByLedgerIdCategoriesRemoveRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdCategoriesRemoveRequest &&
        categoryIds == other.categoryIds &&
        mode == other.mode &&
        targetCategoryId == other.targetCategoryId &&
        expectedTargetUpdatedAt == other.expectedTargetUpdatedAt &&
        previewToken == other.previewToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, categoryIds.hashCode);
    _$hash = $jc(_$hash, mode.hashCode);
    _$hash = $jc(_$hash, targetCategoryId.hashCode);
    _$hash = $jc(_$hash, expectedTargetUpdatedAt.hashCode);
    _$hash = $jc(_$hash, previewToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostLedgersByLedgerIdCategoriesRemoveRequest')
          ..add('categoryIds', categoryIds)
          ..add('mode', mode)
          ..add('targetCategoryId', targetCategoryId)
          ..add('expectedTargetUpdatedAt', expectedTargetUpdatedAt)
          ..add('previewToken', previewToken))
        .toString();
  }
}

class PostLedgersByLedgerIdCategoriesRemoveRequestBuilder
    implements
        Builder<PostLedgersByLedgerIdCategoriesRemoveRequest,
            PostLedgersByLedgerIdCategoriesRemoveRequestBuilder> {
  _$PostLedgersByLedgerIdCategoriesRemoveRequest? _$v;

  SetBuilder<String>? _categoryIds;
  SetBuilder<String> get categoryIds =>
      _$this._categoryIds ??= SetBuilder<String>();
  set categoryIds(SetBuilder<String>? categoryIds) =>
      _$this._categoryIds = categoryIds;

  PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum? _mode;
  PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum? get mode =>
      _$this._mode;
  set mode(PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum? mode) =>
      _$this._mode = mode;

  String? _targetCategoryId;
  String? get targetCategoryId => _$this._targetCategoryId;
  set targetCategoryId(String? targetCategoryId) =>
      _$this._targetCategoryId = targetCategoryId;

  DateTime? _expectedTargetUpdatedAt;
  DateTime? get expectedTargetUpdatedAt => _$this._expectedTargetUpdatedAt;
  set expectedTargetUpdatedAt(DateTime? expectedTargetUpdatedAt) =>
      _$this._expectedTargetUpdatedAt = expectedTargetUpdatedAt;

  String? _previewToken;
  String? get previewToken => _$this._previewToken;
  set previewToken(String? previewToken) => _$this._previewToken = previewToken;

  PostLedgersByLedgerIdCategoriesRemoveRequestBuilder() {
    PostLedgersByLedgerIdCategoriesRemoveRequest._defaults(this);
  }

  PostLedgersByLedgerIdCategoriesRemoveRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _categoryIds = $v.categoryIds.toBuilder();
      _mode = $v.mode;
      _targetCategoryId = $v.targetCategoryId;
      _expectedTargetUpdatedAt = $v.expectedTargetUpdatedAt;
      _previewToken = $v.previewToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdCategoriesRemoveRequest other) {
    _$v = other as _$PostLedgersByLedgerIdCategoriesRemoveRequest;
  }

  @override
  void update(
      void Function(PostLedgersByLedgerIdCategoriesRemoveRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdCategoriesRemoveRequest build() => _build();

  _$PostLedgersByLedgerIdCategoriesRemoveRequest _build() {
    _$PostLedgersByLedgerIdCategoriesRemoveRequest _$result;
    try {
      _$result = _$v ??
          _$PostLedgersByLedgerIdCategoriesRemoveRequest._(
            categoryIds: categoryIds.build(),
            mode: BuiltValueNullFieldError.checkNotNull(
                mode, r'PostLedgersByLedgerIdCategoriesRemoveRequest', 'mode'),
            targetCategoryId: targetCategoryId,
            expectedTargetUpdatedAt: expectedTargetUpdatedAt,
            previewToken: BuiltValueNullFieldError.checkNotNull(
                previewToken,
                r'PostLedgersByLedgerIdCategoriesRemoveRequest',
                'previewToken'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'categoryIds';
        categoryIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostLedgersByLedgerIdCategoriesRemoveRequest',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
