// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_analytics_events200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAnalyticsEvents200Response extends PostAnalyticsEvents200Response {
  @override
  final int accepted;
  @override
  final int duplicates;

  factory _$PostAnalyticsEvents200Response(
          [void Function(PostAnalyticsEvents200ResponseBuilder)? updates]) =>
      (PostAnalyticsEvents200ResponseBuilder()..update(updates))._build();

  _$PostAnalyticsEvents200Response._(
      {required this.accepted, required this.duplicates})
      : super._();
  @override
  PostAnalyticsEvents200Response rebuild(
          void Function(PostAnalyticsEvents200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAnalyticsEvents200ResponseBuilder toBuilder() =>
      PostAnalyticsEvents200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAnalyticsEvents200Response &&
        accepted == other.accepted &&
        duplicates == other.duplicates;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accepted.hashCode);
    _$hash = $jc(_$hash, duplicates.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostAnalyticsEvents200Response')
          ..add('accepted', accepted)
          ..add('duplicates', duplicates))
        .toString();
  }
}

class PostAnalyticsEvents200ResponseBuilder
    implements
        Builder<PostAnalyticsEvents200Response,
            PostAnalyticsEvents200ResponseBuilder> {
  _$PostAnalyticsEvents200Response? _$v;

  int? _accepted;
  int? get accepted => _$this._accepted;
  set accepted(int? accepted) => _$this._accepted = accepted;

  int? _duplicates;
  int? get duplicates => _$this._duplicates;
  set duplicates(int? duplicates) => _$this._duplicates = duplicates;

  PostAnalyticsEvents200ResponseBuilder() {
    PostAnalyticsEvents200Response._defaults(this);
  }

  PostAnalyticsEvents200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accepted = $v.accepted;
      _duplicates = $v.duplicates;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAnalyticsEvents200Response other) {
    _$v = other as _$PostAnalyticsEvents200Response;
  }

  @override
  void update(void Function(PostAnalyticsEvents200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAnalyticsEvents200Response build() => _build();

  _$PostAnalyticsEvents200Response _build() {
    final _$result = _$v ??
        _$PostAnalyticsEvents200Response._(
          accepted: BuiltValueNullFieldError.checkNotNull(
              accepted, r'PostAnalyticsEvents200Response', 'accepted'),
          duplicates: BuiltValueNullFieldError.checkNotNull(
              duplicates, r'PostAnalyticsEvents200Response', 'duplicates'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
