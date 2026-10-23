/// 由 flutter gen-l10n 自动生成，请勿手改。同一语言代码的区域变体（zh 与 zh_TW）合并于同一文件。

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get startupPreparationTitle => 'Unable to finish starting the app';

  @override
  String get startupPreparationMessage =>
      'Local settings could not be read. Please retry to continue.';

  @override
  String get startupPreparing => 'Preparing your data';

  @override
  String get appUpdateCancelDownload => 'Cancel download';

  @override
  String get appUpdateReady => 'Update downloaded. Ready to install.';

  @override
  String get appUpdatePaused => 'Waiting for the network or a system retry.';

  @override
  String get appUpdateBackground =>
      'Downloading in the background. You can close this window.';

  @override
  String get calendarAnniversary => 'Anniversary';

  @override
  String get calendarNote => 'Note';

  @override
  String get calendarCredential => 'Credentials';

  @override
  String get calendarTraining => 'Workout';

  @override
  String get calendarTemplate => 'Template';

  @override
  String get calendarPlan => 'Plan';

  @override
  String get syncCenterSubtitle =>
      'View sync status and resolve conflicts, failures, and pending actions';

  @override
  String get calendarEmptyDay => 'No records for this day';

  @override
  String get fitnessHomeSyncing => 'Refreshing fitness data';

  @override
  String get fitnessPullLocalSuccess => 'Local fitness data refreshed';

  @override
  String get fitnessPullCloudSuccess => 'Cloud fitness data synced';

  @override
  String get fitnessPullCloudFailedButLocalOk =>
      'Local fitness data refreshed; cloud sync failed';

  @override
  String get fitnessDetailEmptyExercises => 'No exercises yet';

  @override
  String get fitnessWorkoutMissing => 'This workout is unavailable';

  @override
  String get fitnessTemplateMissing => 'This template is unavailable';

  @override
  String get fitnessMissingDetailHint => 'Go back and select another item.';

  @override
  String get fitnessReorderHint => 'Long press the title to reorder';

  @override
  String get fitnessHomeExerciseLabel => 'Exercises';

  @override
  String get fitnessSetRestTime => 'Set rest time';

  @override
  String get fitnessWarmupLabel => 'Warmup';

  @override
  String get fitnessRepUnit => 'reps';

  @override
  String get fitnessSideWeight => 'Per side';

  @override
  String get fitnessTotalWeight => 'Total weight';

  @override
  String get fitnessLeftKg => 'L kg';

  @override
  String get fitnessRightKg => 'R kg';

  @override
  String fitnessSideWeightValue(String left, String right) {
    return 'L $left / R $right kg';
  }

  @override
  String fitnessPlanTrainingDays(int count) {
    return 'Train $count days';
  }

  @override
  String fitnessPlanRestDays(int count) {
    return 'Rest $count days';
  }

  @override
  String get fitnessExerciseTotal => 'Exercises';

  @override
  String fitnessSetCount(int count) {
    return '$count sets';
  }

  @override
  String get fitnessFinishConfirm =>
      'End this workout and save the current time and completed sets? You can restart it later.';

  @override
  String get fitnessStartUsingTemplate => 'Start workout with this template';

  @override
  String get fitnessEdit => 'Edit';

  @override
  String get fitnessMyPlans => 'My plans';

  @override
  String get fitnessMyTemplates => 'My templates';

  @override
  String get fitnessViewAll => 'View all';

  @override
  String get fitnessCreateBlank => 'Add workout';

  @override
  String get fitnessSelectedTraining => 'My workouts';

  @override
  String get fitnessNoSelectedTraining => 'No workouts on this date';

  @override
  String get fitnessNoPlans => 'No plans yet';

  @override
  String get fitnessNoTemplates => 'No templates yet';

  @override
  String get memoBackupLocalOnly =>
      'Local backup saved. Cloud upload failed; please try again later.';

  @override
  String get appTitle => 'Sesame Notes';

  @override
  String get tabHome => 'Home';

  @override
  String get tabAnalytics => 'Statistics';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get tabMine => 'Mine';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonOk => 'OK';

  @override
  String get commonDone => 'Done';

  @override
  String get homeSelectBillMonth => 'Select month';

  @override
  String get homePickerHint => 'Swipe up or down to pick';

  @override
  String get homeBackToCurrentMonth => 'Back to current month';

  @override
  String get homeTodayExpense => 'Today';

  @override
  String get homeWeekExpense => 'This week';

  @override
  String get homeMonthExpense => 'This month';

  @override
  String get homeDetailCategory => 'Category';

  @override
  String get homeDetailDate => 'Date';

  @override
  String get homeDetailAmount => 'Amount';

  @override
  String get homeDetailCurrency => 'Currency';

  @override
  String get homeDetailNativeAmount => 'In base currency';

  @override
  String get homeDetailMembers => 'Members';

  @override
  String get homeDetailCreator => 'Created by';

  @override
  String get homeDetailLastEditor => 'Last edited by';

  @override
  String get homeDetailEditHistory => 'Edit history';

  @override
  String get homeDetailEditHistoryHint => 'View only';

  @override
  String get homeDetailEditButton => 'Edit';

  @override
  String get homeDetailNoHistory => 'No edit history';

  @override
  String get homeDeleteDetailTitle => 'Delete this entry?';

  @override
  String homeDeleteDetailMessage(Object name) {
    return 'This will delete the \"$name\" record. This action cannot be undone.';
  }

  @override
  String get commonEmpty => 'Nothing here yet';

  @override
  String get commonError => 'Error';

  @override
  String get commonFailed => 'Failed';

  @override
  String get commonOperationFailed =>
      'Operation failed, please try again later';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonFinish => 'Finish';

  @override
  String get commonOther => 'Other';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonNoteHint => 'Note...';

  @override
  String get commonSettings => 'Settings';

  @override
  String get commonCurrent => 'Current';

  @override
  String get commonConfigure => 'Configure';

  @override
  String get commonPressAgainToExit => 'Press again to exit';

  @override
  String get commonWeekdayMonday => 'Monday';

  @override
  String get commonWeekdayTuesday => 'Tuesday';

  @override
  String get commonWeekdayWednesday => 'Wednesday';

  @override
  String get commonWeekdayThursday => 'Thursday';

  @override
  String get commonWeekdayFriday => 'Friday';

  @override
  String get commonWeekdaySaturday => 'Saturday';

  @override
  String get commonWeekdaySunday => 'Sunday';

  @override
  String get homeExpense => 'Expense';

  @override
  String get homeNoRecords => 'No records yet';

  @override
  String get homeSelectDate => 'Select date';

  @override
  String homeYear(int year) {
    return '$year';
  }

  @override
  String homeMonth(String month) {
    return '${month}M';
  }

  @override
  String homeMonthExpenseOf(String month) {
    return 'Month $month';
  }

  @override
  String get homeBaseCurrencyNeedLedger => 'Please create a ledger first';

  @override
  String homeBaseCurrencySwitched(String code) {
    return 'Ledger currency switched to $code';
  }

  @override
  String get homePullCloudSuccess => 'Synced cloud ledger data';

  @override
  String get homePullCloudFailed => 'Refresh failed, please try again later';

  @override
  String get homePullLocalSuccess => 'Refreshed local ledger data & config';

  @override
  String get homePullCloudFailedButLocalOk =>
      'Cloud sync failed; refreshed local data (rates/config)';

  @override
  String get homeSyncing => 'Refreshing ledger data';

  @override
  String get dayHomeSyncing => 'Refreshing anniversary book data';

  @override
  String get dayPullLocalSuccess => 'Refreshed local anniversary book data';

  @override
  String get dayPullCloudSuccess => 'Synced cloud anniversary book data';

  @override
  String get dayPullCloudFailedButLocalOk =>
      'Cloud sync failed; refreshed local anniversary book data';

  @override
  String get dayPullLocalFailed =>
      'Local anniversary book refresh failed. Please try again later';

  @override
  String get dayPullCloudFailed =>
      'Cloud anniversary book refresh failed. Please try again later';

  @override
  String get analyticsMonth => 'Month';

  @override
  String get analyticsYear => 'Year';

  @override
  String get analyticsWeek => 'Week';

  @override
  String get analyticsTotalExpenseLabel => 'Total Expense';

  @override
  String get analyticsCategoryLabel => 'Category';

  @override
  String get analyticsExpenseRatio => 'Expense Ratio';

  @override
  String get analyticsThisWeek => 'This Week';

  @override
  String get analyticsBackToThisWeek => 'Back to This Week';

  @override
  String get analyticsBackToThisMonth => 'Back to This Month';

  @override
  String get analyticsBackToThisYear => 'Back to This Year';

  @override
  String analyticsWeekN(int week) {
    return 'Week $week';
  }

  @override
  String get analyticsSelectWeek => 'Select week';

  @override
  String get ledgersTitle => 'Ledger Management';

  @override
  String get ledgersArchivedTitle => 'Archived ledgers';

  @override
  String get ledgersArchivedLabel => 'Archived';

  @override
  String get ledgersArchive => 'Archive ledger';

  @override
  String get ledgersRestore => 'Restore ledger';

  @override
  String get ledgersArchiveSuccess => 'Ledger archived';

  @override
  String get ledgersRestoreSuccess => 'Ledger restored';

  @override
  String get ledgersArchivedRestoreRequired =>
      'This ledger is archived. Restore it before continuing.';

  @override
  String get ledgersNew => 'Add Ledger';

  @override
  String get ledgersClear => 'Clear Ledger';

  @override
  String ledgersClearMessage(Object name) {
    return 'Are you sure to clear all transactions in ledger \"$name\"? This action cannot be undone.\\nThe ledger will be kept, only transaction data will be deleted.';
  }

  @override
  String get ledgerDefaultName => 'Default Ledger';

  @override
  String get ledgersEdit => 'Edit Ledger';

  @override
  String get ledgersDelete => 'Delete Ledger';

  @override
  String get ledgersDeleteConfirm => 'Delete Ledger';

  @override
  String get ledgersDeleteMessage =>
      'Are you sure you want to delete this ledger and all its records? This action cannot be undone.\\nIf there is a backup in the cloud, it will also be deleted.';

  @override
  String get ledgersDeleted => 'Deleted';

  @override
  String get ledgersClearTitle => 'Clear Ledger';

  @override
  String get ledgersClearSuccess => 'Ledger cleared';

  @override
  String get ledgersCreateSuccess => 'Ledger created';

  @override
  String get ledgerNameLabel => 'Ledger Name';

  @override
  String get ledgerNameHint => 'Please enter the ledger name';

  @override
  String get ledgersDefaultLedgerName => 'Default Ledger';

  @override
  String get ledgersCurrency => 'Currency';

  @override
  String get ledgersMonthStartDay => 'Month start day';

  @override
  String get ledgersMonthStartDayHint =>
      'Statistics and budgets start each monthly period on the selected day (1~31). If that date does not exist, use the last day of that month (30, 29 or 28).';

  @override
  String get ledgersMonthStartDayNatural => '1st (calendar month)';

  @override
  String ledgersMonthStartDayValue(int day) {
    return 'Day $day of each month';
  }

  @override
  String get ledgersSearchCurrency => 'Search: Chinese or code';

  @override
  String get ledgersCreate => 'Add ledger';

  @override
  String ledgersRecords(String count) {
    return 'Records: $count';
  }

  @override
  String ledgersExpense(String expense) {
    return 'Expense: $expense';
  }

  @override
  String get ledgersEmpty => 'No ledgers';

  @override
  String get ledgersSectionLocal => 'Local ledgers';

  @override
  String get ledgersSectionCloud => 'Cloud Ledgers';

  @override
  String get joinSharedTitle => 'Join Shared Ledger';

  @override
  String get joinSharedCodeHint => 'Enter invite code';

  @override
  String get joinSharedQuery => 'Query';

  @override
  String get joinSharedQueryFailed => 'Invalid or expired invite code';

  @override
  String get joinSharedAlreadyOwner =>
      'You are already the owner of this ledger';

  @override
  String get joinSharedAccept => 'Accept Invite';

  @override
  String get joinSharedSuccess => 'Ledger joined';

  @override
  String get joinSharedNeedLogin => 'Login required to join a shared ledger';

  @override
  String get joinSharedPreviewTitle => 'Invite Details';

  @override
  String get ledgersActionMoveToCloud => 'Move to the Cloud';

  @override
  String get ledgersActionMoveToLocal => 'Move to local';

  @override
  String get ledgersActionCopyToLocal => 'Copy to local';

  @override
  String ledgersMoveToCloudMessage(String name) {
    return 'Ledger \"$name\" will be uploaded to the cloud and synced across your devices.';
  }

  @override
  String ledgersMoveToLocalMessage(String name) {
    return 'Ledger \"$name\" will be deleted from the cloud and kept on this device only. Other devices will no longer see it.';
  }

  @override
  String ledgersCopyToLocalMessage(String name) {
    return 'A local copy of ledger \"$name\" will be created. The cloud ledger stays unchanged.';
  }

  @override
  String get ledgersMoveToCloudSuccess => 'Moved to the Cloud';

  @override
  String get ledgersMoveToLocalSuccess => 'Moved to local';

  @override
  String get ledgersCopyToLocalSuccess => 'Copied to local';

  @override
  String ledgersSwitched(String name) {
    return 'Switched to ledger \"$name\"';
  }

  @override
  String get categoryTitle => 'Category Management';

  @override
  String get categoryExpense => 'Expense';

  @override
  String get categoryEmpty => 'No categories';

  @override
  String get importReading => 'Reading file…';

  @override
  String get importPreparing => 'Preparing…';

  @override
  String get importConfirmMapping => 'Confirm Mapping';

  @override
  String get importCategoryMapping => 'Category Mapping';

  @override
  String get importNoDataParsed =>
      'No data parsed. Please return to previous page to check CSV content or separator.';

  @override
  String get importFieldAmount => 'Amount';

  @override
  String get importFieldNote => 'Note';

  @override
  String get importKeepOriginalName => 'Keep original name';

  @override
  String get importNextStep => 'Next Step';

  @override
  String get importPreviousStep => 'Previous Step';

  @override
  String get importStartImport => 'Start Import';

  @override
  String get importInProgress => 'Import in Progress';

  @override
  String get importFetchingRates => 'Fetching exchange rates…';

  @override
  String get importXlsxFormulaError =>
      'Formula cells detected. Please save values in Excel first and retry';

  @override
  String get importPrecheckTitle => 'Import Pre-check';

  @override
  String importProgressRunning(Object done, Object total) {
    return 'Processed $done / $total records';
  }

  @override
  String get importCancelled => 'Import Cancelled';

  @override
  String get mineTitle => 'Mine';

  @override
  String get mineLanguageSettings => 'Language Settings';

  @override
  String get languageTitle => 'Language Settings';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSystemDefault => 'Follow System';

  @override
  String get mineCloudService => 'Backup & Cloud Sync';

  @override
  String get cloudBackupUrlLabel => 'Server URL';

  @override
  String get cloudBackupAnonKeyLabel => 'Anon Key';

  @override
  String get cloudBackupBucketLabel => 'Bucket';

  @override
  String get cloudBackupAccountLabel => 'Account';

  @override
  String get cloudBackupPasswordLabel => 'Password';

  @override
  String get cloudBackupUsernameLabel => 'Username';

  @override
  String get cloudBackupRemotePathLabel => 'Remote Path';

  @override
  String get cloudBackupEndpointLabel => 'Endpoint';

  @override
  String get cloudBackupRegionLabel => 'Region';

  @override
  String get cloudBackupAccessKeyLabel => 'Access Key';

  @override
  String get cloudBackupSecretKeyLabel => 'Secret Key';

  @override
  String get cloudBackupSslLabel => 'Use SSL';

  @override
  String get cloudBackupPortLabel => 'Port';

  @override
  String get cloudBackupNotConfigured => 'Not configured';

  @override
  String get cloudBackupConfiguredInactive => 'Configured, not currently used';

  @override
  String get cloudBackupActiveNoSuccess => 'In use · No successful backup yet';

  @override
  String cloudBackupActiveLastSuccess(String time) {
    return 'In use · Last success $time';
  }

  @override
  String get mineCategoryManagement => 'Category Management';

  @override
  String get mineReminderSettings => 'Notification Settings';

  @override
  String get categoryEditTitle => 'Edit Category';

  @override
  String get categoryNewTitle => 'Add Category';

  @override
  String get categoryDetailTooltip => 'Category Summary';

  @override
  String get categoryDefaultTitle => 'Default Category';

  @override
  String get categoryNameLabel => 'Category Name';

  @override
  String get categoryNameHint => 'Enter category name';

  @override
  String get categoryNameDuplicate => 'Category name already exists';

  @override
  String get categoryIconLabel => 'Category Icon';

  @override
  String get categoryCurrentIcon => 'Current Icon';

  @override
  String get categorySaveError => 'Save failed';

  @override
  String categoryUpdated(Object name) {
    return 'Category \"$name\" updated';
  }

  @override
  String categoryCreated(Object name) {
    return 'Category \"$name\" created';
  }

  @override
  String get categoryCannotDelete => 'Cannot delete';

  @override
  String get categoryClearUnused => 'Clear Unused Categories';

  @override
  String categoryClearUnusedMessage(Object count) {
    return 'Are you sure you want to delete $count unused categories? This action cannot be undone.';
  }

  @override
  String get categoryClearUnusedListTitle => 'Categories to be deleted:';

  @override
  String get categoryClearUnusedEmpty => 'No unused categories';

  @override
  String categoryClearUnusedSuccess(Object count) {
    return 'Deleted $count categories';
  }

  @override
  String get categoryClearUnusedFailed => 'Clear failed';

  @override
  String get categoryDeleteError => 'Delete failed';

  @override
  String categorySubCategoryCreated(Object name) {
    return 'Subcategory added: $name';
  }

  @override
  String get categoryParentCategoryTitle => 'Belongs To';

  @override
  String get categorySelectParentHint => 'Please select a category';

  @override
  String get categorySelectParentTitle => 'Select Category';

  @override
  String get categoryHasSubCategories =>
      'This category has subcategories and cannot be modified';

  @override
  String get categorySearchCategory => 'Search categories';

  @override
  String get categoryTopLevelLabel => 'Top-level';

  @override
  String get categorySecondLevelLabel => 'Second-level';

  @override
  String get categoryExpenseList =>
      'Dining-Transport-Shopping-Entertainment-Home-Family-Communication-Utilities-Housing-Medical-Education-Pets-Sports-Digital-Travel-Alcohol & Tobacco-Baby Care-Beauty-Repair-Social-Learning-Car-Taxi-Subway-Delivery-Property-Parking-Donation-Give Gift-Tax-Beverage-Clothing-Snacks-Send Red Packet-Fruit-Game-Books-Lover-Decoration-Daily Goods-Lottery-Stock-Social Security-Express-Work-Transfer-Other';

  @override
  String get categoryExpenseDining =>
      'Dining-Breakfast-Lunch-Dinner-Meituan Delivery-Ele.me Delivery-JD Delivery-Restaurant-Food';

  @override
  String get categoryExpenseSnacks =>
      'Snacks-Cookies-Chips-Candy-Chocolate-Nuts';

  @override
  String get categoryExpenseFruit =>
      'Fruit-Apple-Banana-Orange-Grape-Watermelon-Other Fruits';

  @override
  String get categoryExpenseBeverage =>
      'Beverage-Milk Tea-Coffee-Juice-Soda-Mineral Water';

  @override
  String get categoryExpensePastry => 'Pastry-Cake-Bread-Dessert-Baked Goods';

  @override
  String get categoryExpenseCooking =>
      'Cooking Ingredients-Vegetables-Meat-Seafood-Seasoning-Grain & Oil';

  @override
  String get categoryExpenseShopping =>
      'Shopping-Supermarket-Daily Necessities-Clothing-Shoes-Bags';

  @override
  String get categoryExpensePets =>
      'Pets-Pet Food-Pet Supplies-Pet Medical-Pet Grooming';

  @override
  String get categoryExpenseTransport =>
      'Transport-Transit Card-Taxi-Parking Fee-Fuel';

  @override
  String get categoryExpenseCar =>
      'Car-Car Maintenance-Car Repair-Car Insurance-Car Wash-Traffic Fine';

  @override
  String get categoryExpenseClothing =>
      'Apparel-Top-Pants-Dress-Shoes-Apparel Accessories';

  @override
  String get categoryExpenseDailyGoods =>
      'Daily Goods-Personal Care-Paper Products-Cleaning Supplies-Kitchen Supplies';

  @override
  String get categoryExpenseEducation =>
      'Education-Tuition-Training Fee-Books-Stationery-Office Supplies-Learning';

  @override
  String get categoryExpenseInvestLoss =>
      'Investment Loss-Stock Loss-Fund Loss-Other Investment Loss';

  @override
  String get categoryExpenseEntertainment =>
      'Entertainment-Movie-KTV-Amusement Park-Bar-Other Entertainment';

  @override
  String get categoryExpenseGame =>
      'Game-Game Top up-Game Equipment-Game Membership';

  @override
  String get categoryExpenseHealthProducts =>
      'Health Products-Vitamins-Health Food-Nutritional Supplements';

  @override
  String get categoryExpenseSubscription =>
      'Subscription-Video Membership-Music Membership-Cloud Storage-Other Subscription';

  @override
  String get categoryExpenseSports =>
      'Sports-Gym-Sports Equipment-Sports Course-Outdoor Activity';

  @override
  String get categoryExpenseHousing =>
      'Housing-Utilities-Property Fee-Rent-Mortgage-Renovation-Broadband';

  @override
  String get categoryExpenseHome =>
      'Home-Furniture-Appliances-Decorations-Bedding';

  @override
  String get categoryExpenseBeauty =>
      'Beauty-Skincare-Cosmetics-Haircut-Nail Care';

  @override
  String get categoryExpenseTransfer =>
      'Transfer-Living Cost-Family-Parents-Lover-Borrow Money';

  @override
  String get appearanceThemeMode => 'Display mode';

  @override
  String get appearanceThemeModeSystem => 'Follow System';

  @override
  String get appearanceThemeModeLight => 'Light Mode';

  @override
  String get appearanceThemeModeDark => 'Dark Mode';

  @override
  String get reminderTitle => 'Recording Reminder';

  @override
  String get reminderBody => 'Don\'t forget to record today\'s expenses 💰';

  @override
  String get reminderDailyTitle => 'Recording Reminder';

  @override
  String get reminderTimeTitle => 'Daily Reminder Time';

  @override
  String get commonSelectTime => 'Select Time';

  @override
  String get reminderPermissionRequired =>
      'Allow notifications and the relevant reminder channel in system settings';

  @override
  String get reminderCheckBattery => 'Battery';

  @override
  String get reminderStatusUnavailable =>
      'Unable to read status. Please try again later.';

  @override
  String get reminderStatusLoading => 'Reading system settings…';

  @override
  String get reminderChannelNotCreated => 'Not created yet';

  @override
  String get reminderBatteryIgnored =>
      'Battery management: Exempt from system battery restrictions';

  @override
  String get reminderBatteryNotIgnored =>
      'Battery management: Subject to system battery restrictions';

  @override
  String get reminderCheckChannel => 'Notifications';

  @override
  String get reminderStatusNotificationLabel => 'Notification';

  @override
  String get reminderStatusImportanceLabel => 'Importance';

  @override
  String get reminderStatusSoundLabel => 'Sound';

  @override
  String get reminderStatusVibrationLabel => 'Vibration';

  @override
  String get reminderStatusDndLabel => 'DND';

  @override
  String get reminderStatusOn => 'On';

  @override
  String get reminderStatusOff => 'Off';

  @override
  String get reminderStatusDndBypass => 'Allowed';

  @override
  String get reminderStatusDndFollow => 'Follow system';

  @override
  String get reminderImportanceHigh => 'High';

  @override
  String get reminderImportanceDefault => 'Default';

  @override
  String get reminderImportanceLow => 'Low';

  @override
  String get reminderImportanceMin => 'Minimum';

  @override
  String get reminderImportanceNone => 'Off';

  @override
  String get reminderImportanceUnknown => 'Unknown';

  @override
  String get reminderOpenAppSettings => 'App Settings';

  @override
  String get reminderAutoStartSettings => 'Auto-start';

  @override
  String get reminderAutoStartAdvice =>
      'This device cannot open the auto-start page directly. Enable it manually in system settings.\n\nOnePlus, OPPO, realme: Settings → Apps → Auto-start → Sesame Notes.\n\nOther devices: search for Auto-start or App launch management and allow Sesame Notes to start automatically. Menu names vary by system version.';

  @override
  String get reminderDescription =>
      'Settings apply to this device. Turning off notifications pauses all reminders and keeps your preferences. Anniversary reminders are grouped by day and scheduled a year ahead, refreshed when you open the app or dates or records change.';

  @override
  String get reminderAndroidInstructions =>
      '• Enable recording, anniversary and rest reminders separately in notification settings, where you can also manage sound and vibration.\n• Allow Alarms & reminders to reduce delays. A next-alarm indicator may appear. Recording and anniversary reminders use normal notifications; rest timers play sound or vibrate according to your settings.\n• Enable background activity and auto-start separately. Battery status only checks the system power-saving exemption; manufacturer restrictions need a separate check.\n• Force-stopping the app may clear scheduled reminders. Reopen Sesame Notes to restore future reminders. Silent and Do Not Disturb modes may mute notification sounds.';

  @override
  String get categoryDetailLoadFailed =>
      'Could not load data. Please try again.';

  @override
  String get categoryDetailSummaryTitle => 'Category Summary';

  @override
  String get categoryDetailTotalCount => 'Total Count';

  @override
  String get categoryDetailTotalAmount => 'Total Amount';

  @override
  String get categoryDetailAverageAmount => 'Average Amount';

  @override
  String get categoryDetailSortTitle => 'Sort';

  @override
  String get categoryDetailSortTimeDesc => 'Time ↓';

  @override
  String get categoryDetailSortTimeAsc => 'Time ↑';

  @override
  String get categoryDetailSortAmountDesc => 'Amount ↓';

  @override
  String get categoryDetailSortAmountAsc => 'Amount ↑';

  @override
  String get categoryDetailNoTransactions => 'No transactions';

  @override
  String get categoryDetailNoTransactionsSubtext =>
      'No transactions in this category yet';

  @override
  String get categoryDetailDeleteFailed => 'Delete failed';

  @override
  String categoryMigrationTransactionLabel(int count) {
    return '$count records';
  }

  @override
  String get categoryTemplateEntryFlat => 'Flat Template';

  @override
  String get categoryTemplateEntryHierarchical => 'Hierarchical Template';

  @override
  String get categoryTemplateFlatTitle => 'Flat Category Template';

  @override
  String get categoryTemplateHierarchicalTitle =>
      'Hierarchical Category Template';

  @override
  String categoryTemplateSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get categoryTemplateSelectAll => 'Select all';

  @override
  String get categoryTemplateDeselectAll => 'Deselect all';

  @override
  String get categoryTemplateAlreadyAdded => 'Added';

  @override
  String get categoryTemplateAlreadyAddedHint =>
      'Added categories stay selected and cannot be deselected';

  @override
  String get categoryTemplateConfirmTitle => 'Add Categories';

  @override
  String categoryTemplateConfirmMessage(int count) {
    return 'Add the selected $count categories to your category list?';
  }

  @override
  String categoryTemplateAddSuccess(int count) {
    return 'Added $count categories';
  }

  @override
  String categoryTemplateAddFailed(String error) {
    return 'Failed to add: $error';
  }

  @override
  String categoryTemplatePartiallyCompleted(String completed) {
    return '$completed\nThe remaining categories could not be processed. Please try again.';
  }

  @override
  String get categoryManageAdd => 'Add Category';

  @override
  String get categoryManageDelete => 'Batch Delete Categories';

  @override
  String get categoryManageConfirmDelete => 'Confirm Delete';

  @override
  String get categoryManageReorderHint => 'Long press to reorder';

  @override
  String get categorySelectParentsTitle => 'Select Parent Categories';

  @override
  String get categoryChildrenTitle => 'Subcategories';

  @override
  String categoryManageSubcategoryCount(int count) {
    return 'Subcategories: $count';
  }

  @override
  String categorySubcategoryCount(int count) {
    return '$count subcategories';
  }

  @override
  String categoryTransactionBreakdown(int direct, int total) {
    return '$direct direct records · $total total';
  }

  @override
  String get categorySharedManageBannerOwner =>
      'Shared ledger: category changes here sync to all members';

  @override
  String get categorySharedManageBannerEditor =>
      'This shared ledger uses the owner\'s categories; edits here only affect your personal categories';

  @override
  String get categorySortSaveFailed => 'Failed to save order. Please try again';

  @override
  String get categoryDeleteOptionAll =>
      'Delete categories and all data (incl. subcategories)';

  @override
  String get categoryDeleteOptionMigrate =>
      'Delete categories and their subcategories and migrate all data to another category';

  @override
  String get categoryDeleteOptionPromote =>
      'Delete categories and data (excl. subcategories, subcategories become top-level)';

  @override
  String get categoryDeleteSelectedTitle => 'Delete Selected Categories';

  @override
  String categoryDeleteSelectedSubtitleWithSub(int count) {
    return 'Are you sure you want to delete $count selected categories and clear their data? (including subcategories and data) This action cannot be undone.';
  }

  @override
  String categoryDeleteSelectedSubtitleWithoutSub(int count) {
    return 'Are you sure you want to delete $count selected categories and clear their data? (excluding subcategories and data) This action cannot be undone.';
  }

  @override
  String get categoryMigrateSelectTargetTitle => 'Select Target Category';

  @override
  String get categoryMigrateConfirmButton =>
      'Confirm (Migrate data and delete categories)';

  @override
  String categoryMigrateChildLabel(Object parent) {
    return 'Sub · $parent';
  }

  @override
  String get subcategoryAdd => 'Add Subcategory';

  @override
  String get subcategoryDelete => 'Batch Delete';

  @override
  String get subcategoryDeleteOptionAll =>
      'Delete categories and all data under them';

  @override
  String get subcategoryDeleteOptionMigrate =>
      'Delete categories and migrate all data to another category';

  @override
  String subcategoryDeleteSelectedSubtitle(int count) {
    return 'Are you sure you want to delete $count selected categories and clear their data? This action cannot be undone.';
  }

  @override
  String get subcategoryEmpty => 'No subcategories yet';

  @override
  String get cloudFirstSaveSwitchTitle => 'Configuration Saved';

  @override
  String get cloudFirstSaveSwitchMessage =>
      'Switch to this cloud service as the active sync configuration now?';

  @override
  String get cloudSaveOnlyNoSwitch => 'Not Now';

  @override
  String get cloudSaveAndSwitch => 'Switch Now';

  @override
  String get cloudClearConfig => 'Clear configuration';

  @override
  String get cloudClearConfigConfirmTitle => 'Clear cloud configuration';

  @override
  String get cloudClearConfigConfirmMessage =>
      'Clear this cloud service configuration?\nBacked-up data on the cloud will not be deleted. You can reconfigure and restore anytime.';

  @override
  String get cloudClearConfigDone => 'Configuration cleared';

  @override
  String get authLogin => 'Login';

  @override
  String get authPassword => 'Password';

  @override
  String get authErrorInvalidCredentials =>
      'Incorrect phone number or password';

  @override
  String get authErrorRateLimit => 'Too many attempts, please try again later.';

  @override
  String get authErrorNetworkIssue =>
      'Network error, please check your connection and try again.';

  @override
  String get authErrorServerNotConfigured =>
      'This version has no account server configured, so login and registration are unavailable. You can go back and continue using local features.';

  @override
  String get exportCsvHeaderType => 'Type';

  @override
  String get exportCsvHeaderCategory => 'Category';

  @override
  String get exportCsvHeaderSubCategory => 'Subcategory';

  @override
  String get exportCsvHeaderAmount => 'Amount';

  @override
  String get exportCsvHeaderNote => 'Note';

  @override
  String get exportCsvHeaderTime => 'Time';

  @override
  String get exportSuccessTitle => 'Export Successful';

  @override
  String get exportFailedTitle => 'Export Failed';

  @override
  String get exportTypeExpense => 'Expense';

  @override
  String get currencyCNY => 'Chinese Yuan';

  @override
  String get currencyUSD => 'US Dollar';

  @override
  String get currencyEUR => 'Euro';

  @override
  String get currencyJPY => 'Japanese Yen';

  @override
  String get currencyHKD => 'Hong Kong Dollar';

  @override
  String get currencyTWD => 'Add Taiwan Dollar';

  @override
  String get currencyGBP => 'British Pound';

  @override
  String get currencyAUD => 'Australian Dollar';

  @override
  String get currencyCAD => 'Canadian Dollar';

  @override
  String get currencyKRW => 'South Korean Won';

  @override
  String get currencySGD => 'Singapore Dollar';

  @override
  String get currencyMYR => 'Malaysian Ringgit';

  @override
  String get currencyTHB => 'Thai Baht';

  @override
  String get currencyIDR => 'Indonesian Rupiah';

  @override
  String get currencyPHP => 'Philippine Peso';

  @override
  String get currencyVND => 'Vietnamese Dong';

  @override
  String get currencyINR => 'Indian Rupee';

  @override
  String get currencyRUB => 'Russian Ruble';

  @override
  String get currencyBYN => 'Belarusian Ruble';

  @override
  String get currencyNZD => 'Add Zealand Dollar';

  @override
  String get currencyCHF => 'Swiss Franc';

  @override
  String get currencySEK => 'Swedish Krona';

  @override
  String get currencyNOK => 'Norwegian Krone';

  @override
  String get currencyDKK => 'Danish Krone';

  @override
  String get currencyBRL => 'Brazilian Real';

  @override
  String get currencyMXN => 'Mexican Peso';

  @override
  String get currencyTRY => 'Turkish Lira';

  @override
  String get currencyZAR => 'South African Rand';

  @override
  String get currencyAED => 'UAE Dirham';

  @override
  String get currencySAR => 'Saudi Riyal';

  @override
  String get currencyPLN => 'Polish Zloty';

  @override
  String get currencyCZK => 'Czech Koruna';

  @override
  String get currencyHUF => 'Hungarian Forint';

  @override
  String get currencyARS => 'Argentine Peso';

  @override
  String get currencyCLP => 'Chilean Peso';

  @override
  String get currencyCOP => 'Colombian Peso';

  @override
  String get currencyPEN => 'Peruvian Sol';

  @override
  String get currencyEGP => 'Egyptian Pound';

  @override
  String get currencyNGN => 'Nigerian Naira';

  @override
  String get currencyKZT => 'Kazakhstani Tenge';

  @override
  String get currencyUAH => 'Ukrainian Hryvnia';

  @override
  String get currencyILS => 'Israeli New Shekel';

  @override
  String get currencyPKR => 'Pakistani Rupee';

  @override
  String get currencyBDT => 'Bangladeshi Taka';

  @override
  String get currencyLKR => 'Sri Lankan Rupee';

  @override
  String get currencyMMK => 'Myanmar Kyat';

  @override
  String get recurringTransactionEnabled => 'Enabled';

  @override
  String get recurringTransactionDisabled => 'Disabled';

  @override
  String get recurringTransactionTitle => 'Recurring Bills';

  @override
  String get recurringTransactionAdd => 'Add recurring bill';

  @override
  String get recurringTransactionEdit => 'Edit Recurring Bill';

  @override
  String get recurringTransactionFrequency => 'Frequency';

  @override
  String get recurringTransactionDaily => 'Daily';

  @override
  String get recurringTransactionWeekly => 'Weekly';

  @override
  String get recurringTransactionMonthly => 'Monthly';

  @override
  String get recurringTransactionYearly => 'Yearly';

  @override
  String get recurringTransactionInterval => 'Interval';

  @override
  String get recurringTransactionDayOfMonth => 'Day of Month';

  @override
  String get recurringTransactionStartDate => 'Start Date';

  @override
  String get recurringTransactionEndDate => 'End Date';

  @override
  String get recurringTransactionNoEndDate => 'Perpetual';

  @override
  String get recurringTransactionDeleteConfirm =>
      'Are you sure you want to delete this recurring bill?';

  @override
  String get recurringTransactionEndBeforeStart =>
      'End date cannot be earlier than start date';

  @override
  String recurringTransactionEveryNDays(int n) {
    return 'Every $n day(s)';
  }

  @override
  String recurringTransactionEveryNWeeks(int n) {
    return 'Every $n week(s)';
  }

  @override
  String recurringTransactionEveryNMonths(int n) {
    return 'Every $n month(s)';
  }

  @override
  String recurringTransactionEveryNYears(int n) {
    return 'Every $n year(s)';
  }

  @override
  String get ledgerSelectTitle => 'Select Ledger';

  @override
  String get cloudTestConnection => 'Test Connection';

  @override
  String cloudLastTestTime(String time) {
    return 'Last test time: $time';
  }

  @override
  String get cloudLocalStorageTitle => 'Local Storage';

  @override
  String get cloudLocalStorageSubtitle => 'Data is only saved on local device';

  @override
  String get localBackupPageTitle => 'Local Storage';

  @override
  String get localBackupAutoTitle => 'Auto Local Backup';

  @override
  String get localBackupAutoSubtitle =>
      'Automatically back up a database snapshot on first launch each day';

  @override
  String get localBackupNowTooltip => 'Back up now';

  @override
  String get localBackupSuccess => 'Backup completed';

  @override
  String get localBackupFailed =>
      'Backup failed. Check available storage space';

  @override
  String get localBackupListHint => 'Select a backup to restore:';

  @override
  String get localBackupImportFromFile => 'Import from file';

  @override
  String get localBackupImportInvalidFile =>
      'Please select a .snbak backup file';

  @override
  String get localBackupListEmpty => 'No backups yet';

  @override
  String get cloudCustomSupabaseTitle => 'Custom Supabase';

  @override
  String get cloudCustomSupabaseSubtitle =>
      'Click to configure self-hosted Supabase';

  @override
  String get cloudCustomWebdavTitle => 'Custom WebDAV';

  @override
  String get cloudCustomWebdavSubtitle =>
      'Click to configure Nutstore/Nextcloud etc.';

  @override
  String get cloudCustomS3Title => 'S3 Protocol Storage';

  @override
  String get cloudCustomS3Subtitle => 'AWS S3 / Cloudflare R2 / MinIO';

  @override
  String get cloudTabOffline => 'Offline';

  @override
  String get cloudTabBackup => 'Backup';

  @override
  String get cloudBackupEntryLocalOnly => 'Local backup only';

  @override
  String get cloudBackupEntryFailed =>
      'Last backup failed — will retry automatically';

  @override
  String get cloudBackupStatusTitle => 'Backup status';

  @override
  String get cloudBackupUploadNow => 'Upload to cloud now';

  @override
  String get cloudBackupUploading => 'Uploading…';

  @override
  String get cloudBackupUploadSuccess => 'Upload successful';

  @override
  String get cloudBackupRestoreFromCloud => 'Restore from cloud';

  @override
  String get cloudBackupDownloading => 'Downloading…';

  @override
  String get cloudBackupDownloadSuccess => 'Downloaded — opening restore page';

  @override
  String get cloudBackupDownloadFailed =>
      'Download failed — check cloud settings and network';

  @override
  String get cloudBackupNoRemote => 'No cloud backup yet';

  @override
  String get cloudBackupAutoSyncTitle => 'Auto backup to cloud';

  @override
  String get cloudBackupAutoSyncSubtitle =>
      'Sync upload to cloud during each auto backup';

  @override
  String get localBackupRestoreHint => 'Tap a backup to open the restore flow';

  @override
  String get cloudStatusNotTested => 'Not tested';

  @override
  String get cloudStatusNormal => 'Connection normal';

  @override
  String get cloudStatusFailed => 'Connection failed';

  @override
  String get cloudTestSuccessMessage =>
      'Connection normal, configuration valid';

  @override
  String get cloudTestFailedMessage => 'Connection failed';

  @override
  String get cloudSwitchConfirmTitle => 'Switch Cloud Service';

  @override
  String get cloudSwitchConfirmMessage =>
      'Switching cloud service will log out current account. Confirm switch?';

  @override
  String get cloudSwitchFailedTitle => 'Switch Failed';

  @override
  String get cloudSwitchFailedConfigMissing =>
      'Please configure this cloud service first';

  @override
  String get cloudConfigInvalidMessage => 'Please fill in complete information';

  @override
  String get cloudSaveFailed => 'Save Failed';

  @override
  String cloudSwitchedTo(String type) {
    return 'Switched to $type';
  }

  @override
  String get cloudConfigureSupabaseTitle => 'Configure Supabase';

  @override
  String get cloudConfigureWebdavTitle => 'Configure WebDAV';

  @override
  String get cloudConfigureS3Title => 'Configure S3';

  @override
  String get welcomeHomeBookkeeping => 'Bookkeeping';

  @override
  String get welcomeHomeAnniversary => 'Anniversary';

  @override
  String get welcomeHomeFitness => 'Fitness';

  @override
  String get welcomeHomeMemo => 'Memo';

  @override
  String get calendarToday => 'Back to Today';

  @override
  String get commonUncategorized => 'Uncategorized';

  @override
  String get appLockTitle => 'Lock App';

  @override
  String get appLockEnable => 'Enable App Lock';

  @override
  String get appLockEnableDesc => 'Require authentication on launch and resume';

  @override
  String get appLockSetPin => 'Set PIN';

  @override
  String get appLockChangePin => 'Change PIN';

  @override
  String get appLockVerifyPin => 'Verify PIN';

  @override
  String get appLockVerifyCurrentPin => 'Enter current PIN';

  @override
  String get appLockSetNewPin => 'Set new PIN';

  @override
  String get appLockConfirmPin => 'Confirm PIN';

  @override
  String get appLockEnterPin => 'Enter PIN';

  @override
  String get appLockPinSetSuccess => 'PIN set successfully';

  @override
  String get appLockDisabled => 'App Lock disabled';

  @override
  String get appLockBiometric => 'Biometric Unlock';

  @override
  String get appLockBiometricDesc => 'Use Face ID or fingerprint to unlock';

  @override
  String get appLockBiometricReason => 'Verify identity to unlock Sesame Notes';

  @override
  String get appLockTimeout => 'Auto-lock Timeout';

  @override
  String get appLockTimeoutImmediate => 'Immediately';

  @override
  String get appLockTimeout1Min => 'After 1 minute';

  @override
  String get appLockTimeout5Min => 'After 5 minutes';

  @override
  String get appLockTimeout15Min => 'After 15 minutes';

  @override
  String dayOfMonth(int day) {
    return '${day}th of each month';
  }

  @override
  String get sharedRoleOwner => 'Owner';

  @override
  String get sharedRoleEditor => 'Editor';

  @override
  String get commonCopied => 'Copied';

  @override
  String get sharedInviteFormRole => 'Role';

  @override
  String get sharedInviteFormExpiry => 'Valid for';

  @override
  String sharedInviteExpiryDays(int n) {
    return '$n day';
  }

  @override
  String get sharedInviteGenerate => 'Generate invite code';

  @override
  String get sharedInviteGenerateAnother => 'Generate a new code';

  @override
  String get sharedInviteCopyCode => 'Copy code';

  @override
  String get sharedInviteShareCode => 'Share code';

  @override
  String sharedInviteExpiresAt(String dt) {
    return 'Expires at $dt';
  }

  @override
  String get sharedInviteWarning =>
      'Each code can be used once. Generating a new code invalidates all unused codes for this ledger.';

  @override
  String get sharedInviteInstruction =>
      'Ask the recipient to open the ledger list from the bookkeeping home screen and choose Join shared ledger. Generating a new code invalidates all previous unused codes for this ledger.';

  @override
  String sharedInviteShareText(String ledger, String code) {
    return 'I\'m inviting you to the Sesame Notes shared ledger \"$ledger\".\n\nCode: $code\n\nOpen Sesame Notes → Me → Join shared ledger and enter this code.';
  }

  @override
  String get ledgerAaDescription => 'Track each member’s share of expenses';

  @override
  String ledgerMemberCount(int count) {
    return '$count members';
  }

  @override
  String get ledgerOwnerDescription => 'Manage the ledger and members';

  @override
  String get ledgerEditorDescription => 'Record and edit together';

  @override
  String ledgerInviteDescription(String ledger) {
    return 'Invite friends to “$ledger” and keep records together.';
  }

  @override
  String get ledgerInviteRoleDescription =>
      'Can view and edit records in this ledger.';

  @override
  String get ledgerInviteMembers => 'Invite members';

  @override
  String get sharedMembersStatsAllTime => 'All time';

  @override
  String sharedMembersStatsSummary(
    int memberCount,
    int txCount,
    String currency,
  ) {
    return '$memberCount payers · $txCount expenses · $currency';
  }

  @override
  String get sharedMembersStatsDistribution => 'Expense distribution';

  @override
  String get sharedMembersStatsSortHint => 'Highest amount first';

  @override
  String get sharedMembersStatsScopeHint =>
      'Grouped by payer in the ledger currency. Records without a payer are excluded. These are actual expenses, not AA shares.';

  @override
  String get ledgerBasicSettings => 'Basic settings';

  @override
  String get ledgerAaLabel => 'AA splitting';

  @override
  String get ledgerMembersTitle => 'Ledger members';

  @override
  String get ledgerVirtualMembersTitle => 'Virtual members';

  @override
  String get sharedMembersExpenseTotal => 'Member expense total';

  @override
  String get sharedMembersPageTitle => 'Members';

  @override
  String get ledgersLeaveAndDelete => 'Leave and Delete';

  @override
  String get ledgersLeaveAndDeleteConfirm => 'Leave and Delete Ledger';

  @override
  String ledgersLeaveAndDeleteMessage(String name) {
    return 'Leave and delete the shared ledger \"$name\"?\\nAfter leaving, the cloud removes your membership and all local data is cleared. You won\'t be able to access its transactions anymore.';
  }

  @override
  String get ledgersLeaveAndDeleteSuccess => 'Left and deleted the ledger';

  @override
  String get ledgersDeleteShared => 'Delete Shared Ledger';

  @override
  String get ledgersDeleteSharedConfirm => 'Delete Shared Ledger';

  @override
  String ledgersDeleteSharedMessage(String name) {
    return 'Delete the shared ledger \"$name\"?\\nThis also removes all collaborators and clears their local data. This cannot be undone.';
  }

  @override
  String get ledgersDeleteSharedSuccess => 'Shared ledger deleted';

  @override
  String get sharedMembersRemoveTitle => 'Remove member';

  @override
  String get sharedMembersRemoveCta => 'Remove this member';

  @override
  String sharedMembersRemoveConfirm(String name) {
    return 'Remove $name? They will immediately lose access to this ledger.';
  }

  @override
  String get sharedMembersRemoved => 'Member removed';

  @override
  String get sharedMembersRemoveFailed =>
      'Failed to remove member. Please try again later.';

  @override
  String get sharedMembersSaveFirst => 'Please save the ledger first';

  @override
  String get sharedMembersLoadFailed => 'Failed to load members';

  @override
  String get sharedMembersRetry => 'Retry';

  @override
  String sharedTxCreatedBy(String name) {
    return 'Created by $name';
  }

  @override
  String sharedTxEditedBy(String name) {
    return 'Last edited by $name';
  }

  @override
  String sharedTxCreatedAndEditedBy(String name) {
    return 'Created and edited by $name';
  }

  @override
  String get sharedMembersStatsTitle => 'Member expenses';

  @override
  String get sharedMembersStatsEmpty => 'No transactions yet';

  @override
  String sharedMembersStatsTxCount(int count) {
    return '$count tx';
  }

  @override
  String get exchangeRatePageTitle => 'Exchange Rates';

  @override
  String get rateSourceAuto => 'Auto';

  @override
  String get rateSourceManual => 'Manual';

  @override
  String rateUpdatedAt(String date) {
    return 'Updated $date';
  }

  @override
  String get rateNotFetched => 'Not fetched';

  @override
  String get rateEditTitle => 'Edit Rate';

  @override
  String rateInverseHint(String base, String rate, String quote) {
    return 'Inverse: 1 $base ≈ $rate $quote';
  }

  @override
  String get rateResetToAuto => 'Reset to auto';

  @override
  String get rateRefreshSuccess => 'Rates updated';

  @override
  String get rateRefreshFailed => 'Fetch failed, you can set rates manually';

  @override
  String get rateDisclaimer =>
      'Source: open exchange-rate data, updated daily. Conversion is for reference only and may differ from bank rates.';

  @override
  String get txRateLabel => 'Rate';

  @override
  String get txRateMissingHint =>
      'Please enter the rate for this entry before saving';

  @override
  String get ledgerBaseCurrencyLabel => 'Ledger currency';

  @override
  String statsConvertedFootnote(Object currency) {
    return 'Includes foreign currency, converted to $currency at entry-time rates';
  }

  @override
  String get ledgerCurrencyChangeRecalcHint =>
      'Changing the base currency will reconvert all history at current rates';

  @override
  String get ledgerCurrencyChangeRecalcWarning =>
      'Converted amounts of all transactions in this ledger will be recalculated at the latest rates and overwritten; switching away and back cannot restore the original values';

  @override
  String get recalcForeignTxBanner =>
      'Unconverted foreign-currency transactions detected in this ledger';

  @override
  String get recalcForeignTxAction => 'Reconvert at current rates';

  @override
  String recalcForeignTxDone(Object count) {
    return 'Reconverted $count foreign-currency transactions';
  }

  @override
  String get txCurrencyPickerTitle => 'Select currency';

  @override
  String get txAddEntryTitle => 'Add transaction';

  @override
  String get txDeleteLongPress => 'Hold to clear';

  @override
  String get txSelectDateTimeTitle => 'Select date & time';

  @override
  String get txSelectDateTimeHint => 'Swipe up or down to pick a value';

  @override
  String get txEditCategory => 'Edit categories';

  @override
  String get txEditCategoryReadOnly =>
      'Edit categories (read-only in shared ledger)';

  @override
  String get txLedgerBaseCurrency => 'Ledger currency';

  @override
  String recalcSyncCountHint(Object count) {
    return '$count transactions will be reconverted and synced';
  }

  @override
  String get analyticsLoadFailed => 'Could not load data. Please try again.';

  @override
  String get analyticsRetry => 'Retry';

  @override
  String get exportCsvHeaderCurrency => 'Currency';

  @override
  String get importFieldCurrency => 'Currency';

  @override
  String get currencyMOP => 'Macau Pataca';

  @override
  String get currencyMNT => 'Mongolian Tughrik';

  @override
  String get currencyKPW => 'North Korean Won';

  @override
  String get currencyKHR => 'Cambodian Riel';

  @override
  String get currencyLAK => 'Lao Kip';

  @override
  String get currencyBND => 'Bruneian Dollar';

  @override
  String get currencyNPR => 'Nepalese Rupee';

  @override
  String get currencyBTN => 'Bhutanese Ngultrum';

  @override
  String get currencyMVR => 'Maldivian Rufiyaa';

  @override
  String get currencyAFN => 'Afghan Afghani';

  @override
  String get currencyUZS => 'Uzbekistani Som';

  @override
  String get currencyTJS => 'Tajikistani Somoni';

  @override
  String get currencyTMT => 'Turkmenistani Manat';

  @override
  String get currencyKGS => 'Kyrgyzstani Som';

  @override
  String get currencyQAR => 'Qatari Riyal';

  @override
  String get currencyKWD => 'Kuwaiti Dinar';

  @override
  String get currencyBHD => 'Bahraini Dinar';

  @override
  String get currencyOMR => 'Omani Rial';

  @override
  String get currencyJOD => 'Jordanian Dinar';

  @override
  String get currencyLBP => 'Lebanese Pound';

  @override
  String get currencyIQD => 'Iraqi Dinar';

  @override
  String get currencyIRR => 'Iranian Rial';

  @override
  String get currencyYER => 'Yemeni Rial';

  @override
  String get currencySYP => 'Syrian Pound';

  @override
  String get currencyGEL => 'Georgian Lari';

  @override
  String get currencyAMD => 'Armenian Dram';

  @override
  String get currencyAZN => 'Azerbaijan Manat';

  @override
  String get currencyRON => 'Romanian Leu';

  @override
  String get currencyBGN => 'Bulgarian Lev';

  @override
  String get currencyRSD => 'Serbian Dinar';

  @override
  String get currencyISK => 'Icelandic Krona';

  @override
  String get currencyMDL => 'Moldovan Leu';

  @override
  String get currencyALL => 'Albanian Lek';

  @override
  String get currencyMKD => 'Macedonian Denar';

  @override
  String get currencyBAM => 'Bosnian Convertible Mark';

  @override
  String get currencyGIP => 'Gibraltar Pound';

  @override
  String get currencyGTQ => 'Guatemalan Quetzal';

  @override
  String get currencyHNL => 'Honduran Lempira';

  @override
  String get currencyNIO => 'Nicaraguan Cordoba';

  @override
  String get currencyCRC => 'Costa Rican Colon';

  @override
  String get currencyPAB => 'Panamanian Balboa';

  @override
  String get currencyDOP => 'Dominican Peso';

  @override
  String get currencyCUP => 'Cuban Peso';

  @override
  String get currencyJMD => 'Jamaican Dollar';

  @override
  String get currencyTTD => 'Trinidadian Dollar';

  @override
  String get currencyBSD => 'Bahamian Dollar';

  @override
  String get currencyBBD => 'Barbadian or Bajan Dollar';

  @override
  String get currencyBZD => 'Belizean Dollar';

  @override
  String get currencyHTG => 'Haitian Gourde';

  @override
  String get currencyKYD => 'Caymanian Dollar';

  @override
  String get currencyAWG => 'Aruban or Dutch Guilder';

  @override
  String get currencyBMD => 'Bermudian Dollar';

  @override
  String get currencyUYU => 'Uruguayan Peso';

  @override
  String get currencyPYG => 'Paraguayan Guarani';

  @override
  String get currencyBOB => 'Bolivian Bolíviano';

  @override
  String get currencyVES => 'Venezuelan Bolívar';

  @override
  String get currencyGYD => 'Guyanese Dollar';

  @override
  String get currencySRD => 'Surinamese Dollar';

  @override
  String get currencyFJD => 'Fijian Dollar';

  @override
  String get currencyPGK => 'Papua New Guinean Kina';

  @override
  String get currencySBD => 'Solomon Islander Dollar';

  @override
  String get currencyTOP => 'Tongan Pa\'anga';

  @override
  String get currencyVUV => 'Ni-Vanuatu Vatu';

  @override
  String get currencyWST => 'Samoan Tala';

  @override
  String get currencyKES => 'Kenyan Shilling';

  @override
  String get currencyGHS => 'Ghanaian Cedi';

  @override
  String get currencyMAD => 'Moroccan Dirham';

  @override
  String get currencyDZD => 'Algerian Dinar';

  @override
  String get currencyTND => 'Tunisian Dinar';

  @override
  String get currencyLYD => 'Libyan Dinar';

  @override
  String get currencyETB => 'Ethiopian Birr';

  @override
  String get currencyUGX => 'Ugandan Shilling';

  @override
  String get currencyTZS => 'Tanzanian Shilling';

  @override
  String get currencyRWF => 'Rwandan Franc';

  @override
  String get currencyMUR => 'Mauritian Rupee';

  @override
  String get currencyBWP => 'Botswana Pula';

  @override
  String get currencyNAD => 'Namibian Dollar';

  @override
  String get currencyZMW => 'Zambian Kwacha';

  @override
  String get currencyMWK => 'Malawian Kwacha';

  @override
  String get currencyMZN => 'Mozambican Metical';

  @override
  String get currencyAOA => 'Angolan Kwanza';

  @override
  String get currencyCDF => 'Congolese Franc';

  @override
  String get currencyGMD => 'Gambian Dalasi';

  @override
  String get currencyGNF => 'Guinean Franc';

  @override
  String get currencyLRD => 'Liberian Dollar';

  @override
  String get currencySLE => 'Sierra Leonean Leone';

  @override
  String get currencySDG => 'Sudanese Pound';

  @override
  String get currencySSP => 'South Sudanese Pound';

  @override
  String get currencySOS => 'Somali Shilling';

  @override
  String get currencyDJF => 'Djiboutian Franc';

  @override
  String get currencyERN => 'Eritrean Nakfa';

  @override
  String get currencyBIF => 'Burundian Franc';

  @override
  String get currencyCVE => 'Cape Verdean Escudo';

  @override
  String get currencySTN => 'Sao Tomean Dobra';

  @override
  String get currencySCR => 'Seychellois Rupee';

  @override
  String get currencyKMF => 'Comorian Franc';

  @override
  String get currencyLSL => 'Basotho Loti';

  @override
  String get currencySZL => 'Swazi Lilangeni';

  @override
  String get currencyMGA => 'Malagasy Ariary';

  @override
  String get currencyMRU => 'Mauritanian Ouguiya';

  @override
  String get detailImportExportTitle => 'Data Import/Export';

  @override
  String get detailImportExportImportTitle => 'Import data';

  @override
  String get detailImportExportImportSubtitle =>
      'Select a domain and destination, then review the file';

  @override
  String get detailImportExportExportTitle => 'Export data';

  @override
  String get detailImportExportExportSubtitle =>
      'Select domains and sources to export all content';

  @override
  String get detailImportExportImportPoint1 =>
      'Select a domain and destination book or fitness space, then choose and review a file.';

  @override
  String get detailImportExportImportPoint2 =>
      'Import CSV, TSV, TXT, XLSX or JSON. All data types support editable field mapping, record selection and import progress; no file version or application identifier is required.';

  @override
  String get detailImportExportImportPoint3 =>
      'Reimporting the same file skips imported records. Review and select records before importing. Fitness plans can be imported from tables; importing preferences replaces the destination preferences.';

  @override
  String get detailImportExportExportPoint1 =>
      'All four domains are selected by default. Choose one book or fitness space per domain to export its complete content.';

  @override
  String get detailImportExportExportPoint2 =>
      'Bookkeeping exports all transactions, anniversaries all events, and memos all entries. Fitness exports all workouts, plans, templates and fitness preferences in the space, including timer state.';

  @override
  String get detailImportExportExportPoint3 =>
      'Accounting and days export as CSV; memos and complete fitness data export as JSON. Save or share separate files through the system panel.';

  @override
  String get detailExportAction => 'Export';

  @override
  String exchangeRateCurrentLedger(Object name) {
    return 'Current ledger: $name';
  }

  @override
  String get exchangeRateInfoTitle => 'About Ledger Currency';

  @override
  String get exchangeRateInfoMessage =>
      'The ledger currency is the base currency of the current ledger: foreign-currency transactions in this ledger are converted into it at exchange rates, so totals can be compared directly in statistics and asset overviews. Each ledger has its own ledger currency and you can switch it at any time; switching recalculates converted amounts for all transactions in this ledger at the latest rates.\n\nRates are fetched automatically from public data sources on a daily basis. You can also tap \"Edit\" for any currency in the list below to set a manual rate — it overrides the automatic data and takes effect immediately.';

  @override
  String get rateEditLabel => 'Edit';

  @override
  String get rateInvalidInput =>
      'Please enter a valid rate (a number greater than 0)';

  @override
  String get currencyManageTitle => 'Manage Displayed Currencies';

  @override
  String get currencyManageEntry => 'Currency Management';

  @override
  String currencyManageCount(Object count) {
    return '$count currencies selected';
  }

  @override
  String get currencyManageBaseLocked =>
      'Ledger base currency (cannot be hidden)';

  @override
  String get currencyManageHint =>
      'Hiding a currency does not affect existing transactions; you can re-enable it here at any time.';

  @override
  String get detailImportExportMigrateTitle => 'Migration';

  @override
  String get detailImportExportMigrateTip =>
      'Export and import into another book or fitness space. Use the management page to copy or move between local and cloud storage.';

  @override
  String get ledgerMetaReadOnlyToast =>
      'Collaborators cannot modify ledger settings.';

  @override
  String get aaStatisticsTitle => 'AA Statistics';

  @override
  String get aaStatisticsTotalAmount => 'Total shared';

  @override
  String get aaStatisticsPerPerson => 'Split details';

  @override
  String get aaStatisticsPaid => 'Split paid';

  @override
  String get aaStatisticsPaidAll => 'Total paid';

  @override
  String get aaStatisticsShare => 'Share';

  @override
  String get aaStatisticsNet => 'Balance';

  @override
  String get aaStatisticsNetReceive => 'to receive';

  @override
  String get aaStatisticsNetPay => 'to pay';

  @override
  String get aaStatisticsTransferPlan => 'Settlement plan';

  @override
  String get aaStatisticsTransferSeparator => 'pays';

  @override
  String get aaStatisticsNoTransfers => 'All settled up';

  @override
  String get aaStatisticsExcluded => 'No split';

  @override
  String aaStatisticsParticipantCount(int count) {
    return '$count participants';
  }

  @override
  String get aaStatisticsExcludedEmpty => 'No no-split transactions';

  @override
  String get aaStatisticsViewDetails => 'View details';

  @override
  String get aaStatisticsBillSummary => 'Bill summary';

  @override
  String get aaStatisticsNetReceiveAmount => 'To receive';

  @override
  String get aaStatisticsNetPayAmount => 'To pay';

  @override
  String get aaStatisticsSettled => 'Settled';

  @override
  String get aaStatisticsModePerPerson => 'Split equally';

  @override
  String get aaStatisticsModeCustom => 'Custom amount';

  @override
  String get aaStatisticsSplitDetail => 'Split details';

  @override
  String get aaStatisticsPayerPrefix => 'Paid by';

  @override
  String get aaStatisticsMemberTxEmpty => 'No bills for this member';

  @override
  String get aaEditTitle => 'Edit split';

  @override
  String get aaEditSplitButton => 'Edit split';

  @override
  String get aaPayer => 'Paid by';

  @override
  String get aaSplitMode => 'Split method';

  @override
  String get aaParticipants => 'Participants';

  @override
  String get aaModePerPerson => 'Split equally';

  @override
  String get aaModeCustom => 'Custom split';

  @override
  String get aaModeNoSplit => 'No split';

  @override
  String get aaParticipantsAll => 'All members';

  @override
  String get aaParticipantsUnit => '';

  @override
  String get aaVirtualUserNameHint => 'Enter a nickname';

  @override
  String aaVirtualUserDeleteConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get aaVirtualUserInUse =>
      'Has related transactions and cannot be deleted';

  @override
  String aaVirtualUserDefaultName(int index) {
    return 'Virtual User $index';
  }

  @override
  String get aaUnknownUser => 'Unknown';

  @override
  String get ledgerAaStatisticsEntry => 'AA Statistics';

  @override
  String get aaNoParticipants => 'Add participants first';

  @override
  String get aaSplitAmountIncomplete => 'Enter an amount for every participant';

  @override
  String get restoreStep2Title => 'Backup Contents';

  @override
  String get restoreApply => 'Restore Now';

  @override
  String get restoreApplying => 'Applying...';

  @override
  String get restoreDone => 'Restore Complete';

  @override
  String get restoreOpenFailed =>
      'Cannot open backup: file is corrupted or not a backup';

  @override
  String get restoreApplyFailed =>
      'Restore failed; nothing was changed (rolled back)';

  @override
  String get restoreCloudForkHint =>
      'This is a cloud ledger from a different account; it will be restored as a local copy';

  @override
  String get restoreFileNotFound => 'Backup file not found';

  @override
  String get restoreSectionLocal => 'Local Ledgers';

  @override
  String get restoreSectionCloud => 'Cloud Ledgers';

  @override
  String restoreMemberCount(int count) {
    return '$count members';
  }

  @override
  String restoreConflictWarning(int count) {
    return '$count open conflicts (restore uses backup-time state)';
  }

  @override
  String get restoreSchemaUnsupported =>
      'Unsupported backup schema. Choose a backup created by the current version';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authWelcomeSubtitle => 'Sign in to your Sesame Notes account';

  @override
  String get authPhone => 'Phone number';

  @override
  String get authPhoneHint => 'Enter phone number';

  @override
  String get authPasswordHint => 'Enter password';

  @override
  String get authRegisterPasswordHint => 'Set a login password';

  @override
  String get authConfirmPasswordHint => 'Enter password again';

  @override
  String get authPasswordShow => 'Show';

  @override
  String get authPasswordHide => 'Hide';

  @override
  String get authRegionSheetTitle => 'Select country code';

  @override
  String get authRegionCancel => 'Cancel';

  @override
  String get authNoAccount => 'No account? Register now';

  @override
  String get authInvalidPhone => 'Please enter a valid phone number';

  @override
  String get authInvalidPassword => 'Please enter your password';

  @override
  String get authPasswordMismatch => 'Passwords do not match';

  @override
  String get authErrorPhoneAlreadyRegistered =>
      'Phone number already registered';

  @override
  String get authErrorServer => 'Service unavailable, please try again later';

  @override
  String get authErrorOther => 'Operation failed, please try again later';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authAlreadyHaveAccount => 'Have an account? Sign in';

  @override
  String get authRegister => 'Register';

  @override
  String get mineLocalName => 'Local Sesame';

  @override
  String get mineLocalSubtitle => 'Local only · Not signed in';

  @override
  String get mineLoginRegister => 'Sign in / Register';

  @override
  String get mineLoginValue => 'Sign in to use cloud ledgers and sharing';

  @override
  String mineSesameNumber(String number) {
    return 'Sesame number $number';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileNickname => 'Nickname';

  @override
  String get profileSesameNumber => 'Sesame number';

  @override
  String get profileGender => 'Gender';

  @override
  String get profilePhone => 'Phone';

  @override
  String get profileGenderUnset => 'Not set';

  @override
  String get profileGenderMale => 'Male';

  @override
  String get profileGenderFemale => 'Female';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profileLogout => 'Sign out';

  @override
  String get profileLogoutHint =>
      'Signing out keeps all local books on this device. Cloud books remain in your account and can be synced after you sign in again.';

  @override
  String get profileLogoutConfirmTitle => 'Sign out';

  @override
  String get profileLogoutConfirmMessage =>
      'Are you sure you want to sign out?';

  @override
  String get profileLogoutPendingTitle => 'Unsynced changes';

  @override
  String get profileLogoutPendingMessage =>
      'These cloud books contain unsynced changes. “Keep local copies” copies the affected books to this device first. Unconfirmed category changes stay with this account so you can continue after signing in again.';

  @override
  String get profileLogoutSyncFirst => 'Sync first';

  @override
  String get profileLogoutKeepLocalCopy => 'Keep local copy and sign out';

  @override
  String get profileBasicInfo => 'Basic info';

  @override
  String get profileAccountInfo => 'Account info';

  @override
  String get editNameTitle => 'Edit nickname';

  @override
  String get editNameSave => 'Save';

  @override
  String get editNameEmpty => 'Nickname cannot be empty';

  @override
  String get editNameHint =>
      'Nicknames do not need to be unique. Chinese, English, numbers, and Emoji are supported.';

  @override
  String get editNameClear => 'Clear nickname';

  @override
  String get editNameSaved => 'Nickname saved';

  @override
  String get editNameSaveFailed => 'Save failed, try again later';

  @override
  String get editGenderTitle => 'Gender';

  @override
  String get editGenderSaved => 'Gender saved';

  @override
  String get editGenderPrivacyHint =>
      'Your gender is visible only to you and is not shown to other shared ledger members.';

  @override
  String get avatarPreviewTitle => 'Avatar';

  @override
  String get avatarClose => 'Close';

  @override
  String get avatarFromGallery => 'Choose from gallery';

  @override
  String get avatarRestoreDefault => 'Restore default avatar';

  @override
  String get avatarUploadFailed => 'Avatar upload failed, try again later';

  @override
  String get avatarRestored => 'Default avatar restored';

  @override
  String get avatarTooLarge => 'Image too large, choose a smaller one';

  @override
  String get avatarInvalid => 'Cannot recognize the image, choose another one';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get changePasswordCurrent => 'Current password';

  @override
  String get changePasswordCurrentHint => 'Enter current password';

  @override
  String get changePasswordNew => 'Add password';

  @override
  String get changePasswordNewHint => 'Set a new password';

  @override
  String get changePasswordConfirm => 'Confirm new password';

  @override
  String get changePasswordConfirmHint => 'Enter the new password again';

  @override
  String get changePasswordHint =>
      'Use up to 128 characters. Other devices will be signed out after the change; this device stays signed in.';

  @override
  String get changePasswordNewRequired => 'Enter a new password';

  @override
  String get changePasswordTooLong => 'Use no more than 128 characters';

  @override
  String get changePasswordMismatch => 'Add passwords do not match';

  @override
  String get changePasswordCurrentInvalid => 'Current password is incorrect';

  @override
  String get changePasswordSuccess => 'Password changed';

  @override
  String get changePasswordSubmit => 'Save';

  @override
  String get changePasswordFailed => 'Change failed, try again later';

  @override
  String get daysTools => 'Tools';

  @override
  String get dayBooksTitle => 'Anniversary books';

  @override
  String get dayBookNew => 'Add anniversary book';

  @override
  String get dayBookEdit => 'Edit anniversary book';

  @override
  String get dayBookEmpty => 'No anniversary books yet';

  @override
  String get dayEventsEmpty => 'No anniversaries yet';

  @override
  String get dayNoNext => 'No next date within the supported range';

  @override
  String get dayBirthday => 'Birthday';

  @override
  String get dayAnniversary => 'Anniversary';

  @override
  String get dayCountdown => 'Countdown';

  @override
  String get dayStage => 'Stage';

  @override
  String get dayAdd => 'Add anniversary';

  @override
  String get dayEdit => 'Edit anniversary';

  @override
  String get dayName => 'Name';

  @override
  String get dayDate => 'Date';

  @override
  String get dayBirthDate => 'Date of birth';

  @override
  String get dayStart => 'Start time';

  @override
  String get dayEnd => 'End time';

  @override
  String get dayNextDate => 'Next time';

  @override
  String get daySolar => 'Solar';

  @override
  String get dayLunar => 'Lunar';

  @override
  String get dayLeapMonth => 'Leap month';

  @override
  String get dayRepeat => 'Repeat';

  @override
  String get dayNoRepeat => 'Never';

  @override
  String get dayYearly => 'Yearly';

  @override
  String get dayFixedDate => 'Fixed date';

  @override
  String get dayIntervalDays => 'Count X days';

  @override
  String get dayStatistic => 'Display as';

  @override
  String get dayAge => 'Age';

  @override
  String get dayYears => 'Years / months / days';

  @override
  String get dayDays => 'Days';

  @override
  String get dayToday => 'Today';

  @override
  String get daySaveFailed => 'Could not save. Try again.';

  @override
  String get dayInvalid => 'Check the name, dates and repeat settings.';

  @override
  String get dayRecordInvalid =>
      'This record has invalid date data. Select and confirm the dates again.';

  @override
  String dayDateOutOfRange(String first, String last) {
    return 'The result is outside the supported range: $first to $last';
  }

  @override
  String get dayTargetUnavailable =>
      'This anniversary book is unavailable. Keep your input and try again.';

  @override
  String get dayDifference => 'Date interval';

  @override
  String get dayOffset => 'Date offset';

  @override
  String get dayHolidays => 'Holidays';

  @override
  String get dayLocal => 'Local anniversary book';

  @override
  String get dayCloud => 'Cloud anniversary book';

  @override
  String get dayBookPending => 'Pending sync';

  @override
  String get dayBookStale => 'Sync binding expired';

  @override
  String get dayDay => 'Day';

  @override
  String get dayCalculate => 'Calculate';

  @override
  String dayRemaining(int count) {
    return 'In $count days';
  }

  @override
  String dayElapsed(int count) {
    return '$count days ago';
  }

  @override
  String dayAgeValue(int count) {
    return 'Age $count';
  }

  @override
  String dayDeleteEvent(String name) {
    return 'Delete “$name”?';
  }

  @override
  String dayDeleteBook(String name, int count) {
    return 'Delete anniversary book “$name” and its $count anniversaries?';
  }

  @override
  String get dayCloudDeleteHint => 'Deletion syncs to your other devices';

  @override
  String get dayNewYear => 'Add Year\'s Day';

  @override
  String get dayLabour => 'Labour Day';

  @override
  String get dayNational => 'National Day';

  @override
  String get daySpring => 'Spring Festival';

  @override
  String get dayLantern => 'Lantern Festival';

  @override
  String get dayDragonBoat => 'Dragon Boat Festival';

  @override
  String get dayQixi => 'Qixi';

  @override
  String get dayMidAutumn => 'Mid-Autumn Festival';

  @override
  String get dayDoubleNinth => 'Double Ninth Festival';

  @override
  String get dayNewYearsEve => 'Lunar New Year\'s Eve';

  @override
  String get dayQingming => 'Qingming';

  @override
  String get commonPrevious => 'Previous';

  @override
  String get dayBackupSection => 'Anniversaries';

  @override
  String get dayCsvImportSummary => 'Import preview';

  @override
  String get dayDefaultBookName => 'Default anniversaries';

  @override
  String get dayExportSection => 'Export anniversaries';

  @override
  String get exportSelectAtLeastOne => 'Select at least one section';

  @override
  String get importContentDays => 'Anniversaries';

  @override
  String get importContentLedger => 'Bookkeeping';

  @override
  String get importContentTitle => 'Choose import content';

  @override
  String get ledgerExportSection => 'Export bookkeeping';

  @override
  String daySyncPending(int count) {
    return '$count pending changes';
  }

  @override
  String daySyncRejected(int count) {
    return '$count changes need correction';
  }

  @override
  String daySyncConflicts(int count) {
    return '$count sync conflicts';
  }

  @override
  String get dayRestorePending =>
      'Local restore is complete. Selected cloud books are being restored';

  @override
  String get shareHandedToSystem =>
      'Files were handed to system sharing. Confirm they were saved in the destination app';

  @override
  String get startupDatabaseTitle => 'Unable to open current data';

  @override
  String get startupDatabaseMessage =>
      'The data structure does not match this version, or the database cannot currently be read. Keep the original database file, restore from a compatible backup, and restart. The app will not automatically erase or change the original file.';

  @override
  String get dayCachedExportWarning =>
      'This cloud book has unfinished sync or a sync error, so its content may not be current. Export the content already on this device?';

  @override
  String get dayType => 'Type';

  @override
  String get dayUpcomingTitle => 'Upcoming anniversaries';

  @override
  String dayAnniversaryValue(int count) {
    return '$count years';
  }

  @override
  String dayDaysValue(int count) {
    return '$count days';
  }

  @override
  String dayRemainingDuration(String duration) {
    return 'In $duration';
  }

  @override
  String dayElapsedDuration(String duration) {
    return '$duration ago';
  }

  @override
  String dayTotalDuration(String duration) {
    return '$duration in total';
  }

  @override
  String dayYearsValue(int count) {
    return '$count years';
  }

  @override
  String dayMonthsValue(int count) {
    return '$count months';
  }

  @override
  String get dayRepeatQuestion => 'Repeats';

  @override
  String get dayCalculationResult => 'Result:';

  @override
  String dayOffsetBefore(int count) {
    return '$count days before';
  }

  @override
  String dayOffsetAfter(int count) {
    return '$count days after';
  }

  @override
  String get dayNameHint => 'Enter an event name';

  @override
  String get dayDaysHint => 'Enter a number of days';

  @override
  String dayDifferenceFullSpan(int years, int months, int days) {
    return 'Difference: $years years $months months $days days';
  }

  @override
  String dayDifferenceTotalDays(int days) {
    return 'Difference: $days days';
  }

  @override
  String get memosTab => 'Memos';

  @override
  String get memoNormal => 'Notes';

  @override
  String get memoCredentials => 'Accounts and passwords';

  @override
  String get memoEditCard => 'Edit account and password';

  @override
  String get memoName => 'Name';

  @override
  String get memoEnterName => 'Enter a name';

  @override
  String get memoDefaultBookName => 'Default memos';

  @override
  String get memoBooks => 'Memo books';

  @override
  String get memoBooksManagement => 'Manage memo books';

  @override
  String get memoBookType => 'Memo book type';

  @override
  String get memoCreateBookTitle => 'Add book';

  @override
  String get memoStorageLocal => 'On this device';

  @override
  String get memoStorageCloud => 'Cloud';

  @override
  String get memoBookName => 'Memo book name';

  @override
  String get memoRename => 'Rename';

  @override
  String get memoNoBooks => 'Add a book to get started';

  @override
  String get memoNoEntries => 'No entries yet';

  @override
  String get memoNoSearchResult => 'No matching accounts';

  @override
  String get memoUntitled => 'Untitled note';

  @override
  String get memoNewNote => 'Add note';

  @override
  String get memoNewCard => 'Add account and password';

  @override
  String get memoCredentialsTitle => 'Accounts and passwords';

  @override
  String get memoAccount => 'Account';

  @override
  String get memoPassword => 'Password';

  @override
  String memoFieldIndex(int index) {
    return 'Field $index';
  }

  @override
  String get memoFieldName => 'Field name';

  @override
  String get memoFieldValue => 'Value';

  @override
  String get memoAddField => 'Add field';

  @override
  String get memoRemoveField => 'Remove field';

  @override
  String get memoNewField => 'Add field';

  @override
  String get memoFieldNameRequired =>
      'Name the field before filling in a value';

  @override
  String get memoCardEmpty => 'Fill in a name or at least one field';

  @override
  String get memoPhone => 'Phone';

  @override
  String get memoEmail => 'Email';

  @override
  String get memoLoadFailed => 'Could not load data. Please try again.';

  @override
  String get memoUnavailable =>
      'The book or account changed. Reopen it to continue; unsaved input is kept for the original account.';

  @override
  String get memoDownloadRequired => 'Connect to finish downloading this book';

  @override
  String get memoEditing => 'Editing';

  @override
  String get memoSaving => 'Saving';

  @override
  String get memoSaveFailed => 'Save failed. Your input is kept; please retry.';

  @override
  String get memoDeleteEntry => 'Delete this record?';

  @override
  String get memoDeleteEntryMessage => 'This cannot be undone.';

  @override
  String get memoCopy => 'Copy';

  @override
  String get memoCopied => 'Copied';

  @override
  String get memoExport => 'Export';

  @override
  String get memoSelectEntry => 'Select note';

  @override
  String get memoSelectFormat => 'Choose an export format';

  @override
  String get memoExportFailed =>
      'Document generation failed. Retry this note and format.';

  @override
  String get memoExportCancelled => 'Export cancelled';

  @override
  String get memoExportReady => 'File generated';

  @override
  String get memoLocal => 'Local memo books';

  @override
  String get memoCloud => 'Cloud memo books';

  @override
  String get memoSearchHint => 'Search field name or value';

  @override
  String get memoSortManual => 'Manual order';

  @override
  String get memoSortUpdated => 'Recently edited';

  @override
  String get memoReorder => 'Drag to reorder';

  @override
  String get memoReorderFailed => 'Could not save the order. Please try again.';

  @override
  String get memoOrderChanged =>
      'Cards have changed. Refresh before reordering.';

  @override
  String get memoOrderCapacity =>
      'Card order numbers have reached their limit. A new card cannot be added. Your draft has been kept.';

  @override
  String get memoMore => 'Load more';

  @override
  String get memoConflictCopy => 'Conflict copy';

  @override
  String memoDeleteBookMessage(int count) {
    return 'Delete this book and its $count entries?';
  }

  @override
  String memoEntryCount(int count) {
    return '$count entries';
  }

  @override
  String get dayExpired => 'Expired';

  @override
  String get dayPresent => 'Present';

  @override
  String get dayMilestone => 'Anniversary';

  @override
  String dayStatisticExample(String value) {
    return 'Example: $value';
  }

  @override
  String get memoHomeSyncing => 'Refreshing memo data';

  @override
  String get memoHomeEmpty => 'No memos yet';

  @override
  String get memoSelectBook => 'Select memo book';

  @override
  String get memoPullLocalSuccess => 'Local memo data refreshed';

  @override
  String get memoPullCloudSuccess => 'Cloud memo data synced';

  @override
  String get memoPullCloudFailedButLocalOk =>
      'Cloud sync failed; local memo data refreshed';

  @override
  String get memoPullLocalFailed =>
      'Local memo refresh failed. Try again later.';

  @override
  String get memoPullCloudFailed =>
      'Cloud memo refresh failed. Try again later.';

  @override
  String get memoExportSection => 'Export memos';

  @override
  String get fitnessTitle => 'Fitness';

  @override
  String get fitnessContinue => 'Continue workout';

  @override
  String get fitnessStart => 'Start workout';

  @override
  String get fitnessFinish => 'Finish workout';

  @override
  String get fitnessRestart => 'Restart workout';

  @override
  String get fitnessNoData => 'Nothing here yet';

  @override
  String get fitnessPlans => 'Training plans';

  @override
  String get fitnessNewPlan => 'Add training plan';

  @override
  String get fitnessTemplates => 'Workout templates';

  @override
  String get fitnessNewTemplate => 'Add workout template';

  @override
  String get fitnessPlanLibrary => 'Plan library';

  @override
  String get fitnessTemplateLibrary => 'Template library';

  @override
  String get fitnessAddToMyPlan => 'Add to my plans';

  @override
  String get fitnessAddToMyTemplate => 'Add to my templates';

  @override
  String get fitnessAddAgain => 'Add again';

  @override
  String fitnessReuseForTemplate(String name) {
    return 'Reuse \"$name\"';
  }

  @override
  String get fitnessCreateCopies => 'Add copies';

  @override
  String get fitnessOfficialSource => 'Source: official training library';

  @override
  String get fitnessLibraryAdded => 'Added to the current training space';

  @override
  String get fitnessExercises => 'Exercise library';

  @override
  String get fitnessAddExercises => 'Add exercises';

  @override
  String get fitnessReplace => 'Replace exercise';

  @override
  String get fitnessNoExercises => 'Search or change filters to find exercises';

  @override
  String get fitnessName => 'Name';

  @override
  String get fitnessSearch => 'Search names and aliases';

  @override
  String get fitnessPlanned => 'Not started';

  @override
  String get fitnessActive => 'In progress';

  @override
  String get fitnessFinished => 'Finished';

  @override
  String get fitnessDate => 'Scheduled date';

  @override
  String get fitnessTime => 'Time';

  @override
  String get fitnessVolume => 'Volume';

  @override
  String get fitnessSets => 'Sets';

  @override
  String get fitnessDuration => 'Duration (seconds)';

  @override
  String get fitnessAddSet => 'Add set';

  @override
  String get fitnessKeypadAddSet => 'Add set';

  @override
  String get fitnessFillSets => 'Apply';

  @override
  String get fitnessFillAbove => 'Above';

  @override
  String get fitnessFillBelow => 'Below';

  @override
  String get fitnessNextInput => 'Next field';

  @override
  String get fitnessCopySet => 'Copy this set';

  @override
  String get fitnessDeleteSet => 'Delete this set';

  @override
  String get fitnessRest => 'Rest timer';

  @override
  String get fitnessRestSeconds => 'Rest (seconds)';

  @override
  String get fitnessWarmupRest => 'Warm-up rest (seconds)';

  @override
  String get fitnessPause => 'Pause';

  @override
  String get fitnessResume => 'Resume';

  @override
  String get fitnessSkip => 'Skip';

  @override
  String get fitnessRestRestart => 'Restart';

  @override
  String get fitnessRestEnd => 'End';

  @override
  String get fitnessRepeatRest => 'Repeat rest';

  @override
  String get fitnessStartTimer => 'Start timer';

  @override
  String get fitnessCopy => 'Duplicate';

  @override
  String get fitnessMoveUp => 'Move up';

  @override
  String get fitnessMoveDown => 'Move down';

  @override
  String get fitnessUpdateTemplate => 'Update template';

  @override
  String get fitnessUpdateTemplateConfirm =>
      'Update the source template with this workout’s exercises and set configuration? The template name and existing workouts will stay unchanged.';

  @override
  String get fitnessSaveTemplate => 'Save as template';

  @override
  String get fitnessDeleteMessage =>
      'Delete this item? Previously generated workouts and history are kept.';

  @override
  String get fitnessCompletedChange =>
      'This exercise contains completed sets. Replace or remove it?';

  @override
  String get fitnessInvalidSet =>
      'Enter valid fields before confirming this set.';

  @override
  String get fitnessIncompleteSet =>
      'This set is incomplete. Confirm it again after editing.';

  @override
  String get fitnessInvalidForm =>
      'Check the name, numbers and required exercises.';

  @override
  String get fitnessActiveExists =>
      'A workout is already running. Continue it or finish it first.';

  @override
  String get fitnessPaused => 'Paused';

  @override
  String get fitnessStartDate => 'Start date';

  @override
  String get fitnessCycleDays => 'Plan cycle (including rest)';

  @override
  String get fitnessRestDay => 'Rest day';

  @override
  String get fitnessPin => 'Pin exercise';

  @override
  String get fitnessUnpin => 'Unpin exercise';

  @override
  String get fitnessPinned => 'Pinned';

  @override
  String get fitnessRecent => 'Recently used';

  @override
  String get fitnessAll => 'All';

  @override
  String get fitnessBodyPart => 'Body part';

  @override
  String get fitnessEquipment => 'Equipment';

  @override
  String get fitnessInstructions => 'Instructions';

  @override
  String get fitnessPlay => 'Play demonstration';

  @override
  String get fitnessPauseMedia => 'Pause demonstration';

  @override
  String get fitnessDefaultRest => 'Default rest duration';

  @override
  String get fitnessTrainingDays => 'Training days';

  @override
  String get fitnessShowMore => 'Load more';

  @override
  String get fitnessLoadFailed => 'Could not load data. Please try again.';

  @override
  String get fitnessSaveFailed => 'Save failed. Your input is kept; try again.';

  @override
  String get fitnessDetails => 'Details';

  @override
  String get fitnessIncomplete =>
      'Fitness data has not fully downloaded. Sync and try again.';

  @override
  String get fitnessReminderPermissionDenied =>
      'System reminders are not permitted. Workout recording still works.';

  @override
  String get fitnessChest => 'Chest';

  @override
  String get fitnessBack => 'Back';

  @override
  String get fitnessShoulders => 'Shoulders';

  @override
  String get fitnessBiceps => 'Biceps';

  @override
  String get fitnessTriceps => 'Triceps';

  @override
  String get fitnessAbs => 'Abs';

  @override
  String get fitnessGlutes => 'Glutes';

  @override
  String get fitnessHamstrings => 'Hamstrings';

  @override
  String get fitnessQuadriceps => 'Quadriceps';

  @override
  String get fitnessCalves => 'Calves';

  @override
  String get fitnessUpperArms => 'Upper arms';

  @override
  String get fitnessLowerArms => 'Forearms';

  @override
  String get fitnessUpperLegs => 'Thighs';

  @override
  String get fitnessLowerLegs => 'Lower legs';

  @override
  String get fitnessWaist => 'Waist';

  @override
  String get fitnessCardio => 'Cardio';

  @override
  String get fitnessBarbell => 'Barbell';

  @override
  String get fitnessDumbbell => 'Dumbbell';

  @override
  String get fitnessKettlebell => 'Kettlebell';

  @override
  String get fitnessCable => 'Cable';

  @override
  String get fitnessMachine => 'Machine';

  @override
  String get fitnessSledMachine => 'Sled machine';

  @override
  String get fitnessBodyWeightEquipment => 'Body weight';

  @override
  String get fitnessWeightedEquipment => 'Weighted';

  @override
  String get fitnessLats => 'Lats';

  @override
  String get fitnessSpine => 'Spinal erectors';

  @override
  String get fitnessUpperBack => 'Upper back';

  @override
  String get fitnessLowerBack => 'Lower back';

  @override
  String get fitnessRearDeltoids => 'Rear deltoids';

  @override
  String get fitnessRhomboids => 'Rhomboids';

  @override
  String get fitnessTraps => 'Trapezius';

  @override
  String get fitnessHipFlexors => 'Hip flexors';

  @override
  String get fitnessCore => 'Core';

  @override
  String get fitnessFeet => 'Feet';

  @override
  String get fitnessAnkles => 'Ankles';

  @override
  String get fitnessConflicts => 'Sync conflicts';

  @override
  String get fitnessRestCompletedTitle => 'Rest complete';

  @override
  String get fitnessRestCompletedBody =>
      'Rest is over. Continue training or finish your workout.';

  @override
  String get fitnessUnknownPart => 'Unknown body part';

  @override
  String get fitnessBodyFront => 'Front';

  @override
  String get fitnessBodyBack => 'Back';

  @override
  String get fitnessNeck => 'Neck';

  @override
  String get fitnessAdductors => 'Adductors';

  @override
  String get fitnessAbductors => 'Abductors';

  @override
  String get fitnessSerratus => 'Serratus anterior';

  @override
  String get fitnessLevatorScapulae => 'Levator scapulae';

  @override
  String get fitnessBand => 'Band';

  @override
  String get fitnessResistanceBand => 'Resistance band';

  @override
  String get fitnessAssistedEquipment => 'Assisted equipment';

  @override
  String get fitnessBosu => 'Bosu ball';

  @override
  String get fitnessElliptical => 'Elliptical machine';

  @override
  String get fitnessEzBar => 'EZ barbell';

  @override
  String get fitnessHammer => 'Hammer';

  @override
  String get fitnessMedicineBall => 'Medicine ball';

  @override
  String get fitnessOlympicBarbell => 'Olympic barbell';

  @override
  String get fitnessRoller => 'Roller';

  @override
  String get fitnessRope => 'Rope';

  @override
  String get fitnessSkiErg => 'SkiErg machine';

  @override
  String get fitnessSmithMachine => 'Smith machine';

  @override
  String get fitnessStabilityBall => 'Stability ball';

  @override
  String get fitnessStationaryBike => 'Stationary bike';

  @override
  String get fitnessStepmill => 'Stepmill machine';

  @override
  String get fitnessTire => 'Tire';

  @override
  String get fitnessTrapBar => 'Trap bar';

  @override
  String get fitnessUpperBodyErgometer => 'Upper body ergometer';

  @override
  String get fitnessAbWheel => 'Ab wheel';

  @override
  String get fitnessAnkleStabilizers => 'Ankle stabilizers';

  @override
  String get fitnessBrachialis => 'Brachialis';

  @override
  String get fitnessGripMuscles => 'Grip muscles';

  @override
  String get fitnessGroin => 'Groin';

  @override
  String get fitnessHands => 'Hands';

  @override
  String get fitnessLowerAbs => 'Lower abs';

  @override
  String get fitnessObliques => 'Obliques';

  @override
  String get fitnessRotatorCuff => 'Rotator cuff';

  @override
  String get fitnessShins => 'Shins';

  @override
  String get fitnessSoleus => 'Soleus';

  @override
  String get fitnessSternocleidomastoid => 'Sternocleidomastoid';

  @override
  String get fitnessUpperChest => 'Upper chest';

  @override
  String get fitnessWristExtensors => 'Wrist extensors';

  @override
  String get fitnessWristFlexors => 'Wrist flexors';

  @override
  String get fitnessWrists => 'Wrists';

  @override
  String fitnessExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
    );
    return '$_temp0';
  }

  @override
  String get fitnessBodyChestRegions => 'Upper\nMid–low';

  @override
  String get fitnessBodyFrontShoulderRegions => 'Front\nSide';

  @override
  String get fitnessBodyBackShoulderRegions => 'Side\nRear';

  @override
  String get fitnessTrainingTime => 'Training time';

  @override
  String get fitnessTrainingDuration => 'Training duration';

  @override
  String get fitnessTrainingBodyParts => 'Training body parts';

  @override
  String fitnessDurationHours(String hours) {
    return '$hours h';
  }

  @override
  String get fitnessClosed => 'Closed';

  @override
  String get fitnessPlanNoStartDate => 'Not selected';

  @override
  String get fitnessExerciseDetail => 'Exercise details';

  @override
  String get fitnessExerciseHistory => 'Training history';

  @override
  String get fitnessNoExerciseHistory =>
      'No checked sets for this exercise yet';

  @override
  String get fitnessRestNotRecorded => '-';

  @override
  String get fitnessRestInProgress => 'Timer not finished';

  @override
  String get fitnessPlanSchedule => 'Cycle schedule';

  @override
  String get fitnessDeletePlan => 'Delete plan';

  @override
  String get fitnessDeletePlanMessage =>
      'Delete only this plan? All generated workouts and rest days, including completed workouts, will be kept.';

  @override
  String get fitnessPlanEnabled => 'Enable plan';

  @override
  String get fitnessPlanStartDateRequired =>
      'Choose a start date to enable the plan';

  @override
  String get syncCenterTitle => 'Sync Management';

  @override
  String get syncCenterLoadFailed => 'Could not load sync status. Try again.';

  @override
  String get syncCenterActionFailed =>
      'Operation incomplete. Your data is preserved. Try again.';

  @override
  String get syncCenterUseRemote => 'Use cloud version';

  @override
  String get syncCenterKeepLocal => 'Keep local version';

  @override
  String get syncCenterDecisionConfirm =>
      'Use the selected version? Deleted cloud records will not be recreated under the same identity. Local content can be preserved as a copy.';

  @override
  String get syncCenterConflict => 'Conflicting versions need your decision';

  @override
  String get syncCenterRejected => 'Upload rejected';

  @override
  String get syncCenterStale => 'Sync connection is outdated';

  @override
  String get syncCenterDeleting => 'Waiting for cloud deletion confirmation';

  @override
  String get syncCenterMoving => 'Move to device is incomplete';

  @override
  String get syncCenterIncomplete => 'Download incomplete';

  @override
  String get syncCenterDeleted => 'Deleted';

  @override
  String get syncCenterCompare => 'Compare versions';

  @override
  String get syncCenterLocal => 'Local version';

  @override
  String get syncCenterRemote => 'Cloud version';

  @override
  String get syncCenterEmpty => 'No sync issues to resolve';

  @override
  String get syncCenterEdit => 'Edit record';

  @override
  String get syncCenterProtect => 'Keep a copy on this device';

  @override
  String get syncCenterDownload => 'Protect content and download again';

  @override
  String syncCenterPending(int count) {
    return '$count sync operations need attention';
  }

  @override
  String get syncCenterUploading => 'Waiting to upload';

  @override
  String get fitnessPlanUnfilled => 'Empty';

  @override
  String get fitnessPlanFillHint => 'Tap a template to fill a date';

  @override
  String get fitnessPlanFillDays => 'Choose a template or rest for every day';

  @override
  String get fitnessPlanSetRest => 'Set rest day';

  @override
  String get fitnessPlanReplaceHint =>
      'Tap a template to replace this assignment';

  @override
  String syncCenterDeleteReview(String name, int count) {
    return 'Delete “$name”? It currently contains $count cloud records. Unsynced local changes to this book will also be deleted.';
  }

  @override
  String syncCenterMoveReview(String name, int count) {
    return 'Continue moving “$name” to this device? It has $count cloud records. The move finishes after a complete copy is saved and cloud deletion is confirmed.';
  }

  @override
  String syncCenterDeleteGone(String name) {
    return '“$name” is no longer available in the cloud. Finish this deletion? Existing recovery copies will be kept.';
  }

  @override
  String get syncCenterBudget =>
      'This content exceeds the sync size limit. Reduce its size and try again.';

  @override
  String get dataTransferInfoTitle => 'How it works';

  @override
  String get daySelectBook => 'Select anniversary book';

  @override
  String get fitnessExportSection => 'Export fitness';

  @override
  String fitnessRecordCount(Object count) {
    return '$count data items';
  }

  @override
  String get fitnessDefaultSpaceName => 'Default fitness space';

  @override
  String get fitnessSelectSpace => 'Select fitness space';

  @override
  String get fitnessNoSpaces => 'No fitness spaces';

  @override
  String get fitnessSpacesManagement => 'Fitness spaces';

  @override
  String get fitnessCreateSpace => 'Add fitness space';

  @override
  String get fitnessSpaceName => 'Space name';

  @override
  String get fitnessLocalSpaces => 'Local fitness spaces';

  @override
  String get fitnessCloudSpaces => 'Cloud fitness spaces';

  @override
  String fitnessDeleteSpaceMessage(Object count) {
    return 'Delete this fitness space and its $count data items?';
  }

  @override
  String get privateBookDownloadRequired =>
      'Complete data synchronization first';

  @override
  String privateBookMoveToCloudMessage(String name) {
    return '\"$name\" will be uploaded to the cloud and synced across your devices.';
  }

  @override
  String privateBookMoveToLocalMessage(String name) {
    return '\"$name\" will be deleted from the cloud and kept on this device only. Other devices will no longer see it.';
  }

  @override
  String privateBookCopyToLocalMessage(String name) {
    return 'A local copy of \"$name\" will be created. The cloud original stays unchanged.';
  }

  @override
  String get reminderGlobalTitle => 'Enable notifications';

  @override
  String get reminderPlatformUnsupported =>
      'Reminder notifications are not supported on this platform yet.';

  @override
  String get reminderDaysTitle => 'Anniversary reminders';

  @override
  String get reminderDaySame => 'On the day';

  @override
  String get reminderDayBefore => '1 day before';

  @override
  String get reminderThreeDaysBefore => '3 days before';

  @override
  String get reminderWeekBefore => '1 week before';

  @override
  String get reminderChooseOneDay => 'Keep at least one reminder day';

  @override
  String get reminderDaysTimeTitle => 'Reminder time';

  @override
  String get reminderRestTitle => 'Rest timer reminders';

  @override
  String get reminderSystemSettings => 'Reminder help';

  @override
  String get transferCommitting => 'Committing, please wait';

  @override
  String transferBookTypeMismatch(Object fileType, Object targetType) {
    return 'This file is a \"$fileType\" export while the target is \"$targetType\". Go back and pick a matching memo book.';
  }

  @override
  String get transferDefaultValue => 'Default value';

  @override
  String get transferDefaultValueHelp =>
      'Used when this field is not read from the file; leave empty for no value.';

  @override
  String get transferIgnoreField => 'Don\'t read this field';

  @override
  String get transferDuplicate => 'Already imported; will skip';

  @override
  String transferExportProgress(Object count) {
    return 'Generating export files · $count generated';
  }

  @override
  String get transferFailed =>
      'Import did not finish. Check the data or retry. Successfully imported records will not be duplicated.';

  @override
  String get transferFitnessHint =>
      'Each item includes its complete plan/workout, exercises and sets. Importing preferences replaces current fitness preferences.';

  @override
  String get transferMappingHelp =>
      'Auto-detected fields can be changed. Choosing \"Don\'t read this field\" skips the file and uses the default below. * indicates required fields.';

  @override
  String get transferMatchingTitle => 'Match exercises';

  @override
  String get transferPendingSync =>
      'Local import complete. Cloud synchronization will continue in the sync queue.';

  @override
  String transferRecord(Object lines, Object title) {
    return 'Record $lines · $title';
  }

  @override
  String get transferRequired => 'Choose a field';

  @override
  String transferResult(Object failed, Object imported, Object skipped) {
    return 'Imported $imported · Skipped $skipped · Failed $failed';
  }

  @override
  String get transferSelectAll => 'Select all valid records';

  @override
  String get transferSelectCategory => 'Choose an existing category';

  @override
  String get transferSelectExercise => 'Choose an exercise';

  @override
  String transferSummary(
    Object duplicates,
    Object errors,
    Object selected,
    Object total,
    Object valid,
  ) {
    return 'Total $total · Valid $valid · Duplicates $duplicates · Errors $errors · Selected $selected';
  }

  @override
  String transferTarget(Object name) {
    return 'Target: $name';
  }

  @override
  String get transferUnnamed => 'Untitled';

  @override
  String get transferValid => 'Ready to import';

  @override
  String transferFieldLabel(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'faccount': 'Account',
      'famount': 'Amount',
      'fbody': 'Body',
      'fcalendar': 'Calendar',
      'fcategory': 'Category',
      'fcategory_icon': 'Category icon',
      'fcompleted': 'Completed',
      'fcountdown_mode': 'Countdown mode',
      'fcreated_at': 'Created at',
      'fcurrency': 'Currency',
      'fcycle_days': 'Cycle days',
      'fdate': 'Date',
      'fday': 'Training day (1-based)',
      'fdays': 'Training schedule',
      'femail': 'Email',
      'fend_calendar': 'End calendar',
      'fend_date': 'End date',
      'fend_is_leap_month': 'End leap month',
      'fentity_type': 'Record type',
      'fexercise': 'Exercise',
      'fexercises': 'Exercises and sets',
      'fgeneration_state': 'Plan execution state',
      'fid': 'Relationship reference',
      'finterval_days': 'Interval days',
      'fis_leap_month': 'Leap month',
      'fkind': 'Set kind',
      'fname': 'Name',
      'fnote': 'Note',
      'foccurrence_key': 'Plan occurrence',
      'fpassword': 'Password',
      'fpending_schedule': 'Pending schedule',
      'fphone': 'Phone',
      'fpreferences': 'Fitness preferences',
      'fremark': 'Note',
      'frepeat_type': 'Repeat',
      'freps': 'Repetitions',
      'frest_seconds': 'Rest seconds',
      'frest_timer': 'Rest timer',
      'frun_segments': 'Execution segments',
      'fscheduled_date': 'Workout date',
      'fset_count': 'Number of sets',
      'fsource_kind': 'Workout source',
      'fsource_plan_id': 'Related plan',
      'fsource_plan_name': 'Related plan name',
      'fsource_template_id': 'Related template',
      'fstart_calendar': 'Start calendar',
      'fstart_date': 'Start date',
      'fstart_is_leap_month': 'Start leap month',
      'fstatistic_type': 'Count by',
      'fstatus': 'Status',
      'fsub_category': 'Subcategory',
      'fsub_category_icon': 'Subcategory icon',
      'ftitle': 'Title',
      'ftype': 'Type',
      'fupdated_at': 'Updated at',
      'fweight': 'Weight',
      'fsets': 'Sets',
      'fslot': 'Training slot',
      'fday_index': 'Day index (0-based)',
      'other': 'Field',
    });
    return '$_temp0';
  }

  @override
  String get transferCardFields => 'Card fields';

  @override
  String get transferCardFieldsHelp =>
      'Every column can become a card field. Turn a column off, or clear its name, to skip it; rename the field to whatever you prefer.';

  @override
  String get transferCardFieldName => 'Field name';

  @override
  String get transferJsonRoot => 'Entire JSON object';

  @override
  String get fitnessCustom => 'Custom';

  @override
  String get fitnessCustomCreate => 'Add custom exercise';

  @override
  String get fitnessCustomEdit => 'Edit custom exercise';

  @override
  String get fitnessCustomName => 'Exercise name';

  @override
  String get fitnessCustomRequired => 'Please complete this required field';

  @override
  String get fitnessCustomUpload => 'Upload image';

  @override
  String get fitnessCustomImageTooLarge =>
      'Please choose an image smaller than 48 KB';

  @override
  String get fitnessCustomDeleteConfirm =>
      'Delete this custom exercise? Existing workout records will be kept.';

  @override
  String get fitnessCustomLimit =>
      'Custom exercise storage is full. Delete unused exercises or choose icons instead of images.';

  @override
  String commonNameInvalid(int max) {
    return 'Enter a visible name of at most $max characters';
  }

  @override
  String get appUpdateTitle => 'Check for updates';

  @override
  String get appUpdateNotConfigured =>
      'Updates are not configured for this build yet.';

  @override
  String get appUpdateUnsupported =>
      'In-app updates are available for the official Android arm64 app only.';

  @override
  String get appUpdatePermission =>
      'Allow this app to install updates in system settings, then return here to continue.';

  @override
  String get appUpdateFailed =>
      'Update failed. Check your network and free storage, then retry.';

  @override
  String get appUpdateCurrentVersion => 'Current version';

  @override
  String get appUpdateWorking => 'Working…';

  @override
  String get appUpdateDownloading => 'Downloading';

  @override
  String get appUpdateLatest => 'You are up to date.';

  @override
  String get appUpdateClose => 'Close';

  @override
  String get appUpdateDownload => 'Update';

  @override
  String get appUpdateInstall => 'Install';

  @override
  String get syncCenterPullFailed =>
      'Downloaded records could not be applied. Retry sync.';

  @override
  String get localBookMigrationTitle => 'Move local books to the cloud?';

  @override
  String localBookMigrationMessage(int count) {
    return 'You have $count local books across Accounting, Days, Memos, and Fitness. Move them to this account’s cloud and sync across devices? Choose Keep local to leave them on this device.';
  }

  @override
  String get localBookMigrationConfirm => 'Move to cloud';

  @override
  String get localBookMigrationKeepLocal => 'Keep local';

  @override
  String get localBookMigrationFailed =>
      'Migration could not be completed. Your local content is preserved. Please try again.';

  @override
  String get localBookMigrationSuccess => 'Migration successful';

  @override
  String get reminderExactPermissionTitle => 'Allow on-time reminders';

  @override
  String get memoSelectCredentials => 'Select accounts';

  @override
  String memoSelectedEntries(int count) {
    return 'Selected $count records';
  }

  @override
  String get memoPng => 'Image (PNG)';

  @override
  String get memoPngTooLarge =>
      'The content is too long for a single image. Choose PDF, Word or Markdown.';

  @override
  String get shellMemos => 'Notes';

  @override
  String get shellAddMoney => 'Add expense';

  @override
  String get shellAddDay => 'Add a day';

  @override
  String get shellMoneyDetails => 'Transactions';

  @override
  String get shellAddMemo => 'Write a note';

  @override
  String get shellFitnessTraining => 'Training';

  @override
  String get shellMemoNotes => 'Notes';

  @override
  String get homeViewAnalytics => 'View analytics';

  @override
  String get shellFitnessPlans => 'Plans';

  @override
  String homeMonthlyBills(String month) {
    return '$month transactions';
  }

  @override
  String get shellMoney => 'Money';

  @override
  String get shellDays => 'Days';

  @override
  String get shellFitness => 'Fitness';

  @override
  String get shellChooseBook => 'Switch book';

  @override
  String get homeDailyExpenseTrend => 'Daily expenses';

  @override
  String get shellChooseSpace => 'Switch space';

  @override
  String get welcomeDomainsTitle => 'Make room for everyday life';

  @override
  String get appearanceThemeJournal => 'Warm journal';

  @override
  String get appearanceThemeClassicDescription => 'Brand blue and soft corners';

  @override
  String get appearanceThemeMinimal => 'Minimal list';

  @override
  String get appearanceThemeClassic => 'Classic blue';

  @override
  String get appearanceThemeTitle => 'Appearance & themes';

  @override
  String get appearanceThemeMinimalDescription =>
      'Cool whites and defined edges';

  @override
  String get appearanceThemeJournalDescription => 'Warm paper and forest green';

  @override
  String get appearanceThemeSaveFailed =>
      'Appearance applied, but preferences could not be saved. Try again.';

  @override
  String get shellAddFitness => 'New';

  @override
  String get shellAddCalendar => 'Record this day';

  @override
  String get fitnessCalendarPlanned => 'Planned';

  @override
  String get fitnessCalendarRest => 'Rest';

  @override
  String get txEditorContextUnavailable =>
      'This ledger or account has changed. Go back and reopen the entry; your input is still here.';

  @override
  String get appearanceThemeIntro => 'Choose your visual style';

  @override
  String get appearanceThemeNote =>
      'Style and display mode are independent. Changes apply immediately.';

  @override
  String get dayHeroDaysBefore => 'days ago';

  @override
  String get dayHeroDaysAfter => 'days away';

  @override
  String get homeSummaryLoadFailed => 'Could not load expense summary';

  @override
  String get homeSummaryCachedFailure =>
      'Could not refresh; showing the last result';

  @override
  String get txAmountInvalid =>
      'Enter an amount greater than 0 with up to 2 decimal places.';

  @override
  String get txDivisionByZero => 'Cannot divide by zero. Change the amount.';

  @override
  String get txExpressionInvalid => 'Enter a complete, valid expression.';

  @override
  String get categoryConflictCloud => 'Cloud version';

  @override
  String get categoryConflictChooseLocal =>
      'Use the submitted local version? Later edits on this device will be preserved separately for further sync.';

  @override
  String get categoryTemplateRestoreTitle => 'Restore original categories';

  @override
  String get recurringTransactionTimeZone => 'Time zone';

  @override
  String get categoryConflictSubmitted => 'Submitted local version';

  @override
  String categoryTemplateRestoreMessage(String names) {
    return 'The original categories for these templates were deleted:\n$names\nRestore the original categories and their settings? This creates no duplicate categories and restores no deleted transactions.';
  }

  @override
  String get recurringTransactionTimeZoneInvalid =>
      'Select a valid IANA time zone';

  @override
  String get categoryTemplateRestoreConfirm => 'Restore originals';

  @override
  String get categoryConflictRefreshRequired =>
      'Version information is not ready. Reload it before making a decision.';

  @override
  String get recurringTransactionAmountPrecision =>
      'Enter an amount greater than zero, with up to 28 integer digits and 10 decimal places.';

  @override
  String get categoryConflictExplanation =>
      'The local version is from this upload and excludes later edits. Choose which version to use for this category.';

  @override
  String get categoryConflictRestoreTitle => 'Restore deleted cloud category';

  @override
  String get recurringTransactionTimeZoneLocked =>
      'Transactions already exist. Create a new recurring rule to use another time zone.';

  @override
  String get categoryTemplatePendingLabel => 'Awaiting review';

  @override
  String get categoryConflictRetry => 'Retry confirmation';

  @override
  String get recurringTransactionDayOfWeek => 'Day of the week';

  @override
  String get categoryConflictChooseCloud =>
      'Use the displayed cloud version? The local submission in this conflict will not be applied. Later device edits will be preserved separately.';

  @override
  String get categoryTemplateNoChanges =>
      'No categories were added or restored';

  @override
  String get categoryConflictDeleteTitle => 'Confirm category deletion';

  @override
  String get categoryConflictType => 'Category type';

  @override
  String get categoryConflictUnavailable =>
      'This version is unavailable. Reload it to continue.';

  @override
  String get categoryTemplateBlockedParentHierarchy =>
      'The original parent has changed level; this child cannot be added';

  @override
  String get categoryTemplateBlockedDuplicate =>
      'A category with this name exists; this template was not added';

  @override
  String get categoryConflictChanged =>
      'The category changed. Compare the refreshed versions before confirming again.';

  @override
  String get categoryConflictUseLocal => 'Use local version';

  @override
  String get categoryTemplateBlockedParentDuplicate =>
      'A parent with this name exists; this template was not added';

  @override
  String categoryConflictPosition(String value) {
    return 'Sort value: $value';
  }

  @override
  String get categoryConflictRestoreMessage =>
      'This category was deleted in the cloud. Restore that same category using the submitted local version? A second category will not be created.';

  @override
  String get categoryTemplateBlockedLabel => 'Not added';

  @override
  String get categoryConflictRestore => 'Confirm restore';

  @override
  String get categoryConflictParentMissing =>
      'Parent category has not been downloaded';

  @override
  String get categoryConflictRefresh => 'Reload versions';

  @override
  String categoryTemplatePending(int count) {
    return '$count categories await cloud confirmation. Open Sync issues to review them.';
  }

  @override
  String get recurringTransactionIntervalInvalid =>
      'Enter an integer from 1 to 10000.';

  @override
  String get categoryConflictDeleteMessage =>
      'The local submission deletes this category. Applying it will delete the cloud category. Review both versions first.';

  @override
  String get recurringTransactionMonthOfYear => 'Month of the year';

  @override
  String categoryTemplateRestored(int count) {
    return 'Restored $count original categories';
  }

  @override
  String get recurringTransactionTimeZoneHint =>
      'Generate by this time zone’s calendar dates, consistently across devices.';

  @override
  String get categoryConflictPending =>
      'The confirmation result has not arrived. Retry the original decision before choosing another version.';

  @override
  String get categoryConflictUseCloud => 'Use cloud version';

  @override
  String get reminderDaysDailyTitle => 'Daily reminders';

  @override
  String get reminderDaysDailyHint =>
      'Uses the shared reminder time. Scheduled milestones take priority, with no duplicate reminders.';

  @override
  String get reminderDaysDailySelect => 'Select anniversaries (multiple)';

  @override
  String get reminderDaysDailyChooseOne =>
      'Select at least one birthday, anniversary or countdown.';

  @override
  String get reminderDaysDailyEmpty =>
      'No anniversaries available for daily reminders.';

  @override
  String get reminderDaysDailyLoadFailed =>
      'Could not load anniversaries. Please try again.';

  @override
  String get reminderDaysDailyAccountChanged =>
      'Your account changed. Close this dialog and select again.';

  @override
  String syncCenterTransactionTitle(String category) {
    return 'Transaction · $category';
  }

  @override
  String syncCenterCategoryTitle(String name) {
    return 'Category · $name';
  }

  @override
  String syncCenterBookContext(String name) {
    return 'Ledger: $name';
  }

  @override
  String get syncCenterUnknownCategory => 'Category name unavailable';

  @override
  String syncCenterEntityTitle(String type, String name) {
    return '$type · $name';
  }

  @override
  String get syncCenterTypeLedger => 'Ledger';

  @override
  String get syncCenterTypeDayBook => 'Anniversary book';

  @override
  String get syncCenterTypeDayEvent => 'Anniversary';

  @override
  String get syncCenterTypeMemoBook => 'Memo book';

  @override
  String get syncCenterTypeMemoEntry => 'Memo';

  @override
  String get syncCenterTypeFitnessSpace => 'Fitness space';

  @override
  String get syncCenterTypeFitnessWorkout => 'Workout';

  @override
  String get syncCenterTypeFitnessPlan => 'Training plan';

  @override
  String get syncCenterTypeFitnessTemplate => 'Training template';

  @override
  String get syncCenterTypeMember => 'Ledger member';

  @override
  String get syncCenterTypeRecurring => 'Recurring transaction';

  @override
  String get syncCenterTypeExchangeRate => 'Exchange rate';

  @override
  String get syncCenterTypeRecord => 'Record';

  @override
  String get syncCenterPendingRecordHint =>
      'Saved on this device and waiting to upload.';

  @override
  String get syncCenterAwaitingReceiptHint =>
      'The upload result is not confirmed. Retrying uses the original request to continue syncing. Your local content is preserved.';

  @override
  String get syncCenterRecordUnavailable =>
      'The original content was deleted or cannot be read. Sync again and check.';

  @override
  String syncCenterLastFailure(String reason) {
    return 'Last sync did not finish: $reason';
  }
}
