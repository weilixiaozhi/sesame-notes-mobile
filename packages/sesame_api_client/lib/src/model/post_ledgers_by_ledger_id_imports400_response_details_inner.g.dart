// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_imports400_response_details_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum
    _$postLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum_category =
    const PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum._(
        'category');
const PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum
    _$postLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum_transaction =
    const PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum._(
        'transaction');

PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum
    _$postLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnumValueOf(
        String name) {
  switch (name) {
    case 'category':
      return _$postLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum_category;
    case 'transaction':
      return _$postLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum_transaction;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum>
    _$postLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnumValues =
    BuiltSet<
        PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum>(const <PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum>[
  _$postLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum_category,
  _$postLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum_transaction,
]);

Serializer<PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum>
    _$postLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnumSerializer =
    _$PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnumSerializer();

class _$PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnumSerializer
    implements
        PrimitiveSerializer<
            PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'category': 'category',
    'transaction': 'transaction',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'category': 'category',
    'transaction': 'transaction',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum
  ];
  @override
  final String wireName =
      'PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum';

  @override
  Object serialize(Serializers serializers,
          PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostLedgersByLedgerIdImports400ResponseDetailsInner
    extends PostLedgersByLedgerIdImports400ResponseDetailsInner {
  @override
  final PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum entity;
  @override
  final int index;
  @override
  final String reason;

  factory _$PostLedgersByLedgerIdImports400ResponseDetailsInner(
          [void Function(
                  PostLedgersByLedgerIdImports400ResponseDetailsInnerBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdImports400ResponseDetailsInnerBuilder()
            ..update(updates))
          ._build();

  _$PostLedgersByLedgerIdImports400ResponseDetailsInner._(
      {required this.entity, required this.index, required this.reason})
      : super._();
  @override
  PostLedgersByLedgerIdImports400ResponseDetailsInner rebuild(
          void Function(
                  PostLedgersByLedgerIdImports400ResponseDetailsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdImports400ResponseDetailsInnerBuilder toBuilder() =>
      PostLedgersByLedgerIdImports400ResponseDetailsInnerBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdImports400ResponseDetailsInner &&
        entity == other.entity &&
        index == other.index &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, entity.hashCode);
    _$hash = $jc(_$hash, index.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostLedgersByLedgerIdImports400ResponseDetailsInner')
          ..add('entity', entity)
          ..add('index', index)
          ..add('reason', reason))
        .toString();
  }
}

class PostLedgersByLedgerIdImports400ResponseDetailsInnerBuilder
    implements
        Builder<PostLedgersByLedgerIdImports400ResponseDetailsInner,
            PostLedgersByLedgerIdImports400ResponseDetailsInnerBuilder> {
  _$PostLedgersByLedgerIdImports400ResponseDetailsInner? _$v;

  PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum? _entity;
  PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum? get entity =>
      _$this._entity;
  set entity(
          PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum?
              entity) =>
      _$this._entity = entity;

  int? _index;
  int? get index => _$this._index;
  set index(int? index) => _$this._index = index;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  PostLedgersByLedgerIdImports400ResponseDetailsInnerBuilder() {
    PostLedgersByLedgerIdImports400ResponseDetailsInner._defaults(this);
  }

  PostLedgersByLedgerIdImports400ResponseDetailsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _entity = $v.entity;
      _index = $v.index;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdImports400ResponseDetailsInner other) {
    _$v = other as _$PostLedgersByLedgerIdImports400ResponseDetailsInner;
  }

  @override
  void update(
      void Function(PostLedgersByLedgerIdImports400ResponseDetailsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdImports400ResponseDetailsInner build() => _build();

  _$PostLedgersByLedgerIdImports400ResponseDetailsInner _build() {
    final _$result = _$v ??
        _$PostLedgersByLedgerIdImports400ResponseDetailsInner._(
          entity: BuiltValueNullFieldError.checkNotNull(entity,
              r'PostLedgersByLedgerIdImports400ResponseDetailsInner', 'entity'),
          index: BuiltValueNullFieldError.checkNotNull(index,
              r'PostLedgersByLedgerIdImports400ResponseDetailsInner', 'index'),
          reason: BuiltValueNullFieldError.checkNotNull(reason,
              r'PostLedgersByLedgerIdImports400ResponseDetailsInner', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
