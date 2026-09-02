// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_ledgers_by_ledger_id_member_stats200_response_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum
    _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum_owner =
    const GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum._(
        'owner');
const GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum
    _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum_editor =
    const GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum._(
        'editor');
const GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum
    _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum_removed =
    const GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum._(
        'removed');
const GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum
    _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum_unknown =
    const GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum._(
        'unknown');

GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum
    _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnumValueOf(
        String name) {
  switch (name) {
    case 'owner':
      return _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum_owner;
    case 'editor':
      return _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum_editor;
    case 'removed':
      return _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum_removed;
    case 'unknown':
      return _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum_unknown;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum>
    _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnumValues =
    BuiltSet<
        GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum>(const <GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum>[
  _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum_owner,
  _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum_editor,
  _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum_removed,
  _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum_unknown,
]);

Serializer<GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum>
    _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnumSerializer =
    _$GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnumSerializer();

class _$GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnumSerializer
    implements
        PrimitiveSerializer<
            GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'owner': 'owner',
    'editor': 'editor',
    'removed': 'removed',
    'unknown': 'unknown',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'owner': 'owner',
    'editor': 'editor',
    'removed': 'removed',
    'unknown': 'unknown',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum
  ];
  @override
  final String wireName =
      'GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum';

  @override
  Object serialize(Serializers serializers,
          GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetLedgersByLedgerIdMemberStats200ResponseItemsInner
    extends GetLedgersByLedgerIdMemberStats200ResponseItemsInner {
  @override
  final String? userId;
  @override
  final String? memberId;
  @override
  final String? sesameNumber;
  @override
  final String? displayName;
  @override
  final String? avatarUrl;
  @override
  final int avatarVersion;
  @override
  final GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum role;
  @override
  final String incomeTotal;
  @override
  final String expenseTotal;
  @override
  final int txCount;

  factory _$GetLedgersByLedgerIdMemberStats200ResponseItemsInner(
          [void Function(
                  GetLedgersByLedgerIdMemberStats200ResponseItemsInnerBuilder)?
              updates]) =>
      (GetLedgersByLedgerIdMemberStats200ResponseItemsInnerBuilder()
            ..update(updates))
          ._build();

  _$GetLedgersByLedgerIdMemberStats200ResponseItemsInner._(
      {this.userId,
      this.memberId,
      this.sesameNumber,
      this.displayName,
      this.avatarUrl,
      required this.avatarVersion,
      required this.role,
      required this.incomeTotal,
      required this.expenseTotal,
      required this.txCount})
      : super._();
  @override
  GetLedgersByLedgerIdMemberStats200ResponseItemsInner rebuild(
          void Function(
                  GetLedgersByLedgerIdMemberStats200ResponseItemsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetLedgersByLedgerIdMemberStats200ResponseItemsInnerBuilder toBuilder() =>
      GetLedgersByLedgerIdMemberStats200ResponseItemsInnerBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetLedgersByLedgerIdMemberStats200ResponseItemsInner &&
        userId == other.userId &&
        memberId == other.memberId &&
        sesameNumber == other.sesameNumber &&
        displayName == other.displayName &&
        avatarUrl == other.avatarUrl &&
        avatarVersion == other.avatarVersion &&
        role == other.role &&
        incomeTotal == other.incomeTotal &&
        expenseTotal == other.expenseTotal &&
        txCount == other.txCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, memberId.hashCode);
    _$hash = $jc(_$hash, sesameNumber.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, avatarUrl.hashCode);
    _$hash = $jc(_$hash, avatarVersion.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, incomeTotal.hashCode);
    _$hash = $jc(_$hash, expenseTotal.hashCode);
    _$hash = $jc(_$hash, txCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetLedgersByLedgerIdMemberStats200ResponseItemsInner')
          ..add('userId', userId)
          ..add('memberId', memberId)
          ..add('sesameNumber', sesameNumber)
          ..add('displayName', displayName)
          ..add('avatarUrl', avatarUrl)
          ..add('avatarVersion', avatarVersion)
          ..add('role', role)
          ..add('incomeTotal', incomeTotal)
          ..add('expenseTotal', expenseTotal)
          ..add('txCount', txCount))
        .toString();
  }
}

class GetLedgersByLedgerIdMemberStats200ResponseItemsInnerBuilder
    implements
        Builder<GetLedgersByLedgerIdMemberStats200ResponseItemsInner,
            GetLedgersByLedgerIdMemberStats200ResponseItemsInnerBuilder> {
  _$GetLedgersByLedgerIdMemberStats200ResponseItemsInner? _$v;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _memberId;
  String? get memberId => _$this._memberId;
  set memberId(String? memberId) => _$this._memberId = memberId;

  String? _sesameNumber;
  String? get sesameNumber => _$this._sesameNumber;
  set sesameNumber(String? sesameNumber) => _$this._sesameNumber = sesameNumber;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _avatarUrl;
  String? get avatarUrl => _$this._avatarUrl;
  set avatarUrl(String? avatarUrl) => _$this._avatarUrl = avatarUrl;

  int? _avatarVersion;
  int? get avatarVersion => _$this._avatarVersion;
  set avatarVersion(int? avatarVersion) =>
      _$this._avatarVersion = avatarVersion;

  GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum? _role;
  GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum? get role =>
      _$this._role;
  set role(
          GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum? role) =>
      _$this._role = role;

  String? _incomeTotal;
  String? get incomeTotal => _$this._incomeTotal;
  set incomeTotal(String? incomeTotal) => _$this._incomeTotal = incomeTotal;

  String? _expenseTotal;
  String? get expenseTotal => _$this._expenseTotal;
  set expenseTotal(String? expenseTotal) => _$this._expenseTotal = expenseTotal;

  int? _txCount;
  int? get txCount => _$this._txCount;
  set txCount(int? txCount) => _$this._txCount = txCount;

  GetLedgersByLedgerIdMemberStats200ResponseItemsInnerBuilder() {
    GetLedgersByLedgerIdMemberStats200ResponseItemsInner._defaults(this);
  }

  GetLedgersByLedgerIdMemberStats200ResponseItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userId = $v.userId;
      _memberId = $v.memberId;
      _sesameNumber = $v.sesameNumber;
      _displayName = $v.displayName;
      _avatarUrl = $v.avatarUrl;
      _avatarVersion = $v.avatarVersion;
      _role = $v.role;
      _incomeTotal = $v.incomeTotal;
      _expenseTotal = $v.expenseTotal;
      _txCount = $v.txCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetLedgersByLedgerIdMemberStats200ResponseItemsInner other) {
    _$v = other as _$GetLedgersByLedgerIdMemberStats200ResponseItemsInner;
  }

  @override
  void update(
      void Function(
              GetLedgersByLedgerIdMemberStats200ResponseItemsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetLedgersByLedgerIdMemberStats200ResponseItemsInner build() => _build();

  _$GetLedgersByLedgerIdMemberStats200ResponseItemsInner _build() {
    final _$result = _$v ??
        _$GetLedgersByLedgerIdMemberStats200ResponseItemsInner._(
          userId: userId,
          memberId: memberId,
          sesameNumber: sesameNumber,
          displayName: displayName,
          avatarUrl: avatarUrl,
          avatarVersion: BuiltValueNullFieldError.checkNotNull(
              avatarVersion,
              r'GetLedgersByLedgerIdMemberStats200ResponseItemsInner',
              'avatarVersion'),
          role: BuiltValueNullFieldError.checkNotNull(role,
              r'GetLedgersByLedgerIdMemberStats200ResponseItemsInner', 'role'),
          incomeTotal: BuiltValueNullFieldError.checkNotNull(
              incomeTotal,
              r'GetLedgersByLedgerIdMemberStats200ResponseItemsInner',
              'incomeTotal'),
          expenseTotal: BuiltValueNullFieldError.checkNotNull(
              expenseTotal,
              r'GetLedgersByLedgerIdMemberStats200ResponseItemsInner',
              'expenseTotal'),
          txCount: BuiltValueNullFieldError.checkNotNull(
              txCount,
              r'GetLedgersByLedgerIdMemberStats200ResponseItemsInner',
              'txCount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
