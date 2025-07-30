import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_de.dart';
import 'l10n_en.dart';
import 'l10n_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
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
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OpenNutriTracker'**
  String get appTitle;

  /// No description provided for @appVersionName.
  ///
  /// In en, this message translates to:
  /// **'Version {versionNumber}'**
  String appVersionName(Object versionNumber);

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'OpenNutriTracker is a free and open-source calorie and nutrient tracker that respects your privacy.'**
  String get appDescription;

  /// No description provided for @alphaVersionName.
  ///
  /// In en, this message translates to:
  /// **'[Alpha]'**
  String get alphaVersionName;

  /// No description provided for @betaVersionName.
  ///
  /// In en, this message translates to:
  /// **'[Beta]'**
  String get betaVersionName;

  /// No description provided for @addLabel.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addLabel;

  /// No description provided for @createCustomDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Create custom meal item?'**
  String get createCustomDialogTitle;

  /// No description provided for @createCustomDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Do you want create a custom meal item?'**
  String get createCustomDialogContent;

  /// No description provided for @settingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsLabel;

  /// No description provided for @homeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeLabel;

  /// No description provided for @diaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get diaryLabel;

  /// No description provided for @profileLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileLabel;

  /// No description provided for @chatLabel.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatLabel;

  /// No description provided for @searchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchLabel;

  /// No description provided for @searchProductsPage.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get searchProductsPage;

  /// No description provided for @searchFoodPage.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get searchFoodPage;

  /// No description provided for @searchResultsLabel.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get searchResultsLabel;

  /// No description provided for @searchDefaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Please enter a search word'**
  String get searchDefaultLabel;

  /// No description provided for @allItemsLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allItemsLabel;

  /// No description provided for @recentlyAddedLabel.
  ///
  /// In en, this message translates to:
  /// **'Recently'**
  String get recentlyAddedLabel;

  /// No description provided for @noMealsRecentlyAddedLabel.
  ///
  /// In en, this message translates to:
  /// **'No meals recently added'**
  String get noMealsRecentlyAddedLabel;

  /// No description provided for @noActivityRecentlyAddedLabel.
  ///
  /// In en, this message translates to:
  /// **'No activity recently added'**
  String get noActivityRecentlyAddedLabel;

  /// No description provided for @dialogOKLabel.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dialogOKLabel;

  /// No description provided for @dialogCancelLabel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get dialogCancelLabel;

  /// No description provided for @buttonStartLabel.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get buttonStartLabel;

  /// No description provided for @buttonNextLabel.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get buttonNextLabel;

  /// No description provided for @buttonSaveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSaveLabel;

  /// No description provided for @buttonYesLabel.
  ///
  /// In en, this message translates to:
  /// **'YES'**
  String get buttonYesLabel;

  /// No description provided for @buttonResetLabel.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get buttonResetLabel;

  /// No description provided for @onboardingWelcomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get onboardingWelcomeLabel;

  /// No description provided for @onboardingOverviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get onboardingOverviewLabel;

  /// No description provided for @onboardingYourGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Your calorie goal:'**
  String get onboardingYourGoalLabel;

  /// No description provided for @onboardingYourMacrosGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Your macronutrient goals:'**
  String get onboardingYourMacrosGoalLabel;

  /// No description provided for @onboardingKcalPerDayLabel.
  ///
  /// In en, this message translates to:
  /// **'kcal per day'**
  String get onboardingKcalPerDayLabel;

  /// No description provided for @onboardingIntroDescription.
  ///
  /// In en, this message translates to:
  /// **'To start, the app needs some information about you to calculate your daily calorie goal.\nAll information about you is stored securely on your device.'**
  String get onboardingIntroDescription;

  /// No description provided for @onboardingGenderQuestionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your gender?'**
  String get onboardingGenderQuestionSubtitle;

  /// No description provided for @onboardingEnterBirthdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get onboardingEnterBirthdayLabel;

  /// No description provided for @onboardingBirthdayHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Date'**
  String get onboardingBirthdayHint;

  /// No description provided for @onboardingBirthdayQuestionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When is your birthday?'**
  String get onboardingBirthdayQuestionSubtitle;

  /// No description provided for @onboardingHeightQuestionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Whats your current height?'**
  String get onboardingHeightQuestionSubtitle;

  /// No description provided for @onboardingWeightQuestionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Whats your current weight?'**
  String get onboardingWeightQuestionSubtitle;

  /// No description provided for @onboardingWrongHeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter correct height'**
  String get onboardingWrongHeightLabel;

  /// No description provided for @onboardingWrongWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter correct weight'**
  String get onboardingWrongWeightLabel;

  /// No description provided for @onboardingWeightExampleHintKg.
  ///
  /// In en, this message translates to:
  /// **'e.g. 60'**
  String get onboardingWeightExampleHintKg;

  /// No description provided for @onboardingWeightExampleHintLbs.
  ///
  /// In en, this message translates to:
  /// **'e.g. 132'**
  String get onboardingWeightExampleHintLbs;

  /// No description provided for @onboardingHeightExampleHintCm.
  ///
  /// In en, this message translates to:
  /// **'e.g. 170'**
  String get onboardingHeightExampleHintCm;

  /// No description provided for @onboardingHeightExampleHintFt.
  ///
  /// In en, this message translates to:
  /// **'e.g. 5.8'**
  String get onboardingHeightExampleHintFt;

  /// No description provided for @onboardingActivityQuestionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How active are you? (without workouts)'**
  String get onboardingActivityQuestionSubtitle;

  /// No description provided for @onboardingGoalQuestionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your current weight goal?'**
  String get onboardingGoalQuestionSubtitle;

  /// No description provided for @onboardingSaveUserError.
  ///
  /// In en, this message translates to:
  /// **'Wrong input, please try again'**
  String get onboardingSaveUserError;

  /// No description provided for @settingsUnitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get settingsUnitsLabel;

  /// No description provided for @settingsCalculationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Calculations'**
  String get settingsCalculationsLabel;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeLabel;

  /// No description provided for @settingsThemeLightLabel.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLightLabel;

  /// No description provided for @settingsThemeDarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDarkLabel;

  /// No description provided for @settingsThemeSystemDefaultLabel.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsThemeSystemDefaultLabel;

  /// No description provided for @settingsLicensesLabel.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get settingsLicensesLabel;

  /// No description provided for @settingsDisclaimerLabel.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get settingsDisclaimerLabel;

  /// No description provided for @settingsReportErrorLabel.
  ///
  /// In en, this message translates to:
  /// **'Report Error'**
  String get settingsReportErrorLabel;

  /// No description provided for @settingsPrivacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get settingsPrivacySettings;

  /// No description provided for @settingsSourceCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Source Code'**
  String get settingsSourceCodeLabel;

  /// No description provided for @settingFeedbackLabel.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get settingFeedbackLabel;

  /// No description provided for @settingAboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingAboutLabel;

  /// No description provided for @settingsMassLabel.
  ///
  /// In en, this message translates to:
  /// **'Mass'**
  String get settingsMassLabel;

  /// No description provided for @settingsSystemLabel.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsSystemLabel;

  /// No description provided for @settingsMetricLabel.
  ///
  /// In en, this message translates to:
  /// **'Metric (kg, cm, ml)'**
  String get settingsMetricLabel;

  /// No description provided for @settingsImperialLabel.
  ///
  /// In en, this message translates to:
  /// **'Imperial (lbs, ft, oz)'**
  String get settingsImperialLabel;

  /// No description provided for @settingsDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get settingsDistanceLabel;

  /// No description provided for @settingsVolumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get settingsVolumeLabel;

  /// No description provided for @disclaimerText.
  ///
  /// In en, this message translates to:
  /// **'OpenNutriTracker is not a medical application. All data provided is not validated and should be used with caution. Please maintain a healthy lifestyle and consult a professional if you have any problems. Use during illness, pregnancy or lactation is not recommended.'**
  String get disclaimerText;

  /// No description provided for @reportErrorDialogText.
  ///
  /// In en, this message translates to:
  /// **'Do you want to report an error to the developer?'**
  String get reportErrorDialogText;

  /// No description provided for @sendAnonymousUserData.
  ///
  /// In en, this message translates to:
  /// **'Send anonymous usage data'**
  String get sendAnonymousUserData;

  /// No description provided for @appLicenseLabel.
  ///
  /// In en, this message translates to:
  /// **'GPL-3.0 license'**
  String get appLicenseLabel;

  /// No description provided for @calculationsTDEELabel.
  ///
  /// In en, this message translates to:
  /// **'TDEE equation'**
  String get calculationsTDEELabel;

  /// No description provided for @calculationsTDEEIOM2006Label.
  ///
  /// In en, this message translates to:
  /// **'Institute of Medicine Equation'**
  String get calculationsTDEEIOM2006Label;

  /// No description provided for @calculationsRecommendedLabel.
  ///
  /// In en, this message translates to:
  /// **'(recommended)'**
  String get calculationsRecommendedLabel;

  /// No description provided for @calculationsMacronutrientsDistributionLabel.
  ///
  /// In en, this message translates to:
  /// **'Macros distribution'**
  String get calculationsMacronutrientsDistributionLabel;

  /// No description provided for @calculationsMacrosDistribution.
  ///
  /// In en, this message translates to:
  /// **'{pctCarbs}% carbs, {pctFats}% fats, {pctProteins}% proteins'**
  String calculationsMacrosDistribution(Object pctCarbs, Object pctFats, Object pctProteins);

  /// No description provided for @dailyKcalAdjustmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily Kcal adjustment:'**
  String get dailyKcalAdjustmentLabel;

  /// No description provided for @macroDistributionLabel.
  ///
  /// In en, this message translates to:
  /// **'Macronutrient Distribution:'**
  String get macroDistributionLabel;

  /// No description provided for @exportImportLabel.
  ///
  /// In en, this message translates to:
  /// **'Export / Import data'**
  String get exportImportLabel;

  /// No description provided for @exportImportDescription.
  ///
  /// In en, this message translates to:
  /// **'You can export the app data to a zip file and import it later. This is useful if you want to backup your data or transfer it to another device.\n\nThe app does not use any cloud service to store your data.'**
  String get exportImportDescription;

  /// No description provided for @exportImportSuccessLabel.
  ///
  /// In en, this message translates to:
  /// **'Export / Import successful'**
  String get exportImportSuccessLabel;

  /// No description provided for @exportImportErrorLabel.
  ///
  /// In en, this message translates to:
  /// **'Export / Import error'**
  String get exportImportErrorLabel;

  /// No description provided for @exportAction.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportAction;

  /// No description provided for @importAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importAction;

  /// No description provided for @addItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Add new Item:'**
  String get addItemLabel;

  /// No description provided for @activityLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityLabel;

  /// No description provided for @activityExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. running, biking, yoga ...'**
  String get activityExample;

  /// No description provided for @breakfastLabel.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfastLabel;

  /// No description provided for @breakfastExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. cereal, milk, coffee ...'**
  String get breakfastExample;

  /// No description provided for @lunchLabel.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunchLabel;

  /// No description provided for @lunchExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. pizza, salad, rice ...'**
  String get lunchExample;

  /// No description provided for @dinnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinnerLabel;

  /// No description provided for @dinnerExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. soup, chicken, wine ...'**
  String get dinnerExample;

  /// No description provided for @snackLabel.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snackLabel;

  /// No description provided for @snackExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. apple, ice cream, chocolate ...'**
  String get snackExample;

  /// No description provided for @editItemDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get editItemDialogTitle;

  /// No description provided for @itemUpdatedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Item updated'**
  String get itemUpdatedSnackbar;

  /// No description provided for @aiProcessingMessage.
  ///
  /// In en, this message translates to:
  /// **'AI is processing your message...'**
  String get aiProcessingMessage;

  /// No description provided for @deleteTimeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Item?'**
  String get deleteTimeDialogTitle;

  /// No description provided for @deleteTimeDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Do want to delete the selected item?'**
  String get deleteTimeDialogContent;

  /// No description provided for @deleteTimeDialogPluralTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Items?'**
  String get deleteTimeDialogPluralTitle;

  /// No description provided for @deleteTimeDialogPluralContent.
  ///
  /// In en, this message translates to:
  /// **'Do want to delete all items of this meal?'**
  String get deleteTimeDialogPluralContent;

  /// No description provided for @itemDeletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Item deleted'**
  String get itemDeletedSnackbar;

  /// No description provided for @copyDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Which meal type do you want to copy to?'**
  String get copyDialogTitle;

  /// No description provided for @copyOrDeleteTimeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you want to do?'**
  String get copyOrDeleteTimeDialogTitle;

  /// No description provided for @copyOrDeleteTimeDialogContent.
  ///
  /// In en, this message translates to:
  /// **'With \"Copy to today\" you can copy the meal to today. With \"Delete\" you can delete the meal.'**
  String get copyOrDeleteTimeDialogContent;

  /// No description provided for @dialogCopyLabel.
  ///
  /// In en, this message translates to:
  /// **'Copy to today'**
  String get dialogCopyLabel;

  /// No description provided for @dialogDeleteLabel.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get dialogDeleteLabel;

  /// No description provided for @deleteAllLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAllLabel;

  /// No description provided for @suppliedLabel.
  ///
  /// In en, this message translates to:
  /// **'supplied'**
  String get suppliedLabel;

  /// No description provided for @burnedLabel.
  ///
  /// In en, this message translates to:
  /// **'burned'**
  String get burnedLabel;

  /// No description provided for @kcalLeftLabel.
  ///
  /// In en, this message translates to:
  /// **'kcal left'**
  String get kcalLeftLabel;

  /// No description provided for @nutritionInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Information'**
  String get nutritionInfoLabel;

  /// No description provided for @kcalLabel.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcalLabel;

  /// No description provided for @carbsLabel.
  ///
  /// In en, this message translates to:
  /// **'carbs'**
  String get carbsLabel;

  /// No description provided for @fatLabel.
  ///
  /// In en, this message translates to:
  /// **'fat'**
  String get fatLabel;

  /// No description provided for @proteinLabel.
  ///
  /// In en, this message translates to:
  /// **'protein'**
  String get proteinLabel;

  /// No description provided for @energyLabel.
  ///
  /// In en, this message translates to:
  /// **'energy'**
  String get energyLabel;

  /// No description provided for @saturatedFatLabel.
  ///
  /// In en, this message translates to:
  /// **'saturated fat'**
  String get saturatedFatLabel;

  /// No description provided for @carbohydrateLabel.
  ///
  /// In en, this message translates to:
  /// **'carbohydrate'**
  String get carbohydrateLabel;

  /// No description provided for @sugarLabel.
  ///
  /// In en, this message translates to:
  /// **'sugar'**
  String get sugarLabel;

  /// No description provided for @fiberLabel.
  ///
  /// In en, this message translates to:
  /// **'fiber'**
  String get fiberLabel;

  /// No description provided for @per100gmlLabel.
  ///
  /// In en, this message translates to:
  /// **'Per 100g/ml'**
  String get per100gmlLabel;

  /// No description provided for @additionalInfoLabelOFF.
  ///
  /// In en, this message translates to:
  /// **'More Information at\nOpenFoodFacts'**
  String get additionalInfoLabelOFF;

  /// No description provided for @offDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'The data provided to you by this app are retrieved from the Open Food Facts database. No guarantees can be made for the accuracy, completeness, or reliability of the information provided. The data are provided “as is” and the originating source for the data (Open Food Facts) is not liable for any damages arising out of the use of the data.'**
  String get offDisclaimer;

  /// No description provided for @additionalInfoLabelFDC.
  ///
  /// In en, this message translates to:
  /// **'More Information at\nFoodData Central'**
  String get additionalInfoLabelFDC;

  /// No description provided for @additionalInfoLabelUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown Meal Item'**
  String get additionalInfoLabelUnknown;

  /// No description provided for @additionalInfoLabelCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom Meal Item'**
  String get additionalInfoLabelCustom;

  /// No description provided for @additionalInfoLabelCompendium2011.
  ///
  /// In en, this message translates to:
  /// **'Information provided\n by the \n\'2011 Compendium\n of Physical Activities\''**
  String get additionalInfoLabelCompendium2011;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @baseQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Base quantity (g/ml)'**
  String get baseQuantityLabel;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitLabel;

  /// No description provided for @scanProductLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan Product'**
  String get scanProductLabel;

  /// No description provided for @gramUnit.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get gramUnit;

  /// No description provided for @milliliterUnit.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get milliliterUnit;

  /// No description provided for @gramMilliliterUnit.
  ///
  /// In en, this message translates to:
  /// **'g/ml'**
  String get gramMilliliterUnit;

  /// No description provided for @ozUnit.
  ///
  /// In en, this message translates to:
  /// **'oz'**
  String get ozUnit;

  /// No description provided for @flOzUnit.
  ///
  /// In en, this message translates to:
  /// **'fl.oz'**
  String get flOzUnit;

  /// No description provided for @notAvailableLabel.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailableLabel;

  /// No description provided for @missingProductInfo.
  ///
  /// In en, this message translates to:
  /// **'Product missing required kcal or macronutrients information'**
  String get missingProductInfo;

  /// No description provided for @infoAddedIntakeLabel.
  ///
  /// In en, this message translates to:
  /// **'Added new intake'**
  String get infoAddedIntakeLabel;

  /// No description provided for @infoAddedActivityLabel.
  ///
  /// In en, this message translates to:
  /// **'Added new activity'**
  String get infoAddedActivityLabel;

  /// No description provided for @editMealLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit meal'**
  String get editMealLabel;

  /// No description provided for @mealNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal name'**
  String get mealNameLabel;

  /// No description provided for @mealBrandsLabel.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get mealBrandsLabel;

  /// No description provided for @mealSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal size (g/ml)'**
  String get mealSizeLabel;

  /// No description provided for @mealSizeLabelImperial.
  ///
  /// In en, this message translates to:
  /// **'Meal size (oz/fl oz)'**
  String get mealSizeLabelImperial;

  /// No description provided for @servingLabel.
  ///
  /// In en, this message translates to:
  /// **'Serving'**
  String get servingLabel;

  /// No description provided for @perServingLabel.
  ///
  /// In en, this message translates to:
  /// **'Per Serving'**
  String get perServingLabel;

  /// No description provided for @servingSizeLabelMetric.
  ///
  /// In en, this message translates to:
  /// **'Serving size (g/ml)'**
  String get servingSizeLabelMetric;

  /// No description provided for @servingSizeLabelImperial.
  ///
  /// In en, this message translates to:
  /// **'Serving size (oz/fl oz)'**
  String get servingSizeLabelImperial;

  /// No description provided for @mealUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal unit'**
  String get mealUnitLabel;

  /// No description provided for @mealKcalLabel.
  ///
  /// In en, this message translates to:
  /// **'kcal per'**
  String get mealKcalLabel;

  /// No description provided for @mealCarbsLabel.
  ///
  /// In en, this message translates to:
  /// **'carbs per'**
  String get mealCarbsLabel;

  /// No description provided for @mealFatLabel.
  ///
  /// In en, this message translates to:
  /// **'fat per'**
  String get mealFatLabel;

  /// No description provided for @mealProteinLabel.
  ///
  /// In en, this message translates to:
  /// **'protein per 100 g/ml'**
  String get mealProteinLabel;

  /// No description provided for @errorMealSave.
  ///
  /// In en, this message translates to:
  /// **'Error while saving meal. Did you input the correct meal information?'**
  String get errorMealSave;

  /// No description provided for @bmiLabel.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmiLabel;

  /// No description provided for @bmiInfo.
  ///
  /// In en, this message translates to:
  /// **'Body Mass Index (BMI) is a index to classify overweight and obesity in adults. It is defined as weight in kilograms divided by the square of height in meters (kg/m²).\n\nBMI does not differentiate between fat and muscle mass and can be misleading for some individuals.'**
  String get bmiInfo;

  /// No description provided for @readLabel.
  ///
  /// In en, this message translates to:
  /// **'I have read and accept the privacy policy.'**
  String get readLabel;

  /// No description provided for @privacyPolicyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicyLabel;

  /// No description provided for @dataCollectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Support development by providing anonymous usage data'**
  String get dataCollectionLabel;

  /// No description provided for @palSedentaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get palSedentaryLabel;

  /// No description provided for @palSedentaryDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'e.g. office job and mostly sitting free time activities'**
  String get palSedentaryDescriptionLabel;

  /// No description provided for @palLowLActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Low Active'**
  String get palLowLActiveLabel;

  /// No description provided for @palLowActiveDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'e.g. sitting or standing in job and light free time activities'**
  String get palLowActiveDescriptionLabel;

  /// No description provided for @palActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get palActiveLabel;

  /// No description provided for @palActiveDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Mostly standing or walking in job and active free time activities'**
  String get palActiveDescriptionLabel;

  /// No description provided for @palVeryActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Very Active'**
  String get palVeryActiveLabel;

  /// No description provided for @palVeryActiveDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Mostly walking, running or carrying weight in job and active free time activities'**
  String get palVeryActiveDescriptionLabel;

  /// No description provided for @selectPalCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Activity Level'**
  String get selectPalCategoryLabel;

  /// No description provided for @chooseWeightGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose Weight Goal'**
  String get chooseWeightGoalLabel;

  /// No description provided for @goalLoseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose Weight'**
  String get goalLoseWeight;

  /// No description provided for @goalMaintainWeight.
  ///
  /// In en, this message translates to:
  /// **'Maintain Weight'**
  String get goalMaintainWeight;

  /// No description provided for @goalGainWeight.
  ///
  /// In en, this message translates to:
  /// **'Gain Weight'**
  String get goalGainWeight;

  /// No description provided for @goalLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goalLabel;

  /// No description provided for @selectHeightDialogLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Height'**
  String get selectHeightDialogLabel;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightLabel;

  /// No description provided for @cmLabel.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cmLabel;

  /// No description provided for @ftLabel.
  ///
  /// In en, this message translates to:
  /// **'ft'**
  String get ftLabel;

  /// No description provided for @selectWeightDialogLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Weight'**
  String get selectWeightDialogLabel;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightLabel;

  /// No description provided for @kgLabel.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kgLabel;

  /// No description provided for @lbsLabel.
  ///
  /// In en, this message translates to:
  /// **'lbs'**
  String get lbsLabel;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @yearsLabel.
  ///
  /// In en, this message translates to:
  /// **'{age} years'**
  String yearsLabel(Object age);

  /// No description provided for @selectGenderDialogLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGenderDialogLabel;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @genderMaleLabel.
  ///
  /// In en, this message translates to:
  /// **'♂ male'**
  String get genderMaleLabel;

  /// No description provided for @genderFemaleLabel.
  ///
  /// In en, this message translates to:
  /// **'♀ female'**
  String get genderFemaleLabel;

  /// No description provided for @nothingAddedLabel.
  ///
  /// In en, this message translates to:
  /// **'Nothing added'**
  String get nothingAddedLabel;

  /// No description provided for @nutritionalStatusUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get nutritionalStatusUnderweight;

  /// No description provided for @nutritionalStatusNormalWeight.
  ///
  /// In en, this message translates to:
  /// **'Normal Weight'**
  String get nutritionalStatusNormalWeight;

  /// No description provided for @nutritionalStatusPreObesity.
  ///
  /// In en, this message translates to:
  /// **'Pre-obesity'**
  String get nutritionalStatusPreObesity;

  /// No description provided for @nutritionalStatusObeseClassI.
  ///
  /// In en, this message translates to:
  /// **'Obesity Class I'**
  String get nutritionalStatusObeseClassI;

  /// No description provided for @nutritionalStatusObeseClassII.
  ///
  /// In en, this message translates to:
  /// **'Obesity Class II'**
  String get nutritionalStatusObeseClassII;

  /// No description provided for @nutritionalStatusObeseClassIII.
  ///
  /// In en, this message translates to:
  /// **'Obesity Class III'**
  String get nutritionalStatusObeseClassIII;

  /// No description provided for @nutritionalStatusRiskLabel.
  ///
  /// In en, this message translates to:
  /// **'Risk of comorbidities: {riskValue}'**
  String nutritionalStatusRiskLabel(Object riskValue);

  /// No description provided for @nutritionalStatusRiskLow.
  ///
  /// In en, this message translates to:
  /// **'Low \n(but risk of other \nclinical problems increased)'**
  String get nutritionalStatusRiskLow;

  /// No description provided for @nutritionalStatusRiskAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get nutritionalStatusRiskAverage;

  /// No description provided for @nutritionalStatusRiskIncreased.
  ///
  /// In en, this message translates to:
  /// **'Increased'**
  String get nutritionalStatusRiskIncreased;

  /// No description provided for @nutritionalStatusRiskModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get nutritionalStatusRiskModerate;

  /// No description provided for @nutritionalStatusRiskSevere.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get nutritionalStatusRiskSevere;

  /// No description provided for @nutritionalStatusRiskVerySevere.
  ///
  /// In en, this message translates to:
  /// **'Very severe'**
  String get nutritionalStatusRiskVerySevere;

  /// No description provided for @errorOpeningEmail.
  ///
  /// In en, this message translates to:
  /// **'Error while opening email app'**
  String get errorOpeningEmail;

  /// No description provided for @errorOpeningBrowser.
  ///
  /// In en, this message translates to:
  /// **'Error while opening browser app'**
  String get errorOpeningBrowser;

  /// No description provided for @errorFetchingProductData.
  ///
  /// In en, this message translates to:
  /// **'Error while fetching product data'**
  String get errorFetchingProductData;

  /// No description provided for @errorProductNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get errorProductNotFound;

  /// No description provided for @errorLoadingActivities.
  ///
  /// In en, this message translates to:
  /// **'Error while loading activities'**
  String get errorLoadingActivities;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @retryLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryLabel;

  /// No description provided for @paHeadingBicycling.
  ///
  /// In en, this message translates to:
  /// **'bicycling'**
  String get paHeadingBicycling;

  /// No description provided for @paHeadingConditionalExercise.
  ///
  /// In en, this message translates to:
  /// **'conditioning exercise'**
  String get paHeadingConditionalExercise;

  /// No description provided for @paHeadingDancing.
  ///
  /// In en, this message translates to:
  /// **'dancing'**
  String get paHeadingDancing;

  /// No description provided for @paHeadingRunning.
  ///
  /// In en, this message translates to:
  /// **'running'**
  String get paHeadingRunning;

  /// No description provided for @paHeadingSports.
  ///
  /// In en, this message translates to:
  /// **'sports'**
  String get paHeadingSports;

  /// No description provided for @paHeadingWalking.
  ///
  /// In en, this message translates to:
  /// **'walking'**
  String get paHeadingWalking;

  /// No description provided for @paHeadingWaterActivities.
  ///
  /// In en, this message translates to:
  /// **'water activities'**
  String get paHeadingWaterActivities;

  /// No description provided for @paHeadingWinterActivities.
  ///
  /// In en, this message translates to:
  /// **'winter activities'**
  String get paHeadingWinterActivities;

  /// No description provided for @paGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paGeneralDesc;

  /// No description provided for @paBicyclingGeneral.
  ///
  /// In en, this message translates to:
  /// **'bicycling'**
  String get paBicyclingGeneral;

  /// No description provided for @paBicyclingGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paBicyclingGeneralDesc;

  /// No description provided for @paBicyclingMountainGeneral.
  ///
  /// In en, this message translates to:
  /// **'bicycling, mountain'**
  String get paBicyclingMountainGeneral;

  /// No description provided for @paBicyclingMountainGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paBicyclingMountainGeneralDesc;

  /// No description provided for @paUnicyclingGeneral.
  ///
  /// In en, this message translates to:
  /// **'unicycling'**
  String get paUnicyclingGeneral;

  /// No description provided for @paUnicyclingGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paUnicyclingGeneralDesc;

  /// No description provided for @paBicyclingStationaryGeneral.
  ///
  /// In en, this message translates to:
  /// **'bicycling, stationary'**
  String get paBicyclingStationaryGeneral;

  /// No description provided for @paBicyclingStationaryGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paBicyclingStationaryGeneralDesc;

  /// No description provided for @paCalisthenicsGeneral.
  ///
  /// In en, this message translates to:
  /// **'calisthenics'**
  String get paCalisthenicsGeneral;

  /// No description provided for @paCalisthenicsGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'light or moderate effort, general (e.g., back exercises)'**
  String get paCalisthenicsGeneralDesc;

  /// No description provided for @paResistanceTraining.
  ///
  /// In en, this message translates to:
  /// **'resistance training'**
  String get paResistanceTraining;

  /// No description provided for @paResistanceTrainingDesc.
  ///
  /// In en, this message translates to:
  /// **'weight lifting, free weight, nautilus or universal'**
  String get paResistanceTrainingDesc;

  /// No description provided for @paRopeSkippingGeneral.
  ///
  /// In en, this message translates to:
  /// **'rope skipping'**
  String get paRopeSkippingGeneral;

  /// No description provided for @paRopeSkippingGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paRopeSkippingGeneralDesc;

  /// No description provided for @paWaterAerobics.
  ///
  /// In en, this message translates to:
  /// **'water exercise'**
  String get paWaterAerobics;

  /// No description provided for @paWaterAerobicsDesc.
  ///
  /// In en, this message translates to:
  /// **'water aerobics, water calisthenics'**
  String get paWaterAerobicsDesc;

  /// No description provided for @paDancingAerobicGeneral.
  ///
  /// In en, this message translates to:
  /// **'aerobic'**
  String get paDancingAerobicGeneral;

  /// No description provided for @paDancingAerobicGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paDancingAerobicGeneralDesc;

  /// No description provided for @paDancingGeneral.
  ///
  /// In en, this message translates to:
  /// **'general dancing'**
  String get paDancingGeneral;

  /// No description provided for @paDancingGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'e.g. disco, folk, Irish step dancing, line dancing, polka, contra, country'**
  String get paDancingGeneralDesc;

  /// No description provided for @paJoggingGeneral.
  ///
  /// In en, this message translates to:
  /// **'jogging'**
  String get paJoggingGeneral;

  /// No description provided for @paJoggingGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paJoggingGeneralDesc;

  /// No description provided for @paRunningGeneral.
  ///
  /// In en, this message translates to:
  /// **'running'**
  String get paRunningGeneral;

  /// No description provided for @paRunningGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paRunningGeneralDesc;

  /// No description provided for @paArcheryGeneral.
  ///
  /// In en, this message translates to:
  /// **'archery'**
  String get paArcheryGeneral;

  /// No description provided for @paArcheryGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'non-hunting'**
  String get paArcheryGeneralDesc;

  /// No description provided for @paBadmintonGeneral.
  ///
  /// In en, this message translates to:
  /// **'badminton'**
  String get paBadmintonGeneral;

  /// No description provided for @paBadmintonGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'social singles and doubles, general'**
  String get paBadmintonGeneralDesc;

  /// No description provided for @paBasketballGeneral.
  ///
  /// In en, this message translates to:
  /// **'basketball'**
  String get paBasketballGeneral;

  /// No description provided for @paBasketballGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paBasketballGeneralDesc;

  /// No description provided for @paBilliardsGeneral.
  ///
  /// In en, this message translates to:
  /// **'billiards'**
  String get paBilliardsGeneral;

  /// No description provided for @paBilliardsGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paBilliardsGeneralDesc;

  /// No description provided for @paBowlingGeneral.
  ///
  /// In en, this message translates to:
  /// **'bowling'**
  String get paBowlingGeneral;

  /// No description provided for @paBowlingGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paBowlingGeneralDesc;

  /// No description provided for @paBoxingBag.
  ///
  /// In en, this message translates to:
  /// **'boxing'**
  String get paBoxingBag;

  /// No description provided for @paBoxingBagDesc.
  ///
  /// In en, this message translates to:
  /// **'punching bag'**
  String get paBoxingBagDesc;

  /// No description provided for @paBoxingGeneral.
  ///
  /// In en, this message translates to:
  /// **'boxing'**
  String get paBoxingGeneral;

  /// No description provided for @paBoxingGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'in ring, general'**
  String get paBoxingGeneralDesc;

  /// No description provided for @paBroomball.
  ///
  /// In en, this message translates to:
  /// **'broomball'**
  String get paBroomball;

  /// No description provided for @paBroomballDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paBroomballDesc;

  /// No description provided for @paChildrenGame.
  ///
  /// In en, this message translates to:
  /// **'children’s games'**
  String get paChildrenGame;

  /// No description provided for @paChildrenGameDesc.
  ///
  /// In en, this message translates to:
  /// **'(e.g., hopscotch, 4-square, dodgeball, playground apparatus, t-ball, tetherball, marbles, arcade games), moderate effort'**
  String get paChildrenGameDesc;

  /// No description provided for @paCheerleading.
  ///
  /// In en, this message translates to:
  /// **'cheerleading'**
  String get paCheerleading;

  /// No description provided for @paCheerleadingDesc.
  ///
  /// In en, this message translates to:
  /// **'gymnastic moves, competitive'**
  String get paCheerleadingDesc;

  /// No description provided for @paCricket.
  ///
  /// In en, this message translates to:
  /// **'cricket'**
  String get paCricket;

  /// No description provided for @paCricketDesc.
  ///
  /// In en, this message translates to:
  /// **'batting, bowling, fielding'**
  String get paCricketDesc;

  /// No description provided for @paCroquet.
  ///
  /// In en, this message translates to:
  /// **'croquet'**
  String get paCroquet;

  /// No description provided for @paCroquetDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paCroquetDesc;

  /// No description provided for @paCurling.
  ///
  /// In en, this message translates to:
  /// **'curling'**
  String get paCurling;

  /// No description provided for @paCurlingDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paCurlingDesc;

  /// No description provided for @paDartsWall.
  ///
  /// In en, this message translates to:
  /// **'darts'**
  String get paDartsWall;

  /// No description provided for @paDartsWallDesc.
  ///
  /// In en, this message translates to:
  /// **'wall or lawn'**
  String get paDartsWallDesc;

  /// No description provided for @paAutoRacing.
  ///
  /// In en, this message translates to:
  /// **'auto racing'**
  String get paAutoRacing;

  /// No description provided for @paAutoRacingDesc.
  ///
  /// In en, this message translates to:
  /// **'open wheel'**
  String get paAutoRacingDesc;

  /// No description provided for @paFencing.
  ///
  /// In en, this message translates to:
  /// **'fencing'**
  String get paFencing;

  /// No description provided for @paFencingDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paFencingDesc;

  /// No description provided for @paAmericanFootballGeneral.
  ///
  /// In en, this message translates to:
  /// **'football'**
  String get paAmericanFootballGeneral;

  /// No description provided for @paAmericanFootballGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'touch, flag, general'**
  String get paAmericanFootballGeneralDesc;

  /// No description provided for @paCatch.
  ///
  /// In en, this message translates to:
  /// **'football or baseball'**
  String get paCatch;

  /// No description provided for @paCatchDesc.
  ///
  /// In en, this message translates to:
  /// **'playing catch'**
  String get paCatchDesc;

  /// No description provided for @paFrisbee.
  ///
  /// In en, this message translates to:
  /// **'frisbee playing'**
  String get paFrisbee;

  /// No description provided for @paFrisbeeDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paFrisbeeDesc;

  /// No description provided for @paGolfGeneral.
  ///
  /// In en, this message translates to:
  /// **'golf'**
  String get paGolfGeneral;

  /// No description provided for @paGolfGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paGolfGeneralDesc;

  /// No description provided for @paGymnasticsGeneral.
  ///
  /// In en, this message translates to:
  /// **'gymnastics'**
  String get paGymnasticsGeneral;

  /// No description provided for @paGymnasticsGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paGymnasticsGeneralDesc;

  /// No description provided for @paHackySack.
  ///
  /// In en, this message translates to:
  /// **'hacky sack'**
  String get paHackySack;

  /// No description provided for @paHackySackDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paHackySackDesc;

  /// No description provided for @paHandballGeneral.
  ///
  /// In en, this message translates to:
  /// **'handball'**
  String get paHandballGeneral;

  /// No description provided for @paHandballGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paHandballGeneralDesc;

  /// No description provided for @paHangGliding.
  ///
  /// In en, this message translates to:
  /// **'hang gliding'**
  String get paHangGliding;

  /// No description provided for @paHangGlidingDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paHangGlidingDesc;

  /// No description provided for @paHockeyField.
  ///
  /// In en, this message translates to:
  /// **'hockey, field'**
  String get paHockeyField;

  /// No description provided for @paHockeyFieldDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paHockeyFieldDesc;

  /// No description provided for @paIceHockeyGeneral.
  ///
  /// In en, this message translates to:
  /// **'ice hockey'**
  String get paIceHockeyGeneral;

  /// No description provided for @paIceHockeyGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paIceHockeyGeneralDesc;

  /// No description provided for @paHorseRidingGeneral.
  ///
  /// In en, this message translates to:
  /// **'horseback riding'**
  String get paHorseRidingGeneral;

  /// No description provided for @paHorseRidingGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paHorseRidingGeneralDesc;

  /// No description provided for @paJaiAlai.
  ///
  /// In en, this message translates to:
  /// **'jai alai'**
  String get paJaiAlai;

  /// No description provided for @paJaiAlaiDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paJaiAlaiDesc;

  /// No description provided for @paMartialArtsSlower.
  ///
  /// In en, this message translates to:
  /// **'martial arts'**
  String get paMartialArtsSlower;

  /// No description provided for @paMartialArtsSlowerDesc.
  ///
  /// In en, this message translates to:
  /// **'different types, slower pace, novice performers, practice'**
  String get paMartialArtsSlowerDesc;

  /// No description provided for @paMartialArtsModerate.
  ///
  /// In en, this message translates to:
  /// **'martial arts'**
  String get paMartialArtsModerate;

  /// No description provided for @paMartialArtsModerateDesc.
  ///
  /// In en, this message translates to:
  /// **'different types, moderate pace (e.g., judo, jujitsu, karate, kick boxing, tae kwan do, tai-bo, Muay Thai boxing)'**
  String get paMartialArtsModerateDesc;

  /// No description provided for @paJuggling.
  ///
  /// In en, this message translates to:
  /// **'juggling'**
  String get paJuggling;

  /// No description provided for @paJugglingDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paJugglingDesc;

  /// No description provided for @paKickball.
  ///
  /// In en, this message translates to:
  /// **'kickball'**
  String get paKickball;

  /// No description provided for @paKickballDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paKickballDesc;

  /// No description provided for @paLacrosse.
  ///
  /// In en, this message translates to:
  /// **'lacrosse'**
  String get paLacrosse;

  /// No description provided for @paLacrosseDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paLacrosseDesc;

  /// No description provided for @paLawnBowling.
  ///
  /// In en, this message translates to:
  /// **'lawn bowling'**
  String get paLawnBowling;

  /// No description provided for @paLawnBowlingDesc.
  ///
  /// In en, this message translates to:
  /// **'bocce ball, outdoor'**
  String get paLawnBowlingDesc;

  /// No description provided for @paMotoCross.
  ///
  /// In en, this message translates to:
  /// **'moto-cross'**
  String get paMotoCross;

  /// No description provided for @paMotoCrossDesc.
  ///
  /// In en, this message translates to:
  /// **'off-road motor sports, all-terrain vehicle, general'**
  String get paMotoCrossDesc;

  /// No description provided for @paOrienteering.
  ///
  /// In en, this message translates to:
  /// **'orienteering'**
  String get paOrienteering;

  /// No description provided for @paOrienteeringDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paOrienteeringDesc;

  /// No description provided for @paPaddleball.
  ///
  /// In en, this message translates to:
  /// **'paddleball'**
  String get paPaddleball;

  /// No description provided for @paPaddleballDesc.
  ///
  /// In en, this message translates to:
  /// **'casual, general'**
  String get paPaddleballDesc;

  /// No description provided for @paPoloHorse.
  ///
  /// In en, this message translates to:
  /// **'polo'**
  String get paPoloHorse;

  /// No description provided for @paPoloHorseDesc.
  ///
  /// In en, this message translates to:
  /// **'on horseback'**
  String get paPoloHorseDesc;

  /// No description provided for @paRacquetball.
  ///
  /// In en, this message translates to:
  /// **'racquetball'**
  String get paRacquetball;

  /// No description provided for @paRacquetballDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paRacquetballDesc;

  /// No description provided for @paMountainClimbing.
  ///
  /// In en, this message translates to:
  /// **'climbing'**
  String get paMountainClimbing;

  /// No description provided for @paMountainClimbingDesc.
  ///
  /// In en, this message translates to:
  /// **'rock or mountain climbing'**
  String get paMountainClimbingDesc;

  /// No description provided for @paRodeoSportGeneralModerate.
  ///
  /// In en, this message translates to:
  /// **'rodeo sports'**
  String get paRodeoSportGeneralModerate;

  /// No description provided for @paRodeoSportGeneralModerateDesc.
  ///
  /// In en, this message translates to:
  /// **'general, moderate effort'**
  String get paRodeoSportGeneralModerateDesc;

  /// No description provided for @paRopeJumpingGeneral.
  ///
  /// In en, this message translates to:
  /// **'rope jumping'**
  String get paRopeJumpingGeneral;

  /// No description provided for @paRopeJumpingGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'moderate pace, 100-120 skips/min, general, 2 foot skip, plain bounce'**
  String get paRopeJumpingGeneralDesc;

  /// No description provided for @paRugbyCompetitive.
  ///
  /// In en, this message translates to:
  /// **'rugby'**
  String get paRugbyCompetitive;

  /// No description provided for @paRugbyCompetitiveDesc.
  ///
  /// In en, this message translates to:
  /// **'union, team, competitive'**
  String get paRugbyCompetitiveDesc;

  /// No description provided for @paRugbyNonCompetitive.
  ///
  /// In en, this message translates to:
  /// **'rugby'**
  String get paRugbyNonCompetitive;

  /// No description provided for @paRugbyNonCompetitiveDesc.
  ///
  /// In en, this message translates to:
  /// **'touch, non-competitive'**
  String get paRugbyNonCompetitiveDesc;

  /// No description provided for @paShuffleboard.
  ///
  /// In en, this message translates to:
  /// **'shuffleboard'**
  String get paShuffleboard;

  /// No description provided for @paShuffleboardDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paShuffleboardDesc;

  /// No description provided for @paSkateboardingGeneral.
  ///
  /// In en, this message translates to:
  /// **'skateboarding'**
  String get paSkateboardingGeneral;

  /// No description provided for @paSkateboardingGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general, moderate effort'**
  String get paSkateboardingGeneralDesc;

  /// No description provided for @paSkatingRoller.
  ///
  /// In en, this message translates to:
  /// **'roller skating'**
  String get paSkatingRoller;

  /// No description provided for @paSkatingRollerDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paSkatingRollerDesc;

  /// No description provided for @paRollerbladingLight.
  ///
  /// In en, this message translates to:
  /// **'rollerblading'**
  String get paRollerbladingLight;

  /// No description provided for @paRollerbladingLightDesc.
  ///
  /// In en, this message translates to:
  /// **'in-line skating'**
  String get paRollerbladingLightDesc;

  /// No description provided for @paSkydiving.
  ///
  /// In en, this message translates to:
  /// **'skydiving'**
  String get paSkydiving;

  /// No description provided for @paSkydivingDesc.
  ///
  /// In en, this message translates to:
  /// **'skydiving, base jumping, bungee jumping'**
  String get paSkydivingDesc;

  /// No description provided for @paSoccerGeneral.
  ///
  /// In en, this message translates to:
  /// **'soccer'**
  String get paSoccerGeneral;

  /// No description provided for @paSoccerGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'casual, general'**
  String get paSoccerGeneralDesc;

  /// No description provided for @paSoftballBaseballGeneral.
  ///
  /// In en, this message translates to:
  /// **'softball / baseball'**
  String get paSoftballBaseballGeneral;

  /// No description provided for @paSoftballBaseballGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'fast or slow pitch, general'**
  String get paSoftballBaseballGeneralDesc;

  /// No description provided for @paSquashGeneral.
  ///
  /// In en, this message translates to:
  /// **'squash'**
  String get paSquashGeneral;

  /// No description provided for @paSquashGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paSquashGeneralDesc;

  /// No description provided for @paTableTennisGeneral.
  ///
  /// In en, this message translates to:
  /// **'table tennis'**
  String get paTableTennisGeneral;

  /// No description provided for @paTableTennisGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'table tennis, ping pong'**
  String get paTableTennisGeneralDesc;

  /// No description provided for @paTaiChiQiGongGeneral.
  ///
  /// In en, this message translates to:
  /// **'tai chi, qi gong'**
  String get paTaiChiQiGongGeneral;

  /// No description provided for @paTaiChiQiGongGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paTaiChiQiGongGeneralDesc;

  /// No description provided for @paTennisGeneral.
  ///
  /// In en, this message translates to:
  /// **'tennis'**
  String get paTennisGeneral;

  /// No description provided for @paTennisGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paTennisGeneralDesc;

  /// No description provided for @paTrampolineLight.
  ///
  /// In en, this message translates to:
  /// **'trampoline'**
  String get paTrampolineLight;

  /// No description provided for @paTrampolineLightDesc.
  ///
  /// In en, this message translates to:
  /// **'recreational'**
  String get paTrampolineLightDesc;

  /// No description provided for @paVolleyballGeneral.
  ///
  /// In en, this message translates to:
  /// **'volleyball'**
  String get paVolleyballGeneral;

  /// No description provided for @paVolleyballGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'non-competitive, 6 - 9 member team, general'**
  String get paVolleyballGeneralDesc;

  /// No description provided for @paWrestling.
  ///
  /// In en, this message translates to:
  /// **'wrestling'**
  String get paWrestling;

  /// No description provided for @paWrestlingDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paWrestlingDesc;

  /// No description provided for @paWallyball.
  ///
  /// In en, this message translates to:
  /// **'wallyball'**
  String get paWallyball;

  /// No description provided for @paWallyballDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paWallyballDesc;

  /// No description provided for @paTrackField.
  ///
  /// In en, this message translates to:
  /// **'track and field'**
  String get paTrackField;

  /// No description provided for @paTrackField1Desc.
  ///
  /// In en, this message translates to:
  /// **'(e.g. shot, discus, hammer throw)'**
  String get paTrackField1Desc;

  /// No description provided for @paTrackField2Desc.
  ///
  /// In en, this message translates to:
  /// **'(e.g. high jump, long jump, triple jump, javelin, pole vault)'**
  String get paTrackField2Desc;

  /// No description provided for @paTrackField3Desc.
  ///
  /// In en, this message translates to:
  /// **'(e.g. steeplechase, hurdles)'**
  String get paTrackField3Desc;

  /// No description provided for @paBackpackingGeneral.
  ///
  /// In en, this message translates to:
  /// **'backpacking'**
  String get paBackpackingGeneral;

  /// No description provided for @paBackpackingGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paBackpackingGeneralDesc;

  /// No description provided for @paClimbingHillsNoLoadGeneral.
  ///
  /// In en, this message translates to:
  /// **'climbing hills, no load'**
  String get paClimbingHillsNoLoadGeneral;

  /// No description provided for @paClimbingHillsNoLoadGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'no load'**
  String get paClimbingHillsNoLoadGeneralDesc;

  /// No description provided for @paHikingCrossCountry.
  ///
  /// In en, this message translates to:
  /// **'hiking'**
  String get paHikingCrossCountry;

  /// No description provided for @paHikingCrossCountryDesc.
  ///
  /// In en, this message translates to:
  /// **'cross country'**
  String get paHikingCrossCountryDesc;

  /// No description provided for @paWalkingForPleasure.
  ///
  /// In en, this message translates to:
  /// **'walking'**
  String get paWalkingForPleasure;

  /// No description provided for @paWalkingForPleasureDesc.
  ///
  /// In en, this message translates to:
  /// **'for pleasure'**
  String get paWalkingForPleasureDesc;

  /// No description provided for @paWalkingTheDog.
  ///
  /// In en, this message translates to:
  /// **'walking the dog'**
  String get paWalkingTheDog;

  /// No description provided for @paWalkingTheDogDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paWalkingTheDogDesc;

  /// No description provided for @paCanoeingGeneral.
  ///
  /// In en, this message translates to:
  /// **'canoeing'**
  String get paCanoeingGeneral;

  /// No description provided for @paCanoeingGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'rowing, for pleasure, general'**
  String get paCanoeingGeneralDesc;

  /// No description provided for @paDivingSpringboardPlatform.
  ///
  /// In en, this message translates to:
  /// **'diving'**
  String get paDivingSpringboardPlatform;

  /// No description provided for @paDivingSpringboardPlatformDesc.
  ///
  /// In en, this message translates to:
  /// **'springboard or platform'**
  String get paDivingSpringboardPlatformDesc;

  /// No description provided for @paKayakingModerate.
  ///
  /// In en, this message translates to:
  /// **'kayaking'**
  String get paKayakingModerate;

  /// No description provided for @paKayakingModerateDesc.
  ///
  /// In en, this message translates to:
  /// **'moderate effort'**
  String get paKayakingModerateDesc;

  /// No description provided for @paPaddleBoat.
  ///
  /// In en, this message translates to:
  /// **'paddle boat'**
  String get paPaddleBoat;

  /// No description provided for @paPaddleBoatDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paPaddleBoatDesc;

  /// No description provided for @paSailingGeneral.
  ///
  /// In en, this message translates to:
  /// **'sailing'**
  String get paSailingGeneral;

  /// No description provided for @paSailingGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'boat and board sailing, windsurfing, ice sailing, general'**
  String get paSailingGeneralDesc;

  /// No description provided for @paSkiingWaterWakeboarding.
  ///
  /// In en, this message translates to:
  /// **'water skiing'**
  String get paSkiingWaterWakeboarding;

  /// No description provided for @paSkiingWaterWakeboardingDesc.
  ///
  /// In en, this message translates to:
  /// **'water or wakeboarding'**
  String get paSkiingWaterWakeboardingDesc;

  /// No description provided for @paDivingGeneral.
  ///
  /// In en, this message translates to:
  /// **'diving'**
  String get paDivingGeneral;

  /// No description provided for @paDivingGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'skindiving, scuba diving, general'**
  String get paDivingGeneralDesc;

  /// No description provided for @paSnorkeling.
  ///
  /// In en, this message translates to:
  /// **'snorkeling'**
  String get paSnorkeling;

  /// No description provided for @paSnorkelingDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paSnorkelingDesc;

  /// No description provided for @paSurfing.
  ///
  /// In en, this message translates to:
  /// **'surfing'**
  String get paSurfing;

  /// No description provided for @paSurfingDesc.
  ///
  /// In en, this message translates to:
  /// **'body or board, general'**
  String get paSurfingDesc;

  /// No description provided for @paPaddleBoarding.
  ///
  /// In en, this message translates to:
  /// **'paddle boarding'**
  String get paPaddleBoarding;

  /// No description provided for @paPaddleBoardingDesc.
  ///
  /// In en, this message translates to:
  /// **'standing'**
  String get paPaddleBoardingDesc;

  /// No description provided for @paSwimmingGeneral.
  ///
  /// In en, this message translates to:
  /// **'swimming'**
  String get paSwimmingGeneral;

  /// No description provided for @paSwimmingGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'treading water, moderate effort, general'**
  String get paSwimmingGeneralDesc;

  /// No description provided for @paWateraerobicsCalisthenics.
  ///
  /// In en, this message translates to:
  /// **'water aerobics'**
  String get paWateraerobicsCalisthenics;

  /// No description provided for @paWateraerobicsCalisthenicsDesc.
  ///
  /// In en, this message translates to:
  /// **'water aerobics, water calisthenics'**
  String get paWateraerobicsCalisthenicsDesc;

  /// No description provided for @paWaterPolo.
  ///
  /// In en, this message translates to:
  /// **'water polo'**
  String get paWaterPolo;

  /// No description provided for @paWaterPoloDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paWaterPoloDesc;

  /// No description provided for @paWaterVolleyball.
  ///
  /// In en, this message translates to:
  /// **'water volleyball'**
  String get paWaterVolleyball;

  /// No description provided for @paWaterVolleyballDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paWaterVolleyballDesc;

  /// No description provided for @paIceSkatingGeneral.
  ///
  /// In en, this message translates to:
  /// **'ice skating'**
  String get paIceSkatingGeneral;

  /// No description provided for @paIceSkatingGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paIceSkatingGeneralDesc;

  /// No description provided for @paSkiingGeneral.
  ///
  /// In en, this message translates to:
  /// **'skiing'**
  String get paSkiingGeneral;

  /// No description provided for @paSkiingGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get paSkiingGeneralDesc;

  /// No description provided for @paSnowShovingModerate.
  ///
  /// In en, this message translates to:
  /// **'snow shoveling'**
  String get paSnowShovingModerate;

  /// No description provided for @paSnowShovingModerateDesc.
  ///
  /// In en, this message translates to:
  /// **'by hand, moderate effort'**
  String get paSnowShovingModerateDesc;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Assistant'**
  String get chatTitle;

  /// No description provided for @chatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about nutrition, calories, and your food tracking'**
  String get chatSubtitle;

  /// No description provided for @chatPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type your message here...'**
  String get chatPlaceholder;

  /// No description provided for @chatSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSendButton;

  /// No description provided for @chatApiKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'OpenRouter API Key'**
  String get chatApiKeyTitle;

  /// No description provided for @chatApiKeySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your OpenRouter API key to start chatting'**
  String get chatApiKeySubtitle;

  /// No description provided for @chatApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'sk-or-v1-...'**
  String get chatApiKeyHint;

  /// No description provided for @chatApiKeySave.
  ///
  /// In en, this message translates to:
  /// **'Save Key'**
  String get chatApiKeySave;

  /// No description provided for @chatApiKeyError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid API key'**
  String get chatApiKeyError;

  /// No description provided for @chatApiKeySuccess.
  ///
  /// In en, this message translates to:
  /// **'API key saved successfully'**
  String get chatApiKeySuccess;

  /// No description provided for @chatLoading.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get chatLoading;

  /// No description provided for @chatError.
  ///
  /// In en, this message translates to:
  /// **'Sorry, I encountered an error. Please try again.'**
  String get chatError;

  /// No description provided for @chatNoApiKey.
  ///
  /// In en, this message translates to:
  /// **'Please enter your OpenRouter API key to start chatting'**
  String get chatNoApiKey;

  /// No description provided for @chatWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m your nutrition assistant. I can help you with:\n\n• Tracking your food intake\n• Calculating calories and macros\n• Viewing your history\n• Adding, editing, and deleting food entries\n• Providing nutrition advice\n\nPlease enter your OpenRouter API key to get started.'**
  String get chatWelcome;

  /// No description provided for @chatHistoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get chatHistoryLabel;

  /// No description provided for @chatClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get chatClearHistory;

  /// No description provided for @chatClearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all chat history?'**
  String get chatClearHistoryConfirm;

  /// No description provided for @chatClearHistorySuccess.
  ///
  /// In en, this message translates to:
  /// **'Chat history cleared'**
  String get chatClearHistorySuccess;

  /// No description provided for @chatDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete message'**
  String get chatDeleteMessage;

  /// No description provided for @chatCopyMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy message'**
  String get chatCopyMessage;

  /// No description provided for @chatMessageCopied.
  ///
  /// In en, this message translates to:
  /// **'Message copied to clipboard'**
  String get chatMessageCopied;

  /// No description provided for @chatSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Chat Settings'**
  String get chatSettingsLabel;

  /// No description provided for @chatApiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get chatApiKeyLabel;

  /// No description provided for @chatApiKeyDescription.
  ///
  /// In en, this message translates to:
  /// **'Your OpenRouter API key for AI chat functionality'**
  String get chatApiKeyDescription;

  /// No description provided for @chatModelLabel.
  ///
  /// In en, this message translates to:
  /// **'AI Model'**
  String get chatModelLabel;

  /// No description provided for @chatModelDescription.
  ///
  /// In en, this message translates to:
  /// **'Select the AI model to use for chat'**
  String get chatModelDescription;

  /// No description provided for @chatModelClaude35Sonnet.
  ///
  /// In en, this message translates to:
  /// **'Claude 3.5 Sonnet (Recommended)'**
  String get chatModelClaude35Sonnet;

  /// No description provided for @chatModelClaude35Haiku.
  ///
  /// In en, this message translates to:
  /// **'Claude 3.5 Haiku (Fast)'**
  String get chatModelClaude35Haiku;

  /// No description provided for @chatModelClaude3Opus.
  ///
  /// In en, this message translates to:
  /// **'Claude 3 Opus (Most Capable)'**
  String get chatModelClaude3Opus;

  /// No description provided for @chatModelGPT4.
  ///
  /// In en, this message translates to:
  /// **'GPT-4'**
  String get chatModelGPT4;

  /// No description provided for @chatModelGPT35Turbo.
  ///
  /// In en, this message translates to:
  /// **'GPT-3.5 Turbo'**
  String get chatModelGPT35Turbo;

  /// No description provided for @chatModelGeminiPro.
  ///
  /// In en, this message translates to:
  /// **'Gemini Pro'**
  String get chatModelGeminiPro;

  /// No description provided for @chatModelLlama.
  ///
  /// In en, this message translates to:
  /// **'Llama 3.1'**
  String get chatModelLlama;

  /// No description provided for @chatApiKeySaved.
  ///
  /// In en, this message translates to:
  /// **'API key saved'**
  String get chatApiKeySaved;

  /// No description provided for @chatApiKeyRemoved.
  ///
  /// In en, this message translates to:
  /// **'API key removed'**
  String get chatApiKeyRemoved;

  /// No description provided for @chatModelSaved.
  ///
  /// In en, this message translates to:
  /// **'Model saved'**
  String get chatModelSaved;

  /// No description provided for @chatSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Chat settings saved'**
  String get chatSettingsSaved;

  /// No description provided for @settingsChatLabel.
  ///
  /// In en, this message translates to:
  /// **'Chat Settings'**
  String get settingsChatLabel;

  /// No description provided for @chatApiKeyStatus.
  ///
  /// In en, this message translates to:
  /// **'API Key Status'**
  String get chatApiKeyStatus;

  /// No description provided for @chatApiKeyView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get chatApiKeyView;

  /// No description provided for @chatApiKeyChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get chatApiKeyChange;

  /// No description provided for @chatApiKeyRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get chatApiKeyRemove;

  /// No description provided for @chatApiKeyMasked.
  ///
  /// In en, this message translates to:
  /// **'sk-or-v1-****'**
  String get chatApiKeyMasked;

  /// No description provided for @chatCustomModelAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Model'**
  String get chatCustomModelAdd;

  /// No description provided for @chatCustomModelRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get chatCustomModelRemove;

  /// No description provided for @chatCustomModelSetActive.
  ///
  /// In en, this message translates to:
  /// **'Set Active'**
  String get chatCustomModelSetActive;

  /// No description provided for @chatCustomModelAdded.
  ///
  /// In en, this message translates to:
  /// **'Model added successfully'**
  String get chatCustomModelAdded;

  /// No description provided for @chatCustomModelRemoved.
  ///
  /// In en, this message translates to:
  /// **'Model removed successfully'**
  String get chatCustomModelRemoved;

  /// No description provided for @chatCustomModelInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid model identifier'**
  String get chatCustomModelInvalid;

  /// No description provided for @chatCustomModelIdentifierHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., deepseek/deepseek-chat-v3-0324:free'**
  String get chatCustomModelIdentifierHint;

  /// No description provided for @chatCustomModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom Models'**
  String get chatCustomModelLabel;

  /// No description provided for @chatCustomModelInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Model Identifier'**
  String get chatCustomModelInputLabel;

  /// No description provided for @chatCustomModelInputHint.
  ///
  /// In en, this message translates to:
  /// **'Paste model identifier here'**
  String get chatCustomModelInputHint;

  /// No description provided for @chatCustomModelListLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved Models'**
  String get chatCustomModelListLabel;

  /// No description provided for @chatCustomModelNoModels.
  ///
  /// In en, this message translates to:
  /// **'No custom models added yet'**
  String get chatCustomModelNoModels;

  /// No description provided for @chatCustomModelActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get chatCustomModelActive;

  /// No description provided for @chatCustomModelSetAsActive.
  ///
  /// In en, this message translates to:
  /// **'Set as Active Model'**
  String get chatCustomModelSetAsActive;

  /// No description provided for @chatCustomModelRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this model?'**
  String get chatCustomModelRemoveConfirm;

  /// No description provided for @chatApiKeyRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove your API key?'**
  String get chatApiKeyRemoveConfirm;

  /// No description provided for @chatApiKeyViewConfirm.
  ///
  /// In en, this message translates to:
  /// **'View API Key'**
  String get chatApiKeyViewConfirm;

  /// No description provided for @chatApiKeyViewConfirmText.
  ///
  /// In en, this message translates to:
  /// **'This will temporarily show your full API key. Be careful not to share it.'**
  String get chatApiKeyViewConfirmText;

  /// No description provided for @chatApiKeyCopied.
  ///
  /// In en, this message translates to:
  /// **'API key copied to clipboard'**
  String get chatApiKeyCopied;

  /// No description provided for @chatApiKeyChanged.
  ///
  /// In en, this message translates to:
  /// **'API key changed successfully'**
  String get chatApiKeyChanged;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return SDe();
    case 'en': return SEn();
    case 'tr': return STr();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
