// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of4_any_of_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload
    extends PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload {
  @override
  final String baseCurrency;
  @override
  final String quoteCurrency;
  @override
  final String rate;

  factory _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload._(
      {required this.baseCurrency,
      required this.quoteCurrency,
      required this.rate})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload &&
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
            r'PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload')
          ..add('baseCurrency', baseCurrency)
          ..add('quoteCurrency', quoteCurrency)
          ..add('rate', rate))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload? _$v;

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

  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder get _$this {
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
  void replace(PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload._(
          baseCurrency: BuiltValueNullFieldError.checkNotNull(
              baseCurrency,
              r'PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload',
              'baseCurrency'),
          quoteCurrency: BuiltValueNullFieldError.checkNotNull(
              quoteCurrency,
              r'PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload',
              'quoteCurrency'),
          rate: BuiltValueNullFieldError.checkNotNull(rate,
              r'PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload', 'rate'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
