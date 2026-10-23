/// 由 flutter gen-l10n 自动生成，请勿手改。同一语言代码的区域变体（zh 与 zh_TW）合并于同一文件。
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @startupPreparationTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to finish starting the app'**
  String get startupPreparationTitle;

  /// No description provided for @startupPreparationMessage.
  ///
  /// In en, this message translates to:
  /// **'Local settings could not be read. Please retry to continue.'**
  String get startupPreparationMessage;

  /// No description provided for @startupPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your data'**
  String get startupPreparing;

  /// No description provided for @appUpdateCancelDownload.
  ///
  /// In en, this message translates to:
  /// **'Cancel download'**
  String get appUpdateCancelDownload;

  /// No description provided for @appUpdateReady.
  ///
  /// In en, this message translates to:
  /// **'Update downloaded. Ready to install.'**
  String get appUpdateReady;

  /// No description provided for @appUpdatePaused.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the network or a system retry.'**
  String get appUpdatePaused;

  /// No description provided for @appUpdateBackground.
  ///
  /// In en, this message translates to:
  /// **'Downloading in the background. You can close this window.'**
  String get appUpdateBackground;

  /// No description provided for @calendarAnniversary.
  ///
  /// In en, this message translates to:
  /// **'Anniversary'**
  String get calendarAnniversary;

  /// No description provided for @calendarNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get calendarNote;

  /// No description provided for @calendarCredential.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get calendarCredential;

  /// No description provided for @calendarTraining.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get calendarTraining;

  /// No description provided for @calendarTemplate.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get calendarTemplate;

  /// No description provided for @calendarPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get calendarPlan;

  /// No description provided for @syncCenterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View sync status and resolve conflicts, failures, and pending actions'**
  String get syncCenterSubtitle;

  /// No description provided for @calendarEmptyDay.
  ///
  /// In en, this message translates to:
  /// **'No records for this day'**
  String get calendarEmptyDay;

  /// No description provided for @fitnessHomeSyncing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing fitness data'**
  String get fitnessHomeSyncing;

  /// No description provided for @fitnessPullLocalSuccess.
  ///
  /// In en, this message translates to:
  /// **'Local fitness data refreshed'**
  String get fitnessPullLocalSuccess;

  /// No description provided for @fitnessPullCloudSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cloud fitness data synced'**
  String get fitnessPullCloudSuccess;

  /// No description provided for @fitnessPullCloudFailedButLocalOk.
  ///
  /// In en, this message translates to:
  /// **'Local fitness data refreshed; cloud sync failed'**
  String get fitnessPullCloudFailedButLocalOk;

  /// No description provided for @fitnessDetailEmptyExercises.
  ///
  /// In en, this message translates to:
  /// **'No exercises yet'**
  String get fitnessDetailEmptyExercises;

  /// No description provided for @fitnessWorkoutMissing.
  ///
  /// In en, this message translates to:
  /// **'This workout is unavailable'**
  String get fitnessWorkoutMissing;

  /// No description provided for @fitnessTemplateMissing.
  ///
  /// In en, this message translates to:
  /// **'This template is unavailable'**
  String get fitnessTemplateMissing;

  /// No description provided for @fitnessMissingDetailHint.
  ///
  /// In en, this message translates to:
  /// **'Go back and select another item.'**
  String get fitnessMissingDetailHint;

  /// No description provided for @fitnessReorderHint.
  ///
  /// In en, this message translates to:
  /// **'Long press the title to reorder'**
  String get fitnessReorderHint;

  /// No description provided for @fitnessHomeExerciseLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get fitnessHomeExerciseLabel;

  /// No description provided for @fitnessSetRestTime.
  ///
  /// In en, this message translates to:
  /// **'Set rest time'**
  String get fitnessSetRestTime;

  /// No description provided for @fitnessWarmupLabel.
  ///
  /// In en, this message translates to:
  /// **'Warmup'**
  String get fitnessWarmupLabel;

  /// No description provided for @fitnessRepUnit.
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get fitnessRepUnit;

  /// No description provided for @fitnessSideWeight.
  ///
  /// In en, this message translates to:
  /// **'Per side'**
  String get fitnessSideWeight;

  /// No description provided for @fitnessTotalWeight.
  ///
  /// In en, this message translates to:
  /// **'Total weight'**
  String get fitnessTotalWeight;

  /// No description provided for @fitnessLeftKg.
  ///
  /// In en, this message translates to:
  /// **'L kg'**
  String get fitnessLeftKg;

  /// No description provided for @fitnessRightKg.
  ///
  /// In en, this message translates to:
  /// **'R kg'**
  String get fitnessRightKg;

  /// No description provided for @fitnessSideWeightValue.
  ///
  /// In en, this message translates to:
  /// **'L {left} / R {right} kg'**
  String fitnessSideWeightValue(String left, String right);

  /// No description provided for @fitnessPlanTrainingDays.
  ///
  /// In en, this message translates to:
  /// **'Train {count} days'**
  String fitnessPlanTrainingDays(int count);

  /// No description provided for @fitnessPlanRestDays.
  ///
  /// In en, this message translates to:
  /// **'Rest {count} days'**
  String fitnessPlanRestDays(int count);

  /// No description provided for @fitnessExerciseTotal.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get fitnessExerciseTotal;

  /// No description provided for @fitnessSetCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String fitnessSetCount(int count);

  /// No description provided for @fitnessFinishConfirm.
  ///
  /// In en, this message translates to:
  /// **'End this workout and save the current time and completed sets? You can restart it later.'**
  String get fitnessFinishConfirm;

  /// No description provided for @fitnessStartUsingTemplate.
  ///
  /// In en, this message translates to:
  /// **'Start workout with this template'**
  String get fitnessStartUsingTemplate;

  /// No description provided for @fitnessEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get fitnessEdit;

  /// No description provided for @fitnessMyPlans.
  ///
  /// In en, this message translates to:
  /// **'My plans'**
  String get fitnessMyPlans;

  /// No description provided for @fitnessMyTemplates.
  ///
  /// In en, this message translates to:
  /// **'My templates'**
  String get fitnessMyTemplates;

  /// No description provided for @fitnessViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get fitnessViewAll;

  /// No description provided for @fitnessCreateBlank.
  ///
  /// In en, this message translates to:
  /// **'Add workout'**
  String get fitnessCreateBlank;

  /// No description provided for @fitnessSelectedTraining.
  ///
  /// In en, this message translates to:
  /// **'My workouts'**
  String get fitnessSelectedTraining;

  /// No description provided for @fitnessNoSelectedTraining.
  ///
  /// In en, this message translates to:
  /// **'No workouts on this date'**
  String get fitnessNoSelectedTraining;

  /// No description provided for @fitnessNoPlans.
  ///
  /// In en, this message translates to:
  /// **'No plans yet'**
  String get fitnessNoPlans;

  /// No description provided for @fitnessNoTemplates.
  ///
  /// In en, this message translates to:
  /// **'No templates yet'**
  String get fitnessNoTemplates;

  /// No description provided for @memoBackupLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Local backup saved. Cloud upload failed; please try again later.'**
  String get memoBackupLocalOnly;

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Sesame Notes'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get tabAnalytics;

  /// No description provided for @tabCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get tabCalendar;

  /// No description provided for @tabMine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get tabMine;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @homeSelectBillMonth.
  ///
  /// In en, this message translates to:
  /// **'Select month'**
  String get homeSelectBillMonth;

  /// No description provided for @homePickerHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe up or down to pick'**
  String get homePickerHint;

  /// No description provided for @homeBackToCurrentMonth.
  ///
  /// In en, this message translates to:
  /// **'Back to current month'**
  String get homeBackToCurrentMonth;

  /// No description provided for @homeTodayExpense.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeTodayExpense;

  /// No description provided for @homeWeekExpense.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get homeWeekExpense;

  /// No description provided for @homeMonthExpense.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get homeMonthExpense;

  /// No description provided for @homeDetailCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get homeDetailCategory;

  /// No description provided for @homeDetailDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get homeDetailDate;

  /// No description provided for @homeDetailAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get homeDetailAmount;

  /// No description provided for @homeDetailCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get homeDetailCurrency;

  /// No description provided for @homeDetailNativeAmount.
  ///
  /// In en, this message translates to:
  /// **'In base currency'**
  String get homeDetailNativeAmount;

  /// No description provided for @homeDetailMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get homeDetailMembers;

  /// No description provided for @homeDetailCreator.
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get homeDetailCreator;

  /// No description provided for @homeDetailLastEditor.
  ///
  /// In en, this message translates to:
  /// **'Last edited by'**
  String get homeDetailLastEditor;

  /// No description provided for @homeDetailEditHistory.
  ///
  /// In en, this message translates to:
  /// **'Edit history'**
  String get homeDetailEditHistory;

  /// No description provided for @homeDetailEditHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'View only'**
  String get homeDetailEditHistoryHint;

  /// No description provided for @homeDetailEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get homeDetailEditButton;

  /// No description provided for @homeDetailNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No edit history'**
  String get homeDetailNoHistory;

  /// No description provided for @homeDeleteDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get homeDeleteDetailTitle;

  /// No description provided for @homeDeleteDetailMessage.
  ///
  /// In en, this message translates to:
  /// **'This will delete the \"{name}\" record. This action cannot be undone.'**
  String homeDeleteDetailMessage(Object name);

  /// No description provided for @commonEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get commonEmpty;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get commonFailed;

  /// No description provided for @commonOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed, please try again later'**
  String get commonOperationFailed;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get commonFinish;

  /// No description provided for @commonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get commonOther;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Note...'**
  String get commonNoteHint;

  /// No description provided for @commonSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get commonSettings;

  /// No description provided for @commonCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get commonCurrent;

  /// No description provided for @commonConfigure.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get commonConfigure;

  /// No description provided for @commonPressAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press again to exit'**
  String get commonPressAgainToExit;

  /// No description provided for @commonWeekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get commonWeekdayMonday;

  /// No description provided for @commonWeekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get commonWeekdayTuesday;

  /// No description provided for @commonWeekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get commonWeekdayWednesday;

  /// No description provided for @commonWeekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get commonWeekdayThursday;

  /// No description provided for @commonWeekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get commonWeekdayFriday;

  /// No description provided for @commonWeekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get commonWeekdaySaturday;

  /// No description provided for @commonWeekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get commonWeekdaySunday;

  /// No description provided for @homeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get homeExpense;

  /// No description provided for @homeNoRecords.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get homeNoRecords;

  /// No description provided for @homeSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get homeSelectDate;

  /// No description provided for @homeYear.
  ///
  /// In en, this message translates to:
  /// **'{year}'**
  String homeYear(int year);

  /// No description provided for @homeMonth.
  ///
  /// In en, this message translates to:
  /// **'{month}M'**
  String homeMonth(String month);

  /// No description provided for @homeMonthExpenseOf.
  ///
  /// In en, this message translates to:
  /// **'Month {month}'**
  String homeMonthExpenseOf(String month);

  /// No description provided for @homeBaseCurrencyNeedLedger.
  ///
  /// In en, this message translates to:
  /// **'Please create a ledger first'**
  String get homeBaseCurrencyNeedLedger;

  /// No description provided for @homeBaseCurrencySwitched.
  ///
  /// In en, this message translates to:
  /// **'Ledger currency switched to {code}'**
  String homeBaseCurrencySwitched(String code);

  /// No description provided for @homePullCloudSuccess.
  ///
  /// In en, this message translates to:
  /// **'Synced cloud ledger data'**
  String get homePullCloudSuccess;

  /// No description provided for @homePullCloudFailed.
  ///
  /// In en, this message translates to:
  /// **'Refresh failed, please try again later'**
  String get homePullCloudFailed;

  /// No description provided for @homePullLocalSuccess.
  ///
  /// In en, this message translates to:
  /// **'Refreshed local ledger data & config'**
  String get homePullLocalSuccess;

  /// No description provided for @homePullCloudFailedButLocalOk.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync failed; refreshed local data (rates/config)'**
  String get homePullCloudFailedButLocalOk;

  /// No description provided for @homeSyncing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing ledger data'**
  String get homeSyncing;

  /// No description provided for @dayHomeSyncing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing anniversary book data'**
  String get dayHomeSyncing;

  /// No description provided for @dayPullLocalSuccess.
  ///
  /// In en, this message translates to:
  /// **'Refreshed local anniversary book data'**
  String get dayPullLocalSuccess;

  /// No description provided for @dayPullCloudSuccess.
  ///
  /// In en, this message translates to:
  /// **'Synced cloud anniversary book data'**
  String get dayPullCloudSuccess;

  /// No description provided for @dayPullCloudFailedButLocalOk.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync failed; refreshed local anniversary book data'**
  String get dayPullCloudFailedButLocalOk;

  /// No description provided for @dayPullLocalFailed.
  ///
  /// In en, this message translates to:
  /// **'Local anniversary book refresh failed. Please try again later'**
  String get dayPullLocalFailed;

  /// No description provided for @dayPullCloudFailed.
  ///
  /// In en, this message translates to:
  /// **'Cloud anniversary book refresh failed. Please try again later'**
  String get dayPullCloudFailed;

  /// No description provided for @analyticsMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get analyticsMonth;

  /// No description provided for @analyticsYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get analyticsYear;

  /// No description provided for @analyticsWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get analyticsWeek;

  /// No description provided for @analyticsTotalExpenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get analyticsTotalExpenseLabel;

  /// No description provided for @analyticsCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get analyticsCategoryLabel;

  /// No description provided for @analyticsExpenseRatio.
  ///
  /// In en, this message translates to:
  /// **'Expense Ratio'**
  String get analyticsExpenseRatio;

  /// No description provided for @analyticsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get analyticsThisWeek;

  /// No description provided for @analyticsBackToThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Back to This Week'**
  String get analyticsBackToThisWeek;

  /// No description provided for @analyticsBackToThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Back to This Month'**
  String get analyticsBackToThisMonth;

  /// No description provided for @analyticsBackToThisYear.
  ///
  /// In en, this message translates to:
  /// **'Back to This Year'**
  String get analyticsBackToThisYear;

  /// No description provided for @analyticsWeekN.
  ///
  /// In en, this message translates to:
  /// **'Week {week}'**
  String analyticsWeekN(int week);

  /// No description provided for @analyticsSelectWeek.
  ///
  /// In en, this message translates to:
  /// **'Select week'**
  String get analyticsSelectWeek;

  /// No description provided for @ledgersTitle.
  ///
  /// In en, this message translates to:
  /// **'Ledger Management'**
  String get ledgersTitle;

  /// No description provided for @ledgersArchivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Archived ledgers'**
  String get ledgersArchivedTitle;

  /// No description provided for @ledgersArchivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get ledgersArchivedLabel;

  /// No description provided for @ledgersArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive ledger'**
  String get ledgersArchive;

  /// No description provided for @ledgersRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore ledger'**
  String get ledgersRestore;

  /// No description provided for @ledgersArchiveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ledger archived'**
  String get ledgersArchiveSuccess;

  /// No description provided for @ledgersRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ledger restored'**
  String get ledgersRestoreSuccess;

  /// No description provided for @ledgersArchivedRestoreRequired.
  ///
  /// In en, this message translates to:
  /// **'This ledger is archived. Restore it before continuing.'**
  String get ledgersArchivedRestoreRequired;

  /// No description provided for @ledgersNew.
  ///
  /// In en, this message translates to:
  /// **'Add Ledger'**
  String get ledgersNew;

  /// No description provided for @ledgersClear.
  ///
  /// In en, this message translates to:
  /// **'Clear Ledger'**
  String get ledgersClear;

  /// No description provided for @ledgersClearMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to clear all transactions in ledger \"{name}\"? This action cannot be undone.\\nThe ledger will be kept, only transaction data will be deleted.'**
  String ledgersClearMessage(Object name);

  /// No description provided for @ledgerDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Default Ledger'**
  String get ledgerDefaultName;

  /// No description provided for @ledgersEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Ledger'**
  String get ledgersEdit;

  /// No description provided for @ledgersDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Ledger'**
  String get ledgersDelete;

  /// No description provided for @ledgersDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Ledger'**
  String get ledgersDeleteConfirm;

  /// No description provided for @ledgersDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this ledger and all its records? This action cannot be undone.\\nIf there is a backup in the cloud, it will also be deleted.'**
  String get ledgersDeleteMessage;

  /// No description provided for @ledgersDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get ledgersDeleted;

  /// No description provided for @ledgersClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Ledger'**
  String get ledgersClearTitle;

  /// No description provided for @ledgersClearSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ledger cleared'**
  String get ledgersClearSuccess;

  /// No description provided for @ledgersCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ledger created'**
  String get ledgersCreateSuccess;

  /// No description provided for @ledgerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Ledger Name'**
  String get ledgerNameLabel;

  /// No description provided for @ledgerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter the ledger name'**
  String get ledgerNameHint;

  /// No description provided for @ledgersDefaultLedgerName.
  ///
  /// In en, this message translates to:
  /// **'Default Ledger'**
  String get ledgersDefaultLedgerName;

  /// No description provided for @ledgersCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get ledgersCurrency;

  /// No description provided for @ledgersMonthStartDay.
  ///
  /// In en, this message translates to:
  /// **'Month start day'**
  String get ledgersMonthStartDay;

  /// No description provided for @ledgersMonthStartDayHint.
  ///
  /// In en, this message translates to:
  /// **'Statistics and budgets start each monthly period on the selected day (1~31). If that date does not exist, use the last day of that month (30, 29 or 28).'**
  String get ledgersMonthStartDayHint;

  /// No description provided for @ledgersMonthStartDayNatural.
  ///
  /// In en, this message translates to:
  /// **'1st (calendar month)'**
  String get ledgersMonthStartDayNatural;

  /// No description provided for @ledgersMonthStartDayValue.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of each month'**
  String ledgersMonthStartDayValue(int day);

  /// No description provided for @ledgersSearchCurrency.
  ///
  /// In en, this message translates to:
  /// **'Search: Chinese or code'**
  String get ledgersSearchCurrency;

  /// No description provided for @ledgersCreate.
  ///
  /// In en, this message translates to:
  /// **'Add ledger'**
  String get ledgersCreate;

  /// No description provided for @ledgersRecords.
  ///
  /// In en, this message translates to:
  /// **'Records: {count}'**
  String ledgersRecords(String count);

  /// No description provided for @ledgersExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense: {expense}'**
  String ledgersExpense(String expense);

  /// No description provided for @ledgersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No ledgers'**
  String get ledgersEmpty;

  /// No description provided for @ledgersSectionLocal.
  ///
  /// In en, this message translates to:
  /// **'Local ledgers'**
  String get ledgersSectionLocal;

  /// No description provided for @ledgersSectionCloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud Ledgers'**
  String get ledgersSectionCloud;

  /// No description provided for @joinSharedTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Shared Ledger'**
  String get joinSharedTitle;

  /// No description provided for @joinSharedCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter invite code'**
  String get joinSharedCodeHint;

  /// No description provided for @joinSharedQuery.
  ///
  /// In en, this message translates to:
  /// **'Query'**
  String get joinSharedQuery;

  /// No description provided for @joinSharedQueryFailed.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired invite code'**
  String get joinSharedQueryFailed;

  /// No description provided for @joinSharedAlreadyOwner.
  ///
  /// In en, this message translates to:
  /// **'You are already the owner of this ledger'**
  String get joinSharedAlreadyOwner;

  /// No description provided for @joinSharedAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept Invite'**
  String get joinSharedAccept;

  /// No description provided for @joinSharedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ledger joined'**
  String get joinSharedSuccess;

  /// No description provided for @joinSharedNeedLogin.
  ///
  /// In en, this message translates to:
  /// **'Login required to join a shared ledger'**
  String get joinSharedNeedLogin;

  /// No description provided for @joinSharedPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite Details'**
  String get joinSharedPreviewTitle;

  /// No description provided for @ledgersActionMoveToCloud.
  ///
  /// In en, this message translates to:
  /// **'Move to the Cloud'**
  String get ledgersActionMoveToCloud;

  /// No description provided for @ledgersActionMoveToLocal.
  ///
  /// In en, this message translates to:
  /// **'Move to local'**
  String get ledgersActionMoveToLocal;

  /// No description provided for @ledgersActionCopyToLocal.
  ///
  /// In en, this message translates to:
  /// **'Copy to local'**
  String get ledgersActionCopyToLocal;

  /// No description provided for @ledgersMoveToCloudMessage.
  ///
  /// In en, this message translates to:
  /// **'Ledger \"{name}\" will be uploaded to the cloud and synced across your devices.'**
  String ledgersMoveToCloudMessage(String name);

  /// No description provided for @ledgersMoveToLocalMessage.
  ///
  /// In en, this message translates to:
  /// **'Ledger \"{name}\" will be deleted from the cloud and kept on this device only. Other devices will no longer see it.'**
  String ledgersMoveToLocalMessage(String name);

  /// No description provided for @ledgersCopyToLocalMessage.
  ///
  /// In en, this message translates to:
  /// **'A local copy of ledger \"{name}\" will be created. The cloud ledger stays unchanged.'**
  String ledgersCopyToLocalMessage(String name);

  /// No description provided for @ledgersMoveToCloudSuccess.
  ///
  /// In en, this message translates to:
  /// **'Moved to the Cloud'**
  String get ledgersMoveToCloudSuccess;

  /// No description provided for @ledgersMoveToLocalSuccess.
  ///
  /// In en, this message translates to:
  /// **'Moved to local'**
  String get ledgersMoveToLocalSuccess;

  /// No description provided for @ledgersCopyToLocalSuccess.
  ///
  /// In en, this message translates to:
  /// **'Copied to local'**
  String get ledgersCopyToLocalSuccess;

  /// No description provided for @ledgersSwitched.
  ///
  /// In en, this message translates to:
  /// **'Switched to ledger \"{name}\"'**
  String ledgersSwitched(String name);

  /// No description provided for @categoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Category Management'**
  String get categoryTitle;

  /// No description provided for @categoryExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get categoryExpense;

  /// No description provided for @categoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get categoryEmpty;

  /// No description provided for @importReading.
  ///
  /// In en, this message translates to:
  /// **'Reading file…'**
  String get importReading;

  /// No description provided for @importPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing…'**
  String get importPreparing;

  /// No description provided for @importConfirmMapping.
  ///
  /// In en, this message translates to:
  /// **'Confirm Mapping'**
  String get importConfirmMapping;

  /// No description provided for @importCategoryMapping.
  ///
  /// In en, this message translates to:
  /// **'Category Mapping'**
  String get importCategoryMapping;

  /// No description provided for @importNoDataParsed.
  ///
  /// In en, this message translates to:
  /// **'No data parsed. Please return to previous page to check CSV content or separator.'**
  String get importNoDataParsed;

  /// No description provided for @importFieldAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get importFieldAmount;

  /// No description provided for @importFieldNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get importFieldNote;

  /// No description provided for @importKeepOriginalName.
  ///
  /// In en, this message translates to:
  /// **'Keep original name'**
  String get importKeepOriginalName;

  /// No description provided for @importNextStep.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get importNextStep;

  /// No description provided for @importPreviousStep.
  ///
  /// In en, this message translates to:
  /// **'Previous Step'**
  String get importPreviousStep;

  /// No description provided for @importStartImport.
  ///
  /// In en, this message translates to:
  /// **'Start Import'**
  String get importStartImport;

  /// No description provided for @importInProgress.
  ///
  /// In en, this message translates to:
  /// **'Import in Progress'**
  String get importInProgress;

  /// No description provided for @importFetchingRates.
  ///
  /// In en, this message translates to:
  /// **'Fetching exchange rates…'**
  String get importFetchingRates;

  /// No description provided for @importXlsxFormulaError.
  ///
  /// In en, this message translates to:
  /// **'Formula cells detected. Please save values in Excel first and retry'**
  String get importXlsxFormulaError;

  /// No description provided for @importPrecheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Pre-check'**
  String get importPrecheckTitle;

  /// No description provided for @importProgressRunning.
  ///
  /// In en, this message translates to:
  /// **'Processed {done} / {total} records'**
  String importProgressRunning(Object done, Object total);

  /// No description provided for @importCancelled.
  ///
  /// In en, this message translates to:
  /// **'Import Cancelled'**
  String get importCancelled;

  /// No description provided for @mineTitle.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get mineTitle;

  /// No description provided for @mineLanguageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get mineLanguageSettings;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageTitle;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageChinese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get languageSystemDefault;

  /// No description provided for @mineCloudService.
  ///
  /// In en, this message translates to:
  /// **'Backup & Cloud Sync'**
  String get mineCloudService;

  /// No description provided for @cloudBackupUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get cloudBackupUrlLabel;

  /// No description provided for @cloudBackupAnonKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Anon Key'**
  String get cloudBackupAnonKeyLabel;

  /// No description provided for @cloudBackupBucketLabel.
  ///
  /// In en, this message translates to:
  /// **'Bucket'**
  String get cloudBackupBucketLabel;

  /// No description provided for @cloudBackupAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get cloudBackupAccountLabel;

  /// No description provided for @cloudBackupPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get cloudBackupPasswordLabel;

  /// No description provided for @cloudBackupUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get cloudBackupUsernameLabel;

  /// No description provided for @cloudBackupRemotePathLabel.
  ///
  /// In en, this message translates to:
  /// **'Remote Path'**
  String get cloudBackupRemotePathLabel;

  /// No description provided for @cloudBackupEndpointLabel.
  ///
  /// In en, this message translates to:
  /// **'Endpoint'**
  String get cloudBackupEndpointLabel;

  /// No description provided for @cloudBackupRegionLabel.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get cloudBackupRegionLabel;

  /// No description provided for @cloudBackupAccessKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Access Key'**
  String get cloudBackupAccessKeyLabel;

  /// No description provided for @cloudBackupSecretKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Secret Key'**
  String get cloudBackupSecretKeyLabel;

  /// No description provided for @cloudBackupSslLabel.
  ///
  /// In en, this message translates to:
  /// **'Use SSL'**
  String get cloudBackupSslLabel;

  /// No description provided for @cloudBackupPortLabel.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get cloudBackupPortLabel;

  /// No description provided for @cloudBackupNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get cloudBackupNotConfigured;

  /// No description provided for @cloudBackupConfiguredInactive.
  ///
  /// In en, this message translates to:
  /// **'Configured, not currently used'**
  String get cloudBackupConfiguredInactive;

  /// No description provided for @cloudBackupActiveNoSuccess.
  ///
  /// In en, this message translates to:
  /// **'In use · No successful backup yet'**
  String get cloudBackupActiveNoSuccess;

  /// No description provided for @cloudBackupActiveLastSuccess.
  ///
  /// In en, this message translates to:
  /// **'In use · Last success {time}'**
  String cloudBackupActiveLastSuccess(String time);

  /// No description provided for @mineCategoryManagement.
  ///
  /// In en, this message translates to:
  /// **'Category Management'**
  String get mineCategoryManagement;

  /// No description provided for @mineReminderSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get mineReminderSettings;

  /// No description provided for @categoryEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get categoryEditTitle;

  /// No description provided for @categoryNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get categoryNewTitle;

  /// No description provided for @categoryDetailTooltip.
  ///
  /// In en, this message translates to:
  /// **'Category Summary'**
  String get categoryDetailTooltip;

  /// No description provided for @categoryDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Default Category'**
  String get categoryDefaultTitle;

  /// No description provided for @categoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryNameLabel;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter category name'**
  String get categoryNameHint;

  /// No description provided for @categoryNameDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Category name already exists'**
  String get categoryNameDuplicate;

  /// No description provided for @categoryIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Category Icon'**
  String get categoryIconLabel;

  /// No description provided for @categoryCurrentIcon.
  ///
  /// In en, this message translates to:
  /// **'Current Icon'**
  String get categoryCurrentIcon;

  /// No description provided for @categorySaveError.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get categorySaveError;

  /// No description provided for @categoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category \"{name}\" updated'**
  String categoryUpdated(Object name);

  /// No description provided for @categoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category \"{name}\" created'**
  String categoryCreated(Object name);

  /// No description provided for @categoryCannotDelete.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete'**
  String get categoryCannotDelete;

  /// No description provided for @categoryClearUnused.
  ///
  /// In en, this message translates to:
  /// **'Clear Unused Categories'**
  String get categoryClearUnused;

  /// No description provided for @categoryClearUnusedMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} unused categories? This action cannot be undone.'**
  String categoryClearUnusedMessage(Object count);

  /// No description provided for @categoryClearUnusedListTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories to be deleted:'**
  String get categoryClearUnusedListTitle;

  /// No description provided for @categoryClearUnusedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No unused categories'**
  String get categoryClearUnusedEmpty;

  /// No description provided for @categoryClearUnusedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted {count} categories'**
  String categoryClearUnusedSuccess(Object count);

  /// No description provided for @categoryClearUnusedFailed.
  ///
  /// In en, this message translates to:
  /// **'Clear failed'**
  String get categoryClearUnusedFailed;

  /// No description provided for @categoryDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get categoryDeleteError;

  /// No description provided for @categorySubCategoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Subcategory added: {name}'**
  String categorySubCategoryCreated(Object name);

  /// No description provided for @categoryParentCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Belongs To'**
  String get categoryParentCategoryTitle;

  /// No description provided for @categorySelectParentHint.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get categorySelectParentHint;

  /// No description provided for @categorySelectParentTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get categorySelectParentTitle;

  /// No description provided for @categoryHasSubCategories.
  ///
  /// In en, this message translates to:
  /// **'This category has subcategories and cannot be modified'**
  String get categoryHasSubCategories;

  /// No description provided for @categorySearchCategory.
  ///
  /// In en, this message translates to:
  /// **'Search categories'**
  String get categorySearchCategory;

  /// No description provided for @categoryTopLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Top-level'**
  String get categoryTopLevelLabel;

  /// No description provided for @categorySecondLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Second-level'**
  String get categorySecondLevelLabel;

  /// No description provided for @categoryExpenseList.
  ///
  /// In en, this message translates to:
  /// **'Dining-Transport-Shopping-Entertainment-Home-Family-Communication-Utilities-Housing-Medical-Education-Pets-Sports-Digital-Travel-Alcohol & Tobacco-Baby Care-Beauty-Repair-Social-Learning-Car-Taxi-Subway-Delivery-Property-Parking-Donation-Give Gift-Tax-Beverage-Clothing-Snacks-Send Red Packet-Fruit-Game-Books-Lover-Decoration-Daily Goods-Lottery-Stock-Social Security-Express-Work-Transfer-Other'**
  String get categoryExpenseList;

  /// No description provided for @categoryExpenseDining.
  ///
  /// In en, this message translates to:
  /// **'Dining-Breakfast-Lunch-Dinner-Meituan Delivery-Ele.me Delivery-JD Delivery-Restaurant-Food'**
  String get categoryExpenseDining;

  /// No description provided for @categoryExpenseSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks-Cookies-Chips-Candy-Chocolate-Nuts'**
  String get categoryExpenseSnacks;

  /// No description provided for @categoryExpenseFruit.
  ///
  /// In en, this message translates to:
  /// **'Fruit-Apple-Banana-Orange-Grape-Watermelon-Other Fruits'**
  String get categoryExpenseFruit;

  /// No description provided for @categoryExpenseBeverage.
  ///
  /// In en, this message translates to:
  /// **'Beverage-Milk Tea-Coffee-Juice-Soda-Mineral Water'**
  String get categoryExpenseBeverage;

  /// No description provided for @categoryExpensePastry.
  ///
  /// In en, this message translates to:
  /// **'Pastry-Cake-Bread-Dessert-Baked Goods'**
  String get categoryExpensePastry;

  /// No description provided for @categoryExpenseCooking.
  ///
  /// In en, this message translates to:
  /// **'Cooking Ingredients-Vegetables-Meat-Seafood-Seasoning-Grain & Oil'**
  String get categoryExpenseCooking;

  /// No description provided for @categoryExpenseShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping-Supermarket-Daily Necessities-Clothing-Shoes-Bags'**
  String get categoryExpenseShopping;

  /// No description provided for @categoryExpensePets.
  ///
  /// In en, this message translates to:
  /// **'Pets-Pet Food-Pet Supplies-Pet Medical-Pet Grooming'**
  String get categoryExpensePets;

  /// No description provided for @categoryExpenseTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport-Transit Card-Taxi-Parking Fee-Fuel'**
  String get categoryExpenseTransport;

  /// No description provided for @categoryExpenseCar.
  ///
  /// In en, this message translates to:
  /// **'Car-Car Maintenance-Car Repair-Car Insurance-Car Wash-Traffic Fine'**
  String get categoryExpenseCar;

  /// No description provided for @categoryExpenseClothing.
  ///
  /// In en, this message translates to:
  /// **'Apparel-Top-Pants-Dress-Shoes-Apparel Accessories'**
  String get categoryExpenseClothing;

  /// No description provided for @categoryExpenseDailyGoods.
  ///
  /// In en, this message translates to:
  /// **'Daily Goods-Personal Care-Paper Products-Cleaning Supplies-Kitchen Supplies'**
  String get categoryExpenseDailyGoods;

  /// No description provided for @categoryExpenseEducation.
  ///
  /// In en, this message translates to:
  /// **'Education-Tuition-Training Fee-Books-Stationery-Office Supplies-Learning'**
  String get categoryExpenseEducation;

  /// No description provided for @categoryExpenseInvestLoss.
  ///
  /// In en, this message translates to:
  /// **'Investment Loss-Stock Loss-Fund Loss-Other Investment Loss'**
  String get categoryExpenseInvestLoss;

  /// No description provided for @categoryExpenseEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment-Movie-KTV-Amusement Park-Bar-Other Entertainment'**
  String get categoryExpenseEntertainment;

  /// No description provided for @categoryExpenseGame.
  ///
  /// In en, this message translates to:
  /// **'Game-Game Top up-Game Equipment-Game Membership'**
  String get categoryExpenseGame;

  /// No description provided for @categoryExpenseHealthProducts.
  ///
  /// In en, this message translates to:
  /// **'Health Products-Vitamins-Health Food-Nutritional Supplements'**
  String get categoryExpenseHealthProducts;

  /// No description provided for @categoryExpenseSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription-Video Membership-Music Membership-Cloud Storage-Other Subscription'**
  String get categoryExpenseSubscription;

  /// No description provided for @categoryExpenseSports.
  ///
  /// In en, this message translates to:
  /// **'Sports-Gym-Sports Equipment-Sports Course-Outdoor Activity'**
  String get categoryExpenseSports;

  /// No description provided for @categoryExpenseHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing-Utilities-Property Fee-Rent-Mortgage-Renovation-Broadband'**
  String get categoryExpenseHousing;

  /// No description provided for @categoryExpenseHome.
  ///
  /// In en, this message translates to:
  /// **'Home-Furniture-Appliances-Decorations-Bedding'**
  String get categoryExpenseHome;

  /// No description provided for @categoryExpenseBeauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty-Skincare-Cosmetics-Haircut-Nail Care'**
  String get categoryExpenseBeauty;

  /// No description provided for @categoryExpenseTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer-Living Cost-Family-Parents-Lover-Borrow Money'**
  String get categoryExpenseTransfer;

  /// No description provided for @appearanceThemeMode.
  ///
  /// In en, this message translates to:
  /// **'Display mode'**
  String get appearanceThemeMode;

  /// No description provided for @appearanceThemeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get appearanceThemeModeSystem;

  /// No description provided for @appearanceThemeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get appearanceThemeModeLight;

  /// No description provided for @appearanceThemeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get appearanceThemeModeDark;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Recording Reminder'**
  String get reminderTitle;

  /// No description provided for @reminderBody.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to record today\'s expenses 💰'**
  String get reminderBody;

  /// No description provided for @reminderDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Recording Reminder'**
  String get reminderDailyTitle;

  /// No description provided for @reminderTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder Time'**
  String get reminderTimeTitle;

  /// No description provided for @commonSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get commonSelectTime;

  /// No description provided for @reminderPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications and the relevant reminder channel in system settings'**
  String get reminderPermissionRequired;

  /// No description provided for @reminderCheckBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get reminderCheckBattery;

  /// No description provided for @reminderStatusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to read status. Please try again later.'**
  String get reminderStatusUnavailable;

  /// No description provided for @reminderStatusLoading.
  ///
  /// In en, this message translates to:
  /// **'Reading system settings…'**
  String get reminderStatusLoading;

  /// No description provided for @reminderChannelNotCreated.
  ///
  /// In en, this message translates to:
  /// **'Not created yet'**
  String get reminderChannelNotCreated;

  /// No description provided for @reminderBatteryIgnored.
  ///
  /// In en, this message translates to:
  /// **'Battery management: Exempt from system battery restrictions'**
  String get reminderBatteryIgnored;

  /// No description provided for @reminderBatteryNotIgnored.
  ///
  /// In en, this message translates to:
  /// **'Battery management: Subject to system battery restrictions'**
  String get reminderBatteryNotIgnored;

  /// No description provided for @reminderCheckChannel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get reminderCheckChannel;

  /// No description provided for @reminderStatusNotificationLabel.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get reminderStatusNotificationLabel;

  /// No description provided for @reminderStatusImportanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Importance'**
  String get reminderStatusImportanceLabel;

  /// No description provided for @reminderStatusSoundLabel.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get reminderStatusSoundLabel;

  /// No description provided for @reminderStatusVibrationLabel.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get reminderStatusVibrationLabel;

  /// No description provided for @reminderStatusDndLabel.
  ///
  /// In en, this message translates to:
  /// **'DND'**
  String get reminderStatusDndLabel;

  /// No description provided for @reminderStatusOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get reminderStatusOn;

  /// No description provided for @reminderStatusOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get reminderStatusOff;

  /// No description provided for @reminderStatusDndBypass.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get reminderStatusDndBypass;

  /// No description provided for @reminderStatusDndFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get reminderStatusDndFollow;

  /// No description provided for @reminderImportanceHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get reminderImportanceHigh;

  /// No description provided for @reminderImportanceDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get reminderImportanceDefault;

  /// No description provided for @reminderImportanceLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get reminderImportanceLow;

  /// No description provided for @reminderImportanceMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get reminderImportanceMin;

  /// No description provided for @reminderImportanceNone.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get reminderImportanceNone;

  /// No description provided for @reminderImportanceUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get reminderImportanceUnknown;

  /// No description provided for @reminderOpenAppSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get reminderOpenAppSettings;

  /// No description provided for @reminderAutoStartSettings.
  ///
  /// In en, this message translates to:
  /// **'Auto-start'**
  String get reminderAutoStartSettings;

  /// No description provided for @reminderAutoStartAdvice.
  ///
  /// In en, this message translates to:
  /// **'This device cannot open the auto-start page directly. Enable it manually in system settings.\n\nOnePlus, OPPO, realme: Settings → Apps → Auto-start → Sesame Notes.\n\nOther devices: search for Auto-start or App launch management and allow Sesame Notes to start automatically. Menu names vary by system version.'**
  String get reminderAutoStartAdvice;

  /// No description provided for @reminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Settings apply to this device. Turning off notifications pauses all reminders and keeps your preferences. Anniversary reminders are grouped by day and scheduled a year ahead, refreshed when you open the app or dates or records change.'**
  String get reminderDescription;

  /// No description provided for @reminderAndroidInstructions.
  ///
  /// In en, this message translates to:
  /// **'• Enable recording, anniversary and rest reminders separately in notification settings, where you can also manage sound and vibration.\n• Allow Alarms & reminders to reduce delays. A next-alarm indicator may appear. Recording and anniversary reminders use normal notifications; rest timers play sound or vibrate according to your settings.\n• Enable background activity and auto-start separately. Battery status only checks the system power-saving exemption; manufacturer restrictions need a separate check.\n• Force-stopping the app may clear scheduled reminders. Reopen Sesame Notes to restore future reminders. Silent and Do Not Disturb modes may mute notification sounds.'**
  String get reminderAndroidInstructions;

  /// No description provided for @categoryDetailLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load data. Please try again.'**
  String get categoryDetailLoadFailed;

  /// No description provided for @categoryDetailSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Category Summary'**
  String get categoryDetailSummaryTitle;

  /// No description provided for @categoryDetailTotalCount.
  ///
  /// In en, this message translates to:
  /// **'Total Count'**
  String get categoryDetailTotalCount;

  /// No description provided for @categoryDetailTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get categoryDetailTotalAmount;

  /// No description provided for @categoryDetailAverageAmount.
  ///
  /// In en, this message translates to:
  /// **'Average Amount'**
  String get categoryDetailAverageAmount;

  /// No description provided for @categoryDetailSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get categoryDetailSortTitle;

  /// No description provided for @categoryDetailSortTimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Time ↓'**
  String get categoryDetailSortTimeDesc;

  /// No description provided for @categoryDetailSortTimeAsc.
  ///
  /// In en, this message translates to:
  /// **'Time ↑'**
  String get categoryDetailSortTimeAsc;

  /// No description provided for @categoryDetailSortAmountDesc.
  ///
  /// In en, this message translates to:
  /// **'Amount ↓'**
  String get categoryDetailSortAmountDesc;

  /// No description provided for @categoryDetailSortAmountAsc.
  ///
  /// In en, this message translates to:
  /// **'Amount ↑'**
  String get categoryDetailSortAmountAsc;

  /// No description provided for @categoryDetailNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get categoryDetailNoTransactions;

  /// No description provided for @categoryDetailNoTransactionsSubtext.
  ///
  /// In en, this message translates to:
  /// **'No transactions in this category yet'**
  String get categoryDetailNoTransactionsSubtext;

  /// No description provided for @categoryDetailDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get categoryDetailDeleteFailed;

  /// No description provided for @categoryMigrationTransactionLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} records'**
  String categoryMigrationTransactionLabel(int count);

  /// No description provided for @categoryTemplateEntryFlat.
  ///
  /// In en, this message translates to:
  /// **'Flat Template'**
  String get categoryTemplateEntryFlat;

  /// No description provided for @categoryTemplateEntryHierarchical.
  ///
  /// In en, this message translates to:
  /// **'Hierarchical Template'**
  String get categoryTemplateEntryHierarchical;

  /// No description provided for @categoryTemplateFlatTitle.
  ///
  /// In en, this message translates to:
  /// **'Flat Category Template'**
  String get categoryTemplateFlatTitle;

  /// No description provided for @categoryTemplateHierarchicalTitle.
  ///
  /// In en, this message translates to:
  /// **'Hierarchical Category Template'**
  String get categoryTemplateHierarchicalTitle;

  /// No description provided for @categoryTemplateSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String categoryTemplateSelectedCount(int count);

  /// No description provided for @categoryTemplateSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get categoryTemplateSelectAll;

  /// No description provided for @categoryTemplateDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get categoryTemplateDeselectAll;

  /// No description provided for @categoryTemplateAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get categoryTemplateAlreadyAdded;

  /// No description provided for @categoryTemplateAlreadyAddedHint.
  ///
  /// In en, this message translates to:
  /// **'Added categories stay selected and cannot be deselected'**
  String get categoryTemplateAlreadyAddedHint;

  /// No description provided for @categoryTemplateConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Categories'**
  String get categoryTemplateConfirmTitle;

  /// No description provided for @categoryTemplateConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Add the selected {count} categories to your category list?'**
  String categoryTemplateConfirmMessage(int count);

  /// No description provided for @categoryTemplateAddSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added {count} categories'**
  String categoryTemplateAddSuccess(int count);

  /// No description provided for @categoryTemplateAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add: {error}'**
  String categoryTemplateAddFailed(String error);

  /// 已提交的模板处理摘要及剩余操作未完成提示。
  ///
  /// In en, this message translates to:
  /// **'{completed}\nThe remaining categories could not be processed. Please try again.'**
  String categoryTemplatePartiallyCompleted(String completed);

  /// No description provided for @categoryManageAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get categoryManageAdd;

  /// No description provided for @categoryManageDelete.
  ///
  /// In en, this message translates to:
  /// **'Batch Delete Categories'**
  String get categoryManageDelete;

  /// No description provided for @categoryManageConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get categoryManageConfirmDelete;

  /// No description provided for @categoryManageReorderHint.
  ///
  /// In en, this message translates to:
  /// **'Long press to reorder'**
  String get categoryManageReorderHint;

  /// No description provided for @categorySelectParentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Parent Categories'**
  String get categorySelectParentsTitle;

  /// No description provided for @categoryChildrenTitle.
  ///
  /// In en, this message translates to:
  /// **'Subcategories'**
  String get categoryChildrenTitle;

  /// No description provided for @categoryManageSubcategoryCount.
  ///
  /// In en, this message translates to:
  /// **'Subcategories: {count}'**
  String categoryManageSubcategoryCount(int count);

  /// No description provided for @categorySubcategoryCount.
  ///
  /// In en, this message translates to:
  /// **'{count} subcategories'**
  String categorySubcategoryCount(int count);

  /// No description provided for @categoryTransactionBreakdown.
  ///
  /// In en, this message translates to:
  /// **'{direct} direct records · {total} total'**
  String categoryTransactionBreakdown(int direct, int total);

  /// No description provided for @categorySharedManageBannerOwner.
  ///
  /// In en, this message translates to:
  /// **'Shared ledger: category changes here sync to all members'**
  String get categorySharedManageBannerOwner;

  /// No description provided for @categorySharedManageBannerEditor.
  ///
  /// In en, this message translates to:
  /// **'This shared ledger uses the owner\'s categories; edits here only affect your personal categories'**
  String get categorySharedManageBannerEditor;

  /// No description provided for @categorySortSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save order. Please try again'**
  String get categorySortSaveFailed;

  /// No description provided for @categoryDeleteOptionAll.
  ///
  /// In en, this message translates to:
  /// **'Delete categories and all data (incl. subcategories)'**
  String get categoryDeleteOptionAll;

  /// No description provided for @categoryDeleteOptionMigrate.
  ///
  /// In en, this message translates to:
  /// **'Delete categories and their subcategories and migrate all data to another category'**
  String get categoryDeleteOptionMigrate;

  /// No description provided for @categoryDeleteOptionPromote.
  ///
  /// In en, this message translates to:
  /// **'Delete categories and data (excl. subcategories, subcategories become top-level)'**
  String get categoryDeleteOptionPromote;

  /// No description provided for @categoryDeleteSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected Categories'**
  String get categoryDeleteSelectedTitle;

  /// No description provided for @categoryDeleteSelectedSubtitleWithSub.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} selected categories and clear their data? (including subcategories and data) This action cannot be undone.'**
  String categoryDeleteSelectedSubtitleWithSub(int count);

  /// No description provided for @categoryDeleteSelectedSubtitleWithoutSub.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} selected categories and clear their data? (excluding subcategories and data) This action cannot be undone.'**
  String categoryDeleteSelectedSubtitleWithoutSub(int count);

  /// No description provided for @categoryMigrateSelectTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Target Category'**
  String get categoryMigrateSelectTargetTitle;

  /// No description provided for @categoryMigrateConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm (Migrate data and delete categories)'**
  String get categoryMigrateConfirmButton;

  /// No description provided for @categoryMigrateChildLabel.
  ///
  /// In en, this message translates to:
  /// **'Sub · {parent}'**
  String categoryMigrateChildLabel(Object parent);

  /// No description provided for @subcategoryAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Subcategory'**
  String get subcategoryAdd;

  /// No description provided for @subcategoryDelete.
  ///
  /// In en, this message translates to:
  /// **'Batch Delete'**
  String get subcategoryDelete;

  /// No description provided for @subcategoryDeleteOptionAll.
  ///
  /// In en, this message translates to:
  /// **'Delete categories and all data under them'**
  String get subcategoryDeleteOptionAll;

  /// No description provided for @subcategoryDeleteOptionMigrate.
  ///
  /// In en, this message translates to:
  /// **'Delete categories and migrate all data to another category'**
  String get subcategoryDeleteOptionMigrate;

  /// No description provided for @subcategoryDeleteSelectedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} selected categories and clear their data? This action cannot be undone.'**
  String subcategoryDeleteSelectedSubtitle(int count);

  /// No description provided for @subcategoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No subcategories yet'**
  String get subcategoryEmpty;

  /// No description provided for @cloudFirstSaveSwitchTitle.
  ///
  /// In en, this message translates to:
  /// **'Configuration Saved'**
  String get cloudFirstSaveSwitchTitle;

  /// No description provided for @cloudFirstSaveSwitchMessage.
  ///
  /// In en, this message translates to:
  /// **'Switch to this cloud service as the active sync configuration now?'**
  String get cloudFirstSaveSwitchMessage;

  /// No description provided for @cloudSaveOnlyNoSwitch.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get cloudSaveOnlyNoSwitch;

  /// No description provided for @cloudSaveAndSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch Now'**
  String get cloudSaveAndSwitch;

  /// No description provided for @cloudClearConfig.
  ///
  /// In en, this message translates to:
  /// **'Clear configuration'**
  String get cloudClearConfig;

  /// No description provided for @cloudClearConfigConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear cloud configuration'**
  String get cloudClearConfigConfirmTitle;

  /// No description provided for @cloudClearConfigConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Clear this cloud service configuration?\nBacked-up data on the cloud will not be deleted. You can reconfigure and restore anytime.'**
  String get cloudClearConfigConfirmMessage;

  /// No description provided for @cloudClearConfigDone.
  ///
  /// In en, this message translates to:
  /// **'Configuration cleared'**
  String get cloudClearConfigDone;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect phone number or password'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts, please try again later.'**
  String get authErrorRateLimit;

  /// No description provided for @authErrorNetworkIssue.
  ///
  /// In en, this message translates to:
  /// **'Network error, please check your connection and try again.'**
  String get authErrorNetworkIssue;

  /// No description provided for @authErrorServerNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'This version has no account server configured, so login and registration are unavailable. You can go back and continue using local features.'**
  String get authErrorServerNotConfigured;

  /// No description provided for @exportCsvHeaderType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get exportCsvHeaderType;

  /// No description provided for @exportCsvHeaderCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get exportCsvHeaderCategory;

  /// No description provided for @exportCsvHeaderSubCategory.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
  String get exportCsvHeaderSubCategory;

  /// No description provided for @exportCsvHeaderAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get exportCsvHeaderAmount;

  /// No description provided for @exportCsvHeaderNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get exportCsvHeaderNote;

  /// No description provided for @exportCsvHeaderTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get exportCsvHeaderTime;

  /// No description provided for @exportSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Successful'**
  String get exportSuccessTitle;

  /// No description provided for @exportFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Failed'**
  String get exportFailedTitle;

  /// No description provided for @exportTypeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get exportTypeExpense;

  /// No description provided for @currencyCNY.
  ///
  /// In en, this message translates to:
  /// **'Chinese Yuan'**
  String get currencyCNY;

  /// No description provided for @currencyUSD.
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get currencyUSD;

  /// No description provided for @currencyEUR.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get currencyEUR;

  /// No description provided for @currencyJPY.
  ///
  /// In en, this message translates to:
  /// **'Japanese Yen'**
  String get currencyJPY;

  /// No description provided for @currencyHKD.
  ///
  /// In en, this message translates to:
  /// **'Hong Kong Dollar'**
  String get currencyHKD;

  /// No description provided for @currencyTWD.
  ///
  /// In en, this message translates to:
  /// **'Add Taiwan Dollar'**
  String get currencyTWD;

  /// No description provided for @currencyGBP.
  ///
  /// In en, this message translates to:
  /// **'British Pound'**
  String get currencyGBP;

  /// No description provided for @currencyAUD.
  ///
  /// In en, this message translates to:
  /// **'Australian Dollar'**
  String get currencyAUD;

  /// No description provided for @currencyCAD.
  ///
  /// In en, this message translates to:
  /// **'Canadian Dollar'**
  String get currencyCAD;

  /// No description provided for @currencyKRW.
  ///
  /// In en, this message translates to:
  /// **'South Korean Won'**
  String get currencyKRW;

  /// No description provided for @currencySGD.
  ///
  /// In en, this message translates to:
  /// **'Singapore Dollar'**
  String get currencySGD;

  /// No description provided for @currencyMYR.
  ///
  /// In en, this message translates to:
  /// **'Malaysian Ringgit'**
  String get currencyMYR;

  /// No description provided for @currencyTHB.
  ///
  /// In en, this message translates to:
  /// **'Thai Baht'**
  String get currencyTHB;

  /// No description provided for @currencyIDR.
  ///
  /// In en, this message translates to:
  /// **'Indonesian Rupiah'**
  String get currencyIDR;

  /// No description provided for @currencyPHP.
  ///
  /// In en, this message translates to:
  /// **'Philippine Peso'**
  String get currencyPHP;

  /// No description provided for @currencyVND.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese Dong'**
  String get currencyVND;

  /// No description provided for @currencyINR.
  ///
  /// In en, this message translates to:
  /// **'Indian Rupee'**
  String get currencyINR;

  /// No description provided for @currencyRUB.
  ///
  /// In en, this message translates to:
  /// **'Russian Ruble'**
  String get currencyRUB;

  /// No description provided for @currencyBYN.
  ///
  /// In en, this message translates to:
  /// **'Belarusian Ruble'**
  String get currencyBYN;

  /// No description provided for @currencyNZD.
  ///
  /// In en, this message translates to:
  /// **'Add Zealand Dollar'**
  String get currencyNZD;

  /// No description provided for @currencyCHF.
  ///
  /// In en, this message translates to:
  /// **'Swiss Franc'**
  String get currencyCHF;

  /// No description provided for @currencySEK.
  ///
  /// In en, this message translates to:
  /// **'Swedish Krona'**
  String get currencySEK;

  /// No description provided for @currencyNOK.
  ///
  /// In en, this message translates to:
  /// **'Norwegian Krone'**
  String get currencyNOK;

  /// No description provided for @currencyDKK.
  ///
  /// In en, this message translates to:
  /// **'Danish Krone'**
  String get currencyDKK;

  /// No description provided for @currencyBRL.
  ///
  /// In en, this message translates to:
  /// **'Brazilian Real'**
  String get currencyBRL;

  /// No description provided for @currencyMXN.
  ///
  /// In en, this message translates to:
  /// **'Mexican Peso'**
  String get currencyMXN;

  /// No description provided for @currencyTRY.
  ///
  /// In en, this message translates to:
  /// **'Turkish Lira'**
  String get currencyTRY;

  /// No description provided for @currencyZAR.
  ///
  /// In en, this message translates to:
  /// **'South African Rand'**
  String get currencyZAR;

  /// No description provided for @currencyAED.
  ///
  /// In en, this message translates to:
  /// **'UAE Dirham'**
  String get currencyAED;

  /// No description provided for @currencySAR.
  ///
  /// In en, this message translates to:
  /// **'Saudi Riyal'**
  String get currencySAR;

  /// No description provided for @currencyPLN.
  ///
  /// In en, this message translates to:
  /// **'Polish Zloty'**
  String get currencyPLN;

  /// No description provided for @currencyCZK.
  ///
  /// In en, this message translates to:
  /// **'Czech Koruna'**
  String get currencyCZK;

  /// No description provided for @currencyHUF.
  ///
  /// In en, this message translates to:
  /// **'Hungarian Forint'**
  String get currencyHUF;

  /// No description provided for @currencyARS.
  ///
  /// In en, this message translates to:
  /// **'Argentine Peso'**
  String get currencyARS;

  /// No description provided for @currencyCLP.
  ///
  /// In en, this message translates to:
  /// **'Chilean Peso'**
  String get currencyCLP;

  /// No description provided for @currencyCOP.
  ///
  /// In en, this message translates to:
  /// **'Colombian Peso'**
  String get currencyCOP;

  /// No description provided for @currencyPEN.
  ///
  /// In en, this message translates to:
  /// **'Peruvian Sol'**
  String get currencyPEN;

  /// No description provided for @currencyEGP.
  ///
  /// In en, this message translates to:
  /// **'Egyptian Pound'**
  String get currencyEGP;

  /// No description provided for @currencyNGN.
  ///
  /// In en, this message translates to:
  /// **'Nigerian Naira'**
  String get currencyNGN;

  /// No description provided for @currencyKZT.
  ///
  /// In en, this message translates to:
  /// **'Kazakhstani Tenge'**
  String get currencyKZT;

  /// No description provided for @currencyUAH.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian Hryvnia'**
  String get currencyUAH;

  /// No description provided for @currencyILS.
  ///
  /// In en, this message translates to:
  /// **'Israeli New Shekel'**
  String get currencyILS;

  /// No description provided for @currencyPKR.
  ///
  /// In en, this message translates to:
  /// **'Pakistani Rupee'**
  String get currencyPKR;

  /// No description provided for @currencyBDT.
  ///
  /// In en, this message translates to:
  /// **'Bangladeshi Taka'**
  String get currencyBDT;

  /// No description provided for @currencyLKR.
  ///
  /// In en, this message translates to:
  /// **'Sri Lankan Rupee'**
  String get currencyLKR;

  /// No description provided for @currencyMMK.
  ///
  /// In en, this message translates to:
  /// **'Myanmar Kyat'**
  String get currencyMMK;

  /// No description provided for @recurringTransactionEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get recurringTransactionEnabled;

  /// No description provided for @recurringTransactionDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get recurringTransactionDisabled;

  /// No description provided for @recurringTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring Bills'**
  String get recurringTransactionTitle;

  /// No description provided for @recurringTransactionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add recurring bill'**
  String get recurringTransactionAdd;

  /// No description provided for @recurringTransactionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Recurring Bill'**
  String get recurringTransactionEdit;

  /// No description provided for @recurringTransactionFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get recurringTransactionFrequency;

  /// No description provided for @recurringTransactionDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get recurringTransactionDaily;

  /// No description provided for @recurringTransactionWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get recurringTransactionWeekly;

  /// No description provided for @recurringTransactionMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get recurringTransactionMonthly;

  /// No description provided for @recurringTransactionYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get recurringTransactionYearly;

  /// No description provided for @recurringTransactionInterval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get recurringTransactionInterval;

  /// No description provided for @recurringTransactionDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Day of Month'**
  String get recurringTransactionDayOfMonth;

  /// No description provided for @recurringTransactionStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get recurringTransactionStartDate;

  /// No description provided for @recurringTransactionEndDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get recurringTransactionEndDate;

  /// No description provided for @recurringTransactionNoEndDate.
  ///
  /// In en, this message translates to:
  /// **'Perpetual'**
  String get recurringTransactionNoEndDate;

  /// No description provided for @recurringTransactionDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this recurring bill?'**
  String get recurringTransactionDeleteConfirm;

  /// No description provided for @recurringTransactionEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'End date cannot be earlier than start date'**
  String get recurringTransactionEndBeforeStart;

  /// No description provided for @recurringTransactionEveryNDays.
  ///
  /// In en, this message translates to:
  /// **'Every {n} day(s)'**
  String recurringTransactionEveryNDays(int n);

  /// No description provided for @recurringTransactionEveryNWeeks.
  ///
  /// In en, this message translates to:
  /// **'Every {n} week(s)'**
  String recurringTransactionEveryNWeeks(int n);

  /// No description provided for @recurringTransactionEveryNMonths.
  ///
  /// In en, this message translates to:
  /// **'Every {n} month(s)'**
  String recurringTransactionEveryNMonths(int n);

  /// No description provided for @recurringTransactionEveryNYears.
  ///
  /// In en, this message translates to:
  /// **'Every {n} year(s)'**
  String recurringTransactionEveryNYears(int n);

  /// No description provided for @ledgerSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Ledger'**
  String get ledgerSelectTitle;

  /// No description provided for @cloudTestConnection.
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get cloudTestConnection;

  /// No description provided for @cloudLastTestTime.
  ///
  /// In en, this message translates to:
  /// **'Last test time: {time}'**
  String cloudLastTestTime(String time);

  /// No description provided for @cloudLocalStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Local Storage'**
  String get cloudLocalStorageTitle;

  /// No description provided for @cloudLocalStorageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Data is only saved on local device'**
  String get cloudLocalStorageSubtitle;

  /// No description provided for @localBackupPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Local Storage'**
  String get localBackupPageTitle;

  /// No description provided for @localBackupAutoTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto Local Backup'**
  String get localBackupAutoTitle;

  /// No description provided for @localBackupAutoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically back up a database snapshot on first launch each day'**
  String get localBackupAutoSubtitle;

  /// No description provided for @localBackupNowTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get localBackupNowTooltip;

  /// No description provided for @localBackupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup completed'**
  String get localBackupSuccess;

  /// No description provided for @localBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed. Check available storage space'**
  String get localBackupFailed;

  /// No description provided for @localBackupListHint.
  ///
  /// In en, this message translates to:
  /// **'Select a backup to restore:'**
  String get localBackupListHint;

  /// No description provided for @localBackupImportFromFile.
  ///
  /// In en, this message translates to:
  /// **'Import from file'**
  String get localBackupImportFromFile;

  /// No description provided for @localBackupImportInvalidFile.
  ///
  /// In en, this message translates to:
  /// **'Please select a .snbak backup file'**
  String get localBackupImportInvalidFile;

  /// No description provided for @localBackupListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No backups yet'**
  String get localBackupListEmpty;

  /// No description provided for @cloudCustomSupabaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Supabase'**
  String get cloudCustomSupabaseTitle;

  /// No description provided for @cloudCustomSupabaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Click to configure self-hosted Supabase'**
  String get cloudCustomSupabaseSubtitle;

  /// No description provided for @cloudCustomWebdavTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom WebDAV'**
  String get cloudCustomWebdavTitle;

  /// No description provided for @cloudCustomWebdavSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Click to configure Nutstore/Nextcloud etc.'**
  String get cloudCustomWebdavSubtitle;

  /// No description provided for @cloudCustomS3Title.
  ///
  /// In en, this message translates to:
  /// **'S3 Protocol Storage'**
  String get cloudCustomS3Title;

  /// No description provided for @cloudCustomS3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'AWS S3 / Cloudflare R2 / MinIO'**
  String get cloudCustomS3Subtitle;

  /// No description provided for @cloudTabOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get cloudTabOffline;

  /// No description provided for @cloudTabBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get cloudTabBackup;

  /// No description provided for @cloudBackupEntryLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Local backup only'**
  String get cloudBackupEntryLocalOnly;

  /// No description provided for @cloudBackupEntryFailed.
  ///
  /// In en, this message translates to:
  /// **'Last backup failed — will retry automatically'**
  String get cloudBackupEntryFailed;

  /// No description provided for @cloudBackupStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup status'**
  String get cloudBackupStatusTitle;

  /// No description provided for @cloudBackupUploadNow.
  ///
  /// In en, this message translates to:
  /// **'Upload to cloud now'**
  String get cloudBackupUploadNow;

  /// No description provided for @cloudBackupUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get cloudBackupUploading;

  /// No description provided for @cloudBackupUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Upload successful'**
  String get cloudBackupUploadSuccess;

  /// No description provided for @cloudBackupRestoreFromCloud.
  ///
  /// In en, this message translates to:
  /// **'Restore from cloud'**
  String get cloudBackupRestoreFromCloud;

  /// No description provided for @cloudBackupDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get cloudBackupDownloading;

  /// No description provided for @cloudBackupDownloadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Downloaded — opening restore page'**
  String get cloudBackupDownloadSuccess;

  /// No description provided for @cloudBackupDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed — check cloud settings and network'**
  String get cloudBackupDownloadFailed;

  /// No description provided for @cloudBackupNoRemote.
  ///
  /// In en, this message translates to:
  /// **'No cloud backup yet'**
  String get cloudBackupNoRemote;

  /// No description provided for @cloudBackupAutoSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto backup to cloud'**
  String get cloudBackupAutoSyncTitle;

  /// No description provided for @cloudBackupAutoSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sync upload to cloud during each auto backup'**
  String get cloudBackupAutoSyncSubtitle;

  /// No description provided for @localBackupRestoreHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a backup to open the restore flow'**
  String get localBackupRestoreHint;

  /// No description provided for @cloudStatusNotTested.
  ///
  /// In en, this message translates to:
  /// **'Not tested'**
  String get cloudStatusNotTested;

  /// No description provided for @cloudStatusNormal.
  ///
  /// In en, this message translates to:
  /// **'Connection normal'**
  String get cloudStatusNormal;

  /// No description provided for @cloudStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get cloudStatusFailed;

  /// No description provided for @cloudTestSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Connection normal, configuration valid'**
  String get cloudTestSuccessMessage;

  /// No description provided for @cloudTestFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get cloudTestFailedMessage;

  /// No description provided for @cloudSwitchConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch Cloud Service'**
  String get cloudSwitchConfirmTitle;

  /// No description provided for @cloudSwitchConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Switching cloud service will log out current account. Confirm switch?'**
  String get cloudSwitchConfirmMessage;

  /// No description provided for @cloudSwitchFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch Failed'**
  String get cloudSwitchFailedTitle;

  /// No description provided for @cloudSwitchFailedConfigMissing.
  ///
  /// In en, this message translates to:
  /// **'Please configure this cloud service first'**
  String get cloudSwitchFailedConfigMissing;

  /// No description provided for @cloudConfigInvalidMessage.
  ///
  /// In en, this message translates to:
  /// **'Please fill in complete information'**
  String get cloudConfigInvalidMessage;

  /// No description provided for @cloudSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save Failed'**
  String get cloudSaveFailed;

  /// No description provided for @cloudSwitchedTo.
  ///
  /// In en, this message translates to:
  /// **'Switched to {type}'**
  String cloudSwitchedTo(String type);

  /// No description provided for @cloudConfigureSupabaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Configure Supabase'**
  String get cloudConfigureSupabaseTitle;

  /// No description provided for @cloudConfigureWebdavTitle.
  ///
  /// In en, this message translates to:
  /// **'Configure WebDAV'**
  String get cloudConfigureWebdavTitle;

  /// No description provided for @cloudConfigureS3Title.
  ///
  /// In en, this message translates to:
  /// **'Configure S3'**
  String get cloudConfigureS3Title;

  /// No description provided for @welcomeHomeBookkeeping.
  ///
  /// In en, this message translates to:
  /// **'Bookkeeping'**
  String get welcomeHomeBookkeeping;

  /// No description provided for @welcomeHomeAnniversary.
  ///
  /// In en, this message translates to:
  /// **'Anniversary'**
  String get welcomeHomeAnniversary;

  /// No description provided for @welcomeHomeFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get welcomeHomeFitness;

  /// No description provided for @welcomeHomeMemo.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get welcomeHomeMemo;

  /// No description provided for @calendarToday.
  ///
  /// In en, this message translates to:
  /// **'Back to Today'**
  String get calendarToday;

  /// No description provided for @commonUncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get commonUncategorized;

  /// No description provided for @appLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Lock App'**
  String get appLockTitle;

  /// No description provided for @appLockEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable App Lock'**
  String get appLockEnable;

  /// No description provided for @appLockEnableDesc.
  ///
  /// In en, this message translates to:
  /// **'Require authentication on launch and resume'**
  String get appLockEnableDesc;

  /// No description provided for @appLockSetPin.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get appLockSetPin;

  /// No description provided for @appLockChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get appLockChangePin;

  /// No description provided for @appLockVerifyPin.
  ///
  /// In en, this message translates to:
  /// **'Verify PIN'**
  String get appLockVerifyPin;

  /// No description provided for @appLockVerifyCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Enter current PIN'**
  String get appLockVerifyCurrentPin;

  /// No description provided for @appLockSetNewPin.
  ///
  /// In en, this message translates to:
  /// **'Set new PIN'**
  String get appLockSetNewPin;

  /// No description provided for @appLockConfirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get appLockConfirmPin;

  /// No description provided for @appLockEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get appLockEnterPin;

  /// No description provided for @appLockPinSetSuccess.
  ///
  /// In en, this message translates to:
  /// **'PIN set successfully'**
  String get appLockPinSetSuccess;

  /// No description provided for @appLockDisabled.
  ///
  /// In en, this message translates to:
  /// **'App Lock disabled'**
  String get appLockDisabled;

  /// No description provided for @appLockBiometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric Unlock'**
  String get appLockBiometric;

  /// No description provided for @appLockBiometricDesc.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID or fingerprint to unlock'**
  String get appLockBiometricDesc;

  /// No description provided for @appLockBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Verify identity to unlock Sesame Notes'**
  String get appLockBiometricReason;

  /// No description provided for @appLockTimeout.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock Timeout'**
  String get appLockTimeout;

  /// No description provided for @appLockTimeoutImmediate.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get appLockTimeoutImmediate;

  /// No description provided for @appLockTimeout1Min.
  ///
  /// In en, this message translates to:
  /// **'After 1 minute'**
  String get appLockTimeout1Min;

  /// No description provided for @appLockTimeout5Min.
  ///
  /// In en, this message translates to:
  /// **'After 5 minutes'**
  String get appLockTimeout5Min;

  /// No description provided for @appLockTimeout15Min.
  ///
  /// In en, this message translates to:
  /// **'After 15 minutes'**
  String get appLockTimeout15Min;

  /// No description provided for @dayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'{day}th of each month'**
  String dayOfMonth(int day);

  /// No description provided for @sharedRoleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get sharedRoleOwner;

  /// No description provided for @sharedRoleEditor.
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get sharedRoleEditor;

  /// No description provided for @commonCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get commonCopied;

  /// No description provided for @sharedInviteFormRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get sharedInviteFormRole;

  /// No description provided for @sharedInviteFormExpiry.
  ///
  /// In en, this message translates to:
  /// **'Valid for'**
  String get sharedInviteFormExpiry;

  /// No description provided for @sharedInviteExpiryDays.
  ///
  /// In en, this message translates to:
  /// **'{n} day'**
  String sharedInviteExpiryDays(int n);

  /// No description provided for @sharedInviteGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate invite code'**
  String get sharedInviteGenerate;

  /// No description provided for @sharedInviteGenerateAnother.
  ///
  /// In en, this message translates to:
  /// **'Generate a new code'**
  String get sharedInviteGenerateAnother;

  /// No description provided for @sharedInviteCopyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get sharedInviteCopyCode;

  /// No description provided for @sharedInviteShareCode.
  ///
  /// In en, this message translates to:
  /// **'Share code'**
  String get sharedInviteShareCode;

  /// No description provided for @sharedInviteExpiresAt.
  ///
  /// In en, this message translates to:
  /// **'Expires at {dt}'**
  String sharedInviteExpiresAt(String dt);

  /// No description provided for @sharedInviteWarning.
  ///
  /// In en, this message translates to:
  /// **'Each code can be used once. Generating a new code invalidates all unused codes for this ledger.'**
  String get sharedInviteWarning;

  /// No description provided for @sharedInviteInstruction.
  ///
  /// In en, this message translates to:
  /// **'Ask the recipient to open the ledger list from the bookkeeping home screen and choose Join shared ledger. Generating a new code invalidates all previous unused codes for this ledger.'**
  String get sharedInviteInstruction;

  /// No description provided for @sharedInviteShareText.
  ///
  /// In en, this message translates to:
  /// **'I\'m inviting you to the Sesame Notes shared ledger \"{ledger}\".\n\nCode: {code}\n\nOpen Sesame Notes → Me → Join shared ledger and enter this code.'**
  String sharedInviteShareText(String ledger, String code);

  /// No description provided for @ledgerAaDescription.
  ///
  /// In en, this message translates to:
  /// **'Track each member’s share of expenses'**
  String get ledgerAaDescription;

  /// No description provided for @ledgerMemberCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String ledgerMemberCount(int count);

  /// No description provided for @ledgerOwnerDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage the ledger and members'**
  String get ledgerOwnerDescription;

  /// No description provided for @ledgerEditorDescription.
  ///
  /// In en, this message translates to:
  /// **'Record and edit together'**
  String get ledgerEditorDescription;

  /// No description provided for @ledgerInviteDescription.
  ///
  /// In en, this message translates to:
  /// **'Invite friends to “{ledger}” and keep records together.'**
  String ledgerInviteDescription(String ledger);

  /// No description provided for @ledgerInviteRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'Can view and edit records in this ledger.'**
  String get ledgerInviteRoleDescription;

  /// No description provided for @ledgerInviteMembers.
  ///
  /// In en, this message translates to:
  /// **'Invite members'**
  String get ledgerInviteMembers;

  /// No description provided for @sharedMembersStatsAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get sharedMembersStatsAllTime;

  /// No description provided for @sharedMembersStatsSummary.
  ///
  /// In en, this message translates to:
  /// **'{memberCount} payers · {txCount} expenses · {currency}'**
  String sharedMembersStatsSummary(
    int memberCount,
    int txCount,
    String currency,
  );

  /// No description provided for @sharedMembersStatsDistribution.
  ///
  /// In en, this message translates to:
  /// **'Expense distribution'**
  String get sharedMembersStatsDistribution;

  /// No description provided for @sharedMembersStatsSortHint.
  ///
  /// In en, this message translates to:
  /// **'Highest amount first'**
  String get sharedMembersStatsSortHint;

  /// No description provided for @sharedMembersStatsScopeHint.
  ///
  /// In en, this message translates to:
  /// **'Grouped by payer in the ledger currency. Records without a payer are excluded. These are actual expenses, not AA shares.'**
  String get sharedMembersStatsScopeHint;

  /// No description provided for @ledgerBasicSettings.
  ///
  /// In en, this message translates to:
  /// **'Basic settings'**
  String get ledgerBasicSettings;

  /// No description provided for @ledgerAaLabel.
  ///
  /// In en, this message translates to:
  /// **'AA splitting'**
  String get ledgerAaLabel;

  /// No description provided for @ledgerMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Ledger members'**
  String get ledgerMembersTitle;

  /// No description provided for @ledgerVirtualMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Virtual members'**
  String get ledgerVirtualMembersTitle;

  /// No description provided for @sharedMembersExpenseTotal.
  ///
  /// In en, this message translates to:
  /// **'Member expense total'**
  String get sharedMembersExpenseTotal;

  /// No description provided for @sharedMembersPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get sharedMembersPageTitle;

  /// No description provided for @ledgersLeaveAndDelete.
  ///
  /// In en, this message translates to:
  /// **'Leave and Delete'**
  String get ledgersLeaveAndDelete;

  /// No description provided for @ledgersLeaveAndDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave and Delete Ledger'**
  String get ledgersLeaveAndDeleteConfirm;

  /// No description provided for @ledgersLeaveAndDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Leave and delete the shared ledger \"{name}\"?\\nAfter leaving, the cloud removes your membership and all local data is cleared. You won\'t be able to access its transactions anymore.'**
  String ledgersLeaveAndDeleteMessage(String name);

  /// No description provided for @ledgersLeaveAndDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Left and deleted the ledger'**
  String get ledgersLeaveAndDeleteSuccess;

  /// No description provided for @ledgersDeleteShared.
  ///
  /// In en, this message translates to:
  /// **'Delete Shared Ledger'**
  String get ledgersDeleteShared;

  /// No description provided for @ledgersDeleteSharedConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Shared Ledger'**
  String get ledgersDeleteSharedConfirm;

  /// No description provided for @ledgersDeleteSharedMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete the shared ledger \"{name}\"?\\nThis also removes all collaborators and clears their local data. This cannot be undone.'**
  String ledgersDeleteSharedMessage(String name);

  /// No description provided for @ledgersDeleteSharedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Shared ledger deleted'**
  String get ledgersDeleteSharedSuccess;

  /// No description provided for @sharedMembersRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get sharedMembersRemoveTitle;

  /// No description provided for @sharedMembersRemoveCta.
  ///
  /// In en, this message translates to:
  /// **'Remove this member'**
  String get sharedMembersRemoveCta;

  /// No description provided for @sharedMembersRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}? They will immediately lose access to this ledger.'**
  String sharedMembersRemoveConfirm(String name);

  /// No description provided for @sharedMembersRemoved.
  ///
  /// In en, this message translates to:
  /// **'Member removed'**
  String get sharedMembersRemoved;

  /// No description provided for @sharedMembersRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove member. Please try again later.'**
  String get sharedMembersRemoveFailed;

  /// No description provided for @sharedMembersSaveFirst.
  ///
  /// In en, this message translates to:
  /// **'Please save the ledger first'**
  String get sharedMembersSaveFirst;

  /// No description provided for @sharedMembersLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load members'**
  String get sharedMembersLoadFailed;

  /// No description provided for @sharedMembersRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get sharedMembersRetry;

  /// No description provided for @sharedTxCreatedBy.
  ///
  /// In en, this message translates to:
  /// **'Created by {name}'**
  String sharedTxCreatedBy(String name);

  /// No description provided for @sharedTxEditedBy.
  ///
  /// In en, this message translates to:
  /// **'Last edited by {name}'**
  String sharedTxEditedBy(String name);

  /// No description provided for @sharedTxCreatedAndEditedBy.
  ///
  /// In en, this message translates to:
  /// **'Created and edited by {name}'**
  String sharedTxCreatedAndEditedBy(String name);

  /// No description provided for @sharedMembersStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Member expenses'**
  String get sharedMembersStatsTitle;

  /// No description provided for @sharedMembersStatsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get sharedMembersStatsEmpty;

  /// No description provided for @sharedMembersStatsTxCount.
  ///
  /// In en, this message translates to:
  /// **'{count} tx'**
  String sharedMembersStatsTxCount(int count);

  /// No description provided for @exchangeRatePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Exchange Rates'**
  String get exchangeRatePageTitle;

  /// No description provided for @rateSourceAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get rateSourceAuto;

  /// No description provided for @rateSourceManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get rateSourceManual;

  /// No description provided for @rateUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String rateUpdatedAt(String date);

  /// No description provided for @rateNotFetched.
  ///
  /// In en, this message translates to:
  /// **'Not fetched'**
  String get rateNotFetched;

  /// No description provided for @rateEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Rate'**
  String get rateEditTitle;

  /// No description provided for @rateInverseHint.
  ///
  /// In en, this message translates to:
  /// **'Inverse: 1 {base} ≈ {rate} {quote}'**
  String rateInverseHint(String base, String rate, String quote);

  /// No description provided for @rateResetToAuto.
  ///
  /// In en, this message translates to:
  /// **'Reset to auto'**
  String get rateResetToAuto;

  /// No description provided for @rateRefreshSuccess.
  ///
  /// In en, this message translates to:
  /// **'Rates updated'**
  String get rateRefreshSuccess;

  /// No description provided for @rateRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Fetch failed, you can set rates manually'**
  String get rateRefreshFailed;

  /// No description provided for @rateDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Source: open exchange-rate data, updated daily. Conversion is for reference only and may differ from bank rates.'**
  String get rateDisclaimer;

  /// No description provided for @txRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get txRateLabel;

  /// No description provided for @txRateMissingHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter the rate for this entry before saving'**
  String get txRateMissingHint;

  /// No description provided for @ledgerBaseCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Ledger currency'**
  String get ledgerBaseCurrencyLabel;

  /// No description provided for @statsConvertedFootnote.
  ///
  /// In en, this message translates to:
  /// **'Includes foreign currency, converted to {currency} at entry-time rates'**
  String statsConvertedFootnote(Object currency);

  /// No description provided for @ledgerCurrencyChangeRecalcHint.
  ///
  /// In en, this message translates to:
  /// **'Changing the base currency will reconvert all history at current rates'**
  String get ledgerCurrencyChangeRecalcHint;

  /// No description provided for @ledgerCurrencyChangeRecalcWarning.
  ///
  /// In en, this message translates to:
  /// **'Converted amounts of all transactions in this ledger will be recalculated at the latest rates and overwritten; switching away and back cannot restore the original values'**
  String get ledgerCurrencyChangeRecalcWarning;

  /// No description provided for @recalcForeignTxBanner.
  ///
  /// In en, this message translates to:
  /// **'Unconverted foreign-currency transactions detected in this ledger'**
  String get recalcForeignTxBanner;

  /// No description provided for @recalcForeignTxAction.
  ///
  /// In en, this message translates to:
  /// **'Reconvert at current rates'**
  String get recalcForeignTxAction;

  /// No description provided for @recalcForeignTxDone.
  ///
  /// In en, this message translates to:
  /// **'Reconverted {count} foreign-currency transactions'**
  String recalcForeignTxDone(Object count);

  /// No description provided for @txCurrencyPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select currency'**
  String get txCurrencyPickerTitle;

  /// No description provided for @txAddEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get txAddEntryTitle;

  /// No description provided for @txDeleteLongPress.
  ///
  /// In en, this message translates to:
  /// **'Hold to clear'**
  String get txDeleteLongPress;

  /// No description provided for @txSelectDateTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select date & time'**
  String get txSelectDateTimeTitle;

  /// No description provided for @txSelectDateTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe up or down to pick a value'**
  String get txSelectDateTimeHint;

  /// No description provided for @txEditCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit categories'**
  String get txEditCategory;

  /// No description provided for @txEditCategoryReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Edit categories (read-only in shared ledger)'**
  String get txEditCategoryReadOnly;

  /// No description provided for @txLedgerBaseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Ledger currency'**
  String get txLedgerBaseCurrency;

  /// No description provided for @recalcSyncCountHint.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions will be reconverted and synced'**
  String recalcSyncCountHint(Object count);

  /// No description provided for @analyticsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load data. Please try again.'**
  String get analyticsLoadFailed;

  /// No description provided for @analyticsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get analyticsRetry;

  /// No description provided for @exportCsvHeaderCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get exportCsvHeaderCurrency;

  /// No description provided for @importFieldCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get importFieldCurrency;

  /// No description provided for @currencyMOP.
  ///
  /// In en, this message translates to:
  /// **'Macau Pataca'**
  String get currencyMOP;

  /// No description provided for @currencyMNT.
  ///
  /// In en, this message translates to:
  /// **'Mongolian Tughrik'**
  String get currencyMNT;

  /// No description provided for @currencyKPW.
  ///
  /// In en, this message translates to:
  /// **'North Korean Won'**
  String get currencyKPW;

  /// No description provided for @currencyKHR.
  ///
  /// In en, this message translates to:
  /// **'Cambodian Riel'**
  String get currencyKHR;

  /// No description provided for @currencyLAK.
  ///
  /// In en, this message translates to:
  /// **'Lao Kip'**
  String get currencyLAK;

  /// No description provided for @currencyBND.
  ///
  /// In en, this message translates to:
  /// **'Bruneian Dollar'**
  String get currencyBND;

  /// No description provided for @currencyNPR.
  ///
  /// In en, this message translates to:
  /// **'Nepalese Rupee'**
  String get currencyNPR;

  /// No description provided for @currencyBTN.
  ///
  /// In en, this message translates to:
  /// **'Bhutanese Ngultrum'**
  String get currencyBTN;

  /// No description provided for @currencyMVR.
  ///
  /// In en, this message translates to:
  /// **'Maldivian Rufiyaa'**
  String get currencyMVR;

  /// No description provided for @currencyAFN.
  ///
  /// In en, this message translates to:
  /// **'Afghan Afghani'**
  String get currencyAFN;

  /// No description provided for @currencyUZS.
  ///
  /// In en, this message translates to:
  /// **'Uzbekistani Som'**
  String get currencyUZS;

  /// No description provided for @currencyTJS.
  ///
  /// In en, this message translates to:
  /// **'Tajikistani Somoni'**
  String get currencyTJS;

  /// No description provided for @currencyTMT.
  ///
  /// In en, this message translates to:
  /// **'Turkmenistani Manat'**
  String get currencyTMT;

  /// No description provided for @currencyKGS.
  ///
  /// In en, this message translates to:
  /// **'Kyrgyzstani Som'**
  String get currencyKGS;

  /// No description provided for @currencyQAR.
  ///
  /// In en, this message translates to:
  /// **'Qatari Riyal'**
  String get currencyQAR;

  /// No description provided for @currencyKWD.
  ///
  /// In en, this message translates to:
  /// **'Kuwaiti Dinar'**
  String get currencyKWD;

  /// No description provided for @currencyBHD.
  ///
  /// In en, this message translates to:
  /// **'Bahraini Dinar'**
  String get currencyBHD;

  /// No description provided for @currencyOMR.
  ///
  /// In en, this message translates to:
  /// **'Omani Rial'**
  String get currencyOMR;

  /// No description provided for @currencyJOD.
  ///
  /// In en, this message translates to:
  /// **'Jordanian Dinar'**
  String get currencyJOD;

  /// No description provided for @currencyLBP.
  ///
  /// In en, this message translates to:
  /// **'Lebanese Pound'**
  String get currencyLBP;

  /// No description provided for @currencyIQD.
  ///
  /// In en, this message translates to:
  /// **'Iraqi Dinar'**
  String get currencyIQD;

  /// No description provided for @currencyIRR.
  ///
  /// In en, this message translates to:
  /// **'Iranian Rial'**
  String get currencyIRR;

  /// No description provided for @currencyYER.
  ///
  /// In en, this message translates to:
  /// **'Yemeni Rial'**
  String get currencyYER;

  /// No description provided for @currencySYP.
  ///
  /// In en, this message translates to:
  /// **'Syrian Pound'**
  String get currencySYP;

  /// No description provided for @currencyGEL.
  ///
  /// In en, this message translates to:
  /// **'Georgian Lari'**
  String get currencyGEL;

  /// No description provided for @currencyAMD.
  ///
  /// In en, this message translates to:
  /// **'Armenian Dram'**
  String get currencyAMD;

  /// No description provided for @currencyAZN.
  ///
  /// In en, this message translates to:
  /// **'Azerbaijan Manat'**
  String get currencyAZN;

  /// No description provided for @currencyRON.
  ///
  /// In en, this message translates to:
  /// **'Romanian Leu'**
  String get currencyRON;

  /// No description provided for @currencyBGN.
  ///
  /// In en, this message translates to:
  /// **'Bulgarian Lev'**
  String get currencyBGN;

  /// No description provided for @currencyRSD.
  ///
  /// In en, this message translates to:
  /// **'Serbian Dinar'**
  String get currencyRSD;

  /// No description provided for @currencyISK.
  ///
  /// In en, this message translates to:
  /// **'Icelandic Krona'**
  String get currencyISK;

  /// No description provided for @currencyMDL.
  ///
  /// In en, this message translates to:
  /// **'Moldovan Leu'**
  String get currencyMDL;

  /// No description provided for @currencyALL.
  ///
  /// In en, this message translates to:
  /// **'Albanian Lek'**
  String get currencyALL;

  /// No description provided for @currencyMKD.
  ///
  /// In en, this message translates to:
  /// **'Macedonian Denar'**
  String get currencyMKD;

  /// No description provided for @currencyBAM.
  ///
  /// In en, this message translates to:
  /// **'Bosnian Convertible Mark'**
  String get currencyBAM;

  /// No description provided for @currencyGIP.
  ///
  /// In en, this message translates to:
  /// **'Gibraltar Pound'**
  String get currencyGIP;

  /// No description provided for @currencyGTQ.
  ///
  /// In en, this message translates to:
  /// **'Guatemalan Quetzal'**
  String get currencyGTQ;

  /// No description provided for @currencyHNL.
  ///
  /// In en, this message translates to:
  /// **'Honduran Lempira'**
  String get currencyHNL;

  /// No description provided for @currencyNIO.
  ///
  /// In en, this message translates to:
  /// **'Nicaraguan Cordoba'**
  String get currencyNIO;

  /// No description provided for @currencyCRC.
  ///
  /// In en, this message translates to:
  /// **'Costa Rican Colon'**
  String get currencyCRC;

  /// No description provided for @currencyPAB.
  ///
  /// In en, this message translates to:
  /// **'Panamanian Balboa'**
  String get currencyPAB;

  /// No description provided for @currencyDOP.
  ///
  /// In en, this message translates to:
  /// **'Dominican Peso'**
  String get currencyDOP;

  /// No description provided for @currencyCUP.
  ///
  /// In en, this message translates to:
  /// **'Cuban Peso'**
  String get currencyCUP;

  /// No description provided for @currencyJMD.
  ///
  /// In en, this message translates to:
  /// **'Jamaican Dollar'**
  String get currencyJMD;

  /// No description provided for @currencyTTD.
  ///
  /// In en, this message translates to:
  /// **'Trinidadian Dollar'**
  String get currencyTTD;

  /// No description provided for @currencyBSD.
  ///
  /// In en, this message translates to:
  /// **'Bahamian Dollar'**
  String get currencyBSD;

  /// No description provided for @currencyBBD.
  ///
  /// In en, this message translates to:
  /// **'Barbadian or Bajan Dollar'**
  String get currencyBBD;

  /// No description provided for @currencyBZD.
  ///
  /// In en, this message translates to:
  /// **'Belizean Dollar'**
  String get currencyBZD;

  /// No description provided for @currencyHTG.
  ///
  /// In en, this message translates to:
  /// **'Haitian Gourde'**
  String get currencyHTG;

  /// No description provided for @currencyKYD.
  ///
  /// In en, this message translates to:
  /// **'Caymanian Dollar'**
  String get currencyKYD;

  /// No description provided for @currencyAWG.
  ///
  /// In en, this message translates to:
  /// **'Aruban or Dutch Guilder'**
  String get currencyAWG;

  /// No description provided for @currencyBMD.
  ///
  /// In en, this message translates to:
  /// **'Bermudian Dollar'**
  String get currencyBMD;

  /// No description provided for @currencyUYU.
  ///
  /// In en, this message translates to:
  /// **'Uruguayan Peso'**
  String get currencyUYU;

  /// No description provided for @currencyPYG.
  ///
  /// In en, this message translates to:
  /// **'Paraguayan Guarani'**
  String get currencyPYG;

  /// No description provided for @currencyBOB.
  ///
  /// In en, this message translates to:
  /// **'Bolivian Bolíviano'**
  String get currencyBOB;

  /// No description provided for @currencyVES.
  ///
  /// In en, this message translates to:
  /// **'Venezuelan Bolívar'**
  String get currencyVES;

  /// No description provided for @currencyGYD.
  ///
  /// In en, this message translates to:
  /// **'Guyanese Dollar'**
  String get currencyGYD;

  /// No description provided for @currencySRD.
  ///
  /// In en, this message translates to:
  /// **'Surinamese Dollar'**
  String get currencySRD;

  /// No description provided for @currencyFJD.
  ///
  /// In en, this message translates to:
  /// **'Fijian Dollar'**
  String get currencyFJD;

  /// No description provided for @currencyPGK.
  ///
  /// In en, this message translates to:
  /// **'Papua New Guinean Kina'**
  String get currencyPGK;

  /// No description provided for @currencySBD.
  ///
  /// In en, this message translates to:
  /// **'Solomon Islander Dollar'**
  String get currencySBD;

  /// No description provided for @currencyTOP.
  ///
  /// In en, this message translates to:
  /// **'Tongan Pa\'anga'**
  String get currencyTOP;

  /// No description provided for @currencyVUV.
  ///
  /// In en, this message translates to:
  /// **'Ni-Vanuatu Vatu'**
  String get currencyVUV;

  /// No description provided for @currencyWST.
  ///
  /// In en, this message translates to:
  /// **'Samoan Tala'**
  String get currencyWST;

  /// No description provided for @currencyKES.
  ///
  /// In en, this message translates to:
  /// **'Kenyan Shilling'**
  String get currencyKES;

  /// No description provided for @currencyGHS.
  ///
  /// In en, this message translates to:
  /// **'Ghanaian Cedi'**
  String get currencyGHS;

  /// No description provided for @currencyMAD.
  ///
  /// In en, this message translates to:
  /// **'Moroccan Dirham'**
  String get currencyMAD;

  /// No description provided for @currencyDZD.
  ///
  /// In en, this message translates to:
  /// **'Algerian Dinar'**
  String get currencyDZD;

  /// No description provided for @currencyTND.
  ///
  /// In en, this message translates to:
  /// **'Tunisian Dinar'**
  String get currencyTND;

  /// No description provided for @currencyLYD.
  ///
  /// In en, this message translates to:
  /// **'Libyan Dinar'**
  String get currencyLYD;

  /// No description provided for @currencyETB.
  ///
  /// In en, this message translates to:
  /// **'Ethiopian Birr'**
  String get currencyETB;

  /// No description provided for @currencyUGX.
  ///
  /// In en, this message translates to:
  /// **'Ugandan Shilling'**
  String get currencyUGX;

  /// No description provided for @currencyTZS.
  ///
  /// In en, this message translates to:
  /// **'Tanzanian Shilling'**
  String get currencyTZS;

  /// No description provided for @currencyRWF.
  ///
  /// In en, this message translates to:
  /// **'Rwandan Franc'**
  String get currencyRWF;

  /// No description provided for @currencyMUR.
  ///
  /// In en, this message translates to:
  /// **'Mauritian Rupee'**
  String get currencyMUR;

  /// No description provided for @currencyBWP.
  ///
  /// In en, this message translates to:
  /// **'Botswana Pula'**
  String get currencyBWP;

  /// No description provided for @currencyNAD.
  ///
  /// In en, this message translates to:
  /// **'Namibian Dollar'**
  String get currencyNAD;

  /// No description provided for @currencyZMW.
  ///
  /// In en, this message translates to:
  /// **'Zambian Kwacha'**
  String get currencyZMW;

  /// No description provided for @currencyMWK.
  ///
  /// In en, this message translates to:
  /// **'Malawian Kwacha'**
  String get currencyMWK;

  /// No description provided for @currencyMZN.
  ///
  /// In en, this message translates to:
  /// **'Mozambican Metical'**
  String get currencyMZN;

  /// No description provided for @currencyAOA.
  ///
  /// In en, this message translates to:
  /// **'Angolan Kwanza'**
  String get currencyAOA;

  /// No description provided for @currencyCDF.
  ///
  /// In en, this message translates to:
  /// **'Congolese Franc'**
  String get currencyCDF;

  /// No description provided for @currencyGMD.
  ///
  /// In en, this message translates to:
  /// **'Gambian Dalasi'**
  String get currencyGMD;

  /// No description provided for @currencyGNF.
  ///
  /// In en, this message translates to:
  /// **'Guinean Franc'**
  String get currencyGNF;

  /// No description provided for @currencyLRD.
  ///
  /// In en, this message translates to:
  /// **'Liberian Dollar'**
  String get currencyLRD;

  /// No description provided for @currencySLE.
  ///
  /// In en, this message translates to:
  /// **'Sierra Leonean Leone'**
  String get currencySLE;

  /// No description provided for @currencySDG.
  ///
  /// In en, this message translates to:
  /// **'Sudanese Pound'**
  String get currencySDG;

  /// No description provided for @currencySSP.
  ///
  /// In en, this message translates to:
  /// **'South Sudanese Pound'**
  String get currencySSP;

  /// No description provided for @currencySOS.
  ///
  /// In en, this message translates to:
  /// **'Somali Shilling'**
  String get currencySOS;

  /// No description provided for @currencyDJF.
  ///
  /// In en, this message translates to:
  /// **'Djiboutian Franc'**
  String get currencyDJF;

  /// No description provided for @currencyERN.
  ///
  /// In en, this message translates to:
  /// **'Eritrean Nakfa'**
  String get currencyERN;

  /// No description provided for @currencyBIF.
  ///
  /// In en, this message translates to:
  /// **'Burundian Franc'**
  String get currencyBIF;

  /// No description provided for @currencyCVE.
  ///
  /// In en, this message translates to:
  /// **'Cape Verdean Escudo'**
  String get currencyCVE;

  /// No description provided for @currencySTN.
  ///
  /// In en, this message translates to:
  /// **'Sao Tomean Dobra'**
  String get currencySTN;

  /// No description provided for @currencySCR.
  ///
  /// In en, this message translates to:
  /// **'Seychellois Rupee'**
  String get currencySCR;

  /// No description provided for @currencyKMF.
  ///
  /// In en, this message translates to:
  /// **'Comorian Franc'**
  String get currencyKMF;

  /// No description provided for @currencyLSL.
  ///
  /// In en, this message translates to:
  /// **'Basotho Loti'**
  String get currencyLSL;

  /// No description provided for @currencySZL.
  ///
  /// In en, this message translates to:
  /// **'Swazi Lilangeni'**
  String get currencySZL;

  /// No description provided for @currencyMGA.
  ///
  /// In en, this message translates to:
  /// **'Malagasy Ariary'**
  String get currencyMGA;

  /// No description provided for @currencyMRU.
  ///
  /// In en, this message translates to:
  /// **'Mauritanian Ouguiya'**
  String get currencyMRU;

  /// No description provided for @detailImportExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Import/Export'**
  String get detailImportExportTitle;

  /// No description provided for @detailImportExportImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get detailImportExportImportTitle;

  /// No description provided for @detailImportExportImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a domain and destination, then review the file'**
  String get detailImportExportImportSubtitle;

  /// No description provided for @detailImportExportExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get detailImportExportExportTitle;

  /// No description provided for @detailImportExportExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select domains and sources to export all content'**
  String get detailImportExportExportSubtitle;

  /// No description provided for @detailImportExportImportPoint1.
  ///
  /// In en, this message translates to:
  /// **'Select a domain and destination book or fitness space, then choose and review a file.'**
  String get detailImportExportImportPoint1;

  /// No description provided for @detailImportExportImportPoint2.
  ///
  /// In en, this message translates to:
  /// **'Import CSV, TSV, TXT, XLSX or JSON. All data types support editable field mapping, record selection and import progress; no file version or application identifier is required.'**
  String get detailImportExportImportPoint2;

  /// No description provided for @detailImportExportImportPoint3.
  ///
  /// In en, this message translates to:
  /// **'Reimporting the same file skips imported records. Review and select records before importing. Fitness plans can be imported from tables; importing preferences replaces the destination preferences.'**
  String get detailImportExportImportPoint3;

  /// No description provided for @detailImportExportExportPoint1.
  ///
  /// In en, this message translates to:
  /// **'All four domains are selected by default. Choose one book or fitness space per domain to export its complete content.'**
  String get detailImportExportExportPoint1;

  /// No description provided for @detailImportExportExportPoint2.
  ///
  /// In en, this message translates to:
  /// **'Bookkeeping exports all transactions, anniversaries all events, and memos all entries. Fitness exports all workouts, plans, templates and fitness preferences in the space, including timer state.'**
  String get detailImportExportExportPoint2;

  /// No description provided for @detailImportExportExportPoint3.
  ///
  /// In en, this message translates to:
  /// **'Accounting and days export as CSV; memos and complete fitness data export as JSON. Save or share separate files through the system panel.'**
  String get detailImportExportExportPoint3;

  /// No description provided for @detailExportAction.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get detailExportAction;

  /// No description provided for @exchangeRateCurrentLedger.
  ///
  /// In en, this message translates to:
  /// **'Current ledger: {name}'**
  String exchangeRateCurrentLedger(Object name);

  /// No description provided for @exchangeRateInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'About Ledger Currency'**
  String get exchangeRateInfoTitle;

  /// No description provided for @exchangeRateInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'The ledger currency is the base currency of the current ledger: foreign-currency transactions in this ledger are converted into it at exchange rates, so totals can be compared directly in statistics and asset overviews. Each ledger has its own ledger currency and you can switch it at any time; switching recalculates converted amounts for all transactions in this ledger at the latest rates.\n\nRates are fetched automatically from public data sources on a daily basis. You can also tap \"Edit\" for any currency in the list below to set a manual rate — it overrides the automatic data and takes effect immediately.'**
  String get exchangeRateInfoMessage;

  /// No description provided for @rateEditLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get rateEditLabel;

  /// No description provided for @rateInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid rate (a number greater than 0)'**
  String get rateInvalidInput;

  /// No description provided for @currencyManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Displayed Currencies'**
  String get currencyManageTitle;

  /// No description provided for @currencyManageEntry.
  ///
  /// In en, this message translates to:
  /// **'Currency Management'**
  String get currencyManageEntry;

  /// No description provided for @currencyManageCount.
  ///
  /// In en, this message translates to:
  /// **'{count} currencies selected'**
  String currencyManageCount(Object count);

  /// No description provided for @currencyManageBaseLocked.
  ///
  /// In en, this message translates to:
  /// **'Ledger base currency (cannot be hidden)'**
  String get currencyManageBaseLocked;

  /// No description provided for @currencyManageHint.
  ///
  /// In en, this message translates to:
  /// **'Hiding a currency does not affect existing transactions; you can re-enable it here at any time.'**
  String get currencyManageHint;

  /// No description provided for @detailImportExportMigrateTitle.
  ///
  /// In en, this message translates to:
  /// **'Migration'**
  String get detailImportExportMigrateTitle;

  /// No description provided for @detailImportExportMigrateTip.
  ///
  /// In en, this message translates to:
  /// **'Export and import into another book or fitness space. Use the management page to copy or move between local and cloud storage.'**
  String get detailImportExportMigrateTip;

  /// No description provided for @ledgerMetaReadOnlyToast.
  ///
  /// In en, this message translates to:
  /// **'Collaborators cannot modify ledger settings.'**
  String get ledgerMetaReadOnlyToast;

  /// No description provided for @aaStatisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'AA Statistics'**
  String get aaStatisticsTitle;

  /// No description provided for @aaStatisticsTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total shared'**
  String get aaStatisticsTotalAmount;

  /// No description provided for @aaStatisticsPerPerson.
  ///
  /// In en, this message translates to:
  /// **'Split details'**
  String get aaStatisticsPerPerson;

  /// No description provided for @aaStatisticsPaid.
  ///
  /// In en, this message translates to:
  /// **'Split paid'**
  String get aaStatisticsPaid;

  /// No description provided for @aaStatisticsPaidAll.
  ///
  /// In en, this message translates to:
  /// **'Total paid'**
  String get aaStatisticsPaidAll;

  /// No description provided for @aaStatisticsShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get aaStatisticsShare;

  /// No description provided for @aaStatisticsNet.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get aaStatisticsNet;

  /// No description provided for @aaStatisticsNetReceive.
  ///
  /// In en, this message translates to:
  /// **'to receive'**
  String get aaStatisticsNetReceive;

  /// No description provided for @aaStatisticsNetPay.
  ///
  /// In en, this message translates to:
  /// **'to pay'**
  String get aaStatisticsNetPay;

  /// No description provided for @aaStatisticsTransferPlan.
  ///
  /// In en, this message translates to:
  /// **'Settlement plan'**
  String get aaStatisticsTransferPlan;

  /// No description provided for @aaStatisticsTransferSeparator.
  ///
  /// In en, this message translates to:
  /// **'pays'**
  String get aaStatisticsTransferSeparator;

  /// No description provided for @aaStatisticsNoTransfers.
  ///
  /// In en, this message translates to:
  /// **'All settled up'**
  String get aaStatisticsNoTransfers;

  /// No description provided for @aaStatisticsExcluded.
  ///
  /// In en, this message translates to:
  /// **'No split'**
  String get aaStatisticsExcluded;

  /// No description provided for @aaStatisticsParticipantCount.
  ///
  /// In en, this message translates to:
  /// **'{count} participants'**
  String aaStatisticsParticipantCount(int count);

  /// No description provided for @aaStatisticsExcludedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No no-split transactions'**
  String get aaStatisticsExcludedEmpty;

  /// No description provided for @aaStatisticsViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get aaStatisticsViewDetails;

  /// No description provided for @aaStatisticsBillSummary.
  ///
  /// In en, this message translates to:
  /// **'Bill summary'**
  String get aaStatisticsBillSummary;

  /// No description provided for @aaStatisticsNetReceiveAmount.
  ///
  /// In en, this message translates to:
  /// **'To receive'**
  String get aaStatisticsNetReceiveAmount;

  /// No description provided for @aaStatisticsNetPayAmount.
  ///
  /// In en, this message translates to:
  /// **'To pay'**
  String get aaStatisticsNetPayAmount;

  /// No description provided for @aaStatisticsSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get aaStatisticsSettled;

  /// No description provided for @aaStatisticsModePerPerson.
  ///
  /// In en, this message translates to:
  /// **'Split equally'**
  String get aaStatisticsModePerPerson;

  /// No description provided for @aaStatisticsModeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom amount'**
  String get aaStatisticsModeCustom;

  /// No description provided for @aaStatisticsSplitDetail.
  ///
  /// In en, this message translates to:
  /// **'Split details'**
  String get aaStatisticsSplitDetail;

  /// No description provided for @aaStatisticsPayerPrefix.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get aaStatisticsPayerPrefix;

  /// No description provided for @aaStatisticsMemberTxEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bills for this member'**
  String get aaStatisticsMemberTxEmpty;

  /// No description provided for @aaEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit split'**
  String get aaEditTitle;

  /// No description provided for @aaEditSplitButton.
  ///
  /// In en, this message translates to:
  /// **'Edit split'**
  String get aaEditSplitButton;

  /// No description provided for @aaPayer.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get aaPayer;

  /// No description provided for @aaSplitMode.
  ///
  /// In en, this message translates to:
  /// **'Split method'**
  String get aaSplitMode;

  /// No description provided for @aaParticipants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get aaParticipants;

  /// No description provided for @aaModePerPerson.
  ///
  /// In en, this message translates to:
  /// **'Split equally'**
  String get aaModePerPerson;

  /// No description provided for @aaModeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom split'**
  String get aaModeCustom;

  /// No description provided for @aaModeNoSplit.
  ///
  /// In en, this message translates to:
  /// **'No split'**
  String get aaModeNoSplit;

  /// No description provided for @aaParticipantsAll.
  ///
  /// In en, this message translates to:
  /// **'All members'**
  String get aaParticipantsAll;

  /// No description provided for @aaParticipantsUnit.
  ///
  /// In en, this message translates to:
  /// **''**
  String get aaParticipantsUnit;

  /// No description provided for @aaVirtualUserNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a nickname'**
  String get aaVirtualUserNameHint;

  /// No description provided for @aaVirtualUserDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String aaVirtualUserDeleteConfirm(String name);

  /// No description provided for @aaVirtualUserInUse.
  ///
  /// In en, this message translates to:
  /// **'Has related transactions and cannot be deleted'**
  String get aaVirtualUserInUse;

  /// No description provided for @aaVirtualUserDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Virtual User {index}'**
  String aaVirtualUserDefaultName(int index);

  /// No description provided for @aaUnknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get aaUnknownUser;

  /// No description provided for @ledgerAaStatisticsEntry.
  ///
  /// In en, this message translates to:
  /// **'AA Statistics'**
  String get ledgerAaStatisticsEntry;

  /// No description provided for @aaNoParticipants.
  ///
  /// In en, this message translates to:
  /// **'Add participants first'**
  String get aaNoParticipants;

  /// No description provided for @aaSplitAmountIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount for every participant'**
  String get aaSplitAmountIncomplete;

  /// No description provided for @restoreStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Backup Contents'**
  String get restoreStep2Title;

  /// No description provided for @restoreApply.
  ///
  /// In en, this message translates to:
  /// **'Restore Now'**
  String get restoreApply;

  /// No description provided for @restoreApplying.
  ///
  /// In en, this message translates to:
  /// **'Applying...'**
  String get restoreApplying;

  /// No description provided for @restoreDone.
  ///
  /// In en, this message translates to:
  /// **'Restore Complete'**
  String get restoreDone;

  /// No description provided for @restoreOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Cannot open backup: file is corrupted or not a backup'**
  String get restoreOpenFailed;

  /// No description provided for @restoreApplyFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed; nothing was changed (rolled back)'**
  String get restoreApplyFailed;

  /// No description provided for @restoreCloudForkHint.
  ///
  /// In en, this message translates to:
  /// **'This is a cloud ledger from a different account; it will be restored as a local copy'**
  String get restoreCloudForkHint;

  /// No description provided for @restoreFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Backup file not found'**
  String get restoreFileNotFound;

  /// No description provided for @restoreSectionLocal.
  ///
  /// In en, this message translates to:
  /// **'Local Ledgers'**
  String get restoreSectionLocal;

  /// No description provided for @restoreSectionCloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud Ledgers'**
  String get restoreSectionCloud;

  /// No description provided for @restoreMemberCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String restoreMemberCount(int count);

  /// No description provided for @restoreConflictWarning.
  ///
  /// In en, this message translates to:
  /// **'{count} open conflicts (restore uses backup-time state)'**
  String restoreConflictWarning(int count);

  /// No description provided for @restoreSchemaUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Unsupported backup schema. Choose a backup created by the current version'**
  String get restoreSchemaUnsupported;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your Sesame Notes account'**
  String get authWelcomeSubtitle;

  /// No description provided for @authPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get authPhone;

  /// No description provided for @authPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get authPhoneHint;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get authPasswordHint;

  /// No description provided for @authRegisterPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Set a login password'**
  String get authRegisterPasswordHint;

  /// No description provided for @authConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password again'**
  String get authConfirmPasswordHint;

  /// No description provided for @authPasswordShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get authPasswordShow;

  /// No description provided for @authPasswordHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get authPasswordHide;

  /// No description provided for @authRegionSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Select country code'**
  String get authRegionSheetTitle;

  /// No description provided for @authRegionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get authRegionCancel;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account? Register now'**
  String get authNoAccount;

  /// No description provided for @authInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get authInvalidPhone;

  /// No description provided for @authInvalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get authInvalidPassword;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authPasswordMismatch;

  /// No description provided for @authErrorPhoneAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Phone number already registered'**
  String get authErrorPhoneAlreadyRegistered;

  /// No description provided for @authErrorServer.
  ///
  /// In en, this message translates to:
  /// **'Service unavailable, please try again later'**
  String get authErrorServer;

  /// No description provided for @authErrorOther.
  ///
  /// In en, this message translates to:
  /// **'Operation failed, please try again later'**
  String get authErrorOther;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Have an account? Sign in'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegister;

  /// No description provided for @mineLocalName.
  ///
  /// In en, this message translates to:
  /// **'Local Sesame'**
  String get mineLocalName;

  /// No description provided for @mineLocalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Local only · Not signed in'**
  String get mineLocalSubtitle;

  /// No description provided for @mineLoginRegister.
  ///
  /// In en, this message translates to:
  /// **'Sign in / Register'**
  String get mineLoginRegister;

  /// No description provided for @mineLoginValue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to use cloud ledgers and sharing'**
  String get mineLoginValue;

  /// No description provided for @mineSesameNumber.
  ///
  /// In en, this message translates to:
  /// **'Sesame number {number}'**
  String mineSesameNumber(String number);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileNickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get profileNickname;

  /// No description provided for @profileSesameNumber.
  ///
  /// In en, this message translates to:
  /// **'Sesame number'**
  String get profileSesameNumber;

  /// No description provided for @profileGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profileGender;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhone;

  /// No description provided for @profileGenderUnset.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get profileGenderUnset;

  /// No description provided for @profileGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get profileGenderMale;

  /// No description provided for @profileGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get profileGenderFemale;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePassword;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileLogout;

  /// No description provided for @profileLogoutHint.
  ///
  /// In en, this message translates to:
  /// **'Signing out keeps all local books on this device. Cloud books remain in your account and can be synced after you sign in again.'**
  String get profileLogoutHint;

  /// No description provided for @profileLogoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileLogoutConfirmTitle;

  /// No description provided for @profileLogoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get profileLogoutConfirmMessage;

  /// No description provided for @profileLogoutPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsynced changes'**
  String get profileLogoutPendingTitle;

  /// No description provided for @profileLogoutPendingMessage.
  ///
  /// In en, this message translates to:
  /// **'These cloud books contain unsynced changes. “Keep local copies” copies the affected books to this device first. Unconfirmed category changes stay with this account so you can continue after signing in again.'**
  String get profileLogoutPendingMessage;

  /// No description provided for @profileLogoutSyncFirst.
  ///
  /// In en, this message translates to:
  /// **'Sync first'**
  String get profileLogoutSyncFirst;

  /// No description provided for @profileLogoutKeepLocalCopy.
  ///
  /// In en, this message translates to:
  /// **'Keep local copy and sign out'**
  String get profileLogoutKeepLocalCopy;

  /// No description provided for @profileBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic info'**
  String get profileBasicInfo;

  /// No description provided for @profileAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account info'**
  String get profileAccountInfo;

  /// No description provided for @editNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit nickname'**
  String get editNameTitle;

  /// No description provided for @editNameSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get editNameSave;

  /// No description provided for @editNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nickname cannot be empty'**
  String get editNameEmpty;

  /// No description provided for @editNameHint.
  ///
  /// In en, this message translates to:
  /// **'Nicknames do not need to be unique. Chinese, English, numbers, and Emoji are supported.'**
  String get editNameHint;

  /// No description provided for @editNameClear.
  ///
  /// In en, this message translates to:
  /// **'Clear nickname'**
  String get editNameClear;

  /// No description provided for @editNameSaved.
  ///
  /// In en, this message translates to:
  /// **'Nickname saved'**
  String get editNameSaved;

  /// No description provided for @editNameSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed, try again later'**
  String get editNameSaveFailed;

  /// No description provided for @editGenderTitle.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get editGenderTitle;

  /// No description provided for @editGenderSaved.
  ///
  /// In en, this message translates to:
  /// **'Gender saved'**
  String get editGenderSaved;

  /// No description provided for @editGenderPrivacyHint.
  ///
  /// In en, this message translates to:
  /// **'Your gender is visible only to you and is not shown to other shared ledger members.'**
  String get editGenderPrivacyHint;

  /// No description provided for @avatarPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get avatarPreviewTitle;

  /// No description provided for @avatarClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get avatarClose;

  /// No description provided for @avatarFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get avatarFromGallery;

  /// No description provided for @avatarRestoreDefault.
  ///
  /// In en, this message translates to:
  /// **'Restore default avatar'**
  String get avatarRestoreDefault;

  /// No description provided for @avatarUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Avatar upload failed, try again later'**
  String get avatarUploadFailed;

  /// No description provided for @avatarRestored.
  ///
  /// In en, this message translates to:
  /// **'Default avatar restored'**
  String get avatarRestored;

  /// No description provided for @avatarTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image too large, choose a smaller one'**
  String get avatarTooLarge;

  /// No description provided for @avatarInvalid.
  ///
  /// In en, this message translates to:
  /// **'Cannot recognize the image, choose another one'**
  String get avatarInvalid;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get changePasswordCurrent;

  /// No description provided for @changePasswordCurrentHint.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get changePasswordCurrentHint;

  /// No description provided for @changePasswordNew.
  ///
  /// In en, this message translates to:
  /// **'Add password'**
  String get changePasswordNew;

  /// No description provided for @changePasswordNewHint.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get changePasswordNewHint;

  /// No description provided for @changePasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get changePasswordConfirm;

  /// No description provided for @changePasswordConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the new password again'**
  String get changePasswordConfirmHint;

  /// No description provided for @changePasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Use up to 128 characters. Other devices will be signed out after the change; this device stays signed in.'**
  String get changePasswordHint;

  /// No description provided for @changePasswordNewRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password'**
  String get changePasswordNewRequired;

  /// No description provided for @changePasswordTooLong.
  ///
  /// In en, this message translates to:
  /// **'Use no more than 128 characters'**
  String get changePasswordTooLong;

  /// No description provided for @changePasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Add passwords do not match'**
  String get changePasswordMismatch;

  /// No description provided for @changePasswordCurrentInvalid.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get changePasswordCurrentInvalid;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get changePasswordSuccess;

  /// No description provided for @changePasswordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get changePasswordSubmit;

  /// No description provided for @changePasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Change failed, try again later'**
  String get changePasswordFailed;

  /// No description provided for @daysTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get daysTools;

  /// No description provided for @dayBooksTitle.
  ///
  /// In en, this message translates to:
  /// **'Anniversary books'**
  String get dayBooksTitle;

  /// No description provided for @dayBookNew.
  ///
  /// In en, this message translates to:
  /// **'Add anniversary book'**
  String get dayBookNew;

  /// No description provided for @dayBookEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit anniversary book'**
  String get dayBookEdit;

  /// No description provided for @dayBookEmpty.
  ///
  /// In en, this message translates to:
  /// **'No anniversary books yet'**
  String get dayBookEmpty;

  /// No description provided for @dayEventsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No anniversaries yet'**
  String get dayEventsEmpty;

  /// No description provided for @dayNoNext.
  ///
  /// In en, this message translates to:
  /// **'No next date within the supported range'**
  String get dayNoNext;

  /// No description provided for @dayBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get dayBirthday;

  /// No description provided for @dayAnniversary.
  ///
  /// In en, this message translates to:
  /// **'Anniversary'**
  String get dayAnniversary;

  /// No description provided for @dayCountdown.
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get dayCountdown;

  /// No description provided for @dayStage.
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get dayStage;

  /// No description provided for @dayAdd.
  ///
  /// In en, this message translates to:
  /// **'Add anniversary'**
  String get dayAdd;

  /// No description provided for @dayEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit anniversary'**
  String get dayEdit;

  /// No description provided for @dayName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get dayName;

  /// No description provided for @dayDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dayDate;

  /// No description provided for @dayBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dayBirthDate;

  /// No description provided for @dayStart.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get dayStart;

  /// No description provided for @dayEnd.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get dayEnd;

  /// No description provided for @dayNextDate.
  ///
  /// In en, this message translates to:
  /// **'Next time'**
  String get dayNextDate;

  /// No description provided for @daySolar.
  ///
  /// In en, this message translates to:
  /// **'Solar'**
  String get daySolar;

  /// No description provided for @dayLunar.
  ///
  /// In en, this message translates to:
  /// **'Lunar'**
  String get dayLunar;

  /// No description provided for @dayLeapMonth.
  ///
  /// In en, this message translates to:
  /// **'Leap month'**
  String get dayLeapMonth;

  /// No description provided for @dayRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get dayRepeat;

  /// No description provided for @dayNoRepeat.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get dayNoRepeat;

  /// No description provided for @dayYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get dayYearly;

  /// No description provided for @dayFixedDate.
  ///
  /// In en, this message translates to:
  /// **'Fixed date'**
  String get dayFixedDate;

  /// No description provided for @dayIntervalDays.
  ///
  /// In en, this message translates to:
  /// **'Count X days'**
  String get dayIntervalDays;

  /// No description provided for @dayStatistic.
  ///
  /// In en, this message translates to:
  /// **'Display as'**
  String get dayStatistic;

  /// No description provided for @dayAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get dayAge;

  /// No description provided for @dayYears.
  ///
  /// In en, this message translates to:
  /// **'Years / months / days'**
  String get dayYears;

  /// No description provided for @dayDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get dayDays;

  /// No description provided for @dayToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dayToday;

  /// No description provided for @daySaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Try again.'**
  String get daySaveFailed;

  /// No description provided for @dayInvalid.
  ///
  /// In en, this message translates to:
  /// **'Check the name, dates and repeat settings.'**
  String get dayInvalid;

  /// No description provided for @dayRecordInvalid.
  ///
  /// In en, this message translates to:
  /// **'This record has invalid date data. Select and confirm the dates again.'**
  String get dayRecordInvalid;

  /// No description provided for @dayDateOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'The result is outside the supported range: {first} to {last}'**
  String dayDateOutOfRange(String first, String last);

  /// No description provided for @dayTargetUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This anniversary book is unavailable. Keep your input and try again.'**
  String get dayTargetUnavailable;

  /// No description provided for @dayDifference.
  ///
  /// In en, this message translates to:
  /// **'Date interval'**
  String get dayDifference;

  /// No description provided for @dayOffset.
  ///
  /// In en, this message translates to:
  /// **'Date offset'**
  String get dayOffset;

  /// No description provided for @dayHolidays.
  ///
  /// In en, this message translates to:
  /// **'Holidays'**
  String get dayHolidays;

  /// No description provided for @dayLocal.
  ///
  /// In en, this message translates to:
  /// **'Local anniversary book'**
  String get dayLocal;

  /// No description provided for @dayCloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud anniversary book'**
  String get dayCloud;

  /// No description provided for @dayBookPending.
  ///
  /// In en, this message translates to:
  /// **'Pending sync'**
  String get dayBookPending;

  /// No description provided for @dayBookStale.
  ///
  /// In en, this message translates to:
  /// **'Sync binding expired'**
  String get dayBookStale;

  /// No description provided for @dayDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayDay;

  /// No description provided for @dayCalculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get dayCalculate;

  /// No description provided for @dayRemaining.
  ///
  /// In en, this message translates to:
  /// **'In {count} days'**
  String dayRemaining(int count);

  /// No description provided for @dayElapsed.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String dayElapsed(int count);

  /// No description provided for @dayAgeValue.
  ///
  /// In en, this message translates to:
  /// **'Age {count}'**
  String dayAgeValue(int count);

  /// No description provided for @dayDeleteEvent.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String dayDeleteEvent(String name);

  /// No description provided for @dayDeleteBook.
  ///
  /// In en, this message translates to:
  /// **'Delete anniversary book “{name}” and its {count} anniversaries?'**
  String dayDeleteBook(String name, int count);

  /// No description provided for @dayCloudDeleteHint.
  ///
  /// In en, this message translates to:
  /// **'Deletion syncs to your other devices'**
  String get dayCloudDeleteHint;

  /// No description provided for @dayNewYear.
  ///
  /// In en, this message translates to:
  /// **'Add Year\'s Day'**
  String get dayNewYear;

  /// No description provided for @dayLabour.
  ///
  /// In en, this message translates to:
  /// **'Labour Day'**
  String get dayLabour;

  /// No description provided for @dayNational.
  ///
  /// In en, this message translates to:
  /// **'National Day'**
  String get dayNational;

  /// No description provided for @daySpring.
  ///
  /// In en, this message translates to:
  /// **'Spring Festival'**
  String get daySpring;

  /// No description provided for @dayLantern.
  ///
  /// In en, this message translates to:
  /// **'Lantern Festival'**
  String get dayLantern;

  /// No description provided for @dayDragonBoat.
  ///
  /// In en, this message translates to:
  /// **'Dragon Boat Festival'**
  String get dayDragonBoat;

  /// No description provided for @dayQixi.
  ///
  /// In en, this message translates to:
  /// **'Qixi'**
  String get dayQixi;

  /// No description provided for @dayMidAutumn.
  ///
  /// In en, this message translates to:
  /// **'Mid-Autumn Festival'**
  String get dayMidAutumn;

  /// No description provided for @dayDoubleNinth.
  ///
  /// In en, this message translates to:
  /// **'Double Ninth Festival'**
  String get dayDoubleNinth;

  /// No description provided for @dayNewYearsEve.
  ///
  /// In en, this message translates to:
  /// **'Lunar New Year\'s Eve'**
  String get dayNewYearsEve;

  /// No description provided for @dayQingming.
  ///
  /// In en, this message translates to:
  /// **'Qingming'**
  String get dayQingming;

  /// No description provided for @commonPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get commonPrevious;

  /// No description provided for @dayBackupSection.
  ///
  /// In en, this message translates to:
  /// **'Anniversaries'**
  String get dayBackupSection;

  /// No description provided for @dayCsvImportSummary.
  ///
  /// In en, this message translates to:
  /// **'Import preview'**
  String get dayCsvImportSummary;

  /// No description provided for @dayDefaultBookName.
  ///
  /// In en, this message translates to:
  /// **'Default anniversaries'**
  String get dayDefaultBookName;

  /// No description provided for @dayExportSection.
  ///
  /// In en, this message translates to:
  /// **'Export anniversaries'**
  String get dayExportSection;

  /// No description provided for @exportSelectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Select at least one section'**
  String get exportSelectAtLeastOne;

  /// No description provided for @importContentDays.
  ///
  /// In en, this message translates to:
  /// **'Anniversaries'**
  String get importContentDays;

  /// No description provided for @importContentLedger.
  ///
  /// In en, this message translates to:
  /// **'Bookkeeping'**
  String get importContentLedger;

  /// No description provided for @importContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose import content'**
  String get importContentTitle;

  /// No description provided for @ledgerExportSection.
  ///
  /// In en, this message translates to:
  /// **'Export bookkeeping'**
  String get ledgerExportSection;

  /// No description provided for @daySyncPending.
  ///
  /// In en, this message translates to:
  /// **'{count} pending changes'**
  String daySyncPending(int count);

  /// No description provided for @daySyncRejected.
  ///
  /// In en, this message translates to:
  /// **'{count} changes need correction'**
  String daySyncRejected(int count);

  /// No description provided for @daySyncConflicts.
  ///
  /// In en, this message translates to:
  /// **'{count} sync conflicts'**
  String daySyncConflicts(int count);

  /// No description provided for @dayRestorePending.
  ///
  /// In en, this message translates to:
  /// **'Local restore is complete. Selected cloud books are being restored'**
  String get dayRestorePending;

  /// No description provided for @shareHandedToSystem.
  ///
  /// In en, this message translates to:
  /// **'Files were handed to system sharing. Confirm they were saved in the destination app'**
  String get shareHandedToSystem;

  /// No description provided for @startupDatabaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to open current data'**
  String get startupDatabaseTitle;

  /// No description provided for @startupDatabaseMessage.
  ///
  /// In en, this message translates to:
  /// **'The data structure does not match this version, or the database cannot currently be read. Keep the original database file, restore from a compatible backup, and restart. The app will not automatically erase or change the original file.'**
  String get startupDatabaseMessage;

  /// No description provided for @dayCachedExportWarning.
  ///
  /// In en, this message translates to:
  /// **'This cloud book has unfinished sync or a sync error, so its content may not be current. Export the content already on this device?'**
  String get dayCachedExportWarning;

  /// No description provided for @dayType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get dayType;

  /// No description provided for @dayUpcomingTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming anniversaries'**
  String get dayUpcomingTitle;

  /// No description provided for @dayAnniversaryValue.
  ///
  /// In en, this message translates to:
  /// **'{count} years'**
  String dayAnniversaryValue(int count);

  /// No description provided for @dayDaysValue.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String dayDaysValue(int count);

  /// No description provided for @dayRemainingDuration.
  ///
  /// In en, this message translates to:
  /// **'In {duration}'**
  String dayRemainingDuration(String duration);

  /// No description provided for @dayElapsedDuration.
  ///
  /// In en, this message translates to:
  /// **'{duration} ago'**
  String dayElapsedDuration(String duration);

  /// No description provided for @dayTotalDuration.
  ///
  /// In en, this message translates to:
  /// **'{duration} in total'**
  String dayTotalDuration(String duration);

  /// No description provided for @dayYearsValue.
  ///
  /// In en, this message translates to:
  /// **'{count} years'**
  String dayYearsValue(int count);

  /// No description provided for @dayMonthsValue.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String dayMonthsValue(int count);

  /// No description provided for @dayRepeatQuestion.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get dayRepeatQuestion;

  /// No description provided for @dayCalculationResult.
  ///
  /// In en, this message translates to:
  /// **'Result:'**
  String get dayCalculationResult;

  /// No description provided for @dayOffsetBefore.
  ///
  /// In en, this message translates to:
  /// **'{count} days before'**
  String dayOffsetBefore(int count);

  /// No description provided for @dayOffsetAfter.
  ///
  /// In en, this message translates to:
  /// **'{count} days after'**
  String dayOffsetAfter(int count);

  /// No description provided for @dayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter an event name'**
  String get dayNameHint;

  /// No description provided for @dayDaysHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a number of days'**
  String get dayDaysHint;

  /// No description provided for @dayDifferenceFullSpan.
  ///
  /// In en, this message translates to:
  /// **'Difference: {years} years {months} months {days} days'**
  String dayDifferenceFullSpan(int years, int months, int days);

  /// No description provided for @dayDifferenceTotalDays.
  ///
  /// In en, this message translates to:
  /// **'Difference: {days} days'**
  String dayDifferenceTotalDays(int days);

  /// No description provided for @memosTab.
  ///
  /// In en, this message translates to:
  /// **'Memos'**
  String get memosTab;

  /// No description provided for @memoNormal.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get memoNormal;

  /// No description provided for @memoCredentials.
  ///
  /// In en, this message translates to:
  /// **'Accounts and passwords'**
  String get memoCredentials;

  /// No description provided for @memoEditCard.
  ///
  /// In en, this message translates to:
  /// **'Edit account and password'**
  String get memoEditCard;

  /// No description provided for @memoName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get memoName;

  /// No description provided for @memoEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get memoEnterName;

  /// No description provided for @memoDefaultBookName.
  ///
  /// In en, this message translates to:
  /// **'Default memos'**
  String get memoDefaultBookName;

  /// No description provided for @memoBooks.
  ///
  /// In en, this message translates to:
  /// **'Memo books'**
  String get memoBooks;

  /// No description provided for @memoBooksManagement.
  ///
  /// In en, this message translates to:
  /// **'Manage memo books'**
  String get memoBooksManagement;

  /// No description provided for @memoBookType.
  ///
  /// In en, this message translates to:
  /// **'Memo book type'**
  String get memoBookType;

  /// No description provided for @memoCreateBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Add book'**
  String get memoCreateBookTitle;

  /// No description provided for @memoStorageLocal.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get memoStorageLocal;

  /// No description provided for @memoStorageCloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud'**
  String get memoStorageCloud;

  /// No description provided for @memoBookName.
  ///
  /// In en, this message translates to:
  /// **'Memo book name'**
  String get memoBookName;

  /// No description provided for @memoRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get memoRename;

  /// No description provided for @memoNoBooks.
  ///
  /// In en, this message translates to:
  /// **'Add a book to get started'**
  String get memoNoBooks;

  /// No description provided for @memoNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get memoNoEntries;

  /// No description provided for @memoNoSearchResult.
  ///
  /// In en, this message translates to:
  /// **'No matching accounts'**
  String get memoNoSearchResult;

  /// No description provided for @memoUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled note'**
  String get memoUntitled;

  /// No description provided for @memoNewNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get memoNewNote;

  /// No description provided for @memoNewCard.
  ///
  /// In en, this message translates to:
  /// **'Add account and password'**
  String get memoNewCard;

  /// No description provided for @memoCredentialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts and passwords'**
  String get memoCredentialsTitle;

  /// No description provided for @memoAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get memoAccount;

  /// No description provided for @memoPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get memoPassword;

  /// No description provided for @memoFieldIndex.
  ///
  /// In en, this message translates to:
  /// **'Field {index}'**
  String memoFieldIndex(int index);

  /// No description provided for @memoFieldName.
  ///
  /// In en, this message translates to:
  /// **'Field name'**
  String get memoFieldName;

  /// No description provided for @memoFieldValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get memoFieldValue;

  /// No description provided for @memoAddField.
  ///
  /// In en, this message translates to:
  /// **'Add field'**
  String get memoAddField;

  /// No description provided for @memoRemoveField.
  ///
  /// In en, this message translates to:
  /// **'Remove field'**
  String get memoRemoveField;

  /// No description provided for @memoNewField.
  ///
  /// In en, this message translates to:
  /// **'Add field'**
  String get memoNewField;

  /// No description provided for @memoFieldNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name the field before filling in a value'**
  String get memoFieldNameRequired;

  /// No description provided for @memoCardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Fill in a name or at least one field'**
  String get memoCardEmpty;

  /// No description provided for @memoPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get memoPhone;

  /// No description provided for @memoEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get memoEmail;

  /// No description provided for @memoLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load data. Please try again.'**
  String get memoLoadFailed;

  /// No description provided for @memoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The book or account changed. Reopen it to continue; unsaved input is kept for the original account.'**
  String get memoUnavailable;

  /// No description provided for @memoDownloadRequired.
  ///
  /// In en, this message translates to:
  /// **'Connect to finish downloading this book'**
  String get memoDownloadRequired;

  /// No description provided for @memoEditing.
  ///
  /// In en, this message translates to:
  /// **'Editing'**
  String get memoEditing;

  /// No description provided for @memoSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get memoSaving;

  /// No description provided for @memoSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed. Your input is kept; please retry.'**
  String get memoSaveFailed;

  /// No description provided for @memoDeleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete this record?'**
  String get memoDeleteEntry;

  /// No description provided for @memoDeleteEntryMessage.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get memoDeleteEntryMessage;

  /// No description provided for @memoCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get memoCopy;

  /// No description provided for @memoCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get memoCopied;

  /// No description provided for @memoExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get memoExport;

  /// No description provided for @memoSelectEntry.
  ///
  /// In en, this message translates to:
  /// **'Select note'**
  String get memoSelectEntry;

  /// No description provided for @memoSelectFormat.
  ///
  /// In en, this message translates to:
  /// **'Choose an export format'**
  String get memoSelectFormat;

  /// No description provided for @memoExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Document generation failed. Retry this note and format.'**
  String get memoExportFailed;

  /// No description provided for @memoExportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Export cancelled'**
  String get memoExportCancelled;

  /// No description provided for @memoExportReady.
  ///
  /// In en, this message translates to:
  /// **'File generated'**
  String get memoExportReady;

  /// No description provided for @memoLocal.
  ///
  /// In en, this message translates to:
  /// **'Local memo books'**
  String get memoLocal;

  /// No description provided for @memoCloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud memo books'**
  String get memoCloud;

  /// No description provided for @memoSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search field name or value'**
  String get memoSearchHint;

  /// No description provided for @memoSortManual.
  ///
  /// In en, this message translates to:
  /// **'Manual order'**
  String get memoSortManual;

  /// No description provided for @memoSortUpdated.
  ///
  /// In en, this message translates to:
  /// **'Recently edited'**
  String get memoSortUpdated;

  /// No description provided for @memoReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get memoReorder;

  /// No description provided for @memoReorderFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the order. Please try again.'**
  String get memoReorderFailed;

  /// No description provided for @memoOrderChanged.
  ///
  /// In en, this message translates to:
  /// **'Cards have changed. Refresh before reordering.'**
  String get memoOrderChanged;

  /// No description provided for @memoOrderCapacity.
  ///
  /// In en, this message translates to:
  /// **'Card order numbers have reached their limit. A new card cannot be added. Your draft has been kept.'**
  String get memoOrderCapacity;

  /// No description provided for @memoMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get memoMore;

  /// No description provided for @memoConflictCopy.
  ///
  /// In en, this message translates to:
  /// **'Conflict copy'**
  String get memoConflictCopy;

  /// No description provided for @memoDeleteBookMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this book and its {count} entries?'**
  String memoDeleteBookMessage(int count);

  /// No description provided for @memoEntryCount.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String memoEntryCount(int count);

  /// No description provided for @dayExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get dayExpired;

  /// No description provided for @dayPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get dayPresent;

  /// No description provided for @dayMilestone.
  ///
  /// In en, this message translates to:
  /// **'Anniversary'**
  String get dayMilestone;

  /// No description provided for @dayStatisticExample.
  ///
  /// In en, this message translates to:
  /// **'Example: {value}'**
  String dayStatisticExample(String value);

  /// No description provided for @memoHomeSyncing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing memo data'**
  String get memoHomeSyncing;

  /// No description provided for @memoHomeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No memos yet'**
  String get memoHomeEmpty;

  /// No description provided for @memoSelectBook.
  ///
  /// In en, this message translates to:
  /// **'Select memo book'**
  String get memoSelectBook;

  /// No description provided for @memoPullLocalSuccess.
  ///
  /// In en, this message translates to:
  /// **'Local memo data refreshed'**
  String get memoPullLocalSuccess;

  /// No description provided for @memoPullCloudSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cloud memo data synced'**
  String get memoPullCloudSuccess;

  /// No description provided for @memoPullCloudFailedButLocalOk.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync failed; local memo data refreshed'**
  String get memoPullCloudFailedButLocalOk;

  /// No description provided for @memoPullLocalFailed.
  ///
  /// In en, this message translates to:
  /// **'Local memo refresh failed. Try again later.'**
  String get memoPullLocalFailed;

  /// No description provided for @memoPullCloudFailed.
  ///
  /// In en, this message translates to:
  /// **'Cloud memo refresh failed. Try again later.'**
  String get memoPullCloudFailed;

  /// No description provided for @memoExportSection.
  ///
  /// In en, this message translates to:
  /// **'Export memos'**
  String get memoExportSection;

  /// No description provided for @fitnessTitle.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get fitnessTitle;

  /// No description provided for @fitnessContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue workout'**
  String get fitnessContinue;

  /// No description provided for @fitnessStart.
  ///
  /// In en, this message translates to:
  /// **'Start workout'**
  String get fitnessStart;

  /// No description provided for @fitnessFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish workout'**
  String get fitnessFinish;

  /// No description provided for @fitnessRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart workout'**
  String get fitnessRestart;

  /// No description provided for @fitnessNoData.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get fitnessNoData;

  /// No description provided for @fitnessPlans.
  ///
  /// In en, this message translates to:
  /// **'Training plans'**
  String get fitnessPlans;

  /// No description provided for @fitnessNewPlan.
  ///
  /// In en, this message translates to:
  /// **'Add training plan'**
  String get fitnessNewPlan;

  /// No description provided for @fitnessTemplates.
  ///
  /// In en, this message translates to:
  /// **'Workout templates'**
  String get fitnessTemplates;

  /// No description provided for @fitnessNewTemplate.
  ///
  /// In en, this message translates to:
  /// **'Add workout template'**
  String get fitnessNewTemplate;

  /// No description provided for @fitnessPlanLibrary.
  ///
  /// In en, this message translates to:
  /// **'Plan library'**
  String get fitnessPlanLibrary;

  /// No description provided for @fitnessTemplateLibrary.
  ///
  /// In en, this message translates to:
  /// **'Template library'**
  String get fitnessTemplateLibrary;

  /// No description provided for @fitnessAddToMyPlan.
  ///
  /// In en, this message translates to:
  /// **'Add to my plans'**
  String get fitnessAddToMyPlan;

  /// No description provided for @fitnessAddToMyTemplate.
  ///
  /// In en, this message translates to:
  /// **'Add to my templates'**
  String get fitnessAddToMyTemplate;

  /// No description provided for @fitnessAddAgain.
  ///
  /// In en, this message translates to:
  /// **'Add again'**
  String get fitnessAddAgain;

  /// No description provided for @fitnessReuseForTemplate.
  ///
  /// In en, this message translates to:
  /// **'Reuse \"{name}\"'**
  String fitnessReuseForTemplate(String name);

  /// No description provided for @fitnessCreateCopies.
  ///
  /// In en, this message translates to:
  /// **'Add copies'**
  String get fitnessCreateCopies;

  /// No description provided for @fitnessOfficialSource.
  ///
  /// In en, this message translates to:
  /// **'Source: official training library'**
  String get fitnessOfficialSource;

  /// No description provided for @fitnessLibraryAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to the current training space'**
  String get fitnessLibraryAdded;

  /// No description provided for @fitnessExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercise library'**
  String get fitnessExercises;

  /// No description provided for @fitnessAddExercises.
  ///
  /// In en, this message translates to:
  /// **'Add exercises'**
  String get fitnessAddExercises;

  /// No description provided for @fitnessReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace exercise'**
  String get fitnessReplace;

  /// No description provided for @fitnessNoExercises.
  ///
  /// In en, this message translates to:
  /// **'Search or change filters to find exercises'**
  String get fitnessNoExercises;

  /// No description provided for @fitnessName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fitnessName;

  /// No description provided for @fitnessSearch.
  ///
  /// In en, this message translates to:
  /// **'Search names and aliases'**
  String get fitnessSearch;

  /// No description provided for @fitnessPlanned.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get fitnessPlanned;

  /// No description provided for @fitnessActive.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get fitnessActive;

  /// No description provided for @fitnessFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get fitnessFinished;

  /// No description provided for @fitnessDate.
  ///
  /// In en, this message translates to:
  /// **'Scheduled date'**
  String get fitnessDate;

  /// No description provided for @fitnessTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get fitnessTime;

  /// No description provided for @fitnessVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get fitnessVolume;

  /// No description provided for @fitnessSets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get fitnessSets;

  /// No description provided for @fitnessDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration (seconds)'**
  String get fitnessDuration;

  /// No description provided for @fitnessAddSet.
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get fitnessAddSet;

  /// No description provided for @fitnessKeypadAddSet.
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get fitnessKeypadAddSet;

  /// No description provided for @fitnessFillSets.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get fitnessFillSets;

  /// No description provided for @fitnessFillAbove.
  ///
  /// In en, this message translates to:
  /// **'Above'**
  String get fitnessFillAbove;

  /// No description provided for @fitnessFillBelow.
  ///
  /// In en, this message translates to:
  /// **'Below'**
  String get fitnessFillBelow;

  /// No description provided for @fitnessNextInput.
  ///
  /// In en, this message translates to:
  /// **'Next field'**
  String get fitnessNextInput;

  /// No description provided for @fitnessCopySet.
  ///
  /// In en, this message translates to:
  /// **'Copy this set'**
  String get fitnessCopySet;

  /// No description provided for @fitnessDeleteSet.
  ///
  /// In en, this message translates to:
  /// **'Delete this set'**
  String get fitnessDeleteSet;

  /// No description provided for @fitnessRest.
  ///
  /// In en, this message translates to:
  /// **'Rest timer'**
  String get fitnessRest;

  /// No description provided for @fitnessRestSeconds.
  ///
  /// In en, this message translates to:
  /// **'Rest (seconds)'**
  String get fitnessRestSeconds;

  /// No description provided for @fitnessWarmupRest.
  ///
  /// In en, this message translates to:
  /// **'Warm-up rest (seconds)'**
  String get fitnessWarmupRest;

  /// No description provided for @fitnessPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get fitnessPause;

  /// No description provided for @fitnessResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get fitnessResume;

  /// No description provided for @fitnessSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get fitnessSkip;

  /// No description provided for @fitnessRestRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get fitnessRestRestart;

  /// No description provided for @fitnessRestEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get fitnessRestEnd;

  /// No description provided for @fitnessRepeatRest.
  ///
  /// In en, this message translates to:
  /// **'Repeat rest'**
  String get fitnessRepeatRest;

  /// No description provided for @fitnessStartTimer.
  ///
  /// In en, this message translates to:
  /// **'Start timer'**
  String get fitnessStartTimer;

  /// No description provided for @fitnessCopy.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get fitnessCopy;

  /// No description provided for @fitnessMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get fitnessMoveUp;

  /// No description provided for @fitnessMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get fitnessMoveDown;

  /// No description provided for @fitnessUpdateTemplate.
  ///
  /// In en, this message translates to:
  /// **'Update template'**
  String get fitnessUpdateTemplate;

  /// No description provided for @fitnessUpdateTemplateConfirm.
  ///
  /// In en, this message translates to:
  /// **'Update the source template with this workout’s exercises and set configuration? The template name and existing workouts will stay unchanged.'**
  String get fitnessUpdateTemplateConfirm;

  /// No description provided for @fitnessSaveTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save as template'**
  String get fitnessSaveTemplate;

  /// No description provided for @fitnessDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this item? Previously generated workouts and history are kept.'**
  String get fitnessDeleteMessage;

  /// No description provided for @fitnessCompletedChange.
  ///
  /// In en, this message translates to:
  /// **'This exercise contains completed sets. Replace or remove it?'**
  String get fitnessCompletedChange;

  /// No description provided for @fitnessInvalidSet.
  ///
  /// In en, this message translates to:
  /// **'Enter valid fields before confirming this set.'**
  String get fitnessInvalidSet;

  /// No description provided for @fitnessIncompleteSet.
  ///
  /// In en, this message translates to:
  /// **'This set is incomplete. Confirm it again after editing.'**
  String get fitnessIncompleteSet;

  /// No description provided for @fitnessInvalidForm.
  ///
  /// In en, this message translates to:
  /// **'Check the name, numbers and required exercises.'**
  String get fitnessInvalidForm;

  /// No description provided for @fitnessActiveExists.
  ///
  /// In en, this message translates to:
  /// **'A workout is already running. Continue it or finish it first.'**
  String get fitnessActiveExists;

  /// No description provided for @fitnessPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get fitnessPaused;

  /// No description provided for @fitnessStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get fitnessStartDate;

  /// No description provided for @fitnessCycleDays.
  ///
  /// In en, this message translates to:
  /// **'Plan cycle (including rest)'**
  String get fitnessCycleDays;

  /// No description provided for @fitnessRestDay.
  ///
  /// In en, this message translates to:
  /// **'Rest day'**
  String get fitnessRestDay;

  /// No description provided for @fitnessPin.
  ///
  /// In en, this message translates to:
  /// **'Pin exercise'**
  String get fitnessPin;

  /// No description provided for @fitnessUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin exercise'**
  String get fitnessUnpin;

  /// No description provided for @fitnessPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get fitnessPinned;

  /// No description provided for @fitnessRecent.
  ///
  /// In en, this message translates to:
  /// **'Recently used'**
  String get fitnessRecent;

  /// No description provided for @fitnessAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get fitnessAll;

  /// No description provided for @fitnessBodyPart.
  ///
  /// In en, this message translates to:
  /// **'Body part'**
  String get fitnessBodyPart;

  /// No description provided for @fitnessEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get fitnessEquipment;

  /// No description provided for @fitnessInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get fitnessInstructions;

  /// No description provided for @fitnessPlay.
  ///
  /// In en, this message translates to:
  /// **'Play demonstration'**
  String get fitnessPlay;

  /// No description provided for @fitnessPauseMedia.
  ///
  /// In en, this message translates to:
  /// **'Pause demonstration'**
  String get fitnessPauseMedia;

  /// No description provided for @fitnessDefaultRest.
  ///
  /// In en, this message translates to:
  /// **'Default rest duration'**
  String get fitnessDefaultRest;

  /// No description provided for @fitnessTrainingDays.
  ///
  /// In en, this message translates to:
  /// **'Training days'**
  String get fitnessTrainingDays;

  /// No description provided for @fitnessShowMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get fitnessShowMore;

  /// No description provided for @fitnessLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load data. Please try again.'**
  String get fitnessLoadFailed;

  /// No description provided for @fitnessSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed. Your input is kept; try again.'**
  String get fitnessSaveFailed;

  /// No description provided for @fitnessDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get fitnessDetails;

  /// No description provided for @fitnessIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Fitness data has not fully downloaded. Sync and try again.'**
  String get fitnessIncomplete;

  /// No description provided for @fitnessReminderPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'System reminders are not permitted. Workout recording still works.'**
  String get fitnessReminderPermissionDenied;

  /// No description provided for @fitnessChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get fitnessChest;

  /// No description provided for @fitnessBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get fitnessBack;

  /// No description provided for @fitnessShoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get fitnessShoulders;

  /// No description provided for @fitnessBiceps.
  ///
  /// In en, this message translates to:
  /// **'Biceps'**
  String get fitnessBiceps;

  /// No description provided for @fitnessTriceps.
  ///
  /// In en, this message translates to:
  /// **'Triceps'**
  String get fitnessTriceps;

  /// No description provided for @fitnessAbs.
  ///
  /// In en, this message translates to:
  /// **'Abs'**
  String get fitnessAbs;

  /// No description provided for @fitnessGlutes.
  ///
  /// In en, this message translates to:
  /// **'Glutes'**
  String get fitnessGlutes;

  /// No description provided for @fitnessHamstrings.
  ///
  /// In en, this message translates to:
  /// **'Hamstrings'**
  String get fitnessHamstrings;

  /// No description provided for @fitnessQuadriceps.
  ///
  /// In en, this message translates to:
  /// **'Quadriceps'**
  String get fitnessQuadriceps;

  /// No description provided for @fitnessCalves.
  ///
  /// In en, this message translates to:
  /// **'Calves'**
  String get fitnessCalves;

  /// No description provided for @fitnessUpperArms.
  ///
  /// In en, this message translates to:
  /// **'Upper arms'**
  String get fitnessUpperArms;

  /// No description provided for @fitnessLowerArms.
  ///
  /// In en, this message translates to:
  /// **'Forearms'**
  String get fitnessLowerArms;

  /// No description provided for @fitnessUpperLegs.
  ///
  /// In en, this message translates to:
  /// **'Thighs'**
  String get fitnessUpperLegs;

  /// No description provided for @fitnessLowerLegs.
  ///
  /// In en, this message translates to:
  /// **'Lower legs'**
  String get fitnessLowerLegs;

  /// No description provided for @fitnessWaist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get fitnessWaist;

  /// No description provided for @fitnessCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get fitnessCardio;

  /// No description provided for @fitnessBarbell.
  ///
  /// In en, this message translates to:
  /// **'Barbell'**
  String get fitnessBarbell;

  /// No description provided for @fitnessDumbbell.
  ///
  /// In en, this message translates to:
  /// **'Dumbbell'**
  String get fitnessDumbbell;

  /// No description provided for @fitnessKettlebell.
  ///
  /// In en, this message translates to:
  /// **'Kettlebell'**
  String get fitnessKettlebell;

  /// No description provided for @fitnessCable.
  ///
  /// In en, this message translates to:
  /// **'Cable'**
  String get fitnessCable;

  /// No description provided for @fitnessMachine.
  ///
  /// In en, this message translates to:
  /// **'Machine'**
  String get fitnessMachine;

  /// No description provided for @fitnessSledMachine.
  ///
  /// In en, this message translates to:
  /// **'Sled machine'**
  String get fitnessSledMachine;

  /// No description provided for @fitnessBodyWeightEquipment.
  ///
  /// In en, this message translates to:
  /// **'Body weight'**
  String get fitnessBodyWeightEquipment;

  /// No description provided for @fitnessWeightedEquipment.
  ///
  /// In en, this message translates to:
  /// **'Weighted'**
  String get fitnessWeightedEquipment;

  /// No description provided for @fitnessLats.
  ///
  /// In en, this message translates to:
  /// **'Lats'**
  String get fitnessLats;

  /// No description provided for @fitnessSpine.
  ///
  /// In en, this message translates to:
  /// **'Spinal erectors'**
  String get fitnessSpine;

  /// No description provided for @fitnessUpperBack.
  ///
  /// In en, this message translates to:
  /// **'Upper back'**
  String get fitnessUpperBack;

  /// No description provided for @fitnessLowerBack.
  ///
  /// In en, this message translates to:
  /// **'Lower back'**
  String get fitnessLowerBack;

  /// No description provided for @fitnessRearDeltoids.
  ///
  /// In en, this message translates to:
  /// **'Rear deltoids'**
  String get fitnessRearDeltoids;

  /// No description provided for @fitnessRhomboids.
  ///
  /// In en, this message translates to:
  /// **'Rhomboids'**
  String get fitnessRhomboids;

  /// No description provided for @fitnessTraps.
  ///
  /// In en, this message translates to:
  /// **'Trapezius'**
  String get fitnessTraps;

  /// No description provided for @fitnessHipFlexors.
  ///
  /// In en, this message translates to:
  /// **'Hip flexors'**
  String get fitnessHipFlexors;

  /// No description provided for @fitnessCore.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get fitnessCore;

  /// No description provided for @fitnessFeet.
  ///
  /// In en, this message translates to:
  /// **'Feet'**
  String get fitnessFeet;

  /// No description provided for @fitnessAnkles.
  ///
  /// In en, this message translates to:
  /// **'Ankles'**
  String get fitnessAnkles;

  /// No description provided for @fitnessConflicts.
  ///
  /// In en, this message translates to:
  /// **'Sync conflicts'**
  String get fitnessConflicts;

  /// No description provided for @fitnessRestCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest complete'**
  String get fitnessRestCompletedTitle;

  /// No description provided for @fitnessRestCompletedBody.
  ///
  /// In en, this message translates to:
  /// **'Rest is over. Continue training or finish your workout.'**
  String get fitnessRestCompletedBody;

  /// No description provided for @fitnessUnknownPart.
  ///
  /// In en, this message translates to:
  /// **'Unknown body part'**
  String get fitnessUnknownPart;

  /// No description provided for @fitnessBodyFront.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get fitnessBodyFront;

  /// No description provided for @fitnessBodyBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get fitnessBodyBack;

  /// No description provided for @fitnessNeck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get fitnessNeck;

  /// No description provided for @fitnessAdductors.
  ///
  /// In en, this message translates to:
  /// **'Adductors'**
  String get fitnessAdductors;

  /// No description provided for @fitnessAbductors.
  ///
  /// In en, this message translates to:
  /// **'Abductors'**
  String get fitnessAbductors;

  /// No description provided for @fitnessSerratus.
  ///
  /// In en, this message translates to:
  /// **'Serratus anterior'**
  String get fitnessSerratus;

  /// No description provided for @fitnessLevatorScapulae.
  ///
  /// In en, this message translates to:
  /// **'Levator scapulae'**
  String get fitnessLevatorScapulae;

  /// No description provided for @fitnessBand.
  ///
  /// In en, this message translates to:
  /// **'Band'**
  String get fitnessBand;

  /// No description provided for @fitnessResistanceBand.
  ///
  /// In en, this message translates to:
  /// **'Resistance band'**
  String get fitnessResistanceBand;

  /// No description provided for @fitnessAssistedEquipment.
  ///
  /// In en, this message translates to:
  /// **'Assisted equipment'**
  String get fitnessAssistedEquipment;

  /// No description provided for @fitnessBosu.
  ///
  /// In en, this message translates to:
  /// **'Bosu ball'**
  String get fitnessBosu;

  /// No description provided for @fitnessElliptical.
  ///
  /// In en, this message translates to:
  /// **'Elliptical machine'**
  String get fitnessElliptical;

  /// No description provided for @fitnessEzBar.
  ///
  /// In en, this message translates to:
  /// **'EZ barbell'**
  String get fitnessEzBar;

  /// No description provided for @fitnessHammer.
  ///
  /// In en, this message translates to:
  /// **'Hammer'**
  String get fitnessHammer;

  /// No description provided for @fitnessMedicineBall.
  ///
  /// In en, this message translates to:
  /// **'Medicine ball'**
  String get fitnessMedicineBall;

  /// No description provided for @fitnessOlympicBarbell.
  ///
  /// In en, this message translates to:
  /// **'Olympic barbell'**
  String get fitnessOlympicBarbell;

  /// No description provided for @fitnessRoller.
  ///
  /// In en, this message translates to:
  /// **'Roller'**
  String get fitnessRoller;

  /// No description provided for @fitnessRope.
  ///
  /// In en, this message translates to:
  /// **'Rope'**
  String get fitnessRope;

  /// No description provided for @fitnessSkiErg.
  ///
  /// In en, this message translates to:
  /// **'SkiErg machine'**
  String get fitnessSkiErg;

  /// No description provided for @fitnessSmithMachine.
  ///
  /// In en, this message translates to:
  /// **'Smith machine'**
  String get fitnessSmithMachine;

  /// No description provided for @fitnessStabilityBall.
  ///
  /// In en, this message translates to:
  /// **'Stability ball'**
  String get fitnessStabilityBall;

  /// No description provided for @fitnessStationaryBike.
  ///
  /// In en, this message translates to:
  /// **'Stationary bike'**
  String get fitnessStationaryBike;

  /// No description provided for @fitnessStepmill.
  ///
  /// In en, this message translates to:
  /// **'Stepmill machine'**
  String get fitnessStepmill;

  /// No description provided for @fitnessTire.
  ///
  /// In en, this message translates to:
  /// **'Tire'**
  String get fitnessTire;

  /// No description provided for @fitnessTrapBar.
  ///
  /// In en, this message translates to:
  /// **'Trap bar'**
  String get fitnessTrapBar;

  /// No description provided for @fitnessUpperBodyErgometer.
  ///
  /// In en, this message translates to:
  /// **'Upper body ergometer'**
  String get fitnessUpperBodyErgometer;

  /// No description provided for @fitnessAbWheel.
  ///
  /// In en, this message translates to:
  /// **'Ab wheel'**
  String get fitnessAbWheel;

  /// No description provided for @fitnessAnkleStabilizers.
  ///
  /// In en, this message translates to:
  /// **'Ankle stabilizers'**
  String get fitnessAnkleStabilizers;

  /// No description provided for @fitnessBrachialis.
  ///
  /// In en, this message translates to:
  /// **'Brachialis'**
  String get fitnessBrachialis;

  /// No description provided for @fitnessGripMuscles.
  ///
  /// In en, this message translates to:
  /// **'Grip muscles'**
  String get fitnessGripMuscles;

  /// No description provided for @fitnessGroin.
  ///
  /// In en, this message translates to:
  /// **'Groin'**
  String get fitnessGroin;

  /// No description provided for @fitnessHands.
  ///
  /// In en, this message translates to:
  /// **'Hands'**
  String get fitnessHands;

  /// No description provided for @fitnessLowerAbs.
  ///
  /// In en, this message translates to:
  /// **'Lower abs'**
  String get fitnessLowerAbs;

  /// No description provided for @fitnessObliques.
  ///
  /// In en, this message translates to:
  /// **'Obliques'**
  String get fitnessObliques;

  /// No description provided for @fitnessRotatorCuff.
  ///
  /// In en, this message translates to:
  /// **'Rotator cuff'**
  String get fitnessRotatorCuff;

  /// No description provided for @fitnessShins.
  ///
  /// In en, this message translates to:
  /// **'Shins'**
  String get fitnessShins;

  /// No description provided for @fitnessSoleus.
  ///
  /// In en, this message translates to:
  /// **'Soleus'**
  String get fitnessSoleus;

  /// No description provided for @fitnessSternocleidomastoid.
  ///
  /// In en, this message translates to:
  /// **'Sternocleidomastoid'**
  String get fitnessSternocleidomastoid;

  /// No description provided for @fitnessUpperChest.
  ///
  /// In en, this message translates to:
  /// **'Upper chest'**
  String get fitnessUpperChest;

  /// No description provided for @fitnessWristExtensors.
  ///
  /// In en, this message translates to:
  /// **'Wrist extensors'**
  String get fitnessWristExtensors;

  /// No description provided for @fitnessWristFlexors.
  ///
  /// In en, this message translates to:
  /// **'Wrist flexors'**
  String get fitnessWristFlexors;

  /// No description provided for @fitnessWrists.
  ///
  /// In en, this message translates to:
  /// **'Wrists'**
  String get fitnessWrists;

  /// No description provided for @fitnessExerciseCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {1 exercise} other {{count} exercises}}'**
  String fitnessExerciseCount(int count);

  /// No description provided for @fitnessBodyChestRegions.
  ///
  /// In en, this message translates to:
  /// **'Upper\nMid–low'**
  String get fitnessBodyChestRegions;

  /// No description provided for @fitnessBodyFrontShoulderRegions.
  ///
  /// In en, this message translates to:
  /// **'Front\nSide'**
  String get fitnessBodyFrontShoulderRegions;

  /// No description provided for @fitnessBodyBackShoulderRegions.
  ///
  /// In en, this message translates to:
  /// **'Side\nRear'**
  String get fitnessBodyBackShoulderRegions;

  /// No description provided for @fitnessTrainingTime.
  ///
  /// In en, this message translates to:
  /// **'Training time'**
  String get fitnessTrainingTime;

  /// No description provided for @fitnessTrainingDuration.
  ///
  /// In en, this message translates to:
  /// **'Training duration'**
  String get fitnessTrainingDuration;

  /// No description provided for @fitnessTrainingBodyParts.
  ///
  /// In en, this message translates to:
  /// **'Training body parts'**
  String get fitnessTrainingBodyParts;

  /// No description provided for @fitnessDurationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String fitnessDurationHours(String hours);

  /// No description provided for @fitnessClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get fitnessClosed;

  /// No description provided for @fitnessPlanNoStartDate.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get fitnessPlanNoStartDate;

  /// No description provided for @fitnessExerciseDetail.
  ///
  /// In en, this message translates to:
  /// **'Exercise details'**
  String get fitnessExerciseDetail;

  /// No description provided for @fitnessExerciseHistory.
  ///
  /// In en, this message translates to:
  /// **'Training history'**
  String get fitnessExerciseHistory;

  /// No description provided for @fitnessNoExerciseHistory.
  ///
  /// In en, this message translates to:
  /// **'No checked sets for this exercise yet'**
  String get fitnessNoExerciseHistory;

  /// No description provided for @fitnessRestNotRecorded.
  ///
  /// In en, this message translates to:
  /// **'-'**
  String get fitnessRestNotRecorded;

  /// No description provided for @fitnessRestInProgress.
  ///
  /// In en, this message translates to:
  /// **'Timer not finished'**
  String get fitnessRestInProgress;

  /// No description provided for @fitnessPlanSchedule.
  ///
  /// In en, this message translates to:
  /// **'Cycle schedule'**
  String get fitnessPlanSchedule;

  /// No description provided for @fitnessDeletePlan.
  ///
  /// In en, this message translates to:
  /// **'Delete plan'**
  String get fitnessDeletePlan;

  /// No description provided for @fitnessDeletePlanMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete only this plan? All generated workouts and rest days, including completed workouts, will be kept.'**
  String get fitnessDeletePlanMessage;

  /// No description provided for @fitnessPlanEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable plan'**
  String get fitnessPlanEnabled;

  /// No description provided for @fitnessPlanStartDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a start date to enable the plan'**
  String get fitnessPlanStartDateRequired;

  /// No description provided for @syncCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync Management'**
  String get syncCenterTitle;

  /// No description provided for @syncCenterLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load sync status. Try again.'**
  String get syncCenterLoadFailed;

  /// No description provided for @syncCenterActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation incomplete. Your data is preserved. Try again.'**
  String get syncCenterActionFailed;

  /// No description provided for @syncCenterUseRemote.
  ///
  /// In en, this message translates to:
  /// **'Use cloud version'**
  String get syncCenterUseRemote;

  /// No description provided for @syncCenterKeepLocal.
  ///
  /// In en, this message translates to:
  /// **'Keep local version'**
  String get syncCenterKeepLocal;

  /// No description provided for @syncCenterDecisionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Use the selected version? Deleted cloud records will not be recreated under the same identity. Local content can be preserved as a copy.'**
  String get syncCenterDecisionConfirm;

  /// No description provided for @syncCenterConflict.
  ///
  /// In en, this message translates to:
  /// **'Conflicting versions need your decision'**
  String get syncCenterConflict;

  /// No description provided for @syncCenterRejected.
  ///
  /// In en, this message translates to:
  /// **'Upload rejected'**
  String get syncCenterRejected;

  /// No description provided for @syncCenterStale.
  ///
  /// In en, this message translates to:
  /// **'Sync connection is outdated'**
  String get syncCenterStale;

  /// No description provided for @syncCenterDeleting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for cloud deletion confirmation'**
  String get syncCenterDeleting;

  /// No description provided for @syncCenterMoving.
  ///
  /// In en, this message translates to:
  /// **'Move to device is incomplete'**
  String get syncCenterMoving;

  /// No description provided for @syncCenterIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Download incomplete'**
  String get syncCenterIncomplete;

  /// No description provided for @syncCenterDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get syncCenterDeleted;

  /// No description provided for @syncCenterCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare versions'**
  String get syncCenterCompare;

  /// No description provided for @syncCenterLocal.
  ///
  /// In en, this message translates to:
  /// **'Local version'**
  String get syncCenterLocal;

  /// No description provided for @syncCenterRemote.
  ///
  /// In en, this message translates to:
  /// **'Cloud version'**
  String get syncCenterRemote;

  /// No description provided for @syncCenterEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sync issues to resolve'**
  String get syncCenterEmpty;

  /// No description provided for @syncCenterEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit record'**
  String get syncCenterEdit;

  /// No description provided for @syncCenterProtect.
  ///
  /// In en, this message translates to:
  /// **'Keep a copy on this device'**
  String get syncCenterProtect;

  /// No description provided for @syncCenterDownload.
  ///
  /// In en, this message translates to:
  /// **'Protect content and download again'**
  String get syncCenterDownload;

  /// No description provided for @syncCenterPending.
  ///
  /// In en, this message translates to:
  /// **'{count} sync operations need attention'**
  String syncCenterPending(int count);

  /// No description provided for @syncCenterUploading.
  ///
  /// In en, this message translates to:
  /// **'Waiting to upload'**
  String get syncCenterUploading;

  /// No description provided for @fitnessPlanUnfilled.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get fitnessPlanUnfilled;

  /// No description provided for @fitnessPlanFillHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a template to fill a date'**
  String get fitnessPlanFillHint;

  /// No description provided for @fitnessPlanFillDays.
  ///
  /// In en, this message translates to:
  /// **'Choose a template or rest for every day'**
  String get fitnessPlanFillDays;

  /// No description provided for @fitnessPlanSetRest.
  ///
  /// In en, this message translates to:
  /// **'Set rest day'**
  String get fitnessPlanSetRest;

  /// No description provided for @fitnessPlanReplaceHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a template to replace this assignment'**
  String get fitnessPlanReplaceHint;

  /// No description provided for @syncCenterDeleteReview.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”? It currently contains {count} cloud records. Unsynced local changes to this book will also be deleted.'**
  String syncCenterDeleteReview(String name, int count);

  /// No description provided for @syncCenterMoveReview.
  ///
  /// In en, this message translates to:
  /// **'Continue moving “{name}” to this device? It has {count} cloud records. The move finishes after a complete copy is saved and cloud deletion is confirmed.'**
  String syncCenterMoveReview(String name, int count);

  /// No description provided for @syncCenterDeleteGone.
  ///
  /// In en, this message translates to:
  /// **'“{name}” is no longer available in the cloud. Finish this deletion? Existing recovery copies will be kept.'**
  String syncCenterDeleteGone(String name);

  /// No description provided for @syncCenterBudget.
  ///
  /// In en, this message translates to:
  /// **'This content exceeds the sync size limit. Reduce its size and try again.'**
  String get syncCenterBudget;

  /// No description provided for @dataTransferInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get dataTransferInfoTitle;

  /// No description provided for @daySelectBook.
  ///
  /// In en, this message translates to:
  /// **'Select anniversary book'**
  String get daySelectBook;

  /// No description provided for @fitnessExportSection.
  ///
  /// In en, this message translates to:
  /// **'Export fitness'**
  String get fitnessExportSection;

  /// No description provided for @fitnessRecordCount.
  ///
  /// In en, this message translates to:
  /// **'{count} data items'**
  String fitnessRecordCount(Object count);

  /// No description provided for @fitnessDefaultSpaceName.
  ///
  /// In en, this message translates to:
  /// **'Default fitness space'**
  String get fitnessDefaultSpaceName;

  /// No description provided for @fitnessSelectSpace.
  ///
  /// In en, this message translates to:
  /// **'Select fitness space'**
  String get fitnessSelectSpace;

  /// No description provided for @fitnessNoSpaces.
  ///
  /// In en, this message translates to:
  /// **'No fitness spaces'**
  String get fitnessNoSpaces;

  /// No description provided for @fitnessSpacesManagement.
  ///
  /// In en, this message translates to:
  /// **'Fitness spaces'**
  String get fitnessSpacesManagement;

  /// No description provided for @fitnessCreateSpace.
  ///
  /// In en, this message translates to:
  /// **'Add fitness space'**
  String get fitnessCreateSpace;

  /// No description provided for @fitnessSpaceName.
  ///
  /// In en, this message translates to:
  /// **'Space name'**
  String get fitnessSpaceName;

  /// No description provided for @fitnessLocalSpaces.
  ///
  /// In en, this message translates to:
  /// **'Local fitness spaces'**
  String get fitnessLocalSpaces;

  /// No description provided for @fitnessCloudSpaces.
  ///
  /// In en, this message translates to:
  /// **'Cloud fitness spaces'**
  String get fitnessCloudSpaces;

  /// No description provided for @fitnessDeleteSpaceMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this fitness space and its {count} data items?'**
  String fitnessDeleteSpaceMessage(Object count);

  /// No description provided for @privateBookDownloadRequired.
  ///
  /// In en, this message translates to:
  /// **'Complete data synchronization first'**
  String get privateBookDownloadRequired;

  /// No description provided for @privateBookMoveToCloudMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be uploaded to the cloud and synced across your devices.'**
  String privateBookMoveToCloudMessage(String name);

  /// No description provided for @privateBookMoveToLocalMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be deleted from the cloud and kept on this device only. Other devices will no longer see it.'**
  String privateBookMoveToLocalMessage(String name);

  /// No description provided for @privateBookCopyToLocalMessage.
  ///
  /// In en, this message translates to:
  /// **'A local copy of \"{name}\" will be created. The cloud original stays unchanged.'**
  String privateBookCopyToLocalMessage(String name);

  /// No description provided for @reminderGlobalTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get reminderGlobalTitle;

  /// No description provided for @reminderPlatformUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Reminder notifications are not supported on this platform yet.'**
  String get reminderPlatformUnsupported;

  /// No description provided for @reminderDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Anniversary reminders'**
  String get reminderDaysTitle;

  /// No description provided for @reminderDaySame.
  ///
  /// In en, this message translates to:
  /// **'On the day'**
  String get reminderDaySame;

  /// No description provided for @reminderDayBefore.
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get reminderDayBefore;

  /// No description provided for @reminderThreeDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'3 days before'**
  String get reminderThreeDaysBefore;

  /// No description provided for @reminderWeekBefore.
  ///
  /// In en, this message translates to:
  /// **'1 week before'**
  String get reminderWeekBefore;

  /// No description provided for @reminderChooseOneDay.
  ///
  /// In en, this message translates to:
  /// **'Keep at least one reminder day'**
  String get reminderChooseOneDay;

  /// No description provided for @reminderDaysTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderDaysTimeTitle;

  /// No description provided for @reminderRestTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest timer reminders'**
  String get reminderRestTitle;

  /// No description provided for @reminderSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Reminder help'**
  String get reminderSystemSettings;

  /// No description provided for @transferCommitting.
  ///
  /// In en, this message translates to:
  /// **'Committing, please wait'**
  String get transferCommitting;

  /// No description provided for @transferBookTypeMismatch.
  ///
  /// In en, this message translates to:
  /// **'This file is a \"{fileType}\" export while the target is \"{targetType}\". Go back and pick a matching memo book.'**
  String transferBookTypeMismatch(Object fileType, Object targetType);

  /// No description provided for @transferDefaultValue.
  ///
  /// In en, this message translates to:
  /// **'Default value'**
  String get transferDefaultValue;

  /// No description provided for @transferDefaultValueHelp.
  ///
  /// In en, this message translates to:
  /// **'Used when this field is not read from the file; leave empty for no value.'**
  String get transferDefaultValueHelp;

  /// No description provided for @transferIgnoreField.
  ///
  /// In en, this message translates to:
  /// **'Don\'t read this field'**
  String get transferIgnoreField;

  /// No description provided for @transferDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Already imported; will skip'**
  String get transferDuplicate;

  /// No description provided for @transferExportProgress.
  ///
  /// In en, this message translates to:
  /// **'Generating export files · {count} generated'**
  String transferExportProgress(Object count);

  /// No description provided for @transferFailed.
  ///
  /// In en, this message translates to:
  /// **'Import did not finish. Check the data or retry. Successfully imported records will not be duplicated.'**
  String get transferFailed;

  /// No description provided for @transferFitnessHint.
  ///
  /// In en, this message translates to:
  /// **'Each item includes its complete plan/workout, exercises and sets. Importing preferences replaces current fitness preferences.'**
  String get transferFitnessHint;

  /// No description provided for @transferMappingHelp.
  ///
  /// In en, this message translates to:
  /// **'Auto-detected fields can be changed. Choosing \"Don\'t read this field\" skips the file and uses the default below. * indicates required fields.'**
  String get transferMappingHelp;

  /// No description provided for @transferMatchingTitle.
  ///
  /// In en, this message translates to:
  /// **'Match exercises'**
  String get transferMatchingTitle;

  /// No description provided for @transferPendingSync.
  ///
  /// In en, this message translates to:
  /// **'Local import complete. Cloud synchronization will continue in the sync queue.'**
  String get transferPendingSync;

  /// No description provided for @transferRecord.
  ///
  /// In en, this message translates to:
  /// **'Record {lines} · {title}'**
  String transferRecord(Object lines, Object title);

  /// No description provided for @transferRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a field'**
  String get transferRequired;

  /// No description provided for @transferResult.
  ///
  /// In en, this message translates to:
  /// **'Imported {imported} · Skipped {skipped} · Failed {failed}'**
  String transferResult(Object failed, Object imported, Object skipped);

  /// No description provided for @transferSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all valid records'**
  String get transferSelectAll;

  /// No description provided for @transferSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose an existing category'**
  String get transferSelectCategory;

  /// No description provided for @transferSelectExercise.
  ///
  /// In en, this message translates to:
  /// **'Choose an exercise'**
  String get transferSelectExercise;

  /// No description provided for @transferSummary.
  ///
  /// In en, this message translates to:
  /// **'Total {total} · Valid {valid} · Duplicates {duplicates} · Errors {errors} · Selected {selected}'**
  String transferSummary(
    Object duplicates,
    Object errors,
    Object selected,
    Object total,
    Object valid,
  );

  /// No description provided for @transferTarget.
  ///
  /// In en, this message translates to:
  /// **'Target: {name}'**
  String transferTarget(Object name);

  /// No description provided for @transferUnnamed.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get transferUnnamed;

  /// No description provided for @transferValid.
  ///
  /// In en, this message translates to:
  /// **'Ready to import'**
  String get transferValid;

  /// No description provided for @transferFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'{field, select, faccount {Account} famount {Amount} fbody {Body} fcalendar {Calendar} fcategory {Category} fcategory_icon {Category icon} fcompleted {Completed} fcountdown_mode {Countdown mode} fcreated_at {Created at} fcurrency {Currency} fcycle_days {Cycle days} fdate {Date} fday {Training day (1-based)} fdays {Training schedule} femail {Email} fend_calendar {End calendar} fend_date {End date} fend_is_leap_month {End leap month} fentity_type {Record type} fexercise {Exercise} fexercises {Exercises and sets} fgeneration_state {Plan execution state} fid {Relationship reference} finterval_days {Interval days} fis_leap_month {Leap month} fkind {Set kind} fname {Name} fnote {Note} foccurrence_key {Plan occurrence} fpassword {Password} fpending_schedule {Pending schedule} fphone {Phone} fpreferences {Fitness preferences} fremark {Note} frepeat_type {Repeat} freps {Repetitions} frest_seconds {Rest seconds} frest_timer {Rest timer} frun_segments {Execution segments} fscheduled_date {Workout date} fset_count {Number of sets} fsource_kind {Workout source} fsource_plan_id {Related plan} fsource_plan_name {Related plan name} fsource_template_id {Related template} fstart_calendar {Start calendar} fstart_date {Start date} fstart_is_leap_month {Start leap month} fstatistic_type {Count by} fstatus {Status} fsub_category {Subcategory} fsub_category_icon {Subcategory icon} ftitle {Title} ftype {Type} fupdated_at {Updated at} fweight {Weight} fsets {Sets} fslot {Training slot} fday_index {Day index (0-based)} other {Field}}'**
  String transferFieldLabel(String field);

  /// No description provided for @transferCardFields.
  ///
  /// In en, this message translates to:
  /// **'Card fields'**
  String get transferCardFields;

  /// No description provided for @transferCardFieldsHelp.
  ///
  /// In en, this message translates to:
  /// **'Every column can become a card field. Turn a column off, or clear its name, to skip it; rename the field to whatever you prefer.'**
  String get transferCardFieldsHelp;

  /// No description provided for @transferCardFieldName.
  ///
  /// In en, this message translates to:
  /// **'Field name'**
  String get transferCardFieldName;

  /// No description provided for @transferJsonRoot.
  ///
  /// In en, this message translates to:
  /// **'Entire JSON object'**
  String get transferJsonRoot;

  /// No description provided for @fitnessCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get fitnessCustom;

  /// No description provided for @fitnessCustomCreate.
  ///
  /// In en, this message translates to:
  /// **'Add custom exercise'**
  String get fitnessCustomCreate;

  /// No description provided for @fitnessCustomEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit custom exercise'**
  String get fitnessCustomEdit;

  /// No description provided for @fitnessCustomName.
  ///
  /// In en, this message translates to:
  /// **'Exercise name'**
  String get fitnessCustomName;

  /// No description provided for @fitnessCustomRequired.
  ///
  /// In en, this message translates to:
  /// **'Please complete this required field'**
  String get fitnessCustomRequired;

  /// No description provided for @fitnessCustomUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload image'**
  String get fitnessCustomUpload;

  /// No description provided for @fitnessCustomImageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Please choose an image smaller than 48 KB'**
  String get fitnessCustomImageTooLarge;

  /// No description provided for @fitnessCustomDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this custom exercise? Existing workout records will be kept.'**
  String get fitnessCustomDeleteConfirm;

  /// No description provided for @fitnessCustomLimit.
  ///
  /// In en, this message translates to:
  /// **'Custom exercise storage is full. Delete unused exercises or choose icons instead of images.'**
  String get fitnessCustomLimit;

  /// No description provided for @commonNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a visible name of at most {max} characters'**
  String commonNameInvalid(int max);

  /// No description provided for @appUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get appUpdateTitle;

  /// No description provided for @appUpdateNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Updates are not configured for this build yet.'**
  String get appUpdateNotConfigured;

  /// No description provided for @appUpdateUnsupported.
  ///
  /// In en, this message translates to:
  /// **'In-app updates are available for the official Android arm64 app only.'**
  String get appUpdateUnsupported;

  /// No description provided for @appUpdatePermission.
  ///
  /// In en, this message translates to:
  /// **'Allow this app to install updates in system settings, then return here to continue.'**
  String get appUpdatePermission;

  /// No description provided for @appUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed. Check your network and free storage, then retry.'**
  String get appUpdateFailed;

  /// No description provided for @appUpdateCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current version'**
  String get appUpdateCurrentVersion;

  /// No description provided for @appUpdateWorking.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get appUpdateWorking;

  /// No description provided for @appUpdateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get appUpdateDownloading;

  /// No description provided for @appUpdateLatest.
  ///
  /// In en, this message translates to:
  /// **'You are up to date.'**
  String get appUpdateLatest;

  /// No description provided for @appUpdateClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get appUpdateClose;

  /// No description provided for @appUpdateDownload.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get appUpdateDownload;

  /// No description provided for @appUpdateInstall.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get appUpdateInstall;

  /// No description provided for @syncCenterPullFailed.
  ///
  /// In en, this message translates to:
  /// **'Downloaded records could not be applied. Retry sync.'**
  String get syncCenterPullFailed;

  /// No description provided for @localBookMigrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Move local books to the cloud?'**
  String get localBookMigrationTitle;

  /// No description provided for @localBookMigrationMessage.
  ///
  /// In en, this message translates to:
  /// **'You have {count} local books across Accounting, Days, Memos, and Fitness. Move them to this account’s cloud and sync across devices? Choose Keep local to leave them on this device.'**
  String localBookMigrationMessage(int count);

  /// No description provided for @localBookMigrationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Move to cloud'**
  String get localBookMigrationConfirm;

  /// No description provided for @localBookMigrationKeepLocal.
  ///
  /// In en, this message translates to:
  /// **'Keep local'**
  String get localBookMigrationKeepLocal;

  /// No description provided for @localBookMigrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Migration could not be completed. Your local content is preserved. Please try again.'**
  String get localBookMigrationFailed;

  /// No description provided for @localBookMigrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Migration successful'**
  String get localBookMigrationSuccess;

  /// No description provided for @reminderExactPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow on-time reminders'**
  String get reminderExactPermissionTitle;

  /// No description provided for @memoSelectCredentials.
  ///
  /// In en, this message translates to:
  /// **'Select accounts'**
  String get memoSelectCredentials;

  /// No description provided for @memoSelectedEntries.
  ///
  /// In en, this message translates to:
  /// **'Selected {count} records'**
  String memoSelectedEntries(int count);

  /// No description provided for @memoPng.
  ///
  /// In en, this message translates to:
  /// **'Image (PNG)'**
  String get memoPng;

  /// No description provided for @memoPngTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The content is too long for a single image. Choose PDF, Word or Markdown.'**
  String get memoPngTooLarge;

  /// No description provided for @shellMemos.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get shellMemos;

  /// No description provided for @shellAddMoney.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get shellAddMoney;

  /// No description provided for @shellAddDay.
  ///
  /// In en, this message translates to:
  /// **'Add a day'**
  String get shellAddDay;

  /// No description provided for @shellMoneyDetails.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get shellMoneyDetails;

  /// No description provided for @shellAddMemo.
  ///
  /// In en, this message translates to:
  /// **'Write a note'**
  String get shellAddMemo;

  /// No description provided for @shellFitnessTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get shellFitnessTraining;

  /// No description provided for @shellMemoNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get shellMemoNotes;

  /// No description provided for @homeViewAnalytics.
  ///
  /// In en, this message translates to:
  /// **'View analytics'**
  String get homeViewAnalytics;

  /// No description provided for @shellFitnessPlans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get shellFitnessPlans;

  /// No description provided for @homeMonthlyBills.
  ///
  /// In en, this message translates to:
  /// **'{month} transactions'**
  String homeMonthlyBills(String month);

  /// No description provided for @shellMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get shellMoney;

  /// No description provided for @shellDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get shellDays;

  /// No description provided for @shellFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get shellFitness;

  /// No description provided for @shellChooseBook.
  ///
  /// In en, this message translates to:
  /// **'Switch book'**
  String get shellChooseBook;

  /// No description provided for @homeDailyExpenseTrend.
  ///
  /// In en, this message translates to:
  /// **'Daily expenses'**
  String get homeDailyExpenseTrend;

  /// No description provided for @shellChooseSpace.
  ///
  /// In en, this message translates to:
  /// **'Switch space'**
  String get shellChooseSpace;

  /// No description provided for @welcomeDomainsTitle.
  ///
  /// In en, this message translates to:
  /// **'Make room for everyday life'**
  String get welcomeDomainsTitle;

  /// No description provided for @appearanceThemeJournal.
  ///
  /// In en, this message translates to:
  /// **'Warm journal'**
  String get appearanceThemeJournal;

  /// No description provided for @appearanceThemeClassicDescription.
  ///
  /// In en, this message translates to:
  /// **'Brand blue and soft corners'**
  String get appearanceThemeClassicDescription;

  /// No description provided for @appearanceThemeMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal list'**
  String get appearanceThemeMinimal;

  /// No description provided for @appearanceThemeClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic blue'**
  String get appearanceThemeClassic;

  /// No description provided for @appearanceThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance & themes'**
  String get appearanceThemeTitle;

  /// No description provided for @appearanceThemeMinimalDescription.
  ///
  /// In en, this message translates to:
  /// **'Cool whites and defined edges'**
  String get appearanceThemeMinimalDescription;

  /// No description provided for @appearanceThemeJournalDescription.
  ///
  /// In en, this message translates to:
  /// **'Warm paper and forest green'**
  String get appearanceThemeJournalDescription;

  /// No description provided for @appearanceThemeSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Appearance applied, but preferences could not be saved. Try again.'**
  String get appearanceThemeSaveFailed;

  /// No description provided for @shellAddFitness.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get shellAddFitness;

  /// No description provided for @shellAddCalendar.
  ///
  /// In en, this message translates to:
  /// **'Record this day'**
  String get shellAddCalendar;

  /// No description provided for @fitnessCalendarPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get fitnessCalendarPlanned;

  /// No description provided for @fitnessCalendarRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get fitnessCalendarRest;

  /// No description provided for @txEditorContextUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This ledger or account has changed. Go back and reopen the entry; your input is still here.'**
  String get txEditorContextUnavailable;

  /// No description provided for @appearanceThemeIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose your visual style'**
  String get appearanceThemeIntro;

  /// No description provided for @appearanceThemeNote.
  ///
  /// In en, this message translates to:
  /// **'Style and display mode are independent. Changes apply immediately.'**
  String get appearanceThemeNote;

  /// No description provided for @dayHeroDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get dayHeroDaysBefore;

  /// No description provided for @dayHeroDaysAfter.
  ///
  /// In en, this message translates to:
  /// **'days away'**
  String get dayHeroDaysAfter;

  /// No description provided for @homeSummaryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load expense summary'**
  String get homeSummaryLoadFailed;

  /// No description provided for @homeSummaryCachedFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh; showing the last result'**
  String get homeSummaryCachedFailure;

  /// No description provided for @txAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than 0 with up to 2 decimal places.'**
  String get txAmountInvalid;

  /// No description provided for @txDivisionByZero.
  ///
  /// In en, this message translates to:
  /// **'Cannot divide by zero. Change the amount.'**
  String get txDivisionByZero;

  /// No description provided for @txExpressionInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a complete, valid expression.'**
  String get txExpressionInvalid;

  /// No description provided for @categoryConflictCloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud version'**
  String get categoryConflictCloud;

  /// No description provided for @categoryConflictChooseLocal.
  ///
  /// In en, this message translates to:
  /// **'Use the submitted local version? Later edits on this device will be preserved separately for further sync.'**
  String get categoryConflictChooseLocal;

  /// No description provided for @categoryTemplateRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore original categories'**
  String get categoryTemplateRestoreTitle;

  /// No description provided for @recurringTransactionTimeZone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get recurringTransactionTimeZone;

  /// No description provided for @categoryConflictSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted local version'**
  String get categoryConflictSubmitted;

  /// No description provided for @categoryTemplateRestoreMessage.
  ///
  /// In en, this message translates to:
  /// **'The original categories for these templates were deleted:\n{names}\nRestore the original categories and their settings? This creates no duplicate categories and restores no deleted transactions.'**
  String categoryTemplateRestoreMessage(String names);

  /// No description provided for @recurringTransactionTimeZoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Select a valid IANA time zone'**
  String get recurringTransactionTimeZoneInvalid;

  /// No description provided for @categoryTemplateRestoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restore originals'**
  String get categoryTemplateRestoreConfirm;

  /// No description provided for @categoryConflictRefreshRequired.
  ///
  /// In en, this message translates to:
  /// **'Version information is not ready. Reload it before making a decision.'**
  String get categoryConflictRefreshRequired;

  /// No description provided for @recurringTransactionAmountPrecision.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero, with up to 28 integer digits and 10 decimal places.'**
  String get recurringTransactionAmountPrecision;

  /// No description provided for @categoryConflictExplanation.
  ///
  /// In en, this message translates to:
  /// **'The local version is from this upload and excludes later edits. Choose which version to use for this category.'**
  String get categoryConflictExplanation;

  /// No description provided for @categoryConflictRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore deleted cloud category'**
  String get categoryConflictRestoreTitle;

  /// No description provided for @recurringTransactionTimeZoneLocked.
  ///
  /// In en, this message translates to:
  /// **'Transactions already exist. Create a new recurring rule to use another time zone.'**
  String get recurringTransactionTimeZoneLocked;

  /// No description provided for @categoryTemplatePendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Awaiting review'**
  String get categoryTemplatePendingLabel;

  /// No description provided for @categoryConflictRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry confirmation'**
  String get categoryConflictRetry;

  /// No description provided for @recurringTransactionDayOfWeek.
  ///
  /// In en, this message translates to:
  /// **'Day of the week'**
  String get recurringTransactionDayOfWeek;

  /// No description provided for @categoryConflictChooseCloud.
  ///
  /// In en, this message translates to:
  /// **'Use the displayed cloud version? The local submission in this conflict will not be applied. Later device edits will be preserved separately.'**
  String get categoryConflictChooseCloud;

  /// No description provided for @categoryTemplateNoChanges.
  ///
  /// In en, this message translates to:
  /// **'No categories were added or restored'**
  String get categoryTemplateNoChanges;

  /// No description provided for @categoryConflictDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm category deletion'**
  String get categoryConflictDeleteTitle;

  /// No description provided for @categoryConflictType.
  ///
  /// In en, this message translates to:
  /// **'Category type'**
  String get categoryConflictType;

  /// No description provided for @categoryConflictUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This version is unavailable. Reload it to continue.'**
  String get categoryConflictUnavailable;

  /// No description provided for @categoryTemplateBlockedParentHierarchy.
  ///
  /// In en, this message translates to:
  /// **'The original parent has changed level; this child cannot be added'**
  String get categoryTemplateBlockedParentHierarchy;

  /// No description provided for @categoryTemplateBlockedDuplicate.
  ///
  /// In en, this message translates to:
  /// **'A category with this name exists; this template was not added'**
  String get categoryTemplateBlockedDuplicate;

  /// No description provided for @categoryConflictChanged.
  ///
  /// In en, this message translates to:
  /// **'The category changed. Compare the refreshed versions before confirming again.'**
  String get categoryConflictChanged;

  /// No description provided for @categoryConflictUseLocal.
  ///
  /// In en, this message translates to:
  /// **'Use local version'**
  String get categoryConflictUseLocal;

  /// No description provided for @categoryTemplateBlockedParentDuplicate.
  ///
  /// In en, this message translates to:
  /// **'A parent with this name exists; this template was not added'**
  String get categoryTemplateBlockedParentDuplicate;

  /// No description provided for @categoryConflictPosition.
  ///
  /// In en, this message translates to:
  /// **'Sort value: {value}'**
  String categoryConflictPosition(String value);

  /// No description provided for @categoryConflictRestoreMessage.
  ///
  /// In en, this message translates to:
  /// **'This category was deleted in the cloud. Restore that same category using the submitted local version? A second category will not be created.'**
  String get categoryConflictRestoreMessage;

  /// No description provided for @categoryTemplateBlockedLabel.
  ///
  /// In en, this message translates to:
  /// **'Not added'**
  String get categoryTemplateBlockedLabel;

  /// No description provided for @categoryConflictRestore.
  ///
  /// In en, this message translates to:
  /// **'Confirm restore'**
  String get categoryConflictRestore;

  /// No description provided for @categoryConflictParentMissing.
  ///
  /// In en, this message translates to:
  /// **'Parent category has not been downloaded'**
  String get categoryConflictParentMissing;

  /// No description provided for @categoryConflictRefresh.
  ///
  /// In en, this message translates to:
  /// **'Reload versions'**
  String get categoryConflictRefresh;

  /// No description provided for @categoryTemplatePending.
  ///
  /// In en, this message translates to:
  /// **'{count} categories await cloud confirmation. Open Sync issues to review them.'**
  String categoryTemplatePending(int count);

  /// No description provided for @recurringTransactionIntervalInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an integer from 1 to 10000.'**
  String get recurringTransactionIntervalInvalid;

  /// No description provided for @categoryConflictDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'The local submission deletes this category. Applying it will delete the cloud category. Review both versions first.'**
  String get categoryConflictDeleteMessage;

  /// No description provided for @recurringTransactionMonthOfYear.
  ///
  /// In en, this message translates to:
  /// **'Month of the year'**
  String get recurringTransactionMonthOfYear;

  /// No description provided for @categoryTemplateRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored {count} original categories'**
  String categoryTemplateRestored(int count);

  /// No description provided for @recurringTransactionTimeZoneHint.
  ///
  /// In en, this message translates to:
  /// **'Generate by this time zone’s calendar dates, consistently across devices.'**
  String get recurringTransactionTimeZoneHint;

  /// No description provided for @categoryConflictPending.
  ///
  /// In en, this message translates to:
  /// **'The confirmation result has not arrived. Retry the original decision before choosing another version.'**
  String get categoryConflictPending;

  /// No description provided for @categoryConflictUseCloud.
  ///
  /// In en, this message translates to:
  /// **'Use cloud version'**
  String get categoryConflictUseCloud;

  /// No description provided for @reminderDaysDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders'**
  String get reminderDaysDailyTitle;

  /// No description provided for @reminderDaysDailyHint.
  ///
  /// In en, this message translates to:
  /// **'Uses the shared reminder time. Scheduled milestones take priority, with no duplicate reminders.'**
  String get reminderDaysDailyHint;

  /// No description provided for @reminderDaysDailySelect.
  ///
  /// In en, this message translates to:
  /// **'Select anniversaries (multiple)'**
  String get reminderDaysDailySelect;

  /// No description provided for @reminderDaysDailyChooseOne.
  ///
  /// In en, this message translates to:
  /// **'Select at least one birthday, anniversary or countdown.'**
  String get reminderDaysDailyChooseOne;

  /// No description provided for @reminderDaysDailyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No anniversaries available for daily reminders.'**
  String get reminderDaysDailyEmpty;

  /// No description provided for @reminderDaysDailyLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load anniversaries. Please try again.'**
  String get reminderDaysDailyLoadFailed;

  /// No description provided for @reminderDaysDailyAccountChanged.
  ///
  /// In en, this message translates to:
  /// **'Your account changed. Close this dialog and select again.'**
  String get reminderDaysDailyAccountChanged;

  /// No description provided for @syncCenterTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction · {category}'**
  String syncCenterTransactionTitle(String category);

  /// No description provided for @syncCenterCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Category · {name}'**
  String syncCenterCategoryTitle(String name);

  /// No description provided for @syncCenterBookContext.
  ///
  /// In en, this message translates to:
  /// **'Ledger: {name}'**
  String syncCenterBookContext(String name);

  /// No description provided for @syncCenterUnknownCategory.
  ///
  /// In en, this message translates to:
  /// **'Category name unavailable'**
  String get syncCenterUnknownCategory;

  /// No description provided for @syncCenterEntityTitle.
  ///
  /// In en, this message translates to:
  /// **'{type} · {name}'**
  String syncCenterEntityTitle(String type, String name);

  /// No description provided for @syncCenterTypeLedger.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get syncCenterTypeLedger;

  /// No description provided for @syncCenterTypeDayBook.
  ///
  /// In en, this message translates to:
  /// **'Anniversary book'**
  String get syncCenterTypeDayBook;

  /// No description provided for @syncCenterTypeDayEvent.
  ///
  /// In en, this message translates to:
  /// **'Anniversary'**
  String get syncCenterTypeDayEvent;

  /// No description provided for @syncCenterTypeMemoBook.
  ///
  /// In en, this message translates to:
  /// **'Memo book'**
  String get syncCenterTypeMemoBook;

  /// No description provided for @syncCenterTypeMemoEntry.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get syncCenterTypeMemoEntry;

  /// No description provided for @syncCenterTypeFitnessSpace.
  ///
  /// In en, this message translates to:
  /// **'Fitness space'**
  String get syncCenterTypeFitnessSpace;

  /// No description provided for @syncCenterTypeFitnessWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get syncCenterTypeFitnessWorkout;

  /// No description provided for @syncCenterTypeFitnessPlan.
  ///
  /// In en, this message translates to:
  /// **'Training plan'**
  String get syncCenterTypeFitnessPlan;

  /// No description provided for @syncCenterTypeFitnessTemplate.
  ///
  /// In en, this message translates to:
  /// **'Training template'**
  String get syncCenterTypeFitnessTemplate;

  /// No description provided for @syncCenterTypeMember.
  ///
  /// In en, this message translates to:
  /// **'Ledger member'**
  String get syncCenterTypeMember;

  /// No description provided for @syncCenterTypeRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring transaction'**
  String get syncCenterTypeRecurring;

  /// No description provided for @syncCenterTypeExchangeRate.
  ///
  /// In en, this message translates to:
  /// **'Exchange rate'**
  String get syncCenterTypeExchangeRate;

  /// No description provided for @syncCenterTypeRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get syncCenterTypeRecord;

  /// No description provided for @syncCenterPendingRecordHint.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device and waiting to upload.'**
  String get syncCenterPendingRecordHint;

  /// No description provided for @syncCenterAwaitingReceiptHint.
  ///
  /// In en, this message translates to:
  /// **'The upload result is not confirmed. Retrying uses the original request to continue syncing. Your local content is preserved.'**
  String get syncCenterAwaitingReceiptHint;

  /// No description provided for @syncCenterRecordUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The original content was deleted or cannot be read. Sync again and check.'**
  String get syncCenterRecordUnavailable;

  /// No description provided for @syncCenterLastFailure.
  ///
  /// In en, this message translates to:
  /// **'Last sync did not finish: {reason}'**
  String syncCenterLastFailure(String reason);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
