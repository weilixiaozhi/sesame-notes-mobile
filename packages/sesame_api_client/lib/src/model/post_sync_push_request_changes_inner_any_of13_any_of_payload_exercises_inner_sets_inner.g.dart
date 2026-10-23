// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of13_any_of_payload_exercises_inner_sets_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum_warmup =
    const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum
        ._('warmup');
const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum_working =
    const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum
        ._('working');

PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnumValueOf(
        String name) {
  switch (name) {
    case 'warmup':
      return _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum_warmup;
    case 'working':
      return _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum_working;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum>
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum>(const <PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum>[
  _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum_warmup,
  _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum_working,
]);

Serializer<
        PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum>
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'warmup': 'warmup',
    'working': 'working',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'warmup': 'warmup',
    'working': 'working',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum';

  @override
  Object serialize(
          Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner
    extends PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner {
  @override
  final String id;
  @override
  final PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum
      kind;
  @override
  final String? weight;
  @override
  final String? weightLeft;
  @override
  final String? weightRight;
  @override
  final int? reps;
  @override
  final bool completed;
  @override
  final BuiltList<int>? restDurationsSeconds;

  factory _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner._(
      {required this.id,
      required this.kind,
      this.weight,
      this.weightLeft,
      this.weightRight,
      this.reps,
      required this.completed,
      this.restDurationsSeconds})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerBuilder
      toBuilder() =>
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner &&
        id == other.id &&
        kind == other.kind &&
        weight == other.weight &&
        weightLeft == other.weightLeft &&
        weightRight == other.weightRight &&
        reps == other.reps &&
        completed == other.completed &&
        restDurationsSeconds == other.restDurationsSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, weight.hashCode);
    _$hash = $jc(_$hash, weightLeft.hashCode);
    _$hash = $jc(_$hash, weightRight.hashCode);
    _$hash = $jc(_$hash, reps.hashCode);
    _$hash = $jc(_$hash, completed.hashCode);
    _$hash = $jc(_$hash, restDurationsSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner')
          ..add('id', id)
          ..add('kind', kind)
          ..add('weight', weight)
          ..add('weightLeft', weightLeft)
          ..add('weightRight', weightRight)
          ..add('reps', reps)
          ..add('completed', completed)
          ..add('restDurationsSeconds', restDurationsSeconds))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerBuilder
    implements
        Builder<
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner,
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner?
      _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum?
      _kind;
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum?
      get kind => _$this._kind;
  set kind(
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum?
              kind) =>
      _$this._kind = kind;

  String? _weight;
  String? get weight => _$this._weight;
  set weight(String? weight) => _$this._weight = weight;

  String? _weightLeft;
  String? get weightLeft => _$this._weightLeft;
  set weightLeft(String? weightLeft) => _$this._weightLeft = weightLeft;

  String? _weightRight;
  String? get weightRight => _$this._weightRight;
  set weightRight(String? weightRight) => _$this._weightRight = weightRight;

  int? _reps;
  int? get reps => _$this._reps;
  set reps(int? reps) => _$this._reps = reps;

  bool? _completed;
  bool? get completed => _$this._completed;
  set completed(bool? completed) => _$this._completed = completed;

  ListBuilder<int>? _restDurationsSeconds;
  ListBuilder<int> get restDurationsSeconds =>
      _$this._restDurationsSeconds ??= ListBuilder<int>();
  set restDurationsSeconds(ListBuilder<int>? restDurationsSeconds) =>
      _$this._restDurationsSeconds = restDurationsSeconds;

  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerBuilder() {
    PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner
        ._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _kind = $v.kind;
      _weight = $v.weight;
      _weightLeft = $v.weightLeft;
      _weightRight = $v.weightRight;
      _reps = $v.reps;
      _completed = $v.completed;
      _restDurationsSeconds = $v.restDurationsSeconds?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner
          other) {
    _$v = other
        as _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner;
  }

  @override
  void update(
      void Function(
              PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner
      build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner
      _build() {
    _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner
        _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner
              ._(
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner',
                'id'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind,
                r'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner',
                'kind'),
            weight: weight,
            weightLeft: weightLeft,
            weightRight: weightRight,
            reps: reps,
            completed: BuiltValueNullFieldError.checkNotNull(
                completed,
                r'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner',
                'completed'),
            restDurationsSeconds: _restDurationsSeconds?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'restDurationsSeconds';
        _restDurationsSeconds?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner',
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
