//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_analytics_events_request_events_inner.g.dart';

/// PostAnalyticsEventsRequestEventsInner
///
/// Properties:
/// * [eventId]
/// * [occurredAt]
/// * [kind]
/// * [pageId]
/// * [platform]
/// * [appVersion]
/// * [eventName]
/// * [sessionId]
/// * [eventSequence]
/// * [flowId]
@BuiltValue()
abstract class PostAnalyticsEventsRequestEventsInner
    implements
        Built<PostAnalyticsEventsRequestEventsInner,
            PostAnalyticsEventsRequestEventsInnerBuilder> {
  @BuiltValueField(wireName: r'event_id')
  String get eventId;

  @BuiltValueField(wireName: r'occurred_at')
  DateTime get occurredAt;

  @BuiltValueField(wireName: r'kind')
  PostAnalyticsEventsRequestEventsInnerKindEnum get kind;
  // enum kindEnum {  active,  page_view,  action,  };

  @BuiltValueField(wireName: r'page_id')
  PostAnalyticsEventsRequestEventsInnerPageIdEnum? get pageId;
  // enum pageIdEnum {  home,  accounting,  accounting.transaction,  accounting.transaction.editor,  accounting.statistics,  accounting.categories,  accounting.aa_split.editor,  accounting.aa_statistics,  accounting.member_statistics,  accounting.ledgers.edit,  accounting.sharing,  fitness,  fitness.exercises,  fitness.exercise,  fitness.templates,  fitness.template,  fitness.plans,  fitness.plan,  fitness.workouts,  fitness.workout,  fitness.statistics,  fitness.calendar,  fitness.templates.library,  fitness.templates.library.detail,  fitness.plans.library.detail,  fitness.library,  fitness.workouts.editor,  memos,  memos.detail,  memos.editor,  credentials,  credentials.detail,  credentials.editor,  credentials.books.edit,  days,  days.detail,  days.editor,  days.calendar,  calendar,  settings,  settings.profile,  accounting.categories.edit,  accounting.categories.templates.flat,  accounting.categories.templates.hierarchical,  accounting.categories.detail,  accounting.aa_member.detail,  accounting.ledgers,  accounting.ledgers.archived,  accounting.ledgers.join,  accounting.currency,  accounting.exchange_rate,  accounting.recurring.editor,  fitness.spaces,  fitness.spaces.edit,  fitness.exercises.edit,  fitness.templates.edit,  fitness.plans.library,  fitness.plans.edit,  memos.tools,  memos.books,  memos.books.edit,  days.tools,  days.books,  days.books.edit,  settings.profile.name,  settings.profile.avatar,  settings.profile.gender,  settings.reminder,  settings.language,  settings.theme,  settings.app_lock,  settings.cloud,  settings.sync,  };

  @BuiltValueField(wireName: r'platform')
  PostAnalyticsEventsRequestEventsInnerPlatformEnum get platform;
  // enum platformEnum {  app,  web,  };

  @BuiltValueField(wireName: r'app_version')
  String? get appVersion;

  @BuiltValueField(wireName: r'event_name')
  PostAnalyticsEventsRequestEventsInnerEventNameEnum? get eventName;
  // enum eventNameEnum {  home_view,  accounting_view,  accounting_transaction_view,  accounting_transaction_editor_view,  accounting_statistics_view,  accounting_categories_view,  accounting_aa_split_editor_view,  accounting_aa_statistics_view,  accounting_member_statistics_view,  accounting_ledgers_edit_view,  accounting_sharing_view,  fitness_view,  fitness_exercises_view,  fitness_exercise_view,  fitness_templates_view,  fitness_template_view,  fitness_plans_view,  fitness_plan_view,  fitness_workouts_view,  fitness_workout_view,  fitness_statistics_view,  fitness_calendar_view,  fitness_templates_library_view,  fitness_templates_library_detail_view,  fitness_plans_library_detail_view,  fitness_library_view,  fitness_workouts_editor_view,  memos_view,  memos_detail_view,  memos_editor_view,  credentials_view,  credentials_detail_view,  credentials_editor_view,  credentials_books_edit_view,  days_view,  days_detail_view,  days_editor_view,  days_calendar_view,  calendar_view,  settings_view,  settings_profile_view,  accounting_categories_edit_view,  accounting_categories_templates_flat_view,  accounting_categories_templates_hierarchical_view,  accounting_categories_detail_view,  accounting_aa_member_detail_view,  accounting_ledgers_view,  accounting_ledgers_archived_view,  accounting_ledgers_join_view,  accounting_currency_view,  accounting_exchange_rate_view,  accounting_recurring_editor_view,  fitness_spaces_view,  fitness_spaces_edit_view,  fitness_exercises_edit_view,  fitness_templates_edit_view,  fitness_plans_library_view,  fitness_plans_edit_view,  memos_tools_view,  memos_books_view,  memos_books_edit_view,  days_tools_view,  days_books_view,  days_books_edit_view,  settings_profile_name_view,  settings_profile_avatar_view,  settings_profile_gender_view,  settings_reminder_view,  settings_language_view,  settings_theme_view,  settings_app_lock_view,  settings_cloud_view,  settings_sync_view,  navigation_mode_select,  navigation_tab_select,  accounting_ledger_select,  accounting_transaction_create_click,  accounting_transaction_open_click,  accounting_transaction_edit_click,  accounting_transaction_save_click,  accounting_transaction_created,  accounting_transaction_updated,  accounting_transaction_deleted,  accounting_statistics_open_click,  accounting_categories_open_click,  fitness_tab_select,  fitness_space_select,  fitness_workout_create_click,  fitness_workout_open_click,  fitness_workout_save_click,  fitness_workout_created,  fitness_workout_updated,  fitness_workout_start_click,  fitness_workout_started,  fitness_workout_pause_click,  fitness_workout_paused,  fitness_workout_finish_click,  fitness_workout_completed,  fitness_template_save_click,  fitness_template_saved,  fitness_plan_save_click,  fitness_plan_saved,  fitness_template_add_click,  fitness_template_added,  fitness_plan_add_click,  fitness_plan_added,  memos_note_create_click,  memos_note_open_click,  memos_note_save_click,  memos_note_saved,  memos_note_created,  memos_note_deleted,  memos_book_select,  credentials_create_click,  credentials_open_click,  credentials_save_click,  credentials_saved,  credentials_created,  credentials_deleted,  credentials_book_select,  days_event_create_click,  days_event_open_click,  days_event_save_click,  days_event_saved,  days_event_created,  days_event_deleted,  days_book_select,  calendar_day_select,  calendar_section_open_click,  calendar_create_click,  settings_theme_changed,  settings_language_changed,  settings_app_lock_changed,  settings_reminder_changed,  };

  @BuiltValueField(wireName: r'session_id')
  String get sessionId;

  @BuiltValueField(wireName: r'event_sequence')
  int get eventSequence;

  @BuiltValueField(wireName: r'flow_id')
  String? get flowId;

  PostAnalyticsEventsRequestEventsInner._();

  factory PostAnalyticsEventsRequestEventsInner(
          [void updates(PostAnalyticsEventsRequestEventsInnerBuilder b)]) =
      _$PostAnalyticsEventsRequestEventsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAnalyticsEventsRequestEventsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAnalyticsEventsRequestEventsInner> get serializer =>
      _$PostAnalyticsEventsRequestEventsInnerSerializer();
}

class _$PostAnalyticsEventsRequestEventsInnerSerializer
    implements PrimitiveSerializer<PostAnalyticsEventsRequestEventsInner> {
  @override
  final Iterable<Type> types = const [
    PostAnalyticsEventsRequestEventsInner,
    _$PostAnalyticsEventsRequestEventsInner
  ];

  @override
  final String wireName = r'PostAnalyticsEventsRequestEventsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAnalyticsEventsRequestEventsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'event_id';
    yield serializers.serialize(
      object.eventId,
      specifiedType: const FullType(String),
    );
    yield r'occurred_at';
    yield serializers.serialize(
      object.occurredAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType:
          const FullType(PostAnalyticsEventsRequestEventsInnerKindEnum),
    );
    if (object.pageId != null) {
      yield r'page_id';
      yield serializers.serialize(
        object.pageId,
        specifiedType:
            const FullType(PostAnalyticsEventsRequestEventsInnerPageIdEnum),
      );
    }
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType:
          const FullType(PostAnalyticsEventsRequestEventsInnerPlatformEnum),
    );
    if (object.appVersion != null) {
      yield r'app_version';
      yield serializers.serialize(
        object.appVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.eventName != null) {
      yield r'event_name';
      yield serializers.serialize(
        object.eventName,
        specifiedType:
            const FullType(PostAnalyticsEventsRequestEventsInnerEventNameEnum),
      );
    }
    yield r'session_id';
    yield serializers.serialize(
      object.sessionId,
      specifiedType: const FullType(String),
    );
    yield r'event_sequence';
    yield serializers.serialize(
      object.eventSequence,
      specifiedType: const FullType(int),
    );
    if (object.flowId != null) {
      yield r'flow_id';
      yield serializers.serialize(
        object.flowId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAnalyticsEventsRequestEventsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostAnalyticsEventsRequestEventsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'event_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.eventId = valueDes;
          break;
        case r'occurred_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.occurredAt = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PostAnalyticsEventsRequestEventsInnerKindEnum),
          ) as PostAnalyticsEventsRequestEventsInnerKindEnum;
          result.kind = valueDes;
          break;
        case r'page_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PostAnalyticsEventsRequestEventsInnerPageIdEnum),
          ) as PostAnalyticsEventsRequestEventsInnerPageIdEnum?;
          if (valueDes == null) continue;
          result.pageId = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostAnalyticsEventsRequestEventsInnerPlatformEnum),
          ) as PostAnalyticsEventsRequestEventsInnerPlatformEnum;
          result.platform = valueDes;
          break;
        case r'app_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.appVersion = valueDes;
          break;
        case r'event_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PostAnalyticsEventsRequestEventsInnerEventNameEnum),
          ) as PostAnalyticsEventsRequestEventsInnerEventNameEnum?;
          if (valueDes == null) continue;
          result.eventName = valueDes;
          break;
        case r'session_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sessionId = valueDes;
          break;
        case r'event_sequence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.eventSequence = valueDes;
          break;
        case r'flow_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.flowId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAnalyticsEventsRequestEventsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAnalyticsEventsRequestEventsInnerBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class PostAnalyticsEventsRequestEventsInnerKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'active')
  static const PostAnalyticsEventsRequestEventsInnerKindEnum active =
      _$postAnalyticsEventsRequestEventsInnerKindEnum_active;
  @BuiltValueEnumConst(wireName: r'page_view')
  static const PostAnalyticsEventsRequestEventsInnerKindEnum pageView =
      _$postAnalyticsEventsRequestEventsInnerKindEnum_pageView;
  @BuiltValueEnumConst(wireName: r'action')
  static const PostAnalyticsEventsRequestEventsInnerKindEnum action =
      _$postAnalyticsEventsRequestEventsInnerKindEnum_action;

  static Serializer<PostAnalyticsEventsRequestEventsInnerKindEnum>
      get serializer =>
          _$postAnalyticsEventsRequestEventsInnerKindEnumSerializer;

  const PostAnalyticsEventsRequestEventsInnerKindEnum._(String name)
      : super(name);

  static BuiltSet<PostAnalyticsEventsRequestEventsInnerKindEnum> get values =>
      _$postAnalyticsEventsRequestEventsInnerKindEnumValues;
  static PostAnalyticsEventsRequestEventsInnerKindEnum valueOf(String name) =>
      _$postAnalyticsEventsRequestEventsInnerKindEnumValueOf(name);
}

class PostAnalyticsEventsRequestEventsInnerPageIdEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'home')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum home =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_home;
  @BuiltValueEnumConst(wireName: r'accounting')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum accounting =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accounting;
  @BuiltValueEnumConst(wireName: r'accounting.transaction')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      accountingPeriodTransaction =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accountingPeriodTransaction;
  @BuiltValueEnumConst(wireName: r'accounting.transaction.editor')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      accountingPeriodTransactionPeriodEditor =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accountingPeriodTransactionPeriodEditor;
  @BuiltValueEnumConst(wireName: r'accounting.statistics')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      accountingPeriodStatistics =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accountingPeriodStatistics;
  @BuiltValueEnumConst(wireName: r'accounting.categories')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      accountingPeriodCategories =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accountingPeriodCategories;
  @BuiltValueEnumConst(wireName: r'accounting.aa_split.editor')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      accountingPeriodAaSplitPeriodEditor =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accountingPeriodAaSplitPeriodEditor;
  @BuiltValueEnumConst(wireName: r'accounting.aa_statistics')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      accountingPeriodAaStatistics =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accountingPeriodAaStatistics;
  @BuiltValueEnumConst(wireName: r'accounting.member_statistics')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      accountingPeriodMemberStatistics =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accountingPeriodMemberStatistics;
  @BuiltValueEnumConst(wireName: r'accounting.ledgers.edit')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      accountingPeriodLedgersPeriodEdit =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accountingPeriodLedgersPeriodEdit;
  @BuiltValueEnumConst(wireName: r'accounting.sharing')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      accountingPeriodSharing =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accountingPeriodSharing;
  @BuiltValueEnumConst(wireName: r'fitness')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum fitness =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitness;
  @BuiltValueEnumConst(wireName: r'fitness.exercises')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodExercises =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodExercises;
  @BuiltValueEnumConst(wireName: r'fitness.exercise')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodExercise =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodExercise;
  @BuiltValueEnumConst(wireName: r'fitness.templates')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodTemplates =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodTemplates;
  @BuiltValueEnumConst(wireName: r'fitness.template')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodTemplate =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodTemplate;
  @BuiltValueEnumConst(wireName: r'fitness.plans')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodPlans =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodPlans;
  @BuiltValueEnumConst(wireName: r'fitness.plan')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodPlan =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodPlan;
  @BuiltValueEnumConst(wireName: r'fitness.workouts')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodWorkouts =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodWorkouts;
  @BuiltValueEnumConst(wireName: r'fitness.workout')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodWorkout =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodWorkout;
  @BuiltValueEnumConst(wireName: r'fitness.statistics')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodStatistics =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodStatistics;
  @BuiltValueEnumConst(wireName: r'fitness.calendar')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodCalendar =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodCalendar;
  @BuiltValueEnumConst(wireName: r'fitness.templates.library')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodTemplatesPeriodLibrary =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodTemplatesPeriodLibrary;
  @BuiltValueEnumConst(wireName: r'fitness.templates.library.detail')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodTemplatesPeriodLibraryPeriodDetail =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodTemplatesPeriodLibraryPeriodDetail;
  @BuiltValueEnumConst(wireName: r'fitness.plans.library.detail')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodPlansPeriodLibraryPeriodDetail =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodPlansPeriodLibraryPeriodDetail;
  @BuiltValueEnumConst(wireName: r'fitness.library')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodLibrary =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodLibrary;
  @BuiltValueEnumConst(wireName: r'fitness.workouts.editor')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodWorkoutsPeriodEditor =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodWorkoutsPeriodEditor;
  @BuiltValueEnumConst(wireName: r'memos')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum memos =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_memos;
  @BuiltValueEnumConst(wireName: r'memos.detail')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      memosPeriodDetail =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_memosPeriodDetail;
  @BuiltValueEnumConst(wireName: r'memos.editor')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      memosPeriodEditor =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_memosPeriodEditor;
  @BuiltValueEnumConst(wireName: r'credentials')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum credentials =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_credentials;
  @BuiltValueEnumConst(wireName: r'credentials.detail')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      credentialsPeriodDetail =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_credentialsPeriodDetail;
  @BuiltValueEnumConst(wireName: r'credentials.editor')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      credentialsPeriodEditor =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_credentialsPeriodEditor;
  @BuiltValueEnumConst(wireName: r'credentials.books.edit')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      credentialsPeriodBooksPeriodEdit =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_credentialsPeriodBooksPeriodEdit;
  @BuiltValueEnumConst(wireName: r'days')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum days =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_days;
  @BuiltValueEnumConst(wireName: r'days.detail')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      daysPeriodDetail =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_daysPeriodDetail;
  @BuiltValueEnumConst(wireName: r'days.editor')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      daysPeriodEditor =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_daysPeriodEditor;
  @BuiltValueEnumConst(wireName: r'days.calendar')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      daysPeriodCalendar =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_daysPeriodCalendar;
  @BuiltValueEnumConst(wireName: r'calendar')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum calendar =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_calendar;
  @BuiltValueEnumConst(wireName: r'settings')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum settings =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_settings;
  @BuiltValueEnumConst(wireName: r'settings.profile')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      settingsPeriodProfile =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_settingsPeriodProfile;
  @BuiltValueEnumConst(wireName: r'accounting.categories.edit')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      accountingPeriodCategoriesPeriodEdit =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accountingPeriodCategoriesPeriodEdit;
  @BuiltValueEnumConst(wireName: r'accounting.categories.templates.flat')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      accountingPeriodCategoriesPeriodTemplatesPeriodFlat =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accountingPeriodCategoriesPeriodTemplatesPeriodFlat;
  @BuiltValueEnumConst(
      wireName: r'accounting.categories.templates.hierarchical')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      accountingPeriodCategoriesPeriodTemplatesPeriodHierarchical =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accountingPeriodCategoriesPeriodTemplatesPeriodHierarchical;
  @BuiltValueEnumConst(wireName: r'accounting.categories.detail')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      accountingPeriodCategoriesPeriodDetail =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accountingPeriodCategoriesPeriodDetail;
  @BuiltValueEnumConst(wireName: r'accounting.aa_member.detail')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      accountingPeriodAaMemberPeriodDetail =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accountingPeriodAaMemberPeriodDetail;
  @BuiltValueEnumConst(wireName: r'accounting.ledgers')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      accountingPeriodLedgers =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accountingPeriodLedgers;
  @BuiltValueEnumConst(wireName: r'accounting.ledgers.archived')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      accountingPeriodLedgersPeriodArchived =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accountingPeriodLedgersPeriodArchived;
  @BuiltValueEnumConst(wireName: r'accounting.ledgers.join')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      accountingPeriodLedgersPeriodJoin =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accountingPeriodLedgersPeriodJoin;
  @BuiltValueEnumConst(wireName: r'accounting.currency')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      accountingPeriodCurrency =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accountingPeriodCurrency;
  @BuiltValueEnumConst(wireName: r'accounting.exchange_rate')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      accountingPeriodExchangeRate =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accountingPeriodExchangeRate;
  @BuiltValueEnumConst(wireName: r'accounting.recurring.editor')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      accountingPeriodRecurringPeriodEditor =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_accountingPeriodRecurringPeriodEditor;
  @BuiltValueEnumConst(wireName: r'fitness.spaces')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodSpaces =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodSpaces;
  @BuiltValueEnumConst(wireName: r'fitness.spaces.edit')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodSpacesPeriodEdit =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodSpacesPeriodEdit;
  @BuiltValueEnumConst(wireName: r'fitness.exercises.edit')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodExercisesPeriodEdit =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodExercisesPeriodEdit;
  @BuiltValueEnumConst(wireName: r'fitness.templates.edit')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodTemplatesPeriodEdit =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodTemplatesPeriodEdit;
  @BuiltValueEnumConst(wireName: r'fitness.plans.library')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodPlansPeriodLibrary =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodPlansPeriodLibrary;
  @BuiltValueEnumConst(wireName: r'fitness.plans.edit')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      fitnessPeriodPlansPeriodEdit =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_fitnessPeriodPlansPeriodEdit;
  @BuiltValueEnumConst(wireName: r'memos.tools')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      memosPeriodTools =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_memosPeriodTools;
  @BuiltValueEnumConst(wireName: r'memos.books')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      memosPeriodBooks =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_memosPeriodBooks;
  @BuiltValueEnumConst(wireName: r'memos.books.edit')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      memosPeriodBooksPeriodEdit =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_memosPeriodBooksPeriodEdit;
  @BuiltValueEnumConst(wireName: r'days.tools')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum daysPeriodTools =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_daysPeriodTools;
  @BuiltValueEnumConst(wireName: r'days.books')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum daysPeriodBooks =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_daysPeriodBooks;
  @BuiltValueEnumConst(wireName: r'days.books.edit')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      daysPeriodBooksPeriodEdit =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_daysPeriodBooksPeriodEdit;
  @BuiltValueEnumConst(wireName: r'settings.profile.name')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      settingsPeriodProfilePeriodName =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_settingsPeriodProfilePeriodName;
  @BuiltValueEnumConst(wireName: r'settings.profile.avatar')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      settingsPeriodProfilePeriodAvatar =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_settingsPeriodProfilePeriodAvatar;
  @BuiltValueEnumConst(wireName: r'settings.profile.gender')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      settingsPeriodProfilePeriodGender =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_settingsPeriodProfilePeriodGender;
  @BuiltValueEnumConst(wireName: r'settings.reminder')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      settingsPeriodReminder =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_settingsPeriodReminder;
  @BuiltValueEnumConst(wireName: r'settings.language')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      settingsPeriodLanguage =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_settingsPeriodLanguage;
  @BuiltValueEnumConst(wireName: r'settings.theme')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      settingsPeriodTheme =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_settingsPeriodTheme;
  @BuiltValueEnumConst(wireName: r'settings.app_lock')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      settingsPeriodAppLock =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_settingsPeriodAppLock;
  @BuiltValueEnumConst(wireName: r'settings.cloud')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      settingsPeriodCloud =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_settingsPeriodCloud;
  @BuiltValueEnumConst(wireName: r'settings.sync')
  static const PostAnalyticsEventsRequestEventsInnerPageIdEnum
      settingsPeriodSync =
      _$postAnalyticsEventsRequestEventsInnerPageIdEnum_settingsPeriodSync;

  static Serializer<PostAnalyticsEventsRequestEventsInnerPageIdEnum>
      get serializer =>
          _$postAnalyticsEventsRequestEventsInnerPageIdEnumSerializer;

  const PostAnalyticsEventsRequestEventsInnerPageIdEnum._(String name)
      : super(name);

  static BuiltSet<PostAnalyticsEventsRequestEventsInnerPageIdEnum> get values =>
      _$postAnalyticsEventsRequestEventsInnerPageIdEnumValues;
  static PostAnalyticsEventsRequestEventsInnerPageIdEnum valueOf(String name) =>
      _$postAnalyticsEventsRequestEventsInnerPageIdEnumValueOf(name);
}

class PostAnalyticsEventsRequestEventsInnerPlatformEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'app')
  static const PostAnalyticsEventsRequestEventsInnerPlatformEnum app =
      _$postAnalyticsEventsRequestEventsInnerPlatformEnum_app;
  @BuiltValueEnumConst(wireName: r'web')
  static const PostAnalyticsEventsRequestEventsInnerPlatformEnum web =
      _$postAnalyticsEventsRequestEventsInnerPlatformEnum_web;

  static Serializer<PostAnalyticsEventsRequestEventsInnerPlatformEnum>
      get serializer =>
          _$postAnalyticsEventsRequestEventsInnerPlatformEnumSerializer;

  const PostAnalyticsEventsRequestEventsInnerPlatformEnum._(String name)
      : super(name);

  static BuiltSet<PostAnalyticsEventsRequestEventsInnerPlatformEnum>
      get values => _$postAnalyticsEventsRequestEventsInnerPlatformEnumValues;
  static PostAnalyticsEventsRequestEventsInnerPlatformEnum valueOf(
          String name) =>
      _$postAnalyticsEventsRequestEventsInnerPlatformEnumValueOf(name);
}

class PostAnalyticsEventsRequestEventsInnerEventNameEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'home_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum homeView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_homeView;
  @BuiltValueEnumConst(wireName: r'accounting_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingView;
  @BuiltValueEnumConst(wireName: r'accounting_transaction_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingTransactionView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingTransactionView;
  @BuiltValueEnumConst(wireName: r'accounting_transaction_editor_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingTransactionEditorView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingTransactionEditorView;
  @BuiltValueEnumConst(wireName: r'accounting_statistics_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingStatisticsView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingStatisticsView;
  @BuiltValueEnumConst(wireName: r'accounting_categories_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingCategoriesView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingCategoriesView;
  @BuiltValueEnumConst(wireName: r'accounting_aa_split_editor_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingAaSplitEditorView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingAaSplitEditorView;
  @BuiltValueEnumConst(wireName: r'accounting_aa_statistics_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingAaStatisticsView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingAaStatisticsView;
  @BuiltValueEnumConst(wireName: r'accounting_member_statistics_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingMemberStatisticsView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingMemberStatisticsView;
  @BuiltValueEnumConst(wireName: r'accounting_ledgers_edit_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingLedgersEditView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingLedgersEditView;
  @BuiltValueEnumConst(wireName: r'accounting_sharing_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingSharingView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingSharingView;
  @BuiltValueEnumConst(wireName: r'fitness_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum fitnessView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessView;
  @BuiltValueEnumConst(wireName: r'fitness_exercises_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessExercisesView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessExercisesView;
  @BuiltValueEnumConst(wireName: r'fitness_exercise_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessExerciseView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessExerciseView;
  @BuiltValueEnumConst(wireName: r'fitness_templates_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessTemplatesView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessTemplatesView;
  @BuiltValueEnumConst(wireName: r'fitness_template_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessTemplateView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessTemplateView;
  @BuiltValueEnumConst(wireName: r'fitness_plans_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessPlansView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessPlansView;
  @BuiltValueEnumConst(wireName: r'fitness_plan_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessPlanView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessPlanView;
  @BuiltValueEnumConst(wireName: r'fitness_workouts_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessWorkoutsView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessWorkoutsView;
  @BuiltValueEnumConst(wireName: r'fitness_workout_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessWorkoutView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessWorkoutView;
  @BuiltValueEnumConst(wireName: r'fitness_statistics_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessStatisticsView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessStatisticsView;
  @BuiltValueEnumConst(wireName: r'fitness_calendar_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessCalendarView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessCalendarView;
  @BuiltValueEnumConst(wireName: r'fitness_templates_library_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessTemplatesLibraryView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessTemplatesLibraryView;
  @BuiltValueEnumConst(wireName: r'fitness_templates_library_detail_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessTemplatesLibraryDetailView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessTemplatesLibraryDetailView;
  @BuiltValueEnumConst(wireName: r'fitness_plans_library_detail_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessPlansLibraryDetailView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessPlansLibraryDetailView;
  @BuiltValueEnumConst(wireName: r'fitness_library_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessLibraryView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessLibraryView;
  @BuiltValueEnumConst(wireName: r'fitness_workouts_editor_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessWorkoutsEditorView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessWorkoutsEditorView;
  @BuiltValueEnumConst(wireName: r'memos_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum memosView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_memosView;
  @BuiltValueEnumConst(wireName: r'memos_detail_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      memosDetailView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_memosDetailView;
  @BuiltValueEnumConst(wireName: r'memos_editor_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      memosEditorView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_memosEditorView;
  @BuiltValueEnumConst(wireName: r'credentials_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      credentialsView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_credentialsView;
  @BuiltValueEnumConst(wireName: r'credentials_detail_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      credentialsDetailView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_credentialsDetailView;
  @BuiltValueEnumConst(wireName: r'credentials_editor_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      credentialsEditorView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_credentialsEditorView;
  @BuiltValueEnumConst(wireName: r'credentials_books_edit_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      credentialsBooksEditView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_credentialsBooksEditView;
  @BuiltValueEnumConst(wireName: r'days_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum daysView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_daysView;
  @BuiltValueEnumConst(wireName: r'days_detail_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      daysDetailView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_daysDetailView;
  @BuiltValueEnumConst(wireName: r'days_editor_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      daysEditorView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_daysEditorView;
  @BuiltValueEnumConst(wireName: r'days_calendar_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      daysCalendarView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_daysCalendarView;
  @BuiltValueEnumConst(wireName: r'calendar_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum calendarView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_calendarView;
  @BuiltValueEnumConst(wireName: r'settings_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum settingsView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_settingsView;
  @BuiltValueEnumConst(wireName: r'settings_profile_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      settingsProfileView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_settingsProfileView;
  @BuiltValueEnumConst(wireName: r'accounting_categories_edit_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingCategoriesEditView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingCategoriesEditView;
  @BuiltValueEnumConst(wireName: r'accounting_categories_templates_flat_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingCategoriesTemplatesFlatView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingCategoriesTemplatesFlatView;
  @BuiltValueEnumConst(
      wireName: r'accounting_categories_templates_hierarchical_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingCategoriesTemplatesHierarchicalView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingCategoriesTemplatesHierarchicalView;
  @BuiltValueEnumConst(wireName: r'accounting_categories_detail_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingCategoriesDetailView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingCategoriesDetailView;
  @BuiltValueEnumConst(wireName: r'accounting_aa_member_detail_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingAaMemberDetailView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingAaMemberDetailView;
  @BuiltValueEnumConst(wireName: r'accounting_ledgers_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingLedgersView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingLedgersView;
  @BuiltValueEnumConst(wireName: r'accounting_ledgers_archived_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingLedgersArchivedView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingLedgersArchivedView;
  @BuiltValueEnumConst(wireName: r'accounting_ledgers_join_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingLedgersJoinView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingLedgersJoinView;
  @BuiltValueEnumConst(wireName: r'accounting_currency_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingCurrencyView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingCurrencyView;
  @BuiltValueEnumConst(wireName: r'accounting_exchange_rate_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingExchangeRateView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingExchangeRateView;
  @BuiltValueEnumConst(wireName: r'accounting_recurring_editor_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingRecurringEditorView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingRecurringEditorView;
  @BuiltValueEnumConst(wireName: r'fitness_spaces_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessSpacesView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessSpacesView;
  @BuiltValueEnumConst(wireName: r'fitness_spaces_edit_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessSpacesEditView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessSpacesEditView;
  @BuiltValueEnumConst(wireName: r'fitness_exercises_edit_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessExercisesEditView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessExercisesEditView;
  @BuiltValueEnumConst(wireName: r'fitness_templates_edit_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessTemplatesEditView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessTemplatesEditView;
  @BuiltValueEnumConst(wireName: r'fitness_plans_library_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessPlansLibraryView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessPlansLibraryView;
  @BuiltValueEnumConst(wireName: r'fitness_plans_edit_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessPlansEditView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessPlansEditView;
  @BuiltValueEnumConst(wireName: r'memos_tools_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      memosToolsView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_memosToolsView;
  @BuiltValueEnumConst(wireName: r'memos_books_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      memosBooksView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_memosBooksView;
  @BuiltValueEnumConst(wireName: r'memos_books_edit_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      memosBooksEditView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_memosBooksEditView;
  @BuiltValueEnumConst(wireName: r'days_tools_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      daysToolsView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_daysToolsView;
  @BuiltValueEnumConst(wireName: r'days_books_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      daysBooksView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_daysBooksView;
  @BuiltValueEnumConst(wireName: r'days_books_edit_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      daysBooksEditView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_daysBooksEditView;
  @BuiltValueEnumConst(wireName: r'settings_profile_name_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      settingsProfileNameView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_settingsProfileNameView;
  @BuiltValueEnumConst(wireName: r'settings_profile_avatar_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      settingsProfileAvatarView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_settingsProfileAvatarView;
  @BuiltValueEnumConst(wireName: r'settings_profile_gender_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      settingsProfileGenderView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_settingsProfileGenderView;
  @BuiltValueEnumConst(wireName: r'settings_reminder_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      settingsReminderView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_settingsReminderView;
  @BuiltValueEnumConst(wireName: r'settings_language_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      settingsLanguageView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_settingsLanguageView;
  @BuiltValueEnumConst(wireName: r'settings_theme_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      settingsThemeView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_settingsThemeView;
  @BuiltValueEnumConst(wireName: r'settings_app_lock_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      settingsAppLockView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_settingsAppLockView;
  @BuiltValueEnumConst(wireName: r'settings_cloud_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      settingsCloudView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_settingsCloudView;
  @BuiltValueEnumConst(wireName: r'settings_sync_view')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      settingsSyncView =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_settingsSyncView;
  @BuiltValueEnumConst(wireName: r'navigation_mode_select')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      navigationModeSelect =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_navigationModeSelect;
  @BuiltValueEnumConst(wireName: r'navigation_tab_select')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      navigationTabSelect =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_navigationTabSelect;
  @BuiltValueEnumConst(wireName: r'accounting_ledger_select')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingLedgerSelect =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingLedgerSelect;
  @BuiltValueEnumConst(wireName: r'accounting_transaction_create_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingTransactionCreateClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingTransactionCreateClick;
  @BuiltValueEnumConst(wireName: r'accounting_transaction_open_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingTransactionOpenClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingTransactionOpenClick;
  @BuiltValueEnumConst(wireName: r'accounting_transaction_edit_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingTransactionEditClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingTransactionEditClick;
  @BuiltValueEnumConst(wireName: r'accounting_transaction_save_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingTransactionSaveClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingTransactionSaveClick;
  @BuiltValueEnumConst(wireName: r'accounting_transaction_created')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingTransactionCreated =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingTransactionCreated;
  @BuiltValueEnumConst(wireName: r'accounting_transaction_updated')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingTransactionUpdated =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingTransactionUpdated;
  @BuiltValueEnumConst(wireName: r'accounting_transaction_deleted')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingTransactionDeleted =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingTransactionDeleted;
  @BuiltValueEnumConst(wireName: r'accounting_statistics_open_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingStatisticsOpenClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingStatisticsOpenClick;
  @BuiltValueEnumConst(wireName: r'accounting_categories_open_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      accountingCategoriesOpenClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_accountingCategoriesOpenClick;
  @BuiltValueEnumConst(wireName: r'fitness_tab_select')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessTabSelect =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessTabSelect;
  @BuiltValueEnumConst(wireName: r'fitness_space_select')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessSpaceSelect =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessSpaceSelect;
  @BuiltValueEnumConst(wireName: r'fitness_workout_create_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessWorkoutCreateClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessWorkoutCreateClick;
  @BuiltValueEnumConst(wireName: r'fitness_workout_open_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessWorkoutOpenClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessWorkoutOpenClick;
  @BuiltValueEnumConst(wireName: r'fitness_workout_save_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessWorkoutSaveClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessWorkoutSaveClick;
  @BuiltValueEnumConst(wireName: r'fitness_workout_created')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessWorkoutCreated =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessWorkoutCreated;
  @BuiltValueEnumConst(wireName: r'fitness_workout_updated')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessWorkoutUpdated =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessWorkoutUpdated;
  @BuiltValueEnumConst(wireName: r'fitness_workout_start_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessWorkoutStartClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessWorkoutStartClick;
  @BuiltValueEnumConst(wireName: r'fitness_workout_started')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessWorkoutStarted =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessWorkoutStarted;
  @BuiltValueEnumConst(wireName: r'fitness_workout_pause_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessWorkoutPauseClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessWorkoutPauseClick;
  @BuiltValueEnumConst(wireName: r'fitness_workout_paused')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessWorkoutPaused =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessWorkoutPaused;
  @BuiltValueEnumConst(wireName: r'fitness_workout_finish_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessWorkoutFinishClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessWorkoutFinishClick;
  @BuiltValueEnumConst(wireName: r'fitness_workout_completed')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessWorkoutCompleted =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessWorkoutCompleted;
  @BuiltValueEnumConst(wireName: r'fitness_template_save_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessTemplateSaveClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessTemplateSaveClick;
  @BuiltValueEnumConst(wireName: r'fitness_template_saved')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessTemplateSaved =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessTemplateSaved;
  @BuiltValueEnumConst(wireName: r'fitness_plan_save_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessPlanSaveClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessPlanSaveClick;
  @BuiltValueEnumConst(wireName: r'fitness_plan_saved')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessPlanSaved =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessPlanSaved;
  @BuiltValueEnumConst(wireName: r'fitness_template_add_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessTemplateAddClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessTemplateAddClick;
  @BuiltValueEnumConst(wireName: r'fitness_template_added')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessTemplateAdded =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessTemplateAdded;
  @BuiltValueEnumConst(wireName: r'fitness_plan_add_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessPlanAddClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessPlanAddClick;
  @BuiltValueEnumConst(wireName: r'fitness_plan_added')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      fitnessPlanAdded =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_fitnessPlanAdded;
  @BuiltValueEnumConst(wireName: r'memos_note_create_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      memosNoteCreateClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_memosNoteCreateClick;
  @BuiltValueEnumConst(wireName: r'memos_note_open_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      memosNoteOpenClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_memosNoteOpenClick;
  @BuiltValueEnumConst(wireName: r'memos_note_save_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      memosNoteSaveClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_memosNoteSaveClick;
  @BuiltValueEnumConst(wireName: r'memos_note_saved')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      memosNoteSaved =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_memosNoteSaved;
  @BuiltValueEnumConst(wireName: r'memos_note_created')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      memosNoteCreated =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_memosNoteCreated;
  @BuiltValueEnumConst(wireName: r'memos_note_deleted')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      memosNoteDeleted =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_memosNoteDeleted;
  @BuiltValueEnumConst(wireName: r'memos_book_select')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      memosBookSelect =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_memosBookSelect;
  @BuiltValueEnumConst(wireName: r'credentials_create_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      credentialsCreateClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_credentialsCreateClick;
  @BuiltValueEnumConst(wireName: r'credentials_open_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      credentialsOpenClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_credentialsOpenClick;
  @BuiltValueEnumConst(wireName: r'credentials_save_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      credentialsSaveClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_credentialsSaveClick;
  @BuiltValueEnumConst(wireName: r'credentials_saved')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      credentialsSaved =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_credentialsSaved;
  @BuiltValueEnumConst(wireName: r'credentials_created')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      credentialsCreated =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_credentialsCreated;
  @BuiltValueEnumConst(wireName: r'credentials_deleted')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      credentialsDeleted =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_credentialsDeleted;
  @BuiltValueEnumConst(wireName: r'credentials_book_select')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      credentialsBookSelect =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_credentialsBookSelect;
  @BuiltValueEnumConst(wireName: r'days_event_create_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      daysEventCreateClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_daysEventCreateClick;
  @BuiltValueEnumConst(wireName: r'days_event_open_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      daysEventOpenClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_daysEventOpenClick;
  @BuiltValueEnumConst(wireName: r'days_event_save_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      daysEventSaveClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_daysEventSaveClick;
  @BuiltValueEnumConst(wireName: r'days_event_saved')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      daysEventSaved =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_daysEventSaved;
  @BuiltValueEnumConst(wireName: r'days_event_created')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      daysEventCreated =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_daysEventCreated;
  @BuiltValueEnumConst(wireName: r'days_event_deleted')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      daysEventDeleted =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_daysEventDeleted;
  @BuiltValueEnumConst(wireName: r'days_book_select')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      daysBookSelect =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_daysBookSelect;
  @BuiltValueEnumConst(wireName: r'calendar_day_select')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      calendarDaySelect =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_calendarDaySelect;
  @BuiltValueEnumConst(wireName: r'calendar_section_open_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      calendarSectionOpenClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_calendarSectionOpenClick;
  @BuiltValueEnumConst(wireName: r'calendar_create_click')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      calendarCreateClick =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_calendarCreateClick;
  @BuiltValueEnumConst(wireName: r'settings_theme_changed')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      settingsThemeChanged =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_settingsThemeChanged;
  @BuiltValueEnumConst(wireName: r'settings_language_changed')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      settingsLanguageChanged =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_settingsLanguageChanged;
  @BuiltValueEnumConst(wireName: r'settings_app_lock_changed')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      settingsAppLockChanged =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_settingsAppLockChanged;
  @BuiltValueEnumConst(wireName: r'settings_reminder_changed')
  static const PostAnalyticsEventsRequestEventsInnerEventNameEnum
      settingsReminderChanged =
      _$postAnalyticsEventsRequestEventsInnerEventNameEnum_settingsReminderChanged;

  static Serializer<PostAnalyticsEventsRequestEventsInnerEventNameEnum>
      get serializer =>
          _$postAnalyticsEventsRequestEventsInnerEventNameEnumSerializer;

  const PostAnalyticsEventsRequestEventsInnerEventNameEnum._(String name)
      : super(name);

  static BuiltSet<PostAnalyticsEventsRequestEventsInnerEventNameEnum>
      get values => _$postAnalyticsEventsRequestEventsInnerEventNameEnumValues;
  static PostAnalyticsEventsRequestEventsInnerEventNameEnum valueOf(
          String name) =>
      _$postAnalyticsEventsRequestEventsInnerEventNameEnumValueOf(name);
}
