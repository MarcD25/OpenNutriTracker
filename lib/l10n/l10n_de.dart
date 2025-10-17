// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class SDe extends S {
  SDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'OpenNutriTracker';

  @override
  String appVersionName(Object versionNumber) {
    return 'Version $versionNumber';
  }

  @override
  String get appDescription => 'OpenNutriTracker ist ein kostenloser und  quelloffener Kalorien- und Nährstofftracker, der Ihre Privatsphäre respektiert.';

  @override
  String get alphaVersionName => '[Alpha]';

  @override
  String get betaVersionName => '[Beta]';

  @override
  String get addLabel => 'Hinzufügen';

  @override
  String get createCustomDialogTitle => 'Benutzerdefinierte Mahlzeit erstellen?';

  @override
  String get createCustomDialogContent => 'Möchten Sie einen benutzerdefinierte Mahlzeit erstellen?';

  @override
  String get settingsLabel => 'Einstellungen';

  @override
  String get homeLabel => 'Startseite';

  @override
  String get diaryLabel => 'Tagebuch';

  @override
  String get profileLabel => 'Profil';

  @override
  String get chatLabel => 'Chat';

  @override
  String get searchLabel => 'Suchen';

  @override
  String get searchProductsPage => 'Produkte';

  @override
  String get searchFoodPage => 'Lebensmittel';

  @override
  String get searchResultsLabel => 'Suchergebnisse';

  @override
  String get searchDefaultLabel => 'Bitte geben Sie ein Suchwort ein';

  @override
  String get allItemsLabel => 'Alle';

  @override
  String get recentlyAddedLabel => 'Kürzlich';

  @override
  String get noMealsRecentlyAddedLabel => 'Keine kürzlich hinzugefügten Mahlzeiten';

  @override
  String get noActivityRecentlyAddedLabel => 'Keine kürzlich hinzugefügten Aktivitäten';

  @override
  String get dialogOKLabel => 'OK';

  @override
  String get dialogCancelLabel => 'ABBRECHEN';

  @override
  String get buttonStartLabel => 'START';

  @override
  String get buttonNextLabel => 'WEITER';

  @override
  String get buttonSaveLabel => 'Speichern';

  @override
  String get buttonYesLabel => 'JA';

  @override
  String get buttonResetLabel => 'Zurücksetzen';

  @override
  String get onboardingWelcomeLabel => 'Willkommen bei';

  @override
  String get onboardingOverviewLabel => 'Übersicht';

  @override
  String get onboardingYourGoalLabel => 'Ihr Kalorienziel:';

  @override
  String get onboardingYourMacrosGoalLabel => 'Ihr Ziel für Makronährstoffe:';

  @override
  String get onboardingKcalPerDayLabel => 'kcal pro Tag';

  @override
  String get onboardingIntroDescription => 'Um loszulegen, benötigt die App einige Informationen über Sie, um Ihr tägliches Kalorienziel zu berechnen. Alle Informationen über Sie werden sicher auf Ihrem Gerät gespeichert.';

  @override
  String get onboardingGenderQuestionSubtitle => 'Was ist Ihr Geschlecht?';

  @override
  String get onboardingEnterBirthdayLabel => 'Geburtstag';

  @override
  String get onboardingBirthdayHint => 'Datum eingeben';

  @override
  String get onboardingBirthdayQuestionSubtitle => 'Wann haben Sie Geburtstag?';

  @override
  String get onboardingHeightQuestionSubtitle => 'Wie groß sind Sie derzeit?';

  @override
  String get onboardingWeightQuestionSubtitle => 'Wie viel wiegen Sie derzeit?';

  @override
  String get onboardingWrongHeightLabel => 'Geben Sie eine korrekte Größe ein';

  @override
  String get onboardingWrongWeightLabel => 'Geben Sie ein korrekte Gewicht ein';

  @override
  String get onboardingWeightExampleHintKg => 'z. B. 60';

  @override
  String get onboardingWeightExampleHintLbs => 'e.g. 132';

  @override
  String get onboardingHeightExampleHintCm => 'z. B. 170';

  @override
  String get onboardingHeightExampleHintFt => 'e.g. 5.8';

  @override
  String get onboardingActivityQuestionSubtitle => 'Wie aktiv sind Sie? (Ohne Trainingseinheiten)';

  @override
  String get onboardingGoalQuestionSubtitle => 'Was ist Ihr aktuelles Gewichtsziel?';

  @override
  String get onboardingSaveUserError => 'Falsche Eingabe, bitte versuchen Sie es erneut';

  @override
  String get settingsUnitsLabel => 'Einheiten';

  @override
  String get settingsCalculationsLabel => 'Berechnungen';

  @override
  String get settingsThemeLabel => 'Thema';

  @override
  String get settingsThemeLightLabel => 'Hell';

  @override
  String get settingsThemeDarkLabel => 'Dunkel';

  @override
  String get settingsThemeSystemDefaultLabel => 'Systemstandard';

  @override
  String get settingsLicensesLabel => 'Lizenzen';

  @override
  String get settingsDisclaimerLabel => 'Hinweis';

  @override
  String get settingsReportErrorLabel => 'Fehler melden';

  @override
  String get settingsPrivacySettings => 'Datenschutzeinstellungen';

  @override
  String get settingsSourceCodeLabel => 'Quellcode';

  @override
  String get settingFeedbackLabel => 'Feedback';

  @override
  String get settingAboutLabel => 'Über';

  @override
  String get settingsMassLabel => 'Masse';

  @override
  String get settingsSystemLabel => 'System';

  @override
  String get settingsMetricLabel => 'Metric (kg, cm, ml)';

  @override
  String get settingsImperialLabel => 'Imperial (lbs, ft, oz)';

  @override
  String get settingsDistanceLabel => 'Entfernung';

  @override
  String get settingsVolumeLabel => 'Volumen';

  @override
  String get disclaimerText => 'OpenNutriTracker ist keine medizinische Anwendung. Alle bereitgestellten Daten sind nicht validiert und sollten mit Vorsicht verwendet werden. Bitte pflegen Sie einen gesunden Lebensstil und konsultieren Sie einen Fachmann, wenn Sie Probleme haben. Die Verwendung während einer Krankheit, Schwangerschaft oder Stillzeit wird nicht empfohlen.\n\n\nDie Anwendung befindet sich noch in der Entwicklung. Fehler, Bugs und Abstürze können auftreten.';

  @override
  String get reportErrorDialogText => 'Möchten Sie einen Fehler an den Entwickler melden?';

  @override
  String get sendAnonymousUserData => 'Anonyme Nutzungsdaten senden?';

  @override
  String get appLicenseLabel => 'GPL-3.0 Lizenz';

  @override
  String get calculationsTDEELabel => 'TDEE-Gleichung';

  @override
  String get calculationsTDEEIOM2006Label => 'Institute of Medicine Gleichung';

  @override
  String get calculationsRecommendedLabel => '(empfohlen)';

  @override
  String get calculationsMacronutrientsDistributionLabel => 'Verteilung der Makronährstoffe';

  @override
  String calculationsMacrosDistribution(Object pctCarbs, Object pctFats, Object pctProteins) {
    return '$pctCarbs% Kohlenhydrate, $pctFats% Fette, $pctProteins% Proteine';
  }

  @override
  String get dailyKcalAdjustmentLabel => 'Tägliche kcal-Anpassung:';

  @override
  String get macroDistributionLabel => 'Makronährstoff-Verteilung:';

  @override
  String get exportImportLabel => 'Daten Exportieren / Importieren';

  @override
  String get exportImportDescription => 'Sie können die App-Daten in eine Zip-Datei exportieren und später importieren. Dies ist nützlich, wenn Sie Ihre Daten sichern oder auf ein anderes Gerät übertragen möchten.\n\nDie App nutzt keinen Cloud-Dienst, um Ihre Daten zu speichern.';

  @override
  String get exportImportSuccessLabel => 'Export / Import erfolgreich';

  @override
  String get exportImportErrorLabel => 'Fehler beim Export/Import';

  @override
  String get exportAction => 'Exportieren';

  @override
  String get importAction => 'Importieren';

  @override
  String get addItemLabel => 'Neuen Eintrag hinzufügen:';

  @override
  String get activityLabel => 'Aktivität';

  @override
  String get activityExample => 'z. B. Laufen, Radfahren, Yoga ...';

  @override
  String get breakfastLabel => 'Frühstück';

  @override
  String get breakfastExample => 'z. B. Müsli, Milch, Kaffee ...';

  @override
  String get lunchLabel => 'Mittagessen';

  @override
  String get lunchExample => 'z. B. Pizza, Salat, Reis ...';

  @override
  String get dinnerLabel => 'Abendessen';

  @override
  String get dinnerExample => 'z. B. Suppe, Hähnchen, Wein ...';

  @override
  String get snackLabel => 'Snack';

  @override
  String get snackExample => 'z. B. Apfel, Eiscreme, Schokolade ...';

  @override
  String get editItemDialogTitle => 'Eintrag aktualisieren';

  @override
  String get itemUpdatedSnackbar => 'Eintrag aktualisiert';

  @override
  String get aiProcessingMessage => 'KI verarbeitet Ihre Nachricht...';

  @override
  String get deleteTimeDialogTitle => 'Eintrag löschen?';

  @override
  String get deleteTimeDialogContent => 'Möchten Sie den ausgewählten Eintrag löschen?';

  @override
  String get deleteTimeDialogPluralTitle => 'Einträge löschen?';

  @override
  String get deleteTimeDialogPluralContent => 'Möchten Sie alle Einträge dieser Mahlzeit löschen?';

  @override
  String get itemDeletedSnackbar => 'Eintrag gelöscht';

  @override
  String get copyDialogTitle => 'Zu welcher Mahlzeit hinzufügen?';

  @override
  String get copyOrDeleteTimeDialogTitle => 'Was soll getan werden?';

  @override
  String get copyOrDeleteTimeDialogContent => 'Auf \"Zu anderem Tag kopieren\" klicken, um die Mahlzeit zu einem anderen Tag zu kopieren. Mit \"Löschen\" kann die Mahlzeit entfernt werden';

  @override
  String get dialogCopyLabel => 'Zu anderem Tag kopieren';

  @override
  String get dialogDeleteLabel => 'LÖSCHEN';

  @override
  String get deleteAllLabel => 'Alle löschen';

  @override
  String get suppliedLabel => 'zugeführt';

  @override
  String get burnedLabel => 'verbrannt';

  @override
  String get kcalLeftLabel => 'kcal übrig';

  @override
  String get nutritionInfoLabel => 'Nährwertangaben';

  @override
  String get kcalLabel => 'kcal';

  @override
  String get carbsLabel => 'Kohlenhydrate';

  @override
  String get fatLabel => 'Fett';

  @override
  String get proteinLabel => 'Protein';

  @override
  String get energyLabel => 'Energie';

  @override
  String get saturatedFatLabel => 'gesättigtes Fett';

  @override
  String get carbohydrateLabel => 'Kohlenhydrate';

  @override
  String get sugarLabel => 'Zucker';

  @override
  String get fiberLabel => 'Ballaststoffe';

  @override
  String get per100gmlLabel => 'Pro 100 g/ml';

  @override
  String get additionalInfoLabelOFF => 'Weitere Informationen unter\nOpenFoodFacts';

  @override
  String get offDisclaimer => 'Die Daten, die Ihnen mit dieser App zur Verfügung gestellt werden, stammen aus der Open Food Facts-Datenbank. Es kann keine Garantie für die Richtigkeit, Vollständigkeit oder Zuverlässigkeit der bereitgestellten Informationen übernommen werden. Die Daten werden ohne Mängelgewähr zur Verfügung gestellt, und die Ursprungsquelle der Daten (Open Food Facts) haftet nicht für Schäden, die aus der Verwendung der Daten entstehen.';

  @override
  String get additionalInfoLabelFDC => 'Weitere Informationen unter\nFoodData Central';

  @override
  String get additionalInfoLabelUnknown => 'Unbekannte Mahlzeit';

  @override
  String get additionalInfoLabelCustom => 'Benutzerdefinierte Mahlzeit';

  @override
  String get additionalInfoLabelCompendium2011 => 'Informationen bereitgestellt von\n\'2011 Compendium\n of Physical Activities\'';

  @override
  String get quantityLabel => 'Menge';

  @override
  String get baseQuantityLabel => 'Base quantity (g/ml)';

  @override
  String get unitLabel => 'Einheit';

  @override
  String get scanProductLabel => 'Produkt scannen';

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
  String get missingProductInfo => 'Produkt fehlen die erforderlichen Angaben zu Kalorien oder Makronährstoffen';

  @override
  String get infoAddedIntakeLabel => 'Neue Aufnahme hinzugefügt';

  @override
  String get infoAddedActivityLabel => 'Neue Aktivität hinzugefügt';

  @override
  String get editMealLabel => 'Mahlzeit bearbeiten';

  @override
  String get mealNameLabel => 'Mahlzeitenname';

  @override
  String get mealBrandsLabel => 'Marken';

  @override
  String get mealSizeLabel => 'Mahlzeitsgröße (g/ml)';

  @override
  String get mealSizeLabelImperial => 'Mahlzeitsgröße (oz/fl oz)';

  @override
  String get servingLabel => 'Portion';

  @override
  String get perServingLabel => 'Pro Portion';

  @override
  String get servingSizeLabelMetric => 'Portionsgröße (g/ml)';

  @override
  String get servingSizeLabelImperial => 'Portionsgröße (oz/fl oz)';

  @override
  String get mealUnitLabel => 'Mahlzeiteinheit';

  @override
  String get mealKcalLabel => 'kcal pro 100 g/ml';

  @override
  String get mealCarbsLabel => 'Kohlenhydrate pro 100 g/ml';

  @override
  String get mealFatLabel => 'Fett pro 100 g/ml';

  @override
  String get mealProteinLabel => 'Protein pro 100 g/ml';

  @override
  String get errorMealSave => 'Fehler beim Speichern der Mahlzeit. Haben Sie die korrekten Mahlzeiteninformationen eingegeben?';

  @override
  String get bmiLabel => 'BMI';

  @override
  String get bmiInfo => 'Der Body-Mass-Index (BMI) ist ein Index zur Klassifizierung von Übergewicht und Fettleibigkeit bei Erwachsenen. Er wird berechnet, indem das Gewicht in Kilogramm durch das Quadrat der Körpergröße in Metern (kg/m²) geteilt wird.\n\nDer BMI unterscheidet nicht zwischen Fett- und Muskelmasse und kann für einige Personen irreführend sein.';

  @override
  String get readLabel => 'Ich habe die Datenschutzbestimmungen gelesen und akzeptiere sie.';

  @override
  String get privacyPolicyLabel => 'Datenschutzrichtlinie';

  @override
  String get dataCollectionLabel => 'Unterstützen der Entwicklung durch Bereitstellung anonymer Nutzungsdaten';

  @override
  String get palSedentaryLabel => 'Sitzend';

  @override
  String get palSedentaryDescriptionLabel => 'z. B. Büroarbeit und hauptsächlich sitzende Freizeitaktivitäten';

  @override
  String get palLowLActiveLabel => 'Leicht aktiv';

  @override
  String get palLowActiveDescriptionLabel => 'z. B. Sitzen oder Stehen bei der Arbeit und leichte Freizeitaktivitäten';

  @override
  String get palActiveLabel => 'Aktiv';

  @override
  String get palActiveDescriptionLabel => 'Überwiegend Stehen oder Gehen bei der Arbeit und aktive Freizeitaktivitäten';

  @override
  String get palVeryActiveLabel => 'Sehr aktiv';

  @override
  String get palVeryActiveDescriptionLabel => 'Überwiegend Gehen, Laufen oder Gewichte tragen bei der Arbeit und aktive Freizeitaktivitäten';

  @override
  String get selectPalCategoryLabel => 'Aktivitätslevel auswählen';

  @override
  String get chooseWeightGoalLabel => 'Gewichtsziel wählen';

  @override
  String get goalLoseWeight => 'Gewicht verlieren';

  @override
  String get goalMaintainWeight => 'Gewicht halten';

  @override
  String get goalGainWeight => 'Gewicht zunehmen';

  @override
  String get goalLabel => 'Ziel';

  @override
  String get selectHeightDialogLabel => 'Größe auswählen';

  @override
  String get heightLabel => 'Größe';

  @override
  String get cmLabel => 'cm';

  @override
  String get ftLabel => 'ft';

  @override
  String get selectWeightDialogLabel => 'Gewicht auswählen';

  @override
  String get weightLabel => 'Gewicht';

  @override
  String get kgLabel => 'kg';

  @override
  String get lbsLabel => 'lbs';

  @override
  String get ageLabel => 'Alter';

  @override
  String yearsLabel(Object age) {
    return '$age Jahre';
  }

  @override
  String get selectGenderDialogLabel => 'Geschlecht auswählen';

  @override
  String get genderLabel => 'Geschlecht';

  @override
  String get genderMaleLabel => '♂ männlich';

  @override
  String get genderFemaleLabel => '♀ weiblich';

  @override
  String get nothingAddedLabel => 'Nichts hinzugefügt';

  @override
  String get nutritionalStatusUnderweight => 'Untergewicht';

  @override
  String get nutritionalStatusNormalWeight => 'Normales Gewicht';

  @override
  String get nutritionalStatusPreObesity => 'Prä-Adipositas';

  @override
  String get nutritionalStatusObeseClassI => 'Fettleibigkeit Klasse I';

  @override
  String get nutritionalStatusObeseClassII => 'Fettleibigkeit Klasse II';

  @override
  String get nutritionalStatusObeseClassIII => 'Fettleibigkeit Klasse III';

  @override
  String nutritionalStatusRiskLabel(Object riskValue) {
    return 'Risiko für Begleiterkrankungen: $riskValue';
  }

  @override
  String get nutritionalStatusRiskLow => 'Niedrig \n(aber erhöhtes Risiko für andere \nklinische Probleme)';

  @override
  String get nutritionalStatusRiskAverage => 'Durchschnittlich';

  @override
  String get nutritionalStatusRiskIncreased => 'Erhöht';

  @override
  String get nutritionalStatusRiskModerate => 'Mäßig';

  @override
  String get nutritionalStatusRiskSevere => 'Schwerwiegend';

  @override
  String get nutritionalStatusRiskVerySevere => 'Sehr schwerwiegend';

  @override
  String get errorOpeningEmail => 'Fehler beim Öffnen der E-Mail-Anwendung';

  @override
  String get errorOpeningBrowser => 'Fehler beim Öffnen der Browser-Anwendung';

  @override
  String get errorFetchingProductData => 'Fehler beim Abrufen von Produktinformationen';

  @override
  String get errorProductNotFound => 'Produkt nicht gefunden';

  @override
  String get errorLoadingActivities => 'Fehler beim Laden von Aktivitäten';

  @override
  String get noResultsFound => 'Keine Ergebnisse gefunden';

  @override
  String get retryLabel => 'Erneut versuchen';

  @override
  String get paHeadingBicycling => 'Radfahren';

  @override
  String get paHeadingConditionalExercise => 'Konditionstraining';

  @override
  String get paHeadingDancing => 'Tanzen';

  @override
  String get paHeadingRunning => 'Laufen';

  @override
  String get paHeadingSports => 'Sport';

  @override
  String get paHeadingWalking => 'Gehen';

  @override
  String get paHeadingWaterActivities => 'Wassersport';

  @override
  String get paHeadingWinterActivities => 'Winteraktivitäten';

  @override
  String get paGeneralDesc => 'allgemein';

  @override
  String get paBicyclingGeneral => 'Radfahren';

  @override
  String get paBicyclingGeneralDesc => 'allgemein';

  @override
  String get paBicyclingMountainGeneral => 'Mountainbiking';

  @override
  String get paBicyclingMountainGeneralDesc => 'allgemein';

  @override
  String get paUnicyclingGeneral => 'Einradfahren';

  @override
  String get paUnicyclingGeneralDesc => 'allgemein';

  @override
  String get paBicyclingStationaryGeneral => 'Stationäres Radfahren';

  @override
  String get paBicyclingStationaryGeneralDesc => 'allgemein';

  @override
  String get paCalisthenicsGeneral => 'Calisthenics';

  @override
  String get paCalisthenicsGeneralDesc => 'leichte oder mäßige Anstrengung, allgemein (z.B. Rückenübungen)';

  @override
  String get paResistanceTraining => 'Krafttraining';

  @override
  String get paResistanceTrainingDesc => 'Gewichtheben, Freigewichte, Nautilus oder Universal';

  @override
  String get paRopeSkippingGeneral => 'Seilspringen';

  @override
  String get paRopeSkippingGeneralDesc => 'allgemein';

  @override
  String get paWaterAerobics => 'Wassergymnastik';

  @override
  String get paWaterAerobicsDesc => 'Wassergymnastik, Wasser-Calisthenics';

  @override
  String get paDancingAerobicGeneral => 'Aerobic';

  @override
  String get paDancingAerobicGeneralDesc => 'allgemein';

  @override
  String get paDancingGeneral => 'allgemeines Tanzen';

  @override
  String get paDancingGeneralDesc => 'z.B. Disco, Folk, irischer Stepptanz, Line Dance, Polka, Contra, Country';

  @override
  String get paJoggingGeneral => 'Joggen';

  @override
  String get paJoggingGeneralDesc => 'allgemein';

  @override
  String get paRunningGeneral => 'Laufen';

  @override
  String get paRunningGeneralDesc => 'allgemein';

  @override
  String get paArcheryGeneral => 'Bogenschießen';

  @override
  String get paArcheryGeneralDesc => 'keine Jagd';

  @override
  String get paBadmintonGeneral => 'Badminton';

  @override
  String get paBadmintonGeneralDesc => 'gesellige Einzel- und Doppelspiele, allgemein';

  @override
  String get paBasketballGeneral => 'Basketball';

  @override
  String get paBasketballGeneralDesc => 'allgemein';

  @override
  String get paBilliardsGeneral => 'Billard';

  @override
  String get paBilliardsGeneralDesc => 'allgemein';

  @override
  String get paBowlingGeneral => 'Bowling';

  @override
  String get paBowlingGeneralDesc => 'allgemein';

  @override
  String get paBoxingBag => 'Boxen';

  @override
  String get paBoxingBagDesc => 'Boxsack';

  @override
  String get paBoxingGeneral => 'Boxen';

  @override
  String get paBoxingGeneralDesc => 'im Ring, allgemein';

  @override
  String get paBroomball => 'Broomball';

  @override
  String get paBroomballDesc => 'allgemein';

  @override
  String get paChildrenGame => 'Kinderspiele';

  @override
  String get paChildrenGameDesc => '(z.B. Himmel und Hölle, Vier gewinnt, Völkerball, Spielplatzgeräte, T-Ball, Leitball, Murmeln, Arcade-Spiele), mäßige Anstrengung';

  @override
  String get paCheerleading => 'Cheerleading';

  @override
  String get paCheerleadingDesc => 'gymnastische Übungen, Wettkampf';

  @override
  String get paCricket => 'Cricket';

  @override
  String get paCricketDesc => 'Schlagen, Werfen, Feldarbeit';

  @override
  String get paCroquet => 'Croquet';

  @override
  String get paCroquetDesc => 'allgemein';

  @override
  String get paCurling => 'Curling';

  @override
  String get paCurlingDesc => 'allgemein';

  @override
  String get paDartsWall => 'Darts';

  @override
  String get paDartsWallDesc => 'Wand oder Rasen';

  @override
  String get paAutoRacing => 'Autorennen';

  @override
  String get paAutoRacingDesc => 'offene Räder';

  @override
  String get paFencing => 'Fechten';

  @override
  String get paFencingDesc => 'allgemein';

  @override
  String get paAmericanFootballGeneral => 'American Football';

  @override
  String get paAmericanFootballGeneralDesc => 'Touch, Flag, allgemein';

  @override
  String get paCatch => 'Football oder Baseball';

  @override
  String get paCatchDesc => 'Fangen spielen';

  @override
  String get paFrisbee => 'Frisbee spielen';

  @override
  String get paFrisbeeDesc => 'allgemein';

  @override
  String get paGolfGeneral => 'Golf';

  @override
  String get paGolfGeneralDesc => 'allgemein';

  @override
  String get paGymnasticsGeneral => 'Gymnastik';

  @override
  String get paGymnasticsGeneralDesc => 'allgemein';

  @override
  String get paHackySack => 'Hacky Sack';

  @override
  String get paHackySackDesc => 'allgemein';

  @override
  String get paHandballGeneral => 'Handball';

  @override
  String get paHandballGeneralDesc => 'allgemein';

  @override
  String get paHangGliding => 'Drachenfliegen';

  @override
  String get paHangGlidingDesc => 'allgemein';

  @override
  String get paHockeyField => 'Hockey, Feld';

  @override
  String get paHockeyFieldDesc => 'allgemein';

  @override
  String get paIceHockeyGeneral => 'Eishockey';

  @override
  String get paIceHockeyGeneralDesc => 'allgemein';

  @override
  String get paHorseRidingGeneral => 'Reiten';

  @override
  String get paHorseRidingGeneralDesc => 'allgemein';

  @override
  String get paJaiAlai => 'Jai Alai';

  @override
  String get paJaiAlaiDesc => 'allgemein';

  @override
  String get paMartialArtsSlower => 'Kampfsport';

  @override
  String get paMartialArtsSlowerDesc => 'verschiedene Arten, langsames Tempo, Anfänger, Übung';

  @override
  String get paMartialArtsModerate => 'Kampfsport';

  @override
  String get paMartialArtsModerateDesc => 'verschiedene Arten, moderates Tempo (z.B. Judo, Jujitsu, Karate, Kickboxen, Taekwondo, Tai-Bo, Muay Thai Boxen)';

  @override
  String get paJuggling => 'Jonglieren';

  @override
  String get paJugglingDesc => 'allgemein';

  @override
  String get paKickball => 'Kickball';

  @override
  String get paKickballDesc => 'allgemein';

  @override
  String get paLacrosse => 'Lacrosse';

  @override
  String get paLacrosseDesc => 'allgemein';

  @override
  String get paLawnBowling => 'Rasenbowling';

  @override
  String get paLawnBowlingDesc => 'Boccia, draußen';

  @override
  String get paMotoCross => 'Motocross';

  @override
  String get paMotoCrossDesc => 'Geländemotorsport, Geländewagen, allgemein';

  @override
  String get paOrienteering => 'Orientierungslauf';

  @override
  String get paOrienteeringDesc => 'allgemein';

  @override
  String get paPaddleball => 'Paddleball';

  @override
  String get paPaddleballDesc => 'ungezwungen, allgemein';

  @override
  String get paPoloHorse => 'Polo';

  @override
  String get paPoloHorseDesc => 'auf dem Pferd';

  @override
  String get paRacquetball => 'Racquetball';

  @override
  String get paRacquetballDesc => 'allgemein';

  @override
  String get paMountainClimbing => 'Klettern';

  @override
  String get paMountainClimbingDesc => 'Felsen- oder Bergsteigen';

  @override
  String get paRodeoSportGeneralModerate => 'Rodeosport';

  @override
  String get paRodeoSportGeneralModerateDesc => 'allgemein, moderater Aufwand';

  @override
  String get paRopeJumpingGeneral => 'Seilspringen';

  @override
  String get paRopeJumpingGeneralDesc => 'mittleres Tempo, 100-120 Sprünge/Min., allgemein, beidfüßiges Springen, einfacher Sprung';

  @override
  String get paRugbyCompetitive => 'Rugby';

  @override
  String get paRugbyCompetitiveDesc => 'Union, Mannschaft, wettbewerbsorientiert';

  @override
  String get paRugbyNonCompetitive => 'Rugby';

  @override
  String get paRugbyNonCompetitiveDesc => 'Berührung, nicht wettbewerbsorientiert';

  @override
  String get paShuffleboard => 'Shuffleboard';

  @override
  String get paShuffleboardDesc => 'allgemein';

  @override
  String get paSkateboardingGeneral => 'Skateboarding';

  @override
  String get paSkateboardingGeneralDesc => 'allgemein, mäßiger Aufwand';

  @override
  String get paSkatingRoller => 'Roller-Skating';

  @override
  String get paSkatingRollerDesc => 'allgemein';

  @override
  String get paRollerbladingLight => 'Inlineskaten';

  @override
  String get paRollerbladingLightDesc => 'allgemein';

  @override
  String get paSkydiving => 'skydiving';

  @override
  String get paSkydivingDesc => 'Fallschirmspringen, Base-Jumping, Bungee-Jumping';

  @override
  String get paSoccerGeneral => 'Fußball';

  @override
  String get paSoccerGeneralDesc => 'Freizeit, allgemein';

  @override
  String get paSoftballBaseballGeneral => 'Softball / Baseball';

  @override
  String get paSoftballBaseballGeneralDesc => 'Schnell- oder Langstreckenpitching, allgemein';

  @override
  String get paSquashGeneral => 'Squash';

  @override
  String get paSquashGeneralDesc => 'allgemein';

  @override
  String get paTableTennisGeneral => 'Tischtennis';

  @override
  String get paTableTennisGeneralDesc => 'Tischtennis, Ping Pong';

  @override
  String get paTaiChiQiGongGeneral => 'Tai Chi, Qi Gong';

  @override
  String get paTaiChiQiGongGeneralDesc => 'allgemein';

  @override
  String get paTennisGeneral => 'Tennis';

  @override
  String get paTennisGeneralDesc => 'allgemein';

  @override
  String get paTrampolineLight => 'Trampolin';

  @override
  String get paTrampolineLightDesc => 'Freizeit';

  @override
  String get paVolleyballGeneral => 'Volleyball';

  @override
  String get paVolleyballGeneralDesc => 'nicht-wettkampforientiert, 6-9 Spieler, allgemein';

  @override
  String get paWrestling => 'Ringen';

  @override
  String get paWrestlingDesc => 'allgemein';

  @override
  String get paWallyball => 'Wallyball';

  @override
  String get paWallyballDesc => 'allgemein';

  @override
  String get paTrackField => 'Leichtathletik';

  @override
  String get paTrackField1Desc => '(z. B. Kugelstoßen, Diskuswurf, Hammerwurf)';

  @override
  String get paTrackField2Desc => '(z. B. Hochsprung, Weitsprung, Dreisprung, Speerwurf, Stabhochsprung)';

  @override
  String get paTrackField3Desc => '(z. B. Hindernislauf, Hürdenlauf)';

  @override
  String get paBackpackingGeneral => 'Wandern mit Rucksack';

  @override
  String get paBackpackingGeneralDesc => 'allgemein';

  @override
  String get paClimbingHillsNoLoadGeneral => 'Hügelklettern ohne Last';

  @override
  String get paClimbingHillsNoLoadGeneralDesc => 'keine Last';

  @override
  String get paHikingCrossCountry => 'Wandern';

  @override
  String get paHikingCrossCountryDesc => 'Cross-Country';

  @override
  String get paWalkingForPleasure => 'Spazieren gehen';

  @override
  String get paWalkingForPleasureDesc => 'aus Vergnügen';

  @override
  String get paWalkingTheDog => 'Gassi gehen';

  @override
  String get paWalkingTheDogDesc => 'allgemein';

  @override
  String get paCanoeingGeneral => 'Kanufahren';

  @override
  String get paCanoeingGeneralDesc => 'rudern, zum Vergnügen, allgemein';

  @override
  String get paDivingSpringboardPlatform => 'Tauchen';

  @override
  String get paDivingSpringboardPlatformDesc => 'Sprungbrett oder Plattform';

  @override
  String get paKayakingModerate => 'Kajakfahren';

  @override
  String get paKayakingModerateDesc => 'mäßige Anstrengung';

  @override
  String get paPaddleBoat => 'Tretboot';

  @override
  String get paPaddleBoatDesc => 'allgemein';

  @override
  String get paSailingGeneral => 'Segeln';

  @override
  String get paSailingGeneralDesc => 'Segeln, Windsurfen, Eissegeln, allgemein';

  @override
  String get paSkiingWaterWakeboarding => 'Wasserski';

  @override
  String get paSkiingWaterWakeboardingDesc => 'Wasser- oder Wakeboarding';

  @override
  String get paDivingGeneral => 'Tauchen';

  @override
  String get paDivingGeneralDesc => 'Gerätetauchen, Sporttauchen, allgemein';

  @override
  String get paSnorkeling => 'Schnorcheln';

  @override
  String get paSnorkelingDesc => 'allgemein';

  @override
  String get paSurfing => 'Surfen';

  @override
  String get paSurfingDesc => 'Körper- oder Brettsurfen, allgemein';

  @override
  String get paPaddleBoarding => 'Stand-Up Paddeln';

  @override
  String get paPaddleBoardingDesc => 'stehend';

  @override
  String get paSwimmingGeneral => 'Schwimmen';

  @override
  String get paSwimmingGeneralDesc => 'Wassertreten, mäßige Anstrengung, allgemein';

  @override
  String get paWateraerobicsCalisthenics => 'Wassergymnastik';

  @override
  String get paWateraerobicsCalisthenicsDesc => 'Wassergymnastik, Wasser-Kalorienverbrennungsgymnastik';

  @override
  String get paWaterPolo => 'Wasserball';

  @override
  String get paWaterPoloDesc => 'allgemein';

  @override
  String get paWaterVolleyball => 'Wasser-Volleyball';

  @override
  String get paWaterVolleyballDesc => 'allgemein';

  @override
  String get paIceSkatingGeneral => 'Eislaufen';

  @override
  String get paIceSkatingGeneralDesc => 'allgemein';

  @override
  String get paSkiingGeneral => 'Skifahren';

  @override
  String get paSkiingGeneralDesc => 'allgemein';

  @override
  String get paSnowShovingModerate => 'Schnee schaufeln';

  @override
  String get paSnowShovingModerateDesc => 'manuell, mäßige Anstrengung';

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
  String get netCalorieTrackingLabel => 'Netto-Kalorienverfolgung';

  @override
  String get baseTDEELabel => 'Basis TDEE';

  @override
  String get tdeeWithExerciseLabel => 'TDEE + Übung';

  @override
  String get netRemainingLabel => 'Netto Verbleibend';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get notificationsEnabled => 'Benachrichtigungen sind aktiviert';

  @override
  String get notificationsDisabled => 'Benachrichtigungen sind deaktiviert';

  @override
  String get notificationPermissionTitle => 'Benachrichtigungsberechtigung erforderlich';

  @override
  String get notificationPermissionMessage => 'Um Erinnerungen für Gewichtskontrollen zu erhalten, aktivieren Sie bitte Benachrichtigungen in Ihren Geräteeinstellungen.';

  @override
  String get ok => 'OK';
}
