// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of_any_of_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostSyncPushRequestChangesInnerAnyOfAnyOfPayload
    extends PostSyncPushRequestChangesInnerAnyOfAnyOfPayload {
  @override
  final String name;
  @override
  final String currency;
  @override
  final int monthStartDay;
  @override
  final bool aaEnabled;

  factory _$PostSyncPushRequestChangesInnerAnyOfAnyOfPayload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOfAnyOfPayload._(
      {required this.name,
      required this.currency,
      required this.monthStartDay,
      required this.aaEnabled})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOfAnyOfPayload rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOfAnyOfPayload &&
        name == other.name &&
        currency == other.currency &&
        monthStartDay == other.monthStartDay &&
        aaEnabled == other.aaEnabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, monthStartDay.hashCode);
    _$hash = $jc(_$hash, aaEnabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOfAnyOfPayload')
          ..add('name', name)
          ..add('currency', currency)
          ..add('monthStartDay', monthStartDay)
          ..add('aaEnabled', aaEnabled))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOfAnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOfAnyOfPayload? _$v;

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

  PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOfAnyOfPayload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _currency = $v.currency;
      _monthStartDay = $v.monthStartDay;
      _aaEnabled = $v.aaEnabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOfAnyOfPayload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOfAnyOfPayload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOfAnyOfPayload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOfAnyOfPayload _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOfAnyOfPayload._(
          name: BuiltValueNullFieldError.checkNotNull(name,
              r'PostSyncPushRequestChangesInnerAnyOfAnyOfPayload', 'name'),
          currency: BuiltValueNullFieldError.checkNotNull(currency,
              r'PostSyncPushRequestChangesInnerAnyOfAnyOfPayload', 'currency'),
          monthStartDay: BuiltValueNullFieldError.checkNotNull(
              monthStartDay,
              r'PostSyncPushRequestChangesInnerAnyOfAnyOfPayload',
              'monthStartDay'),
          aaEnabled: BuiltValueNullFieldError.checkNotNull(aaEnabled,
              r'PostSyncPushRequestChangesInnerAnyOfAnyOfPayload', 'aaEnabled'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
