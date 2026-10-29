// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (Serializers().toBuilder()
      ..add(Category.serializer)
      ..add(CategoryConflict.serializer)
      ..add(CategoryConflictActionEnum.serializer)
      ..add(CategoryConflictLocalPayload.serializer)
      ..add(CategoryConflictLocalPayloadKindEnum.serializer)
      ..add(CategoryConflictLocalPayloadLevelEnum.serializer)
      ..add(CategoryConflictResolutionEnum.serializer)
      ..add(CategoryConflictStatusEnum.serializer)
      ..add(CategoryKindEnum.serializer)
      ..add(CategoryLevelEnum.serializer)
      ..add(CategoryResolution.serializer)
      ..add(CategoryResolutionResolutionEnum.serializer)
      ..add(CreateAdminBannerRequest.serializer)
      ..add(CreateAdminBannerRequestSlotEnum.serializer)
      ..add(CreateAdminBannerRequestTargetEnum.serializer)
      ..add(CreateOfficialFitnessTaxonomyRequest.serializer)
      ..add(DayBook.serializer)
      ..add(DayEvent.serializer)
      ..add(DayEventCategoryEnum.serializer)
      ..add(DayEventCountdownModeEnum.serializer)
      ..add(DayEventRepeatTypeEnum.serializer)
      ..add(DayEventStatisticTypeEnum.serializer)
      ..add(DayOriginalDate.serializer)
      ..add(DayOriginalDateCalendarTypeEnum.serializer)
      ..add(DeleteAdminBanner200Response.serializer)
      ..add(DeleteAdminBannerRequest.serializer)
      ..add(DeleteAdminGroupsByGroupIdRequest.serializer)
      ..add(DeleteAdminUsersByUserIdAvatarRequest.serializer)
      ..add(
          DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest.serializer)
      ..add(DeleteOfficialFitnessTaxonomyRequest.serializer)
      ..add(Error.serializer)
      ..add(ExchangeRateOverride.serializer)
      ..add(GetAdminAnalytics200Response.serializer)
      ..add(GetAdminAnalytics200ResponseCoverage.serializer)
      ..add(GetAdminAnalytics200ResponseRange.serializer)
      ..add(GetAdminAnalytics200ResponseRangeBucketEnum.serializer)
      ..add(GetAdminAnalytics200ResponseRangePlatformEnum.serializer)
      ..add(GetAdminAnalytics200ResponseRangeTimezoneEnum.serializer)
      ..add(GetAdminAnalytics200ResponseSeriesInner.serializer)
      ..add(GetAdminAnalytics200ResponseSummary.serializer)
      ..add(GetAdminAnalyticsCatalog200Response.serializer)
      ..add(GetAdminAnalyticsCatalog200ResponseEventsInner.serializer)
      ..add(
          GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum.serializer)
      ..add(GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum.serializer)
      ..add(GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum
          .serializer)
      ..add(GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner
          .serializer)
      ..add(
          GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum
              .serializer)
      ..add(GetAdminAnalyticsDetails200Response.serializer)
      ..add(GetAdminAnalyticsDetails200ResponseEventsInner.serializer)
      ..add(
          GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum.serializer)
      ..add(GetAdminAnalyticsDetails200ResponseExposuresInner.serializer)
      ..add(GetAdminAnalyticsDetails200ResponsePagesInner.serializer)
      ..add(GetAdminAnalyticsDetails200ResponseSeriesInner.serializer)
      ..add(GetAdminAnalyticsDetails200ResponseSummary.serializer)
      ..add(GetAdminAuditLogs200Response.serializer)
      ..add(GetAdminAuditLogs200ResponseItemsInner.serializer)
      ..add(GetAdminBannerStatistics200Response.serializer)
      ..add(GetAdminBannerStatistics200ResponseCoverage.serializer)
      ..add(GetAdminBannerStatistics200ResponseCoverageAudienceEnum.serializer)
      ..add(GetAdminBannerStatistics200ResponseItemsInner.serializer)
      ..add(GetAdminBannerStatistics200ResponseItemsInnerSlotEnum.serializer)
      ..add(GetAdminBannerStatistics200ResponseItemsInnerSource_Enum.serializer)
      ..add(GetAdminBannerStatistics200ResponseRange.serializer)
      ..add(GetAdminBannerStatistics200ResponseRangeTimezoneEnum.serializer)
      ..add(GetAdminBannerStatistics200ResponseScopeEnum.serializer)
      ..add(GetAdminGroups200Response.serializer)
      ..add(GetAdminGroups200ResponseItemsInner.serializer)
      ..add(GetAdminGroupsByGroupIdMembers200Response.serializer)
      ..add(GetAdminGroupsByGroupIdMembers200ResponseItemsInner.serializer)
      ..add(GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum
          .serializer)
      ..add(GetAdminIdentityTypes200Response.serializer)
      ..add(GetAdminIdentityTypes200ResponseItemsInner.serializer)
      ..add(GetAdminIdentityTypes200ResponseItemsInnerValueEnum.serializer)
      ..add(GetAdminPermissionCatalog200Response.serializer)
      ..add(GetAdminPermissionCatalog200ResponseIdentitiesInner.serializer)
      ..add(GetAdminPermissionCatalog200ResponsePagesInner.serializer)
      ..add(GetAdminPermissionCatalog200ResponsePermissionsInner.serializer)
      ..add(GetAdminStatus200Response.serializer)
      ..add(GetAdminStatus200ResponseLedgers.serializer)
      ..add(GetAdminStatus200ResponseUsers.serializer)
      ..add(GetAdminUsers200Response.serializer)
      ..add(GetAdminUsers200ResponseItemsInner.serializer)
      ..add(GetAdminUsers200ResponseItemsInnerGenderEnum.serializer)
      ..add(GetAdminUsersByUserId200Response.serializer)
      ..add(GetAdminUsersByUserId200ResponseGenderEnum.serializer)
      ..add(GetAdminUsersByUserIdDevices200Response.serializer)
      ..add(GetAdminUsersByUserIdDevices200ResponseItemsInner.serializer)
      ..add(GetAppBanners200Response.serializer)
      ..add(GetAppBanners200ResponseAnyOf.serializer)
      ..add(GetAppBanners200ResponseAnyOf1.serializer)
      ..add(GetAppBanners200ResponseAnyOf1ItemsInner.serializer)
      ..add(GetAppBanners200ResponseAnyOf1ItemsInnerSlotEnum.serializer)
      ..add(GetAppBanners200ResponseAnyOf1ItemsInnerTargetEnum.serializer)
      ..add(GetAppBanners200ResponseAnyOfItemsInner.serializer)
      ..add(GetAppBanners200ResponseAnyOfItemsInnerSlotEnum.serializer)
      ..add(GetAppBanners200ResponseAnyOfItemsInnerTargetEnum.serializer)
      ..add(GetCategoryConflicts200Response.serializer)
      ..add(GetDayBooksByDayBookIdEvents200Response.serializer)
      ..add(GetDevices200ResponseInner.serializer)
      ..add(GetExchangeRates200Response.serializer)
      ..add(GetFitnessCatalog200Response.serializer)
      ..add(GetFitnessCatalog200ResponseExercisesInner.serializer)
      ..add(GetFitnessCatalog200ResponseTaxonomies.serializer)
      ..add(GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner.serializer)
      ..add(GetFitnessLibrary200Response.serializer)
      ..add(GetFitnessLibrary200ResponsePlansInner.serializer)
      ..add(GetFitnessLibrary200ResponsePlansInnerDaysInner.serializer)
      ..add(GetFitnessLibrary200ResponsePlansInnerDifficultyEnum.serializer)
      ..add(GetFitnessLibrary200ResponseTemplatesInner.serializer)
      ..add(GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum.serializer)
      ..add(GetFitnessLibrary200ResponseTemplatesInnerExercisesInner.serializer)
      ..add(
          GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum
              .serializer)
      ..add(GetFitnessLibrary200ResponseTemplatesInnerGoals.serializer)
      ..add(GetFitnessLibrary200ResponseTemplatesInnerName.serializer)
      ..add(GetFitnessSpacesByFitnessSpaceIdCalendar200Response.serializer)
      ..add(GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner
          .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum
              .serializer)
      ..add(GetFitnessSpacesByFitnessSpaceIdExport200Response.serializer)
      ..add(GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner
          .serializer)
      ..add(GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf
          .serializer)
      ..add(GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1
          .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum
              .serializer)
      ..add(GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2
          .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum
              .serializer)
      ..add(GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3
          .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum
              .serializer)
      ..add(GetFitnessSpacesByFitnessSpaceIdPlans200Response.serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner.serializer)
      ..add(GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner
          .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlot
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule
              .serializer)
      ..add(GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum
          .serializer)
      ..add(GetFitnessSpacesByFitnessSpaceIdPreferences200Response.serializer)
      ..add(GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner
          .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue
              .serializer)
      ..add(GetFitnessSpacesByFitnessSpaceIdStatistics200Response.serializer)
      ..add(GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner
          .serializer)
      ..add(GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner
          .serializer)
      ..add(GetFitnessSpacesByFitnessSpaceIdTemplates200Response.serializer)
      ..add(GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner
          .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
              .serializer)
      ..add(GetFitnessSpacesByFitnessSpaceIdWorkouts200Response.serializer)
      ..add(GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner
          .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum
              .serializer)
      ..add(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum
              .serializer)
      ..add(GetHealth200Response.serializer)
      ..add(GetInvitesByCode200Response.serializer)
      ..add(GetInvitesByCode200ResponseRoleEnum.serializer)
      ..add(GetLedgersByLedgerIdAaStats200Response.serializer)
      ..add(GetLedgersByLedgerIdAaStats200ResponseParticipantsInner.serializer)
      ..add(GetLedgersByLedgerIdAaStats200ResponseTransfersInner.serializer)
      ..add(GetLedgersByLedgerIdActionPreview200Response.serializer)
      ..add(GetLedgersByLedgerIdMemberStats200Response.serializer)
      ..add(GetLedgersByLedgerIdMemberStats200ResponseItemsInner.serializer)
      ..add(GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum
          .serializer)
      ..add(GetLedgersByLedgerIdMemberStats200ResponseScopeEnum.serializer)
      ..add(GetLedgersByLedgerIdMembers200ResponseInner.serializer)
      ..add(GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum.serializer)
      ..add(GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum.serializer)
      ..add(GetLedgersByLedgerIdRecurringTransactions200Response.serializer)
      ..add(GetLedgersByLedgerIdSharedResources200Response.serializer)
      ..add(GetLedgersByLedgerIdTransactionStats200Response.serializer)
      ..add(GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner
          .serializer)
      ..add(GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner
          .serializer)
      ..add(
          GetLedgersByLedgerIdTransactionStats200ResponseByDayInner.serializer)
      ..add(GetLedgersByLedgerIdTransactions200Response.serializer)
      ..add(GetMemoBooksByMemoBookIdCalendarCounts200Response.serializer)
      ..add(
          GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner.serializer)
      ..add(GetMemoBooksByMemoBookIdEntries200Response.serializer)
      ..add(GetProfileMe200Response.serializer)
      ..add(GetProfileMe200ResponseGenderEnum.serializer)
      ..add(GetSyncAccountingFull200Response.serializer)
      ..add(GetSyncAccountingFull200ResponseLedgerSnapshotsInner.serializer)
      ..add(GetSyncDayBooks200Response.serializer)
      ..add(GetSyncDayBooksFull200Response.serializer)
      ..add(GetSyncFitnessSpaces200Response.serializer)
      ..add(GetSyncFitnessSpaces200ResponseFitnessSpacesInner.serializer)
      ..add(GetSyncFitnessSpacesFull200Response.serializer)
      ..add(GetSyncFitnessSpacesFull200ResponseFitnessSpace.serializer)
      ..add(GetSyncFull200Response.serializer)
      ..add(GetSyncFull200ResponseLedger.serializer)
      ..add(GetSyncFull200ResponseRecurringState.serializer)
      ..add(GetSyncFull200ResponseRecurringStateOccurrencesInner.serializer)
      ..add(GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum
          .serializer)
      ..add(GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum
          .serializer)
      ..add(GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum
          .serializer)
      ..add(GetSyncFull200ResponseRecurringStateRulesInner.serializer)
      ..add(GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum
          .serializer)
      ..add(GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum.serializer)
      ..add(GetSyncMemoBooks200Response.serializer)
      ..add(GetSyncMemoBooks200ResponseMemoBooksInner.serializer)
      ..add(GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum.serializer)
      ..add(GetSyncMemoBooksFull200Response.serializer)
      ..add(GetSyncPull200Response.serializer)
      ..add(GetSyncPull200ResponseChangesInner.serializer)
      ..add(GetSyncPull200ResponseChangesInnerActionEnum.serializer)
      ..add(GetSyncPull200ResponseChangesInnerEntityTypeEnum.serializer)
      ..add(Ledger.serializer)
      ..add(LedgerRoleEnum.serializer)
      ..add(ListAdminBannerTargets200Response.serializer)
      ..add(ListAdminBannerTargets200ResponseItemsInner.serializer)
      ..add(ListAdminBannerTargets200ResponseItemsInnerName.serializer)
      ..add(ListAdminBanners200Response.serializer)
      ..add(ListAdminBanners200ResponseItemsInner.serializer)
      ..add(ListAdminBanners200ResponseItemsInnerSlotEnum.serializer)
      ..add(ListAdminBanners200ResponseItemsInnerSource_Enum.serializer)
      ..add(ListAdminBanners200ResponseItemsInnerTargetEnum.serializer)
      ..add(ListOfficialExercises200Response.serializer)
      ..add(ListOfficialExercises200ResponseItemsInner.serializer)
      ..add(ListOfficialExercises200ResponseItemsInnerContent.serializer)
      ..add(ListOfficialExercises200ResponseItemsInnerKindEnum.serializer)
      ..add(ListOfficialFitnessReferences200Response.serializer)
      ..add(ListOfficialFitnessReferences200ResponseExercisesInner.serializer)
      ..add(ListOfficialFitnessTaxonomies200Response.serializer)
      ..add(ListOfficialFitnessTaxonomies200ResponseItemsInner.serializer)
      ..add(
          ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum.serializer)
      ..add(ListOfficialFitnessTaxonomies200ResponseItemsInnerName.serializer)
      ..add(ListOfficialPlans200Response.serializer)
      ..add(ListOfficialPlans200ResponseItemsInner.serializer)
      ..add(ListOfficialPlans200ResponseItemsInnerKindEnum.serializer)
      ..add(ListOfficialTemplates200Response.serializer)
      ..add(ListOfficialTemplates200ResponseItemsInner.serializer)
      ..add(ListOfficialTemplates200ResponseItemsInnerKindEnum.serializer)
      ..add(Member.serializer)
      ..add(MemberMemberTypeEnum.serializer)
      ..add(MemberStatusEnum.serializer)
      ..add(MemoBook.serializer)
      ..add(MemoBookTypeEnum.serializer)
      ..add(MemoEntry.serializer)
      ..add(MemoEntryBodyFormatEnum.serializer)
      ..add(MemoEntryBookTypeEnum.serializer)
      ..add(PatchAdminAccountsByAdminIdRequest.serializer)
      ..add(PatchAdminFitnessExercisesByContentIdRequest.serializer)
      ..add(PatchAdminFitnessPlansByContentIdRequest.serializer)
      ..add(PatchAdminFitnessTemplatesByContentIdRequest.serializer)
      ..add(PatchAdminGroupsByGroupIdRequest.serializer)
      ..add(PatchAdminUsersByUserIdDisable200Response.serializer)
      ..add(PatchAdminUsersByUserIdDisableRequest.serializer)
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
      ..add(PostAdminAccountsByAdminIdResetPasswordRequest.serializer)
      ..add(PostAdminAccountsRequest.serializer)
      ..add(PostAdminAnalyticsFunnel200Response.serializer)
      ..add(PostAdminAnalyticsFunnel200ResponseCoverage.serializer)
      ..add(PostAdminAnalyticsFunnel200ResponseRange.serializer)
      ..add(PostAdminAnalyticsFunnel200ResponseRangePlatformEnum.serializer)
      ..add(PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum.serializer)
      ..add(PostAdminAnalyticsFunnel200ResponseScopeEnum.serializer)
      ..add(PostAdminAnalyticsFunnel200ResponseStepsInner.serializer)
      ..add(PostAdminAnalyticsFunnelRequest.serializer)
      ..add(PostAdminAnalyticsFunnelRequestPlatformEnum.serializer)
      ..add(PostAdminAnalyticsFunnelRequestScopeEnum.serializer)
      ..add(PostAdminAuthLogin200Response.serializer)
      ..add(PostAdminAuthLogin200ResponseAdmin.serializer)
      ..add(PostAdminAuthLogin200ResponseAdminGroup.serializer)
      ..add(PostAdminAuthLogin200ResponseAdminIdentityTypeEnum.serializer)
      ..add(PostAdminAuthLoginRequest.serializer)
      ..add(PostAdminAuthPasswordRequest.serializer)
      ..add(PostAdminFitnessExercisesRequest.serializer)
      ..add(PostAdminFitnessExercisesRequestContent.serializer)
      ..add(PostAdminFitnessPlansRequest.serializer)
      ..add(PostAdminFitnessPlansRequestContent.serializer)
      ..add(PostAdminFitnessPlansRequestContentDifficultyEnum.serializer)
      ..add(PostAdminFitnessTemplatesRequest.serializer)
      ..add(PostAdminFitnessTemplatesRequestContent.serializer)
      ..add(PostAdminFitnessTemplatesRequestContentDifficultyEnum.serializer)
      ..add(PostAdminGroupsByGroupIdMembers200Response.serializer)
      ..add(PostAdminGroupsByGroupIdMembersRequest.serializer)
      ..add(PostAdminGroupsByGroupIdMembersRequestMembersInner.serializer)
      ..add(PostAdminGroupsRequest.serializer)
      ..add(PostAdminUsersByUserIdResetPasswordRequest.serializer)
      ..add(PostAnalyticsEvents200Response.serializer)
      ..add(PostAnalyticsEventsRequest.serializer)
      ..add(PostAnalyticsEventsRequestEventsInner.serializer)
      ..add(PostAnalyticsEventsRequestEventsInnerBannerSlotEnum.serializer)
      ..add(PostAnalyticsEventsRequestEventsInnerBannerSourceEnum.serializer)
      ..add(PostAnalyticsEventsRequestEventsInnerEventNameEnum.serializer)
      ..add(PostAnalyticsEventsRequestEventsInnerKindEnum.serializer)
      ..add(PostAnalyticsEventsRequestEventsInnerPageIdEnum.serializer)
      ..add(PostAnalyticsEventsRequestEventsInnerPlatformEnum.serializer)
      ..add(PostAuthBrowserRefreshRequest.serializer)
      ..add(PostAuthBrowserRegister201Response.serializer)
      ..add(PostAuthBrowserRegister201ResponseTokenTypeEnum.serializer)
      ..add(PostAuthLoginRequest.serializer)
      ..add(PostAuthLogoutRequest.serializer)
      ..add(PostAuthRefreshRequest.serializer)
      ..add(PostAuthRegister201Response.serializer)
      ..add(PostAuthRegister201ResponseTokenTypeEnum.serializer)
      ..add(PostAuthRegister201ResponseUser.serializer)
      ..add(PostAuthRegister201ResponseUserGenderEnum.serializer)
      ..add(PostAuthRegisterRequest.serializer)
      ..add(PostAuthRegisterRequestDevice.serializer)
      ..add(PostCategoryConflictsByConflictIdResolveRequest.serializer)
      ..add(
          PostCategoryConflictsByConflictIdResolveRequestChoiceEnum.serializer)
      ..add(PostFitnessSpacesByFitnessSpaceIdImport200Response.serializer)
      ..add(PostFitnessSpacesByFitnessSpaceIdImportRequest.serializer)
      ..add(PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response
          .serializer)
      ..add(PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest
          .serializer)
      ..add(
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum
              .serializer)
      ..add(PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan
          .serializer)
      ..add(
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum
              .serializer)
      ..add(
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner
              .serializer)
      ..add(
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload
              .serializer)
      ..add(PostInvitesByCodeAccept200Response.serializer)
      ..add(PostInvitesByCodeAccept200ResponseRoleEnum.serializer)
      ..add(PostLedgersByLedgerIdCategoriesAddBatchRequest.serializer)
      ..add(PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf.serializer)
      ..add(PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1.serializer)
      ..add(PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner
          .serializer)
      ..add(
          PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum
              .serializer)
      ..add(
          PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum
              .serializer)
      ..add(PostLedgersByLedgerIdCategoriesRemovalPreview200Response.serializer)
      ..add(PostLedgersByLedgerIdCategoriesRemovalPreviewRequest.serializer)
      ..add(PostLedgersByLedgerIdCategoriesRemove200Response.serializer)
      ..add(PostLedgersByLedgerIdCategoriesRemoveRequest.serializer)
      ..add(PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum.serializer)
      ..add(PostLedgersByLedgerIdCategoriesReorderRequest.serializer)
      ..add(PostLedgersByLedgerIdCategoriesReorderRequestItemsInner.serializer)
      ..add(PostLedgersByLedgerIdCategoriesRequest.serializer)
      ..add(PostLedgersByLedgerIdCategoriesRequestKindEnum.serializer)
      ..add(PostLedgersByLedgerIdCategoriesRequestLevelEnum.serializer)
      ..add(PostLedgersByLedgerIdChangeCurrency200Response.serializer)
      ..add(PostLedgersByLedgerIdChangeCurrencyRequest.serializer)
      ..add(PostLedgersByLedgerIdClear200Response.serializer)
      ..add(PostLedgersByLedgerIdClearRequest.serializer)
      ..add(PostLedgersByLedgerIdImports200Response.serializer)
      ..add(PostLedgersByLedgerIdImportsRequest.serializer)
      ..add(PostLedgersByLedgerIdInvites201Response.serializer)
      ..add(PostLedgersByLedgerIdInvites201ResponseRoleEnum.serializer)
      ..add(PostLedgersByLedgerIdInvitesRequest.serializer)
      ..add(PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response
          .serializer)
      ..add(
          PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner
              .serializer)
      ..add(PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest
          .serializer)
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
      ..add(PostSyncPushRequestChangesInnerAnyOf10.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf10AnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf10AnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum
          .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum
          .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf11.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf11AnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf11AnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf11AnyOf1ActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf11AnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin
          .serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum
              .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf12.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf12AnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf12AnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf12AnyOf1ActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf12AnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum
          .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf13.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf13AnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf13AnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf13AnyOf1ActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf13AnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner
          .serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner
              .serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum
              .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner
          .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum
          .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum
          .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf14.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf14AnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf14AnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf14AnyOf1ActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf14AnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf15.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf15AnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf15AnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf15AnyOf1ActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf15AnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf15AnyOfActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf15AnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf1AnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf1AnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf1AnyOf1ActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf1AnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnum
          .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCountdownModeEnum
          .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum
              .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadRepeatTypeEnum
          .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadStatisticTypeEnum
          .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf2.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf2AnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf2AnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf2AnyOf1ActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf2AnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf3.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf3ActionEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf3Payload.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf4.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf4AnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf4AnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum
          .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum
          .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf5.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf5AnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf5AnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf5AnyOf1ActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf5AnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf6.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf6AnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf6AnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf6AnyOf1ActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf6AnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum
          .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState
          .serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner
              .serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayload
              .serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadAaModeEnum
              .serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadTxTypeEnum
              .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum
          .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf7.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf7AnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf7AnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf7AnyOf1ActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf7AnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf8.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf8AnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf8AnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf8AnyOf1ActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf8AnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum
          .serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf9.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf9AnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf9AnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf9AnyOf1ActionEnum.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf9AnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload.serializer)
      ..add(
          PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOfAnyOf.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOfAnyOf1.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum.serializer)
      ..add(PostSyncPushRequestChangesInnerAnyOfAnyOfPayload.serializer)
      ..add(PostWsTicket200Response.serializer)
      ..add(PutAdminAccountsByAdminIdIdentityRequest.serializer)
      ..add(PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum.serializer)
      ..add(PutAdminGroupsByGroupIdPermissionsRequest.serializer)
      ..add(PutAdminUsersByUserIdAvatar200Response.serializer)
      ..add(PutAdminUsersByUserIdAvatarRequest.serializer)
      ..add(PutAdminUsersByUserIdAvatarRequestContentTypeEnum.serializer)
      ..add(PutAdminUsersByUserIdPhoneRequest.serializer)
      ..add(PutProfileAvatarRequest.serializer)
      ..add(PutProfileAvatarRequestContentTypeEnum.serializer)
      ..add(RecurringTransaction.serializer)
      ..add(RecurringTransactionFrequencyEnum.serializer)
      ..add(RecurringTransactionTxTypeEnum.serializer)
      ..add(ResetAdminBannerSlotRequest.serializer)
      ..add(ResetAdminBannerSlotRequestRevisionsInner.serializer)
      ..add(Transaction.serializer)
      ..add(TransactionAaModeEnum.serializer)
      ..add(TransactionCategoryKindEnum.serializer)
      ..add(TransactionSplit.serializer)
      ..add(TransactionTxTypeEnum.serializer)
      ..add(UpdateAdminBannerRequest.serializer)
      ..add(UpdateAdminBannerRequestSlotEnum.serializer)
      ..add(UpdateAdminBannerRequestTargetEnum.serializer)
      ..add(UpdateOfficialFitnessTaxonomyRequest.serializer)
      ..add(UploadAdminBannerImage201Response.serializer)
      ..add(UploadAdminBannerImageRequest.serializer)
      ..add(UploadOfficialFitnessMedia201Response.serializer)
      ..add(UploadOfficialFitnessMediaRequest.serializer)
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Category)]),
          () => ListBuilder<Category>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Category)]),
          () => ListBuilder<Category>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(CategoryConflict)]),
          () => ListBuilder<CategoryConflict>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(DayBook)]),
          () => ListBuilder<DayBook>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(DayEvent)]),
          () => ListBuilder<DayEvent>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(DayEvent)]),
          () => ListBuilder<DayEvent>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GetAdminAnalytics200ResponseSeriesInner)]),
          () => ListBuilder<GetAdminAnalytics200ResponseSeriesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetAdminAnalyticsCatalog200ResponseEventsInner)
          ]),
          () => ListBuilder<GetAdminAnalyticsCatalog200ResponseEventsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetAdminAnalyticsDetails200ResponseSeriesInner)
          ]),
          () => ListBuilder<GetAdminAnalyticsDetails200ResponseSeriesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetAdminAnalyticsDetails200ResponsePagesInner)
          ]),
          () => ListBuilder<GetAdminAnalyticsDetails200ResponsePagesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetAdminAnalyticsDetails200ResponseEventsInner)
          ]),
          () => ListBuilder<GetAdminAnalyticsDetails200ResponseEventsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetAdminAnalyticsDetails200ResponseExposuresInner)
          ]),
          () =>
              ListBuilder<GetAdminAnalyticsDetails200ResponseExposuresInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GetAdminAuditLogs200ResponseItemsInner)]),
          () => ListBuilder<GetAdminAuditLogs200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetAdminBannerStatistics200ResponseItemsInner)
          ]),
          () => ListBuilder<GetAdminBannerStatistics200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GetAdminGroups200ResponseItemsInner)]),
          () => ListBuilder<GetAdminGroups200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetAdminGroupsByGroupIdMembers200ResponseItemsInner)
          ]),
          () => ListBuilder<
              GetAdminGroupsByGroupIdMembers200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetAdminIdentityTypes200ResponseItemsInner)
          ]),
          () => ListBuilder<GetAdminIdentityTypes200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetAdminPermissionCatalog200ResponsePermissionsInner)
          ]),
          () => ListBuilder<
              GetAdminPermissionCatalog200ResponsePermissionsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetAdminPermissionCatalog200ResponsePagesInner)
          ]),
          () => ListBuilder<GetAdminPermissionCatalog200ResponsePagesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetAdminPermissionCatalog200ResponseIdentitiesInner)
          ]),
          () => ListBuilder<
              GetAdminPermissionCatalog200ResponseIdentitiesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GetAdminUsers200ResponseItemsInner)]),
          () => ListBuilder<GetAdminUsers200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetAdminUsersByUserIdDevices200ResponseItemsInner)
          ]),
          () =>
              ListBuilder<GetAdminUsersByUserIdDevices200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GetAppBanners200ResponseAnyOf1ItemsInner)]),
          () => ListBuilder<GetAppBanners200ResponseAnyOf1ItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GetAppBanners200ResponseAnyOfItemsInner)]),
          () => ListBuilder<GetAppBanners200ResponseAnyOfItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetFitnessCatalog200ResponseExercisesInner)
          ]),
          () => ListBuilder<GetFitnessCatalog200ResponseExercisesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner)
          ]),
          () => ListBuilder<
              GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner)
          ]),
          () => ListBuilder<
              GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetFitnessLibrary200ResponsePlansInnerDaysInner)
          ]),
          () => ListBuilder<GetFitnessLibrary200ResponsePlansInnerDaysInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetFitnessLibrary200ResponsePlansInnerDaysInner)
          ]),
          () => ListBuilder<GetFitnessLibrary200ResponsePlansInnerDaysInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetFitnessLibrary200ResponseTemplatesInner)
          ]),
          () => ListBuilder<GetFitnessLibrary200ResponseTemplatesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GetFitnessLibrary200ResponsePlansInner)]),
          () => ListBuilder<GetFitnessLibrary200ResponsePlansInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue)
          ]),
          () => MapBuilder<String,
              GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue>())
      ..addBuilderFactory(
          const FullType(BuiltSet, const [const FullType(String)]),
          () => SetBuilder<String>())
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(bool)]),
          () => MapBuilder<String, bool>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue)
          ]),
          () => MapBuilder<String,
              GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue>())
      ..addBuilderFactory(
          const FullType(BuiltSet, const [const FullType(String)]),
          () => SetBuilder<String>())
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(bool)]),
          () => MapBuilder<String, bool>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner)
          ]),
          () => ListBuilder<
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetLedgersByLedgerIdAaStats200ResponseParticipantsInner)
          ]),
          () => ListBuilder<
              GetLedgersByLedgerIdAaStats200ResponseParticipantsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetLedgersByLedgerIdAaStats200ResponseTransfersInner)
          ]),
          () => ListBuilder<
              GetLedgersByLedgerIdAaStats200ResponseTransfersInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetLedgersByLedgerIdMemberStats200ResponseItemsInner)
          ]),
          () => ListBuilder<
              GetLedgersByLedgerIdMemberStats200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner)
          ]),
          () => ListBuilder<
              GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetLedgersByLedgerIdTransactionStats200ResponseByDayInner)
          ]),
          () => ListBuilder<
              GetLedgersByLedgerIdTransactionStats200ResponseByDayInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner)
          ]),
          () => ListBuilder<
              GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner)
          ]),
          () => ListBuilder<
              GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetSyncAccountingFull200ResponseLedgerSnapshotsInner)
          ]),
          () => ListBuilder<
              GetSyncAccountingFull200ResponseLedgerSnapshotsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Category)]),
          () => ListBuilder<Category>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(ExchangeRateOverride)]),
          () => ListBuilder<ExchangeRateOverride>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Category)]),
          () => ListBuilder<Category>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetSyncFitnessSpaces200ResponseFitnessSpacesInner)
          ]),
          () =>
              ListBuilder<GetSyncFitnessSpaces200ResponseFitnessSpacesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetSyncFull200ResponseRecurringStateRulesInner)
          ]),
          () => ListBuilder<GetSyncFull200ResponseRecurringStateRulesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetSyncFull200ResponseRecurringStateOccurrencesInner)
          ]),
          () => ListBuilder<
              GetSyncFull200ResponseRecurringStateOccurrencesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GetSyncMemoBooks200ResponseMemoBooksInner)
          ]),
          () => ListBuilder<GetSyncMemoBooks200ResponseMemoBooksInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GetSyncPull200ResponseChangesInner)]),
          () => ListBuilder<GetSyncPull200ResponseChangesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(ListAdminBannerTargets200ResponseItemsInner)
          ]),
          () => ListBuilder<ListAdminBannerTargets200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(ListAdminBanners200ResponseItemsInner)]),
          () => ListBuilder<ListAdminBanners200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(ListOfficialExercises200ResponseItemsInner)
          ]),
          () => ListBuilder<ListOfficialExercises200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                ListOfficialFitnessReferences200ResponseExercisesInner)
          ]),
          () => ListBuilder<
              ListOfficialFitnessReferences200ResponseExercisesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                ListOfficialFitnessReferences200ResponseExercisesInner)
          ]),
          () => ListBuilder<
              ListOfficialFitnessReferences200ResponseExercisesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(ListOfficialFitnessTaxonomies200ResponseItemsInner)
          ]),
          () =>
              ListBuilder<ListOfficialFitnessTaxonomies200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(ListOfficialPlans200ResponseItemsInner)]),
          () => ListBuilder<ListOfficialPlans200ResponseItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(ListOfficialTemplates200ResponseItemsInner)
          ]),
          () => ListBuilder<ListOfficialTemplates200ResponseItemsInner>())
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
          const FullType(BuiltList, const [const FullType(Member)]),
          () => ListBuilder<Member>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Transaction)]),
          () => ListBuilder<Transaction>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Category)]),
          () => ListBuilder<Category>())
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
          const FullType(BuiltList, const [const FullType(MemoEntry)]),
          () => ListBuilder<MemoEntry>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(MemoEntry)]),
          () => ListBuilder<MemoEntry>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(PostAdminAnalyticsFunnel200ResponseStepsInner)
          ]),
          () => ListBuilder<PostAdminAnalyticsFunnel200ResponseStepsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(PostAdminGroupsByGroupIdMembersRequestMembersInner)
          ]),
          () =>
              ListBuilder<PostAdminGroupsByGroupIdMembersRequestMembersInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(PostAnalyticsEventsRequestEventsInner)]),
          () => ListBuilder<PostAnalyticsEventsRequestEventsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner)
          ]),
          () => ListBuilder<
              PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner)
          ]),
          () => ListBuilder<
              PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner)
          ]),
          () => ListBuilder<
              PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                PostLedgersByLedgerIdCategoriesReorderRequestItemsInner)
          ]),
          () => ListBuilder<
              PostLedgersByLedgerIdCategoriesReorderRequestItemsInner>())
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
            const FullType(
                PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner)
          ]),
          () => ListBuilder<
              PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner>())
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
          const FullType(BuiltList, const [
            const FullType(
                PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner)
          ]),
          () => ListBuilder<
              PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner)
          ]),
          () => ListBuilder<
              PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner)
          ]),
          () => ListBuilder<
              PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner)
          ]),
          () => ListBuilder<
              PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(RecurringTransaction)]),
          () => ListBuilder<RecurringTransaction>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
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
          const FullType(BuiltList, const [const FullType(TransactionSplit)]),
          () => ListBuilder<TransactionSplit>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(String)]),
          () => MapBuilder<String, String>())
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(String)]),
          () => MapBuilder<String, String>())
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(String)]),
          () => MapBuilder<String, String>())
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
          const FullType(BuiltSet, const [
            const FullType(
                GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum)
          ]),
          () => SetBuilder<
              GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner)
          ]),
          () => ListBuilder<
              GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner>())
      ..addBuilderFactory(
          const FullType(BuiltSet, const [
            const FullType(
                GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum)
          ]),
          () => SetBuilder<
              GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum>())
      ..addBuilderFactory(
          const FullType(BuiltSet, const [
            const FullType(ResetAdminBannerSlotRequestRevisionsInner)
          ]),
          () => SetBuilder<ResetAdminBannerSlotRequestRevisionsInner>())
      ..addBuilderFactory(
          const FullType(BuiltSet, const [const FullType(String)]),
          () => SetBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltSet, const [const FullType(String)]),
          () => SetBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltSet, const [const FullType(String)]),
          () => SetBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessLibrary200ResponseTemplatesInnerExercisesInner)
          ]),
          () => ListBuilder<
              GetFitnessLibrary200ResponseTemplatesInnerExercisesInner>())
      ..addBuilderFactory(
          const FullType(BuiltSet, const [const FullType(String)]),
          () => SetBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GetFitnessLibrary200ResponseTemplatesInnerExercisesInner)
          ]),
          () => ListBuilder<
              GetFitnessLibrary200ResponseTemplatesInnerExercisesInner>())
      ..addBuilderFactory(
          const FullType(BuiltSet, const [const FullType(String)]),
          () => SetBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltSet, const [const FullType(String)]),
          () => SetBuilder<String>()))
    .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
