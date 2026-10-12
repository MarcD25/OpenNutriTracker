// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OpenNutriTracker';

  @override
  String appVersionName(Object versionNumber) {
    return 'Version $versionNumber';
  }

  @override
  String get appDescription => 'OpenNutriTracker is a free and open-source calorie and nutrient tracker that respects your privacy.';

  @override
  String get alphaVersionName => '[Alpha]';

  @override
  String get betaVersionName => '[Beta]';

  @override
  String get addLabel => 'Add';

  @override
  String get createCustomDialogTitle => 'Create custom meal item?';

  @override
  String get createCustomDialogContent => 'Do you want create a custom meal item?';

  @override
  String get settingsLabel => 'Settings';

  @override
  String get homeLabel => 'Home';

  @override
  String get diaryLabel => 'Diary';

  @override
  String get profileLabel => 'Profile';

  @override
  String get chatLabel => 'Chat';

  @override
  String get searchLabel => 'Search';

  @override
  String get searchProductsPage => 'Products';

  @override
  String get searchFoodPage => 'Food';

  @override
  String get searchResultsLabel => 'Search results';

  @override
  String get searchDefaultLabel => 'Please enter a search word';

  @override
  String get allItemsLabel => 'All';

  @override
  String get recentlyAddedLabel => 'Recently';

  @override
  String get noMealsRecentlyAddedLabel => 'No meals recently added';

  @override
  String get noActivityRecentlyAddedLabel => 'No activity recently added';

  @override
  String get dialogOKLabel => 'OK';

  @override
  String get dialogCancelLabel => 'CANCEL';

  @override
  String get buttonStartLabel => 'START';

  @override
  String get buttonNextLabel => 'NEXT';

  @override
  String get buttonSaveLabel => 'Save';

  @override
  String get buttonYesLabel => 'YES';

  @override
  String get buttonResetLabel => 'Reset';

  @override
  String get onboardingWelcomeLabel => 'Welcome to';

  @override
  String get onboardingOverviewLabel => 'Overview';

  @override
  String get onboardingYourGoalLabel => 'Your calorie goal:';

  @override
  String get onboardingYourMacrosGoalLabel => 'Your macronutrient goals:';

  @override
  String get onboardingKcalPerDayLabel => 'kcal per day';

  @override
  String get onboardingIntroDescription => 'To start, the app needs some information about you to calculate your daily calorie goal.\nAll information about you is stored securely on your device.';

  @override
  String get onboardingGenderQuestionSubtitle => 'What\'s your gender?';

  @override
  String get onboardingEnterBirthdayLabel => 'Birthday';

  @override
  String get onboardingBirthdayHint => 'Enter Date';

  @override
  String get onboardingBirthdayQuestionSubtitle => 'When is your birthday?';

  @override
  String get onboardingHeightQuestionSubtitle => 'Whats your current height?';

  @override
  String get onboardingWeightQuestionSubtitle => 'Whats your current weight?';

  @override
  String get onboardingWrongHeightLabel => 'Enter correct height';

  @override
  String get onboardingWrongWeightLabel => 'Enter correct weight';

  @override
  String get onboardingWeightExampleHintKg => 'e.g. 60';

  @override
  String get onboardingWeightExampleHintLbs => 'e.g. 132';

  @override
  String get onboardingHeightExampleHintCm => 'e.g. 170';

  @override
  String get onboardingHeightExampleHintFt => 'e.g. 5.8';

  @override
  String get onboardingActivityQuestionSubtitle => 'How active are you? (without workouts)';

  @override
  String get onboardingGoalQuestionSubtitle => 'What\'s your current weight goal?';

  @override
  String get onboardingSaveUserError => 'Wrong input, please try again';

  @override
  String get settingsUnitsLabel => 'Units';

  @override
  String get settingsCalculationsLabel => 'Calculations';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get settingsThemeLightLabel => 'Light';

  @override
  String get settingsThemeDarkLabel => 'Dark';

  @override
  String get settingsThemeSystemDefaultLabel => 'System default';

  @override
  String get settingsLicensesLabel => 'Licenses';

  @override
  String get settingsDisclaimerLabel => 'Disclaimer';

  @override
  String get settingsReportErrorLabel => 'Report Error';

  @override
  String get settingsPrivacySettings => 'Privacy Settings';

  @override
  String get settingsSourceCodeLabel => 'Source Code';

  @override
  String get settingFeedbackLabel => 'Feedback';

  @override
  String get settingAboutLabel => 'About';

  @override
  String get settingsMassLabel => 'Mass';

  @override
  String get settingsSystemLabel => 'System';

  @override
  String get settingsMetricLabel => 'Metric (kg, cm, ml)';

  @override
  String get settingsImperialLabel => 'Imperial (lbs, ft, oz)';

  @override
  String get settingsDistanceLabel => 'Distance';

  @override
  String get settingsVolumeLabel => 'Volume';

  @override
  String get disclaimerText => 'OpenNutriTracker is not a medical application. All data provided is not validated and should be used with caution. Please maintain a healthy lifestyle and consult a professional if you have any problems. Use during illness, pregnancy or lactation is not recommended.';

  @override
  String get reportErrorDialogText => 'Do you want to report an error to the developer?';

  @override
  String get sendAnonymousUserData => 'Send anonymous usage data';

  @override
  String get appLicenseLabel => 'GPL-3.0 license';

  @override
  String get calculationsTDEELabel => 'TDEE equation';

  @override
  String get calculationsTDEEIOM2006Label => 'Institute of Medicine Equation';

  @override
  String get calculationsRecommendedLabel => '(recommended)';

  @override
  String get calculationsMacronutrientsDistributionLabel => 'Macros distribution';

  @override
  String calculationsMacrosDistribution(Object pctCarbs, Object pctFats, Object pctProteins) {
    return '$pctCarbs% carbs, $pctFats% fats, $pctProteins% proteins';
  }

  @override
  String get dailyKcalAdjustmentLabel => 'Daily Kcal adjustment:';

  @override
  String get macroDistributionLabel => 'Macronutrient Distribution:';

  @override
  String get exportImportLabel => 'Export / Import data';

  @override
  String get exportImportDescription => 'You can export the app data to a zip file and import it later. This is useful if you want to backup your data or transfer it to another device.\n\nThe app does not use any cloud service to store your data.';

  @override
  String get exportImportSuccessLabel => 'Export / Import successful';

  @override
  String get exportImportErrorLabel => 'Export / Import error';

  @override
  String get exportAction => 'Export';

  @override
  String get importAction => 'Import';

  @override
  String get addItemLabel => 'Add new Item:';

  @override
  String get activityLabel => 'Activity';

  @override
  String get activityExample => 'e.g. running, biking, yoga ...';

  @override
  String get breakfastLabel => 'Breakfast';

  @override
  String get breakfastExample => 'e.g. cereal, milk, coffee ...';

  @override
  String get lunchLabel => 'Lunch';

  @override
  String get lunchExample => 'e.g. pizza, salad, rice ...';

  @override
  String get dinnerLabel => 'Dinner';

  @override
  String get dinnerExample => 'e.g. soup, chicken, wine ...';

  @override
  String get snackLabel => 'Snack';

  @override
  String get snackExample => 'e.g. apple, ice cream, chocolate ...';

  @override
  String get editItemDialogTitle => 'Edit item';

  @override
  String get itemUpdatedSnackbar => 'Item updated';

  @override
  String get aiProcessingMessage => 'AI is processing your message...';

  @override
  String get deleteTimeDialogTitle => 'Delete Item?';

  @override
  String get deleteTimeDialogContent => 'Do want to delete the selected item?';

  @override
  String get deleteTimeDialogPluralTitle => 'Delete Items?';

  @override
  String get deleteTimeDialogPluralContent => 'Do want to delete all items of this meal?';

  @override
  String get itemDeletedSnackbar => 'Item deleted';

  @override
  String get copyDialogTitle => 'Which meal type do you want to copy to?';

  @override
  String get copyOrDeleteTimeDialogTitle => 'What do you want to do?';

  @override
  String get copyOrDeleteTimeDialogContent => 'With \"Copy to another day\" you can copy the meal to another day. With \"Delete\" you can delete the meal.';

  @override
  String get dialogCopyLabel => 'Copy to another day';

  @override
  String get dialogDeleteLabel => 'DELETE';

  @override
  String get deleteAllLabel => 'Delete all';

  @override
  String get suppliedLabel => 'supplied';

  @override
  String get burnedLabel => 'burned';

  @override
  String get kcalLeftLabel => 'kcal left';

  @override
  String get nutritionInfoLabel => 'Nutrition Information';

  @override
  String get kcalLabel => 'kcal';

  @override
  String get carbsLabel => 'carbs';

  @override
  String get fatLabel => 'fat';

  @override
  String get proteinLabel => 'protein';

  @override
  String get energyLabel => 'energy';

  @override
  String get saturatedFatLabel => 'saturated fat';

  @override
  String get carbohydrateLabel => 'carbohydrate';

  @override
  String get sugarLabel => 'sugar';

  @override
  String get fiberLabel => 'fiber';

  @override
  String get per100gmlLabel => 'Per 100g/ml';

  @override
  String get additionalInfoLabelOFF => 'More Information at\nOpenFoodFacts';

  @override
  String get offDisclaimer => 'The data provided to you by this app are retrieved from the Open Food Facts database. No guarantees can be made for the accuracy, completeness, or reliability of the information provided. The data are provided “as is” and the originating source for the data (Open Food Facts) is not liable for any damages arising out of the use of the data.';

  @override
  String get additionalInfoLabelFDC => 'More Information at\nFoodData Central';

  @override
  String get additionalInfoLabelUnknown => 'Unknown Meal Item';

  @override
  String get additionalInfoLabelCustom => 'Custom Meal Item';

  @override
  String get additionalInfoLabelCompendium2011 => 'Information provided\n by the \n\'2011 Compendium\n of Physical Activities\'';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get baseQuantityLabel => 'Base quantity (g/ml)';

  @override
  String get unitLabel => 'Unit';

  @override
  String get scanProductLabel => 'Scan Product';

  @override
  String get gramUnit => 'g';

  @override
  String get milliliterUnit => 'ml';

  @override
  String get gramMilliliterUnit => 'g/ml';

  @override
  String get ozUnit => 'oz';

  @override
  String get flOzUnit => 'fl.oz';

  @override
  String get notAvailableLabel => 'N/A';

  @override
  String get missingProductInfo => 'Product missing required kcal or macronutrients information';

  @override
  String get infoAddedIntakeLabel => 'Added new intake';

  @override
  String get infoAddedActivityLabel => 'Added new activity';

  @override
  String get editMealLabel => 'Edit meal';

  @override
  String get mealNameLabel => 'Meal name';

  @override
  String get mealBrandsLabel => 'Brands';

  @override
  String get mealSizeLabel => 'Meal size (g/ml)';

  @override
  String get mealSizeLabelImperial => 'Meal size (oz/fl oz)';

  @override
  String get servingLabel => 'Serving';

  @override
  String get perServingLabel => 'Per Serving';

  @override
  String get servingSizeLabelMetric => 'Serving size (g/ml)';

  @override
  String get servingSizeLabelImperial => 'Serving size (oz/fl oz)';

  @override
  String get mealUnitLabel => 'Meal unit';

  @override
  String get mealKcalLabel => 'kcal per';

  @override
  String get mealCarbsLabel => 'carbs per';

  @override
  String get mealFatLabel => 'fat per';

  @override
  String get mealProteinLabel => 'protein per 100 g/ml';

  @override
  String get errorMealSave => 'Error while saving meal. Did you input the correct meal information?';

  @override
  String get bmiLabel => 'BMI';

  @override
  String get bmiInfo => 'Body Mass Index (BMI) is a index to classify overweight and obesity in adults. It is defined as weight in kilograms divided by the square of height in meters (kg/m²).\n\nBMI does not differentiate between fat and muscle mass and can be misleading for some individuals.';

  @override
  String get readLabel => 'I have read and accept the privacy policy.';

  @override
  String get privacyPolicyLabel => 'Privacy policy';

  @override
  String get dataCollectionLabel => 'Support development by providing anonymous usage data';

  @override
  String get palSedentaryLabel => 'Sedentary';

  @override
  String get palSedentaryDescriptionLabel => 'e.g. office job and mostly sitting free time activities';

  @override
  String get palLowLActiveLabel => 'Low Active';

  @override
  String get palLowActiveDescriptionLabel => 'e.g. sitting or standing in job and light free time activities';

  @override
  String get palActiveLabel => 'Active';

  @override
  String get palActiveDescriptionLabel => 'Mostly standing or walking in job and active free time activities';

  @override
  String get palVeryActiveLabel => 'Very Active';

  @override
  String get palVeryActiveDescriptionLabel => 'Mostly walking, running or carrying weight in job and active free time activities';

  @override
  String get selectPalCategoryLabel => 'Select Activity Level';

  @override
  String get chooseWeightGoalLabel => 'Choose Weight Goal';

  @override
  String get goalLoseWeight => 'Lose Weight';

  @override
  String get goalMaintainWeight => 'Maintain Weight';

  @override
  String get goalGainWeight => 'Gain Weight';

  @override
  String get goalLabel => 'Goal';

  @override
  String get selectHeightDialogLabel => 'Select Height';

  @override
  String get heightLabel => 'Height';

  @override
  String get cmLabel => 'cm';

  @override
  String get ftLabel => 'ft';

  @override
  String get selectWeightDialogLabel => 'Select Weight';

  @override
  String get weightLabel => 'Weight';

  @override
  String get kgLabel => 'kg';

  @override
  String get lbsLabel => 'lbs';

  @override
  String get ageLabel => 'Age';

  @override
  String yearsLabel(Object age) {
    return '$age years';
  }

  @override
  String get selectGenderDialogLabel => 'Select Gender';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderMaleLabel => '♂ male';

  @override
  String get genderFemaleLabel => '♀ female';

  @override
  String get nothingAddedLabel => 'Nothing added';

  @override
  String get nutritionalStatusUnderweight => 'Underweight';

  @override
  String get nutritionalStatusNormalWeight => 'Normal Weight';

  @override
  String get nutritionalStatusPreObesity => 'Pre-obesity';

  @override
  String get nutritionalStatusObeseClassI => 'Obesity Class I';

  @override
  String get nutritionalStatusObeseClassII => 'Obesity Class II';

  @override
  String get nutritionalStatusObeseClassIII => 'Obesity Class III';

  @override
  String nutritionalStatusRiskLabel(Object riskValue) {
    return 'Risk of comorbidities: $riskValue';
  }

  @override
  String get nutritionalStatusRiskLow => 'Low \n(but risk of other \nclinical problems increased)';

  @override
  String get nutritionalStatusRiskAverage => 'Average';

  @override
  String get nutritionalStatusRiskIncreased => 'Increased';

  @override
  String get nutritionalStatusRiskModerate => 'Moderate';

  @override
  String get nutritionalStatusRiskSevere => 'Severe';

  @override
  String get nutritionalStatusRiskVerySevere => 'Very severe';

  @override
  String get errorOpeningEmail => 'Error while opening email app';

  @override
  String get errorOpeningBrowser => 'Error while opening browser app';

  @override
  String get errorFetchingProductData => 'Error while fetching product data';

  @override
  String get errorProductNotFound => 'Product not found';

  @override
  String get errorLoadingActivities => 'Error while loading activities';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get retryLabel => 'Retry';

  @override
  String get paHeadingBicycling => 'bicycling';

  @override
  String get paHeadingConditionalExercise => 'conditioning exercise';

  @override
  String get paHeadingDancing => 'dancing';

  @override
  String get paHeadingRunning => 'running';

  @override
  String get paHeadingSports => 'sports';

  @override
  String get paHeadingWalking => 'walking';

  @override
  String get paHeadingWaterActivities => 'water activities';

  @override
  String get paHeadingWinterActivities => 'winter activities';

  @override
  String get paGeneralDesc => 'general';

  @override
  String get paBicyclingGeneral => 'bicycling';

  @override
  String get paBicyclingGeneralDesc => 'general';

  @override
  String get paBicyclingMountainGeneral => 'bicycling, mountain';

  @override
  String get paBicyclingMountainGeneralDesc => 'general';

  @override
  String get paUnicyclingGeneral => 'unicycling';

  @override
  String get paUnicyclingGeneralDesc => 'general';

  @override
  String get paBicyclingStationaryGeneral => 'bicycling, stationary';

  @override
  String get paBicyclingStationaryGeneralDesc => 'general';

  @override
  String get paCalisthenicsGeneral => 'calisthenics';

  @override
  String get paCalisthenicsGeneralDesc => 'light or moderate effort, general (e.g., back exercises)';

  @override
  String get paResistanceTraining => 'resistance training';

  @override
  String get paResistanceTrainingDesc => 'weight lifting, free weight, nautilus or universal';

  @override
  String get paRopeSkippingGeneral => 'rope skipping';

  @override
  String get paRopeSkippingGeneralDesc => 'general';

  @override
  String get paWaterAerobics => 'water exercise';

  @override
  String get paWaterAerobicsDesc => 'water aerobics, water calisthenics';

  @override
  String get paDancingAerobicGeneral => 'aerobic';

  @override
  String get paDancingAerobicGeneralDesc => 'general';

  @override
  String get paDancingGeneral => 'general dancing';

  @override
  String get paDancingGeneralDesc => 'e.g. disco, folk, Irish step dancing, line dancing, polka, contra, country';

  @override
  String get paJoggingGeneral => 'jogging';

  @override
  String get paJoggingGeneralDesc => 'general';

  @override
  String get paRunningGeneral => 'running';

  @override
  String get paRunningGeneralDesc => 'general';

  @override
  String get paArcheryGeneral => 'archery';

  @override
  String get paArcheryGeneralDesc => 'non-hunting';

  @override
  String get paBadmintonGeneral => 'badminton';

  @override
  String get paBadmintonGeneralDesc => 'social singles and doubles, general';

  @override
  String get paBasketballGeneral => 'basketball';

  @override
  String get paBasketballGeneralDesc => 'general';

  @override
  String get paBilliardsGeneral => 'billiards';

  @override
  String get paBilliardsGeneralDesc => 'general';

  @override
  String get paBowlingGeneral => 'bowling';

  @override
  String get paBowlingGeneralDesc => 'general';

  @override
  String get paBoxingBag => 'boxing';

  @override
  String get paBoxingBagDesc => 'punching bag';

  @override
  String get paBoxingGeneral => 'boxing';

  @override
  String get paBoxingGeneralDesc => 'in ring, general';

  @override
  String get paBroomball => 'broomball';

  @override
  String get paBroomballDesc => 'general';

  @override
  String get paChildrenGame => 'children’s games';

  @override
  String get paChildrenGameDesc => '(e.g., hopscotch, 4-square, dodgeball, playground apparatus, t-ball, tetherball, marbles, arcade games), moderate effort';

  @override
  String get paCheerleading => 'cheerleading';

  @override
  String get paCheerleadingDesc => 'gymnastic moves, competitive';

  @override
  String get paCricket => 'cricket';

  @override
  String get paCricketDesc => 'batting, bowling, fielding';

  @override
  String get paCroquet => 'croquet';

  @override
  String get paCroquetDesc => 'general';

  @override
  String get paCurling => 'curling';

  @override
  String get paCurlingDesc => 'general';

  @override
  String get paDartsWall => 'darts';

  @override
  String get paDartsWallDesc => 'wall or lawn';

  @override
  String get paAutoRacing => 'auto racing';

  @override
  String get paAutoRacingDesc => 'open wheel';

  @override
  String get paFencing => 'fencing';

  @override
  String get paFencingDesc => 'general';

  @override
  String get paAmericanFootballGeneral => 'football';

  @override
  String get paAmericanFootballGeneralDesc => 'touch, flag, general';

  @override
  String get paCatch => 'football or baseball';

  @override
  String get paCatchDesc => 'playing catch';

  @override
  String get paFrisbee => 'frisbee playing';

  @override
  String get paFrisbeeDesc => 'general';

  @override
  String get paGolfGeneral => 'golf';

  @override
  String get paGolfGeneralDesc => 'general';

  @override
  String get paGymnasticsGeneral => 'gymnastics';

  @override
  String get paGymnasticsGeneralDesc => 'general';

  @override
  String get paHackySack => 'hacky sack';

  @override
  String get paHackySackDesc => 'general';

  @override
  String get paHandballGeneral => 'handball';

  @override
  String get paHandballGeneralDesc => 'general';

  @override
  String get paHangGliding => 'hang gliding';

  @override
  String get paHangGlidingDesc => 'general';

  @override
  String get paHockeyField => 'hockey, field';

  @override
  String get paHockeyFieldDesc => 'general';

  @override
  String get paIceHockeyGeneral => 'ice hockey';

  @override
  String get paIceHockeyGeneralDesc => 'general';

  @override
  String get paHorseRidingGeneral => 'horseback riding';

  @override
  String get paHorseRidingGeneralDesc => 'general';

  @override
  String get paJaiAlai => 'jai alai';

  @override
  String get paJaiAlaiDesc => 'general';

  @override
  String get paMartialArtsSlower => 'martial arts';

  @override
  String get paMartialArtsSlowerDesc => 'different types, slower pace, novice performers, practice';

  @override
  String get paMartialArtsModerate => 'martial arts';

  @override
  String get paMartialArtsModerateDesc => 'different types, moderate pace (e.g., judo, jujitsu, karate, kick boxing, tae kwan do, tai-bo, Muay Thai boxing)';

  @override
  String get paJuggling => 'juggling';

  @override
  String get paJugglingDesc => 'general';

  @override
  String get paKickball => 'kickball';

  @override
  String get paKickballDesc => 'general';

  @override
  String get paLacrosse => 'lacrosse';

  @override
  String get paLacrosseDesc => 'general';

  @override
  String get paLawnBowling => 'lawn bowling';

  @override
  String get paLawnBowlingDesc => 'bocce ball, outdoor';

  @override
  String get paMotoCross => 'moto-cross';

  @override
  String get paMotoCrossDesc => 'off-road motor sports, all-terrain vehicle, general';

  @override
  String get paOrienteering => 'orienteering';

  @override
  String get paOrienteeringDesc => 'general';

  @override
  String get paPaddleball => 'paddleball';

  @override
  String get paPaddleballDesc => 'casual, general';

  @override
  String get paPoloHorse => 'polo';

  @override
  String get paPoloHorseDesc => 'on horseback';

  @override
  String get paRacquetball => 'racquetball';

  @override
  String get paRacquetballDesc => 'general';

  @override
  String get paMountainClimbing => 'climbing';

  @override
  String get paMountainClimbingDesc => 'rock or mountain climbing';

  @override
  String get paRodeoSportGeneralModerate => 'rodeo sports';

  @override
  String get paRodeoSportGeneralModerateDesc => 'general, moderate effort';

  @override
  String get paRopeJumpingGeneral => 'rope jumping';

  @override
  String get paRopeJumpingGeneralDesc => 'moderate pace, 100-120 skips/min, general, 2 foot skip, plain bounce';

  @override
  String get paRugbyCompetitive => 'rugby';

  @override
  String get paRugbyCompetitiveDesc => 'union, team, competitive';

  @override
  String get paRugbyNonCompetitive => 'rugby';

  @override
  String get paRugbyNonCompetitiveDesc => 'touch, non-competitive';

  @override
  String get paShuffleboard => 'shuffleboard';

  @override
  String get paShuffleboardDesc => 'general';

  @override
  String get paSkateboardingGeneral => 'skateboarding';

  @override
  String get paSkateboardingGeneralDesc => 'general, moderate effort';

  @override
  String get paSkatingRoller => 'roller skating';

  @override
  String get paSkatingRollerDesc => 'general';

  @override
  String get paRollerbladingLight => 'rollerblading';

  @override
  String get paRollerbladingLightDesc => 'in-line skating';

  @override
  String get paSkydiving => 'skydiving';

  @override
  String get paSkydivingDesc => 'skydiving, base jumping, bungee jumping';

  @override
  String get paSoccerGeneral => 'soccer';

  @override
  String get paSoccerGeneralDesc => 'casual, general';

  @override
  String get paSoftballBaseballGeneral => 'softball / baseball';

  @override
  String get paSoftballBaseballGeneralDesc => 'fast or slow pitch, general';

  @override
  String get paSquashGeneral => 'squash';

  @override
  String get paSquashGeneralDesc => 'general';

  @override
  String get paTableTennisGeneral => 'table tennis';

  @override
  String get paTableTennisGeneralDesc => 'table tennis, ping pong';

  @override
  String get paTaiChiQiGongGeneral => 'tai chi, qi gong';

  @override
  String get paTaiChiQiGongGeneralDesc => 'general';

  @override
  String get paTennisGeneral => 'tennis';

  @override
  String get paTennisGeneralDesc => 'general';

  @override
  String get paTrampolineLight => 'trampoline';

  @override
  String get paTrampolineLightDesc => 'recreational';

  @override
  String get paVolleyballGeneral => 'volleyball';

  @override
  String get paVolleyballGeneralDesc => 'non-competitive, 6 - 9 member team, general';

  @override
  String get paWrestling => 'wrestling';

  @override
  String get paWrestlingDesc => 'general';

  @override
  String get paWallyball => 'wallyball';

  @override
  String get paWallyballDesc => 'general';

  @override
  String get paTrackField => 'track and field';

  @override
  String get paTrackField1Desc => '(e.g. shot, discus, hammer throw)';

  @override
  String get paTrackField2Desc => '(e.g. high jump, long jump, triple jump, javelin, pole vault)';

  @override
  String get paTrackField3Desc => '(e.g. steeplechase, hurdles)';

  @override
  String get paBackpackingGeneral => 'backpacking';

  @override
  String get paBackpackingGeneralDesc => 'general';

  @override
  String get paClimbingHillsNoLoadGeneral => 'climbing hills, no load';

  @override
  String get paClimbingHillsNoLoadGeneralDesc => 'no load';

  @override
  String get paHikingCrossCountry => 'hiking';

  @override
  String get paHikingCrossCountryDesc => 'cross country';

  @override
  String get paWalkingForPleasure => 'walking';

  @override
  String get paWalkingForPleasureDesc => 'for pleasure';

  @override
  String get paWalkingTheDog => 'walking the dog';

  @override
  String get paWalkingTheDogDesc => 'general';

  @override
  String get paCanoeingGeneral => 'canoeing';

  @override
  String get paCanoeingGeneralDesc => 'rowing, for pleasure, general';

  @override
  String get paDivingSpringboardPlatform => 'diving';

  @override
  String get paDivingSpringboardPlatformDesc => 'springboard or platform';

  @override
  String get paKayakingModerate => 'kayaking';

  @override
  String get paKayakingModerateDesc => 'moderate effort';

  @override
  String get paPaddleBoat => 'paddle boat';

  @override
  String get paPaddleBoatDesc => 'general';

  @override
  String get paSailingGeneral => 'sailing';

  @override
  String get paSailingGeneralDesc => 'boat and board sailing, windsurfing, ice sailing, general';

  @override
  String get paSkiingWaterWakeboarding => 'water skiing';

  @override
  String get paSkiingWaterWakeboardingDesc => 'water or wakeboarding';

  @override
  String get paDivingGeneral => 'diving';

  @override
  String get paDivingGeneralDesc => 'skindiving, scuba diving, general';

  @override
  String get paSnorkeling => 'snorkeling';

  @override
  String get paSnorkelingDesc => 'general';

  @override
  String get paSurfing => 'surfing';

  @override
  String get paSurfingDesc => 'body or board, general';

  @override
  String get paPaddleBoarding => 'paddle boarding';

  @override
  String get paPaddleBoardingDesc => 'standing';

  @override
  String get paSwimmingGeneral => 'swimming';

  @override
  String get paSwimmingGeneralDesc => 'treading water, moderate effort, general';

  @override
  String get paWateraerobicsCalisthenics => 'water aerobics';

  @override
  String get paWateraerobicsCalisthenicsDesc => 'water aerobics, water calisthenics';

  @override
  String get paWaterPolo => 'water polo';

  @override
  String get paWaterPoloDesc => 'general';

  @override
  String get paWaterVolleyball => 'water volleyball';

  @override
  String get paWaterVolleyballDesc => 'general';

  @override
  String get paIceSkatingGeneral => 'ice skating';

  @override
  String get paIceSkatingGeneralDesc => 'general';

  @override
  String get paSkiingGeneral => 'skiing';

  @override
  String get paSkiingGeneralDesc => 'general';

  @override
  String get paSnowShovingModerate => 'snow shoveling';

  @override
  String get paSnowShovingModerateDesc => 'by hand, moderate effort';

  @override
  String get chatTitle => 'Nutrition Assistant';

  @override
  String get chatSubtitle => 'Ask me anything about nutrition, calories, and your food tracking';

  @override
  String get chatPlaceholder => 'Type your message here...';

  @override
  String get chatSendButton => 'Send';

  @override
  String get chatApiKeyTitle => 'OpenRouter API Key';

  @override
  String get chatApiKeySubtitle => 'Enter your OpenRouter API key to start chatting';

  @override
  String get chatApiKeyHint => 'sk-or-v1-...';

  @override
  String get chatApiKeySave => 'Save Key';

  @override
  String get chatApiKeyError => 'Please enter a valid API key';

  @override
  String get chatApiKeySuccess => 'API key saved successfully';

  @override
  String get chatLoading => 'Thinking...';

  @override
  String get chatError => 'Sorry, I encountered an error. Please try again.';

  @override
  String get chatNoApiKey => 'Please enter your OpenRouter API key to start chatting';

  @override
  String get chatWelcome => 'Hi! I\'m your nutrition assistant. I can help you with:\n\n• Tracking your food intake\n• Calculating calories and macros\n• Viewing your history\n• Adding, editing, and deleting food entries\n• Providing nutrition advice\n\nPlease enter your OpenRouter API key to get started.';

  @override
  String get chatHistoryLabel => 'Chat History';

  @override
  String get chatClearHistory => 'Clear History';

  @override
  String get chatClearHistoryConfirm => 'Are you sure you want to clear all chat history?';

  @override
  String get chatClearHistorySuccess => 'Chat history cleared';

  @override
  String get chatDeleteMessage => 'Delete message';

  @override
  String get chatCopyMessage => 'Copy message';

  @override
  String get chatMessageCopied => 'Message copied to clipboard';

  @override
  String get chatSettingsLabel => 'Chat Settings';

  @override
  String get chatApiKeyLabel => 'API Key';

  @override
  String get chatApiKeyDescription => 'Your OpenRouter API key for AI chat functionality';

  @override
  String get chatModelLabel => 'AI Model';

  @override
  String get chatModelDescription => 'Select the AI model to use for chat';

  @override
  String get chatModelClaude35Sonnet => 'Claude 3.5 Sonnet (Recommended)';

  @override
  String get chatModelClaude35Haiku => 'Claude 3.5 Haiku (Fast)';

  @override
  String get chatModelClaude3Opus => 'Claude 3 Opus (Most Capable)';

  @override
  String get chatModelGPT4 => 'GPT-4';

  @override
  String get chatModelGPT35Turbo => 'GPT-3.5 Turbo';

  @override
  String get chatModelGeminiPro => 'Gemini Pro';

  @override
  String get chatModelLlama => 'Llama 3.1';

  @override
  String get chatApiKeySaved => 'API key saved';

  @override
  String get chatApiKeyRemoved => 'API key removed';

  @override
  String get chatModelSaved => 'Model saved';

  @override
  String get chatSettingsSaved => 'Chat settings saved';

  @override
  String get settingsChatLabel => 'Chat Settings';

  @override
  String get chatApiKeyStatus => 'API Key Status';

  @override
  String get chatApiKeyView => 'View';

  @override
  String get chatApiKeyChange => 'Change';

  @override
  String get chatApiKeyRemove => 'Remove';

  @override
  String get chatApiKeyMasked => 'sk-or-v1-****';

  @override
  String get chatCustomModelAdd => 'Add Model';

  @override
  String get chatCustomModelRemove => 'Remove';

  @override
  String get chatCustomModelSetActive => 'Set Active';

  @override
  String get chatCustomModelAdded => 'Model added successfully';

  @override
  String get chatCustomModelRemoved => 'Model removed successfully';

  @override
  String get chatCustomModelInvalid => 'Invalid model identifier';

  @override
  String get chatCustomModelIdentifierHint => 'e.g., deepseek/deepseek-chat-v3-0324:free';

  @override
  String get chatCustomModelLabel => 'Custom Models';

  @override
  String get chatCustomModelInputLabel => 'Model Identifier';

  @override
  String get chatCustomModelInputHint => 'Paste model identifier here';

  @override
  String get chatCustomModelListLabel => 'Saved Models';

  @override
  String get chatCustomModelNoModels => 'No custom models added yet';

  @override
  String get chatCustomModelActive => 'Active';

  @override
  String get chatCustomModelSetAsActive => 'Set as Active Model';

  @override
  String get chatCustomModelRemoveConfirm => 'Are you sure you want to remove this model?';

  @override
  String get chatApiKeyRemoveConfirm => 'Are you sure you want to remove your API key?';

  @override
  String get chatApiKeyViewConfirm => 'View API Key';

  @override
  String get chatApiKeyViewConfirmText => 'This will temporarily show your full API key. Be careful not to share it.';

  @override
  String get chatApiKeyCopied => 'API key copied to clipboard';

  @override
  String get chatApiKeyChanged => 'API key changed successfully';

  @override
  String get netCalorieTrackingLabel => 'Net Calorie Tracking';

  @override
  String get baseTDEELabel => 'Base TDEE';

  @override
  String get tdeeWithExerciseLabel => 'TDEE + Exercise';

  @override
  String get netRemainingLabel => 'Net Remaining';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsEnabled => 'Notifications are enabled';

  @override
  String get notificationsDisabled => 'Notifications are disabled';

  @override
  String get notificationPermissionTitle => 'Notification Permission Required';

  @override
  String get notificationPermissionMessage => 'To receive weight check-in reminders, please enable notifications in your device settings.';

  @override
  String get ok => 'OK';
}
