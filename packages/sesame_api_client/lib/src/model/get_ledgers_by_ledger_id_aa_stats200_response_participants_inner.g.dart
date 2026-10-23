// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_ledgers_by_ledger_id_aa_stats200_response_participants_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetLedgersByLedgerIdAaStats200ResponseParticipantsInner
    extends GetLedgersByLedgerIdAaStats200ResponseParticipantsInner {
  @override
  final String memberId;
  @override
  final String displayName;
  @override
  final bool isSelf;
  @override
  final String totalPaid;
  @override
  final String totalShouldPay;
  @override
  final String net;
  @override
  final String nonSplitPaid;

  factory _$GetLedgersByLedgerIdAaStats200ResponseParticipantsInner(
          [void Function(
                  GetLedgersByLedgerIdAaStats200ResponseParticipantsInnerBuilder)?
              updates]) =>
      (GetLedgersByLedgerIdAaStats200ResponseParticipantsInnerBuilder()
            ..update(updates))
          ._build();

  _$GetLedgersByLedgerIdAaStats200ResponseParticipantsInner._(
      {required this.memberId,
      required this.displayName,
      required this.isSelf,
      required this.totalPaid,
      required this.totalShouldPay,
      required this.net,
      required this.nonSplitPaid})
      : super._();
  @override
  GetLedgersByLedgerIdAaStats200ResponseParticipantsInner rebuild(
          void Function(
                  GetLedgersByLedgerIdAaStats200ResponseParticipantsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetLedgersByLedgerIdAaStats200ResponseParticipantsInnerBuilder toBuilder() =>
      GetLedgersByLedgerIdAaStats200ResponseParticipantsInnerBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetLedgersByLedgerIdAaStats200ResponseParticipantsInner &&
        memberId == other.memberId &&
        displayName == other.displayName &&
        isSelf == other.isSelf &&
        totalPaid == other.totalPaid &&
        totalShouldPay == other.totalShouldPay &&
        net == other.net &&
        nonSplitPaid == other.nonSplitPaid;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, memberId.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, isSelf.hashCode);
    _$hash = $jc(_$hash, totalPaid.hashCode);
    _$hash = $jc(_$hash, totalShouldPay.hashCode);
    _$hash = $jc(_$hash, net.hashCode);
    _$hash = $jc(_$hash, nonSplitPaid.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetLedgersByLedgerIdAaStats200ResponseParticipantsInner')
          ..add('memberId', memberId)
          ..add('displayName', displayName)
          ..add('isSelf', isSelf)
          ..add('totalPaid', totalPaid)
          ..add('totalShouldPay', totalShouldPay)
          ..add('net', net)
          ..add('nonSplitPaid', nonSplitPaid))
        .toString();
  }
}

class GetLedgersByLedgerIdAaStats200ResponseParticipantsInnerBuilder
    implements
        Builder<GetLedgersByLedgerIdAaStats200ResponseParticipantsInner,
            GetLedgersByLedgerIdAaStats200ResponseParticipantsInnerBuilder> {
  _$GetLedgersByLedgerIdAaStats200ResponseParticipantsInner? _$v;

  String? _memberId;
  String? get memberId => _$this._memberId;
  set memberId(String? memberId) => _$this._memberId = memberId;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  bool? _isSelf;
  bool? get isSelf => _$this._isSelf;
  set isSelf(bool? isSelf) => _$this._isSelf = isSelf;

  String? _totalPaid;
  String? get totalPaid => _$this._totalPaid;
  set totalPaid(String? totalPaid) => _$this._totalPaid = totalPaid;

  String? _totalShouldPay;
  String? get totalShouldPay => _$this._totalShouldPay;
  set totalShouldPay(String? totalShouldPay) =>
      _$this._totalShouldPay = totalShouldPay;

  String? _net;
  String? get net => _$this._net;
  set net(String? net) => _$this._net = net;

  String? _nonSplitPaid;
  String? get nonSplitPaid => _$this._nonSplitPaid;
  set nonSplitPaid(String? nonSplitPaid) => _$this._nonSplitPaid = nonSplitPaid;

  GetLedgersByLedgerIdAaStats200ResponseParticipantsInnerBuilder() {
    GetLedgersByLedgerIdAaStats200ResponseParticipantsInner._defaults(this);
  }

  GetLedgersByLedgerIdAaStats200ResponseParticipantsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _memberId = $v.memberId;
      _displayName = $v.displayName;
      _isSelf = $v.isSelf;
      _totalPaid = $v.totalPaid;
      _totalShouldPay = $v.totalShouldPay;
      _net = $v.net;
      _nonSplitPaid = $v.nonSplitPaid;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetLedgersByLedgerIdAaStats200ResponseParticipantsInner other) {
    _$v = other as _$GetLedgersByLedgerIdAaStats200ResponseParticipantsInner;
  }

  @override
  void update(
      void Function(
              GetLedgersByLedgerIdAaStats200ResponseParticipantsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetLedgersByLedgerIdAaStats200ResponseParticipantsInner build() => _build();

  _$GetLedgersByLedgerIdAaStats200ResponseParticipantsInner _build() {
    final _$result = _$v ??
        _$GetLedgersByLedgerIdAaStats200ResponseParticipantsInner._(
          memberId: BuiltValueNullFieldError.checkNotNull(
              memberId,
              r'GetLedgersByLedgerIdAaStats200ResponseParticipantsInner',
              'memberId'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName,
              r'GetLedgersByLedgerIdAaStats200ResponseParticipantsInner',
              'displayName'),
          isSelf: BuiltValueNullFieldError.checkNotNull(
              isSelf,
              r'GetLedgersByLedgerIdAaStats200ResponseParticipantsInner',
              'isSelf'),
          totalPaid: BuiltValueNullFieldError.checkNotNull(
              totalPaid,
              r'GetLedgersByLedgerIdAaStats200ResponseParticipantsInner',
              'totalPaid'),
          totalShouldPay: BuiltValueNullFieldError.checkNotNull(
              totalShouldPay,
              r'GetLedgersByLedgerIdAaStats200ResponseParticipantsInner',
              'totalShouldPay'),
          net: BuiltValueNullFieldError.checkNotNull(
              net,
              r'GetLedgersByLedgerIdAaStats200ResponseParticipantsInner',
              'net'),
          nonSplitPaid: BuiltValueNullFieldError.checkNotNull(
              nonSplitPaid,
              r'GetLedgersByLedgerIdAaStats200ResponseParticipantsInner',
              'nonSplitPaid'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
