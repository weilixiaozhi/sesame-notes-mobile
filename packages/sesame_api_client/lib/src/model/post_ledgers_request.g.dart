// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersRequest extends PostLedgersRequest {
  @override
  final String? id;
  @override
  final String name;
  @override
  final String? currency;
  @override
  final int? monthStartDay;
  @override
  final bool? aaEnabled;

  factory _$PostLedgersRequest(
          [void Function(PostLedgersRequestBuilder)? updates]) =>
      (PostLedgersRequestBuilder()..update(updates))._build();

  _$PostLedgersRequest._(
      {this.id,
      required this.name,
      this.currency,
      this.monthStartDay,
      this.aaEnabled})
      : super._();
  @override
  PostLedgersRequest rebuild(
          void Function(PostLedgersRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersRequestBuilder toBuilder() =>
      PostLedgersRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersRequest &&
        id == other.id &&
        name == other.name &&
        currency == other.currency &&
        monthStartDay == other.monthStartDay &&
        aaEnabled == other.aaEnabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, monthStartDay.hashCode);
    _$hash = $jc(_$hash, aaEnabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostLedgersRequest')
          ..add('id', id)
          ..add('name', name)
          ..add('currency', currency)
          ..add('monthStartDay', monthStartDay)
          ..add('aaEnabled', aaEnabled))
        .toString();
  }
}

class PostLedgersRequestBuilder
    implements Builder<PostLedgersRequest, PostLedgersRequestBuilder> {
  _$PostLedgersRequest? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  int? _monthStartDay;
  int? get monthStartDay => _$this._monthStartDay;
  set monthStartDay(int? monthStartDay) =>
      _$this._monthStartDay = monthStartDay;

  bool? _aaEnabled;
  bool? get aaEnabled => _$this._aaEnabled;
  set aaEnabled(bool? aaEnabled) => _$this._aaEnabled = aaEnabled;

  PostLedgersRequestBuilder() {
    PostLedgersRequest._defaults(this);
  }

  PostLedgersRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _currency = $v.currency;
      _monthStartDay = $v.monthStartDay;
      _aaEnabled = $v.aaEnabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersRequest other) {
    _$v = other as _$PostLedgersRequest;
  }

  @override
  void update(void Function(PostLedgersRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersRequest build() => _build();

  _$PostLedgersRequest _build() {
    final _$result = _$v ??
        _$PostLedgersRequest._(
          id: id,
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'PostLedgersRequest', 'name'),
          currency: currency,
          monthStartDay: monthStartDay,
          aaEnabled: aaEnabled,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
