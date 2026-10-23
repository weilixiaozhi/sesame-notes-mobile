// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of7_any_of_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload
    extends PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload {
  @override
  final String baseCurrency;
  @override
  final String quoteCurrency;
  @override
  final String rate;

  factory _$PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf7AnyOfPayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf7AnyOfPayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload._(
      {required this.baseCurrency,
      required this.quoteCurrency,
      required this.rate})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf7AnyOfPayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf7AnyOfPayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf7AnyOfPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload &&
        baseCurrency == other.baseCurrency &&
        quoteCurrency == other.quoteCurrency &&
        rate == other.rate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, baseCurrency.hashCode);
    _$hash = $jc(_$hash, quoteCurrency.hashCode);
    _$hash = $jc(_$hash, rate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload')
          ..add('baseCurrency', baseCurrency)
          ..add('quoteCurrency', quoteCurrency)
          ..add('rate', rate))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf7AnyOfPayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf7AnyOfPayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload? _$v;

  String? _baseCurrency;
  String? get baseCurrency => _$this._baseCurrency;
  set baseCurrency(String? baseCurrency) => _$this._baseCurrency = baseCurrency;

  String? _quoteCurrency;
  String? get quoteCurrency => _$this._quoteCurrency;
  set quoteCurrency(String? quoteCurrency) =>
      _$this._quoteCurrency = quoteCurrency;

  String? _rate;
  String? get rate => _$this._rate;
  set rate(String? rate) => _$this._rate = rate;

  PostSyncPushRequestChangesInnerAnyOf7AnyOfPayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf7AnyOfPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _baseCurrency = $v.baseCurrency;
      _quoteCurrency = $v.quoteCurrency;
      _rate = $v.rate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf7AnyOfPayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload._(
          baseCurrency: BuiltValueNullFieldError.checkNotNull(
              baseCurrency,
              r'PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload',
              'baseCurrency'),
          quoteCurrency: BuiltValueNullFieldError.checkNotNull(
              quoteCurrency,
              r'PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload',
              'quoteCurrency'),
          rate: BuiltValueNullFieldError.checkNotNull(rate,
              r'PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload', 'rate'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
