// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_admin_banner_targets200_response_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListAdminBannerTargets200ResponseItemsInner
    extends ListAdminBannerTargets200ResponseItemsInner {
  @override
  final String id;
  @override
  final ListAdminBannerTargets200ResponseItemsInnerName name;

  factory _$ListAdminBannerTargets200ResponseItemsInner(
          [void Function(ListAdminBannerTargets200ResponseItemsInnerBuilder)?
              updates]) =>
      (ListAdminBannerTargets200ResponseItemsInnerBuilder()..update(updates))
          ._build();

  _$ListAdminBannerTargets200ResponseItemsInner._(
      {required this.id, required this.name})
      : super._();
  @override
  ListAdminBannerTargets200ResponseItemsInner rebuild(
          void Function(ListAdminBannerTargets200ResponseItemsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListAdminBannerTargets200ResponseItemsInnerBuilder toBuilder() =>
      ListAdminBannerTargets200ResponseItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListAdminBannerTargets200ResponseItemsInner &&
        id == other.id &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'ListAdminBannerTargets200ResponseItemsInner')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class ListAdminBannerTargets200ResponseItemsInnerBuilder
    implements
        Builder<ListAdminBannerTargets200ResponseItemsInner,
            ListAdminBannerTargets200ResponseItemsInnerBuilder> {
  _$ListAdminBannerTargets200ResponseItemsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  ListAdminBannerTargets200ResponseItemsInnerNameBuilder? _name;
  ListAdminBannerTargets200ResponseItemsInnerNameBuilder get name =>
      _$this._name ??= ListAdminBannerTargets200ResponseItemsInnerNameBuilder();
  set name(ListAdminBannerTargets200ResponseItemsInnerNameBuilder? name) =>
      _$this._name = name;

  ListAdminBannerTargets200ResponseItemsInnerBuilder() {
    ListAdminBannerTargets200ResponseItemsInner._defaults(this);
  }

  ListAdminBannerTargets200ResponseItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ListAdminBannerTargets200ResponseItemsInner other) {
    _$v = other as _$ListAdminBannerTargets200ResponseItemsInner;
  }

  @override
  void update(
      void Function(ListAdminBannerTargets200ResponseItemsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  ListAdminBannerTargets200ResponseItemsInner build() => _build();

  _$ListAdminBannerTargets200ResponseItemsInner _build() {
    _$ListAdminBannerTargets200ResponseItemsInner _$result;
    try {
      _$result = _$v ??
          _$ListAdminBannerTargets200ResponseItemsInner._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'ListAdminBannerTargets200ResponseItemsInner', 'id'),
            name: name.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'name';
        name.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ListAdminBannerTargets200ResponseItemsInner',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
