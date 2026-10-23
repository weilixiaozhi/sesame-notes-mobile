// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of2_any_of_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload
    extends PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload {
  @override
  final String name;
  @override
  final String currency;
  @override
  final int monthStartDay;
  @override
  final bool aaEnabled;

  factory _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload._(
      {required this.name,
      required this.currency,
      required this.monthStartDay,
      required this.aaEnabled})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload &&
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
            r'PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload')
          ..add('name', name)
          ..add('currency', currency)
          ..add('monthStartDay', monthStartDay)
          ..add('aaEnabled', aaEnabled))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload? _$v;

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

  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder get _$this {
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
  void replace(PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload._(
          name: BuiltValueNullFieldError.checkNotNull(name,
              r'PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload', 'name'),
          currency: BuiltValueNullFieldError.checkNotNull(currency,
              r'PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload', 'currency'),
          monthStartDay: BuiltValueNullFieldError.checkNotNull(
              monthStartDay,
              r'PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload',
              'monthStartDay'),
          aaEnabled: BuiltValueNullFieldError.checkNotNull(
              aaEnabled,
              r'PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload',
              'aaEnabled'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
