// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_analytics_funnel200_response_steps_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAdminAnalyticsFunnel200ResponseStepsInner
    extends PostAdminAnalyticsFunnel200ResponseStepsInner {
  @override
  final String id;
  @override
  final String name;
  @override
  final int users;
  @override
  final num? conversionRate;
  @override
  final int dropOff;

  factory _$PostAdminAnalyticsFunnel200ResponseStepsInner(
          [void Function(PostAdminAnalyticsFunnel200ResponseStepsInnerBuilder)?
              updates]) =>
      (PostAdminAnalyticsFunnel200ResponseStepsInnerBuilder()..update(updates))
          ._build();

  _$PostAdminAnalyticsFunnel200ResponseStepsInner._(
      {required this.id,
      required this.name,
      required this.users,
      this.conversionRate,
      required this.dropOff})
      : super._();
  @override
  PostAdminAnalyticsFunnel200ResponseStepsInner rebuild(
          void Function(PostAdminAnalyticsFunnel200ResponseStepsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminAnalyticsFunnel200ResponseStepsInnerBuilder toBuilder() =>
      PostAdminAnalyticsFunnel200ResponseStepsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminAnalyticsFunnel200ResponseStepsInner &&
        id == other.id &&
        name == other.name &&
        users == other.users &&
        conversionRate == other.conversionRate &&
        dropOff == other.dropOff;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, users.hashCode);
    _$hash = $jc(_$hash, conversionRate.hashCode);
    _$hash = $jc(_$hash, dropOff.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostAdminAnalyticsFunnel200ResponseStepsInner')
          ..add('id', id)
          ..add('name', name)
          ..add('users', users)
          ..add('conversionRate', conversionRate)
          ..add('dropOff', dropOff))
        .toString();
  }
}

class PostAdminAnalyticsFunnel200ResponseStepsInnerBuilder
    implements
        Builder<PostAdminAnalyticsFunnel200ResponseStepsInner,
            PostAdminAnalyticsFunnel200ResponseStepsInnerBuilder> {
  _$PostAdminAnalyticsFunnel200ResponseStepsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _users;
  int? get users => _$this._users;
  set users(int? users) => _$this._users = users;

  num? _conversionRate;
  num? get conversionRate => _$this._conversionRate;
  set conversionRate(num? conversionRate) =>
      _$this._conversionRate = conversionRate;

  int? _dropOff;
  int? get dropOff => _$this._dropOff;
  set dropOff(int? dropOff) => _$this._dropOff = dropOff;

  PostAdminAnalyticsFunnel200ResponseStepsInnerBuilder() {
    PostAdminAnalyticsFunnel200ResponseStepsInner._defaults(this);
  }

  PostAdminAnalyticsFunnel200ResponseStepsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _users = $v.users;
      _conversionRate = $v.conversionRate;
      _dropOff = $v.dropOff;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminAnalyticsFunnel200ResponseStepsInner other) {
    _$v = other as _$PostAdminAnalyticsFunnel200ResponseStepsInner;
  }

  @override
  void update(
      void Function(PostAdminAnalyticsFunnel200ResponseStepsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminAnalyticsFunnel200ResponseStepsInner build() => _build();

  _$PostAdminAnalyticsFunnel200ResponseStepsInner _build() {
    final _$result = _$v ??
        _$PostAdminAnalyticsFunnel200ResponseStepsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'PostAdminAnalyticsFunnel200ResponseStepsInner', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'PostAdminAnalyticsFunnel200ResponseStepsInner', 'name'),
          users: BuiltValueNullFieldError.checkNotNull(
              users, r'PostAdminAnalyticsFunnel200ResponseStepsInner', 'users'),
          conversionRate: conversionRate,
          dropOff: BuiltValueNullFieldError.checkNotNull(dropOff,
              r'PostAdminAnalyticsFunnel200ResponseStepsInner', 'dropOff'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
