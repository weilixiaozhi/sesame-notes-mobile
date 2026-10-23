// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_category_conflicts_by_conflict_id_resolve_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostCategoryConflictsByConflictIdResolveRequestChoiceEnum
    _$postCategoryConflictsByConflictIdResolveRequestChoiceEnum_cloud =
    const PostCategoryConflictsByConflictIdResolveRequestChoiceEnum._('cloud');
const PostCategoryConflictsByConflictIdResolveRequestChoiceEnum
    _$postCategoryConflictsByConflictIdResolveRequestChoiceEnum_local =
    const PostCategoryConflictsByConflictIdResolveRequestChoiceEnum._('local');

PostCategoryConflictsByConflictIdResolveRequestChoiceEnum
    _$postCategoryConflictsByConflictIdResolveRequestChoiceEnumValueOf(
        String name) {
  switch (name) {
    case 'cloud':
      return _$postCategoryConflictsByConflictIdResolveRequestChoiceEnum_cloud;
    case 'local':
      return _$postCategoryConflictsByConflictIdResolveRequestChoiceEnum_local;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostCategoryConflictsByConflictIdResolveRequestChoiceEnum>
    _$postCategoryConflictsByConflictIdResolveRequestChoiceEnumValues =
    BuiltSet<
        PostCategoryConflictsByConflictIdResolveRequestChoiceEnum>(const <PostCategoryConflictsByConflictIdResolveRequestChoiceEnum>[
  _$postCategoryConflictsByConflictIdResolveRequestChoiceEnum_cloud,
  _$postCategoryConflictsByConflictIdResolveRequestChoiceEnum_local,
]);

Serializer<PostCategoryConflictsByConflictIdResolveRequestChoiceEnum>
    _$postCategoryConflictsByConflictIdResolveRequestChoiceEnumSerializer =
    _$PostCategoryConflictsByConflictIdResolveRequestChoiceEnumSerializer();

class _$PostCategoryConflictsByConflictIdResolveRequestChoiceEnumSerializer
    implements
        PrimitiveSerializer<
            PostCategoryConflictsByConflictIdResolveRequestChoiceEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'cloud': 'cloud',
    'local': 'local',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'cloud': 'cloud',
    'local': 'local',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostCategoryConflictsByConflictIdResolveRequestChoiceEnum
  ];
  @override
  final String wireName =
      'PostCategoryConflictsByConflictIdResolveRequestChoiceEnum';

  @override
  Object serialize(Serializers serializers,
          PostCategoryConflictsByConflictIdResolveRequestChoiceEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostCategoryConflictsByConflictIdResolveRequestChoiceEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostCategoryConflictsByConflictIdResolveRequestChoiceEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostCategoryConflictsByConflictIdResolveRequest
    extends PostCategoryConflictsByConflictIdResolveRequest {
  @override
  final String mutationId;
  @override
  final int expectedCandidateVersion;
  @override
  final String expectedCloudToken;
  @override
  final PostCategoryConflictsByConflictIdResolveRequestChoiceEnum choice;
  @override
  final bool? restoreDeleted;

  factory _$PostCategoryConflictsByConflictIdResolveRequest(
          [void Function(
                  PostCategoryConflictsByConflictIdResolveRequestBuilder)?
              updates]) =>
      (PostCategoryConflictsByConflictIdResolveRequestBuilder()
            ..update(updates))
          ._build();

  _$PostCategoryConflictsByConflictIdResolveRequest._(
      {required this.mutationId,
      required this.expectedCandidateVersion,
      required this.expectedCloudToken,
      required this.choice,
      this.restoreDeleted})
      : super._();
  @override
  PostCategoryConflictsByConflictIdResolveRequest rebuild(
          void Function(PostCategoryConflictsByConflictIdResolveRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostCategoryConflictsByConflictIdResolveRequestBuilder toBuilder() =>
      PostCategoryConflictsByConflictIdResolveRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostCategoryConflictsByConflictIdResolveRequest &&
        mutationId == other.mutationId &&
        expectedCandidateVersion == other.expectedCandidateVersion &&
        expectedCloudToken == other.expectedCloudToken &&
        choice == other.choice &&
        restoreDeleted == other.restoreDeleted;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mutationId.hashCode);
    _$hash = $jc(_$hash, expectedCandidateVersion.hashCode);
    _$hash = $jc(_$hash, expectedCloudToken.hashCode);
    _$hash = $jc(_$hash, choice.hashCode);
    _$hash = $jc(_$hash, restoreDeleted.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostCategoryConflictsByConflictIdResolveRequest')
          ..add('mutationId', mutationId)
          ..add('expectedCandidateVersion', expectedCandidateVersion)
          ..add('expectedCloudToken', expectedCloudToken)
          ..add('choice', choice)
          ..add('restoreDeleted', restoreDeleted))
        .toString();
  }
}

class PostCategoryConflictsByConflictIdResolveRequestBuilder
    implements
        Builder<PostCategoryConflictsByConflictIdResolveRequest,
            PostCategoryConflictsByConflictIdResolveRequestBuilder> {
  _$PostCategoryConflictsByConflictIdResolveRequest? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  int? _expectedCandidateVersion;
  int? get expectedCandidateVersion => _$this._expectedCandidateVersion;
  set expectedCandidateVersion(int? expectedCandidateVersion) =>
      _$this._expectedCandidateVersion = expectedCandidateVersion;

  String? _expectedCloudToken;
  String? get expectedCloudToken => _$this._expectedCloudToken;
  set expectedCloudToken(String? expectedCloudToken) =>
      _$this._expectedCloudToken = expectedCloudToken;

  PostCategoryConflictsByConflictIdResolveRequestChoiceEnum? _choice;
  PostCategoryConflictsByConflictIdResolveRequestChoiceEnum? get choice =>
      _$this._choice;
  set choice(
          PostCategoryConflictsByConflictIdResolveRequestChoiceEnum? choice) =>
      _$this._choice = choice;

  bool? _restoreDeleted;
  bool? get restoreDeleted => _$this._restoreDeleted;
  set restoreDeleted(bool? restoreDeleted) =>
      _$this._restoreDeleted = restoreDeleted;

  PostCategoryConflictsByConflictIdResolveRequestBuilder() {
    PostCategoryConflictsByConflictIdResolveRequest._defaults(this);
  }

  PostCategoryConflictsByConflictIdResolveRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mutationId = $v.mutationId;
      _expectedCandidateVersion = $v.expectedCandidateVersion;
      _expectedCloudToken = $v.expectedCloudToken;
      _choice = $v.choice;
      _restoreDeleted = $v.restoreDeleted;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostCategoryConflictsByConflictIdResolveRequest other) {
    _$v = other as _$PostCategoryConflictsByConflictIdResolveRequest;
  }

  @override
  void update(
      void Function(PostCategoryConflictsByConflictIdResolveRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostCategoryConflictsByConflictIdResolveRequest build() => _build();

  _$PostCategoryConflictsByConflictIdResolveRequest _build() {
    final _$result = _$v ??
        _$PostCategoryConflictsByConflictIdResolveRequest._(
          mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
              r'PostCategoryConflictsByConflictIdResolveRequest', 'mutationId'),
          expectedCandidateVersion: BuiltValueNullFieldError.checkNotNull(
              expectedCandidateVersion,
              r'PostCategoryConflictsByConflictIdResolveRequest',
              'expectedCandidateVersion'),
          expectedCloudToken: BuiltValueNullFieldError.checkNotNull(
              expectedCloudToken,
              r'PostCategoryConflictsByConflictIdResolveRequest',
              'expectedCloudToken'),
          choice: BuiltValueNullFieldError.checkNotNull(choice,
              r'PostCategoryConflictsByConflictIdResolveRequest', 'choice'),
          restoreDeleted: restoreDeleted,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
