// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MemberMemberTypeEnum _$memberMemberTypeEnum_REGISTERED =
    const MemberMemberTypeEnum._('REGISTERED');
const MemberMemberTypeEnum _$memberMemberTypeEnum_PLACEHOLDER =
    const MemberMemberTypeEnum._('PLACEHOLDER');

MemberMemberTypeEnum _$memberMemberTypeEnumValueOf(String name) {
  switch (name) {
    case 'REGISTERED':
      return _$memberMemberTypeEnum_REGISTERED;
    case 'PLACEHOLDER':
      return _$memberMemberTypeEnum_PLACEHOLDER;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MemberMemberTypeEnum> _$memberMemberTypeEnumValues =
    BuiltSet<MemberMemberTypeEnum>(const <MemberMemberTypeEnum>[
  _$memberMemberTypeEnum_REGISTERED,
  _$memberMemberTypeEnum_PLACEHOLDER,
]);

const MemberStatusEnum _$memberStatusEnum_ACTIVE =
    const MemberStatusEnum._('ACTIVE');
const MemberStatusEnum _$memberStatusEnum_LEFT =
    const MemberStatusEnum._('LEFT');
const MemberStatusEnum _$memberStatusEnum_REMOVED =
    const MemberStatusEnum._('REMOVED');

MemberStatusEnum _$memberStatusEnumValueOf(String name) {
  switch (name) {
    case 'ACTIVE':
      return _$memberStatusEnum_ACTIVE;
    case 'LEFT':
      return _$memberStatusEnum_LEFT;
    case 'REMOVED':
      return _$memberStatusEnum_REMOVED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MemberStatusEnum> _$memberStatusEnumValues =
    BuiltSet<MemberStatusEnum>(const <MemberStatusEnum>[
  _$memberStatusEnum_ACTIVE,
  _$memberStatusEnum_LEFT,
  _$memberStatusEnum_REMOVED,
]);

Serializer<MemberMemberTypeEnum> _$memberMemberTypeEnumSerializer =
    _$MemberMemberTypeEnumSerializer();
Serializer<MemberStatusEnum> _$memberStatusEnumSerializer =
    _$MemberStatusEnumSerializer();

class _$MemberMemberTypeEnumSerializer
    implements PrimitiveSerializer<MemberMemberTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'REGISTERED': 'REGISTERED',
    'PLACEHOLDER': 'PLACEHOLDER',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'REGISTERED': 'REGISTERED',
    'PLACEHOLDER': 'PLACEHOLDER',
  };

  @override
  final Iterable<Type> types = const <Type>[MemberMemberTypeEnum];
  @override
  final String wireName = 'MemberMemberTypeEnum';

  @override
  Object serialize(Serializers serializers, MemberMemberTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MemberMemberTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MemberMemberTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MemberStatusEnumSerializer
    implements PrimitiveSerializer<MemberStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ACTIVE': 'ACTIVE',
    'LEFT': 'LEFT',
    'REMOVED': 'REMOVED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ACTIVE': 'ACTIVE',
    'LEFT': 'LEFT',
    'REMOVED': 'REMOVED',
  };

  @override
  final Iterable<Type> types = const <Type>[MemberStatusEnum];
  @override
  final String wireName = 'MemberStatusEnum';

  @override
  Object serialize(Serializers serializers, MemberStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MemberStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MemberStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Member extends Member {
  @override
  final String id;
  @override
  final String ledgerId;
  @override
  final String displayName;
  @override
  final MemberMemberTypeEnum memberType;
  @override
  final MemberStatusEnum status;
  @override
  final DateTime updatedAt;

  factory _$Member([void Function(MemberBuilder)? updates]) =>
      (MemberBuilder()..update(updates))._build();

  _$Member._(
      {required this.id,
      required this.ledgerId,
      required this.displayName,
      required this.memberType,
      required this.status,
      required this.updatedAt})
      : super._();
  @override
  Member rebuild(void Function(MemberBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MemberBuilder toBuilder() => MemberBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Member &&
        id == other.id &&
        ledgerId == other.ledgerId &&
        displayName == other.displayName &&
        memberType == other.memberType &&
        status == other.status &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, ledgerId.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, memberType.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Member')
          ..add('id', id)
          ..add('ledgerId', ledgerId)
          ..add('displayName', displayName)
          ..add('memberType', memberType)
          ..add('status', status)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class MemberBuilder implements Builder<Member, MemberBuilder> {
  _$Member? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _ledgerId;
  String? get ledgerId => _$this._ledgerId;
  set ledgerId(String? ledgerId) => _$this._ledgerId = ledgerId;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  MemberMemberTypeEnum? _memberType;
  MemberMemberTypeEnum? get memberType => _$this._memberType;
  set memberType(MemberMemberTypeEnum? memberType) =>
      _$this._memberType = memberType;

  MemberStatusEnum? _status;
  MemberStatusEnum? get status => _$this._status;
  set status(MemberStatusEnum? status) => _$this._status = status;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  MemberBuilder() {
    Member._defaults(this);
  }

  MemberBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _ledgerId = $v.ledgerId;
      _displayName = $v.displayName;
      _memberType = $v.memberType;
      _status = $v.status;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Member other) {
    _$v = other as _$Member;
  }

  @override
  void update(void Function(MemberBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Member build() => _build();

  _$Member _build() {
    final _$result = _$v ??
        _$Member._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Member', 'id'),
          ledgerId: BuiltValueNullFieldError.checkNotNull(
              ledgerId, r'Member', 'ledgerId'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'Member', 'displayName'),
          memberType: BuiltValueNullFieldError.checkNotNull(
              memberType, r'Member', 'memberType'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'Member', 'status'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'Member', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
