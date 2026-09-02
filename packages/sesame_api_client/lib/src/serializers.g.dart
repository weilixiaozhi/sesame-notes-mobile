// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (Serializers().toBuilder()
      ..add(Category.serializer)
      ..add(CategoryKindEnum.serializer)
      ..add(CategoryLevelEnum.serializer)
      ..add(
          DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest.serializer)
      ..add(Error.serializer)
      ..add(ExchangeRateOverride.serializer)
      ..add(GetAdminAuditLogs200Response.serializer)
      ..add(GetAdminAuditLogs200ResponseItemsInner.serializer)
      ..add(GetAdminAuditLogs200ResponseItemsInnerTarget.serializer)
      ..add(GetAdminStatus200Response.serializer)
      ..add(GetAdminStatus200ResponseLedgers.serializer)
      ..add(GetAdminStatus200ResponseUsers.serializer)
      ..add(GetAdminUsers200Response.serializer)
      ..add(GetAdminUsers200ResponseItemsInner.serializer)
      ..add(GetDevices200ResponseInner.serializer)
      ..add(GetExchangeRates200Response.serializer)
      ..add(GetHealth200Response.serializer)
      ..add(GetInvitesByCode200Response.serializer)
      ..add(GetInvitesByCode200ResponseRoleEnum.serializer)
      ..add(GetLedgersByLedgerIdInvites200ResponseInner.serializer)
      ..add(GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum.serializer)
      ..add(GetLedgersByLedgerIdMemberStats200Response.serializer)
      ..add(GetLedgersByLedgerIdMemberStats200ResponseItemsInner.serializer)
      ..add(GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum
          .serializer)
      ..add(GetLedgersByLedgerIdMemberStats200ResponseScopeEnum.serializer)
      ..add(GetLedgersByLedgerIdMembers200ResponseInner.serializer)
      ..add(GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum.serializer)
      ..add(GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum.serializer)
      ..add(GetLedgersByLedgerIdSharedResources200Response.serializer)
      ..add(GetLedgersByLedgerIdTransactions200Response.serializer)
      ..add(GetProfileAvatarByUserId200Response.serializer)
      ..add(GetProfileAvatarByUserId200ResponseContentTypeEnum.serializer)
      ..add(GetProfileMe200Response.serializer)
      ..add(GetProfileMe200ResponseGenderEnum.serializer)
      ..add(GetSyncFull200Response.serializer)
      ..add(GetSyncFull200ResponseLedger.serializer)
      ..add(GetSyncPull200Response.serializer)
      ..add(GetSyncPull200ResponseChangesInner.serializer)
      ..add(GetSyncPull200ResponseChangesInnerActionEnum.serializer)
      ..add(GetSyncPull200ResponseChangesInnerEntityTypeEnum.serializer)
      ..add(Ledger.serializer)
      ..add(LedgerRoleEnum.serializer)
      ..add(Member.serializer)
      ..add(MemberMemberTypeEnum.serializer)
      ..add(MemberStatusEnum.serializer)
      ..add(PatchAdminUsersByUserIdDisable200Response.serializer)
      ..add(PatchAuthPasswordRequest.serializer)
      ..add(PatchLedgersByLedgerIdCategoriesByCategoryIdRequest.serializer)
      ..add(PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum
          .serializer)
      ..add(PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum
          .serializer)
      ..add(PatchLedgersByLedgerIdRequest.serializer)
      ..add(PatchLedgersByLedgerIdTransactionsByTransactionIdRequest.serializer)
      ..add(PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum
          .serializer)
      ..add(PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum
          .serializer)
      ..add(PatchProfileMeRequest.serializer)
      ..add(PostAuthLoginRequest.serializer)
      ..add(PostAuthRefreshRequest.serializer)
      ..add(PostAuthRegister201Response.serializer)
      ..add(PostAuthRegister201ResponseTokenTypeEnum.serializer)
      ..add(PostAuthRegister201ResponseUser.serializer)
      ..add(PostAuthRegister201ResponseUserGenderEnum.serializer)
      ..add(PostAuthRegisterRequest.serializer)
      ..add(PostAuthRegisterRequestDevice.serializer)
      ..add(PostInvitesByCodeAccept200Response.serializer)
      ..add(PostInvitesByCodeAccept200ResponseRoleEnum.serializer)
      ..add(PostLedgersByLedgerIdCategoriesRequest.serializer)
      ..add(PostLedgersByLedgerIdCategoriesRequestKindEnum.serializer)
      ..add(PostLedgersByLedgerIdCategoriesRequestLevelEnum.serializer)
      ..add(PostLedgersByLedgerIdImports201Response.serializer)
      ..add(PostLedgersByLedgerIdImports400Response.serializer)
      ..add(PostLedgersByLedgerIdImports400ResponseCodeEnum.serializer)
      ..add(PostLedgersByLedgerIdImports400ResponseDetailsInner.serializer)
      ..add(PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum
          .serializer)
      ..add(PostLedgersByLedgerIdImportsRequest.serializer)
      ..add(PostLedgersByLedgerIdInvites201Response.serializer)
      ..add(PostLedgersByLedgerIdInvites201ResponseRoleEnum.serializer)
      ..add(PostLedgersByLedgerIdInvitesRequest.serializer)
      ..add(PostLedgersByLedgerIdTransactionsRequest.serializer)
      ..add(PostLedgersByLedgerIdTransactionsRequestAaModeEnum.serializer)
      ..add(PostLedgersByLedgerIdTransactionsRequestSplitsInner.serializer)
      ..add(PostLedgersByLedgerIdTransactionsRequestTxTypeEnum.serializer)
      ..add(PostLedgersRequest.serializer)
      ..add(PostSyncPush200Response.serializer)
      ..add(PostSyncPush200ResponseOutcomesInner.serializer)
      ..add(PostSyncPush200ResponseOutcomesInnerStatusEnum.serializer)
      ..add(PostSyncPushRequest.serializer)
      ..add(PostSyncPushRequestChangesInner.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf1AnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf1AnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf1AnyOf1ActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf1AnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum
          .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum
          .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf2.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf2AnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf2AnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf2AnyOf1ActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf2AnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf3.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf3AnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf3AnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf3AnyOf1ActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf3AnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum
          .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum
          .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf4.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf4AnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf4AnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf5.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf5AnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf5AnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf5AnyOf1ActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf5AnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOfAnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOfAnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOfAnyOfPayload.serializer)
      ..add(PostWsTicket200Response.serializer)
      ..add(PutProfileAvatar200Response.serializer)
      ..add(PutProfileAvatarRequest.serializer)
      ..add(PutProfileAvatarRequestContentTypeEnum.serializer)
      ..add(RecurringTransaction.serializer)
      ..add(RecurringTransactionFrequencyEnum.serializer)
      ..add(RecurringTransactionTxTypeEnum.serializer)
      ..add(Transaction.serializer)
      ..add(TransactionAaModeEnum.serializer)
      ..add(TransactionCategoryKindEnum.serializer)
      ..add(TransactionSplit.serializer)
      ..add(TransactionTxTypeEnum.serializer)
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Category)]),
          () => ListBuilder<Category>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GetAdminAuditLogs200ResponseItemsInner)]),
          () => ListBuilder<GetAdminAuditLogs200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GetAdminUsers200ResponseItemsInner)]),
          () => ListBuilder<GetAdminUsers200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetLedgersByLedgerIdMemberStats200ResponseItemsInner)
          ]),
          () => ListBuilder<
              GetLedgersByLedgerIdMemberStats200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GetSyncPull200ResponseChangesInner)]),
          () => ListBuilder<GetSyncPull200ResponseChangesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Member)]),
          () => ListBuilder<Member>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Transaction)]),
          () => ListBuilder<Transaction>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Category)]),
          () => ListBuilder<Category>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(RecurringTransaction)]),
          () => ListBuilder<RecurringTransaction>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(ExchangeRateOverride)]),
          () => ListBuilder<ExchangeRateOverride>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(PostLedgersByLedgerIdCategoriesRequest)]),
          () => ListBuilder<PostLedgersByLedgerIdCategoriesRequest>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(PostLedgersByLedgerIdTransactionsRequest)]),
          () => ListBuilder<PostLedgersByLedgerIdTransactionsRequest>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(PostLedgersByLedgerIdImports400ResponseDetailsInner)
          ]),
          () => ListBuilder<
              PostLedgersByLedgerIdImports400ResponseDetailsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(PostLedgersByLedgerIdTransactionsRequestSplitsInner)
          ]),
          () => ListBuilder<
              PostLedgersByLedgerIdTransactionsRequestSplitsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(PostLedgersByLedgerIdTransactionsRequestSplitsInner)
          ]),
          () => ListBuilder<
              PostLedgersByLedgerIdTransactionsRequestSplitsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(PostLedgersByLedgerIdTransactionsRequestSplitsInner)
          ]),
          () => ListBuilder<
              PostLedgersByLedgerIdTransactionsRequestSplitsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(PostSyncPush200ResponseOutcomesInner)]),
          () => ListBuilder<PostSyncPush200ResponseOutcomesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(PostSyncPushRequestChangesInner)]),
          () => ListBuilder<PostSyncPushRequestChangesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Transaction)]),
          () => ListBuilder<Transaction>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(TransactionSplit)]),
          () => ListBuilder<TransactionSplit>())
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(String)]),
          () => MapBuilder<String, String>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>()))
    .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
