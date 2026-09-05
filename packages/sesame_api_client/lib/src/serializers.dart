//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:sesame_api_client/src/date_serializer.dart';
import 'package:sesame_api_client/src/model/date.dart';

import 'package:sesame_api_client/src/model/category.dart';
import 'package:sesame_api_client/src/model/delete_ledgers_by_ledger_id_transactions_by_transaction_id_request.dart';
import 'package:sesame_api_client/src/model/error.dart';
import 'package:sesame_api_client/src/model/exchange_rate_override.dart';
import 'package:sesame_api_client/src/model/get_admin_audit_logs200_response.dart';
import 'package:sesame_api_client/src/model/get_admin_audit_logs200_response_items_inner.dart';
import 'package:sesame_api_client/src/model/get_admin_audit_logs200_response_items_inner_target.dart';
import 'package:sesame_api_client/src/model/get_admin_status200_response.dart';
import 'package:sesame_api_client/src/model/get_admin_status200_response_ledgers.dart';
import 'package:sesame_api_client/src/model/get_admin_status200_response_users.dart';
import 'package:sesame_api_client/src/model/get_admin_users200_response.dart';
import 'package:sesame_api_client/src/model/get_admin_users200_response_items_inner.dart';
import 'package:sesame_api_client/src/model/get_devices200_response_inner.dart';
import 'package:sesame_api_client/src/model/get_exchange_rates200_response.dart';
import 'package:sesame_api_client/src/model/get_health200_response.dart';
import 'package:sesame_api_client/src/model/get_invites_by_code200_response.dart';
import 'package:sesame_api_client/src/model/get_ledgers_by_ledger_id_invites200_response_inner.dart';
import 'package:sesame_api_client/src/model/get_ledgers_by_ledger_id_member_stats200_response.dart';
import 'package:sesame_api_client/src/model/get_ledgers_by_ledger_id_member_stats200_response_items_inner.dart';
import 'package:sesame_api_client/src/model/get_ledgers_by_ledger_id_members200_response_inner.dart';
import 'package:sesame_api_client/src/model/get_ledgers_by_ledger_id_shared_resources200_response.dart';
import 'package:sesame_api_client/src/model/get_ledgers_by_ledger_id_transactions200_response.dart';
import 'package:sesame_api_client/src/model/get_profile_me200_response.dart';
import 'package:sesame_api_client/src/model/get_sync_full200_response.dart';
import 'package:sesame_api_client/src/model/get_sync_full200_response_ledger.dart';
import 'package:sesame_api_client/src/model/get_sync_pull200_response.dart';
import 'package:sesame_api_client/src/model/get_sync_pull200_response_changes_inner.dart';
import 'package:sesame_api_client/src/model/ledger.dart';
import 'package:sesame_api_client/src/model/member.dart';
import 'package:sesame_api_client/src/model/patch_admin_users_by_user_id_disable200_response.dart';
import 'package:sesame_api_client/src/model/patch_auth_password_request.dart';
import 'package:sesame_api_client/src/model/patch_ledgers_by_ledger_id_categories_by_category_id_request.dart';
import 'package:sesame_api_client/src/model/patch_ledgers_by_ledger_id_request.dart';
import 'package:sesame_api_client/src/model/patch_ledgers_by_ledger_id_transactions_by_transaction_id_request.dart';
import 'package:sesame_api_client/src/model/patch_profile_me_request.dart';
import 'package:sesame_api_client/src/model/post_auth_login_request.dart';
import 'package:sesame_api_client/src/model/post_auth_refresh_request.dart';
import 'package:sesame_api_client/src/model/post_auth_register201_response.dart';
import 'package:sesame_api_client/src/model/post_auth_register201_response_user.dart';
import 'package:sesame_api_client/src/model/post_auth_register_request.dart';
import 'package:sesame_api_client/src/model/post_auth_register_request_device.dart';
import 'package:sesame_api_client/src/model/post_invites_by_code_accept200_response.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_categories_request.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_imports200_response.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_imports400_response.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_imports400_response_details_inner.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_imports_request.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_invites201_response.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_invites_request.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_transactions_request.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_transactions_request_splits_inner.dart';
import 'package:sesame_api_client/src/model/post_ledgers_request.dart';
import 'package:sesame_api_client/src/model/post_sync_push200_response.dart';
import 'package:sesame_api_client/src/model/post_sync_push200_response_outcomes_inner.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of1.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of1_any_of.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of1_any_of1.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of1_any_of_payload.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of2.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of2_any_of.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of2_any_of1.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of2_any_of_payload.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of3.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of3_any_of.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of3_any_of1.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of3_any_of_payload.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of4.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of4_any_of.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of4_any_of1.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of4_any_of_payload.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of5.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of5_any_of.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of5_any_of1.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of5_any_of_payload.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of_any_of.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of_any_of1.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of_any_of_payload.dart';
import 'package:sesame_api_client/src/model/post_ws_ticket200_response.dart';
import 'package:sesame_api_client/src/model/put_profile_avatar200_response.dart';
import 'package:sesame_api_client/src/model/put_profile_avatar_request.dart';
import 'package:sesame_api_client/src/model/recurring_transaction.dart';
import 'package:sesame_api_client/src/model/transaction.dart';
import 'package:sesame_api_client/src/model/transaction_split.dart';

part 'serializers.g.dart';

@SerializersFor([
  Category,
  DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest,
  Error,
  ExchangeRateOverride,
  GetAdminAuditLogs200Response,
  GetAdminAuditLogs200ResponseItemsInner,
  GetAdminAuditLogs200ResponseItemsInnerTarget,
  GetAdminStatus200Response,
  GetAdminStatus200ResponseLedgers,
  GetAdminStatus200ResponseUsers,
  GetAdminUsers200Response,
  GetAdminUsers200ResponseItemsInner,
  GetDevices200ResponseInner,
  GetExchangeRates200Response,
  GetHealth200Response,
  GetInvitesByCode200Response,
  GetLedgersByLedgerIdInvites200ResponseInner,
  GetLedgersByLedgerIdMemberStats200Response,
  GetLedgersByLedgerIdMemberStats200ResponseItemsInner,
  GetLedgersByLedgerIdMembers200ResponseInner,
  GetLedgersByLedgerIdSharedResources200Response,
  GetLedgersByLedgerIdTransactions200Response,
  GetProfileMe200Response,
  GetSyncFull200Response,
  GetSyncFull200ResponseLedger,
  GetSyncPull200Response,
  GetSyncPull200ResponseChangesInner,
  Ledger,
  Member,
  PatchAdminUsersByUserIdDisable200Response,
  PatchAuthPasswordRequest,
  PatchLedgersByLedgerIdCategoriesByCategoryIdRequest,
  PatchLedgersByLedgerIdRequest,
  PatchLedgersByLedgerIdTransactionsByTransactionIdRequest,
  PatchProfileMeRequest,
  PostAuthLoginRequest,
  PostAuthRefreshRequest,
  PostAuthRegister201Response,
  PostAuthRegister201ResponseUser,
  PostAuthRegisterRequest,
  PostAuthRegisterRequestDevice,
  PostInvitesByCodeAccept200Response,
  PostLedgersByLedgerIdCategoriesRequest,
  PostLedgersByLedgerIdImports200Response,
  PostLedgersByLedgerIdImports400Response,
  PostLedgersByLedgerIdImports400ResponseDetailsInner,
  PostLedgersByLedgerIdImportsRequest,
  PostLedgersByLedgerIdInvites201Response,
  PostLedgersByLedgerIdInvitesRequest,
  PostLedgersByLedgerIdTransactionsRequest,
  PostLedgersByLedgerIdTransactionsRequestSplitsInner,
  PostLedgersRequest,
  PostSyncPush200Response,
  PostSyncPush200ResponseOutcomesInner,
  PostSyncPushRequest,
  PostSyncPushRequestChangesInner,
  PostSyncPushRequestChangesInnerAnyOf,
  PostSyncPushRequestChangesInnerAnyOf1,
  PostSyncPushRequestChangesInnerAnyOf1AnyOf,
  PostSyncPushRequestChangesInnerAnyOf1AnyOf1,
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload,
  PostSyncPushRequestChangesInnerAnyOf2,
  PostSyncPushRequestChangesInnerAnyOf2AnyOf,
  PostSyncPushRequestChangesInnerAnyOf2AnyOf1,
  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload,
  PostSyncPushRequestChangesInnerAnyOf3,
  PostSyncPushRequestChangesInnerAnyOf3AnyOf,
  PostSyncPushRequestChangesInnerAnyOf3AnyOf1,
  PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload,
  PostSyncPushRequestChangesInnerAnyOf4,
  PostSyncPushRequestChangesInnerAnyOf4AnyOf,
  PostSyncPushRequestChangesInnerAnyOf4AnyOf1,
  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload,
  PostSyncPushRequestChangesInnerAnyOf5,
  PostSyncPushRequestChangesInnerAnyOf5AnyOf,
  PostSyncPushRequestChangesInnerAnyOf5AnyOf1,
  PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload,
  PostSyncPushRequestChangesInnerAnyOfAnyOf,
  PostSyncPushRequestChangesInnerAnyOfAnyOf1,
  PostSyncPushRequestChangesInnerAnyOfAnyOfPayload,
  PostWsTicket200Response,
  PutProfileAvatar200Response,
  PutProfileAvatarRequest,
  RecurringTransaction,
  Transaction,
  TransactionSplit,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltMap, [FullType(String), FullType(String)]),
        () => MapBuilder<String, String>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(GetDevices200ResponseInner)]),
        () => ListBuilder<GetDevices200ResponseInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PostSyncPushRequestChangesInner)]),
        () => ListBuilder<PostSyncPushRequestChangesInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList,
            [FullType(PostLedgersByLedgerIdTransactionsRequestSplitsInner)]),
        () =>
            ListBuilder<PostLedgersByLedgerIdTransactionsRequestSplitsInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList,
            [FullType(PostLedgersByLedgerIdImports400ResponseDetailsInner)]),
        () =>
            ListBuilder<PostLedgersByLedgerIdImports400ResponseDetailsInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList,
            [FullType(GetLedgersByLedgerIdMemberStats200ResponseItemsInner)]),
        () =>
            ListBuilder<GetLedgersByLedgerIdMemberStats200ResponseItemsInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Ledger)]),
        () => ListBuilder<Ledger>(),
      )
      ..addBuilderFactory(
        const FullType(
            BuiltList, [FullType(GetAdminAuditLogs200ResponseItemsInner)]),
        () => ListBuilder<GetAdminAuditLogs200ResponseItemsInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Category)]),
        () => ListBuilder<Category>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ExchangeRateOverride)]),
        () => ListBuilder<ExchangeRateOverride>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Transaction)]),
        () => ListBuilder<Transaction>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(RecurringTransaction)]),
        () => ListBuilder<RecurringTransaction>(),
      )
      ..addBuilderFactory(
        const FullType(
            BuiltList, [FullType(GetAdminUsers200ResponseItemsInner)]),
        () => ListBuilder<GetAdminUsers200ResponseItemsInner>(),
      )
      ..addBuilderFactory(
        const FullType(
            BuiltList, [FullType(PostLedgersByLedgerIdTransactionsRequest)]),
        () => ListBuilder<PostLedgersByLedgerIdTransactionsRequest>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Member)]),
        () => ListBuilder<Member>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(TransactionSplit)]),
        () => ListBuilder<TransactionSplit>(),
      )
      ..addBuilderFactory(
        const FullType(
            BuiltList, [FullType(PostSyncPush200ResponseOutcomesInner)]),
        () => ListBuilder<PostSyncPush200ResponseOutcomesInner>(),
      )
      ..addBuilderFactory(
        const FullType(
            BuiltList, [FullType(GetSyncPull200ResponseChangesInner)]),
        () => ListBuilder<GetSyncPull200ResponseChangesInner>(),
      )
      ..addBuilderFactory(
        const FullType(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
        () => MapBuilder<String, JsonObject?>(),
      )
      ..addBuilderFactory(
        const FullType(
            BuiltList, [FullType(PostLedgersByLedgerIdCategoriesRequest)]),
        () => ListBuilder<PostLedgersByLedgerIdCategoriesRequest>(),
      )
      ..addBuilderFactory(
        const FullType(
            BuiltList, [FullType(GetLedgersByLedgerIdMembers200ResponseInner)]),
        () => ListBuilder<GetLedgersByLedgerIdMembers200ResponseInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(String)]),
        () => ListBuilder<String>(),
      )
      ..addBuilderFactory(
        const FullType(
            BuiltList, [FullType(GetLedgersByLedgerIdInvites200ResponseInner)]),
        () => ListBuilder<GetLedgersByLedgerIdInvites200ResponseInner>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
