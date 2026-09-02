// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_status200_response_ledgers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminStatus200ResponseLedgers
    extends GetAdminStatus200ResponseLedgers {
  @override
  final int total;

  factory _$GetAdminStatus200ResponseLedgers(
          [void Function(GetAdminStatus200ResponseLedgersBuilder)? updates]) =>
      (GetAdminStatus200ResponseLedgersBuilder()..update(updates))._build();

  _$GetAdminStatus200ResponseLedgers._({required this.total}) : super._();
  @override
  GetAdminStatus200ResponseLedgers rebuild(
          void Function(GetAdminStatus200ResponseLedgersBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminStatus200ResponseLedgersBuilder toBuilder() =>
      GetAdminStatus200ResponseLedgersBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminStatus200ResponseLedgers && total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetAdminStatus200ResponseLedgers')
          ..add('total', total))
        .toString();
  }
}

class GetAdminStatus200ResponseLedgersBuilder
    implements
        Builder<GetAdminStatus200ResponseLedgers,
            GetAdminStatus200ResponseLedgersBuilder> {
  _$GetAdminStatus200ResponseLedgers? _$v;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  GetAdminStatus200ResponseLedgersBuilder() {
    GetAdminStatus200ResponseLedgers._defaults(this);
  }

  GetAdminStatus200ResponseLedgersBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminStatus200ResponseLedgers other) {
    _$v = other as _$GetAdminStatus200ResponseLedgers;
  }

  @override
  void update(void Function(GetAdminStatus200ResponseLedgersBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminStatus200ResponseLedgers build() => _build();

  _$GetAdminStatus200ResponseLedgers _build() {
    final _$result = _$v ??
        _$GetAdminStatus200ResponseLedgers._(
          total: BuiltValueNullFieldError.checkNotNull(
              total, r'GetAdminStatus200ResponseLedgers', 'total'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
