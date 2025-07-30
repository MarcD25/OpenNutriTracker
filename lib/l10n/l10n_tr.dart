// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class STr extends S {
  STr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'OpenNutriTracker';

  @override
  String appVersionName(Object versionNumber) {
    return 'Versiyon $versionNumber';
  }

  @override
  String get appDescription => 'OpenNutriTracker, gizliliğinize saygı duyan ücretsiz ve açık kaynaklı bir kalori ve besin takipçisidir.';

  @override
  String get alphaVersionName => '[Alpha]';

  @override
  String get betaVersionName => '[Beta]';

  @override
  String get addLabel => 'Ekle';

  @override
  String get createCustomDialogTitle => 'Özel yemek öğesi oluştur?';

  @override
  String get createCustomDialogContent => 'Özel bir yemek öğesi oluşturmak istiyor musunuz?';

  @override
  String get settingsLabel => 'Ayarlar';

  @override
  String get homeLabel => 'Ana Sayfa';

  @override
  String get diaryLabel => 'Günlük';

  @override
  String get profileLabel => 'Profil';

  @override
  String get chatLabel => 'Chat';

  @override
  String get searchLabel => 'Ara';

  @override
  String get searchProductsPage => 'Ürünler';

  @override
  String get searchFoodPage => 'Yiyecek';

  @override
  String get searchResultsLabel => 'Arama sonuçları';

  @override
  String get searchDefaultLabel => 'Lütfen bir arama kelimesi girin';

  @override
  String get allItemsLabel => 'Tümü';

  @override
  String get recentlyAddedLabel => 'Son Eklenenler';

  @override
  String get noMealsRecentlyAddedLabel => 'Son zamanlarda eklenen yemek yok';

  @override
  String get noActivityRecentlyAddedLabel => 'Son zamanlarda eklenen aktivite yok';

  @override
  String get dialogOKLabel => 'TAMAM';

  @override
  String get dialogCancelLabel => 'İPTAL';

  @override
  String get buttonStartLabel => 'BAŞLA';

  @override
  String get buttonNextLabel => 'İLERİ';

  @override
  String get buttonSaveLabel => 'Kaydet';

  @override
  String get buttonYesLabel => 'EVET';

  @override
  String get buttonResetLabel => 'Sıfırla';

  @override
  String get onboardingWelcomeLabel => 'Hoş geldiniz';

  @override
  String get onboardingOverviewLabel => 'Genel Bakış';

  @override
  String get onboardingYourGoalLabel => 'Kalori hedefiniz:';

  @override
  String get onboardingYourMacrosGoalLabel => 'Makro besin hedefleriniz:';

  @override
  String get onboardingKcalPerDayLabel => 'günlük kcal';

  @override
  String get onboardingIntroDescription => 'Başlamak için, uygulamanın günlük kalori hedefinizi hesaplamak için hakkınızda bazı bilgilere ihtiyacı var.\nHakkınızdaki tüm bilgiler cihazınızda güvenli bir şekilde saklanır.';

  @override
  String get onboardingGenderQuestionSubtitle => 'Cinsiyetiniz nedir?';

  @override
  String get onboardingEnterBirthdayLabel => 'Doğum Günü';

  @override
  String get onboardingBirthdayHint => 'Tarih Girin';

  @override
  String get onboardingBirthdayQuestionSubtitle => 'Doğum gününüz ne zaman?';

  @override
  String get onboardingHeightQuestionSubtitle => 'Mevcut boyunuz nedir?';

  @override
  String get onboardingWeightQuestionSubtitle => 'Mevcut kilonuz nedir?';

  @override
  String get onboardingWrongHeightLabel => 'Doğru boy girin';

  @override
  String get onboardingWrongWeightLabel => 'Doğru kilo girin';

  @override
  String get onboardingWeightExampleHintKg => 'ör. 60';

  @override
  String get onboardingWeightExampleHintLbs => 'ör. 132';

  @override
  String get onboardingHeightExampleHintCm => 'ör. 170';

  @override
  String get onboardingHeightExampleHintFt => 'ör. 5.8';

  @override
  String get onboardingActivityQuestionSubtitle => 'Ne kadar aktifsiz? (antrenmanlar hariç)';

  @override
  String get onboardingGoalQuestionSubtitle => 'Mevcut kilo hedefiniz nedir?';

  @override
  String get onboardingSaveUserError => 'Yanlış giriş, lütfen tekrar deneyin';

  @override
  String get settingsUnitsLabel => 'Birimler';

  @override
  String get settingsCalculationsLabel => 'Hesaplamalar';

  @override
  String get settingsThemeLabel => 'Tema';

  @override
  String get settingsThemeLightLabel => 'Açık';

  @override
  String get settingsThemeDarkLabel => 'Koyu';

  @override
  String get settingsThemeSystemDefaultLabel => 'Sistem varsayılanı';

  @override
  String get settingsLicensesLabel => 'Lisanslar';

  @override
  String get settingsDisclaimerLabel => 'Sorumluluk Reddi';

  @override
  String get settingsReportErrorLabel => 'Hata Bildir';

  @override
  String get settingsPrivacySettings => 'Gizlilik Ayarları';

  @override
  String get settingsSourceCodeLabel => 'Kaynak Kodu';

  @override
  String get settingFeedbackLabel => 'Geri Bildirim';

  @override
  String get settingAboutLabel => 'Hakkında';

  @override
  String get settingsMassLabel => 'Kütle';

  @override
  String get settingsSystemLabel => 'Sistem';

  @override
  String get settingsMetricLabel => 'Metrik (kg, cm, ml)';

  @override
  String get settingsImperialLabel => 'İmperial (lbs, ft, oz)';

  @override
  String get settingsDistanceLabel => 'Mesafe';

  @override
  String get settingsVolumeLabel => 'Hacim';

  @override
  String get disclaimerText => 'OpenNutriTracker bir tıbbi uygulama değildir. Sağlanan tüm veriler doğrulanmamıştır ve dikkatle kullanılmalıdır. Lütfen sağlıklı bir yaşam tarzı sürdürün ve herhangi bir sorununuz varsa bir profesyonele danışın. Hastalık, hamilelik veya emzirme döneminde kullanımı önerilmez.\n\n\nUygulama hala geliştirme aşamasındadır. Hatalar, aksaklıklar ve çökmeler meydana gelebilir.';

  @override
  String get reportErrorDialogText => 'Geliştiriciye bir hata bildirmek istiyor musunuz?';

  @override
  String get sendAnonymousUserData => 'Anonim kullanım verileri gönder';

  @override
  String get appLicenseLabel => 'GPL-3.0 lisansı';

  @override
  String get calculationsTDEELabel => 'TDEE denklemi';

  @override
  String get calculationsTDEEIOM2006Label => 'Tıp Enstitüsü Denklemi';

  @override
  String get calculationsRecommendedLabel => '(önerilen)';

  @override
  String get calculationsMacronutrientsDistributionLabel => 'Makro besin dağılımı';

  @override
  String calculationsMacrosDistribution(Object pctCarbs, Object pctFats, Object pctProteins) {
    return '%$pctCarbs karbonhidrat, %$pctFats yağ, %$pctProteins protein';
  }

  @override
  String get dailyKcalAdjustmentLabel => 'Günlük Kcal ayarı:';

  @override
  String get macroDistributionLabel => 'Makro besin Dağılımı:';

  @override
  String get exportImportLabel => 'Verileri Dışa Aktar / İçe Aktar';

  @override
  String get exportImportDescription => 'Uygulama verilerini bir zip dosyasına dışa aktarabilir ve daha sonra içe aktarabilirsiniz. Bu, verilerinizi yedeklemek veya başka bir cihaza aktarmak istiyorsanız kullanışlıdır.\n\nUygulama, verilerinizi saklamak için herhangi bir bulut hizmeti kullanmaz.';

  @override
  String get exportImportSuccessLabel => 'Dışa Aktarma / İçe Aktarma başarılı';

  @override
  String get exportImportErrorLabel => 'Dışa Aktarma / İçe Aktarma hatası';

  @override
  String get exportAction => 'Dışa Aktar';

  @override
  String get importAction => 'İçe Aktar';

  @override
  String get addItemLabel => 'Yeni Öğe Ekle:';

  @override
  String get activityLabel => 'Aktivite';

  @override
  String get activityExample => 'ör. koşu, bisiklet, yoga ...';

  @override
  String get breakfastLabel => 'Kahvaltı';

  @override
  String get breakfastExample => 'ör. mısır gevreği, süt, kahve ...';

  @override
  String get lunchLabel => 'Öğle Yemeği';

  @override
  String get lunchExample => 'ör. pizza, salata, pirinç ...';

  @override
  String get dinnerLabel => 'Akşam Yemeği';

  @override
  String get dinnerExample => 'ör. çorba, tavuk, şarap ...';

  @override
  String get snackLabel => 'Atıştırmalık';

  @override
  String get snackExample => 'ör. elma, dondurma, çikolata ...';

  @override
  String get editItemDialogTitle => 'Öğeyi Düzenle';

  @override
  String get itemUpdatedSnackbar => 'Öğe güncellendi';

  @override
  String get aiProcessingMessage => 'AI mesajınızı işliyor...';

  @override
  String get deleteTimeDialogTitle => 'Öğeyi Sil?';

  @override
  String get deleteTimeDialogContent => 'Seçilen öğeyi silmek istiyor musunuz?';

  @override
  String get deleteTimeDialogPluralTitle => 'Girdiler silinsin mi?';

  @override
  String get deleteTimeDialogPluralContent => 'Bu öğüne ait tüm girdileri silmek istiyor musunuz?';

  @override
  String get itemDeletedSnackbar => 'Öğe silindi';

  @override
  String get copyDialogTitle => 'Hangi yemek türüne kopyalamak istiyorsunuz?';

  @override
  String get copyOrDeleteTimeDialogTitle => 'Ne yapmak istiyorsunuz?';

  @override
  String get copyOrDeleteTimeDialogContent => '\"Bugüne Kopyala\" ile yemeği bugüne kopyalayabilirsiniz. \"Sil\" ile yemeği silebilirsiniz.';

  @override
  String get dialogCopyLabel => 'BUGÜNE KOPYALA';

  @override
  String get dialogDeleteLabel => 'SİL';

  @override
  String get deleteAllLabel => 'Delete all';

  @override
  String get suppliedLabel => 'tüketilen';

  @override
  String get burnedLabel => 'yakılan';

  @override
  String get kcalLeftLabel => 'kalan kcal';

  @override
  String get nutritionInfoLabel => 'Beslenme Bilgileri';

  @override
  String get kcalLabel => 'kcal';

  @override
  String get carbsLabel => 'karbonhidrat';

  @override
  String get fatLabel => 'yağ';

  @override
  String get proteinLabel => 'protein';

  @override
  String get energyLabel => 'enerji';

  @override
  String get saturatedFatLabel => 'doymuş yağ';

  @override
  String get carbohydrateLabel => 'karbonhidrat';

  @override
  String get sugarLabel => 'şeker';

  @override
  String get fiberLabel => 'lif';

  @override
  String get per100gmlLabel => '100g/ml başına';

  @override
  String get additionalInfoLabelOFF => 'Daha Fazla Bilgi\nOpenFoodFacts\'te';

  @override
  String get offDisclaimer => 'Bu uygulama tarafından size sağlanan veriler Open Food Facts veritabanından alınmaktadır. Sağlanan bilgilerin doğruluğu, eksiksizliği veya güvenilirliği konusunda hiçbir garanti verilmemektedir. Veriler \"olduğu gibi\" sağlanır ve verilerin kullanımıyla ilgili herhangi bir zarardan verilerin kaynağı (Open Food Facts) sorumlu tutulamaz.';

  @override
  String get additionalInfoLabelFDC => 'Daha Fazla Bilgi\nFoodData Central\'da';

  @override
  String get additionalInfoLabelUnknown => 'Bilinmeyen Yemek Öğesi';

  @override
  String get additionalInfoLabelCustom => 'Özel Yemek Öğesi';

  @override
  String get additionalInfoLabelCompendium2011 => 'Bilgi\n\'2011 Compendium\n of Physical Activities\'\nden sağlanmıştır';

  @override
  String get quantityLabel => 'Miktar';

  @override
  String get baseQuantityLabel => 'Temel miktar (g/ml)';

  @override
  String get unitLabel => 'Birim';

  @override
  String get scanProductLabel => 'Ürünü Tara';

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
  String get notAvailableLabel => 'Mevcut Değil';

  @override
  String get missingProductInfo => 'Üründe gerekli kcal veya makro besin bilgileri eksik';

  @override
  String get infoAddedIntakeLabel => 'Yeni alım eklendi';

  @override
  String get infoAddedActivityLabel => 'Yeni aktivite eklendi';

  @override
  String get editMealLabel => 'Yemeği Düzenle';

  @override
  String get mealNameLabel => 'Yemek adı';

  @override
  String get mealBrandsLabel => 'Markalar';

  @override
  String get mealSizeLabel => 'Yemek boyutu (g/ml)';

  @override
  String get mealSizeLabelImperial => 'Yemek boyutu (oz/fl oz)';

  @override
  String get servingLabel => 'Porsiyon';

  @override
  String get perServingLabel => 'Porsiyon Başına';

  @override
  String get servingSizeLabelMetric => 'Porsiyon boyutu (g/ml)';

  @override
  String get servingSizeLabelImperial => 'Porsiyon boyutu (oz/fl oz)';

  @override
  String get mealUnitLabel => 'Yemek birimi';

  @override
  String get mealKcalLabel => 'kcal başına';

  @override
  String get mealCarbsLabel => 'karbonhidrat başına';

  @override
  String get mealFatLabel => 'yağ başına';

  @override
  String get mealProteinLabel => 'protein başına 100 g/ml';

  @override
  String get errorMealSave => 'Yemek kaydedilirken hata oluştu. Doğru yemek bilgilerini girdiniz mi?';

  @override
  String get bmiLabel => 'BMI';

  @override
  String get bmiInfo => 'Vücut Kitle İndeksi (BMI), yetişkinlerde aşırı kiloyu ve obeziteyi sınıflandırmak için kullanılan bir indekstir. Kilogram cinsinden ağırlığın, metre cinsinden boyun karesine bölünmesiyle tanımlanır (kg/m²).\n\nBMI, yağ ve kas kütlesi arasında ayrım yapmaz ve bazı bireyler için yanıltıcı olabilir.';

  @override
  String get readLabel => 'Gizlilik politikasını okudum ve kabul ediyorum.';

  @override
  String get privacyPolicyLabel => 'Gizlilik politikası';

  @override
  String get dataCollectionLabel => 'Anonim kullanım verileri sağlayarak geliştirmeyi destekleyin';

  @override
  String get palSedentaryLabel => 'Hareketsiz';

  @override
  String get palSedentaryDescriptionLabel => 'ör. ofis işi ve çoğunlukla oturarak geçirilen serbest zaman aktiviteleri';

  @override
  String get palLowLActiveLabel => 'Düşük Aktif';

  @override
  String get palLowActiveDescriptionLabel => 'ör. iş yerinde oturma veya ayakta durma ve hafif serbest zaman aktiviteleri';

  @override
  String get palActiveLabel => 'Aktif';

  @override
  String get palActiveDescriptionLabel => 'iş yerinde çoğunlukla ayakta durma veya yürüme ve aktif serbest zaman aktiviteleri';

  @override
  String get palVeryActiveLabel => 'Çok Aktif';

  @override
  String get palVeryActiveDescriptionLabel => 'iş yerinde çoğunlukla yürüme, koşma veya ağırlık taşıma ve aktif serbest zaman aktiviteleri';

  @override
  String get selectPalCategoryLabel => 'Aktivite Seviyesini Seçin';

  @override
  String get chooseWeightGoalLabel => 'Kilo Hedefini Seçin';

  @override
  String get goalLoseWeight => 'Kilo Ver';

  @override
  String get goalMaintainWeight => 'Kilo Koru';

  @override
  String get goalGainWeight => 'Kilo Al';

  @override
  String get goalLabel => 'Hedef';

  @override
  String get selectHeightDialogLabel => 'Boy Seçin';

  @override
  String get heightLabel => 'Boy';

  @override
  String get cmLabel => 'cm';

  @override
  String get ftLabel => 'ft';

  @override
  String get selectWeightDialogLabel => 'Kilo Seçin';

  @override
  String get weightLabel => 'Kilo';

  @override
  String get kgLabel => 'kg';

  @override
  String get lbsLabel => 'lbs';

  @override
  String get ageLabel => 'Yaş';

  @override
  String yearsLabel(Object age) {
    return '$age yıl';
  }

  @override
  String get selectGenderDialogLabel => 'Cinsiyet Seçin';

  @override
  String get genderLabel => 'Cinsiyet';

  @override
  String get genderMaleLabel => '♂ erkek';

  @override
  String get genderFemaleLabel => '♀ kadın';

  @override
  String get nothingAddedLabel => 'Hiçbir şey eklenmedi';

  @override
  String get nutritionalStatusUnderweight => 'Düşük Kilolu';

  @override
  String get nutritionalStatusNormalWeight => 'Normal Kilo';

  @override
  String get nutritionalStatusPreObesity => 'Obezite Öncesi';

  @override
  String get nutritionalStatusObeseClassI => 'Obezite Sınıf I';

  @override
  String get nutritionalStatusObeseClassII => 'Obezite Sınıf II';

  @override
  String get nutritionalStatusObeseClassIII => 'Obezite Sınıf III';

  @override
  String nutritionalStatusRiskLabel(Object riskValue) {
    return 'Eşlik eden hastalık riski: $riskValue';
  }

  @override
  String get nutritionalStatusRiskLow => 'Düşük \n(ancak diğer \nklinik sorunların riski artmış)';

  @override
  String get nutritionalStatusRiskAverage => 'Ortalama';

  @override
  String get nutritionalStatusRiskIncreased => 'Artmış';

  @override
  String get nutritionalStatusRiskModerate => 'Orta';

  @override
  String get nutritionalStatusRiskSevere => 'Şiddetli';

  @override
  String get nutritionalStatusRiskVerySevere => 'Çok şiddetli';

  @override
  String get errorOpeningEmail => 'E-posta uygulaması açılırken hata oluştu';

  @override
  String get errorOpeningBrowser => 'Tarayıcı uygulaması açılırken hata oluştu';

  @override
  String get errorFetchingProductData => 'Ürün verileri alınırken hata oluştu';

  @override
  String get errorProductNotFound => 'Ürün bulunamadı';

  @override
  String get errorLoadingActivities => 'Aktiviteler yüklenirken hata oluştu';

  @override
  String get noResultsFound => 'Sonuç bulunamadı';

  @override
  String get retryLabel => 'Tekrar Dene';

  @override
  String get paHeadingBicycling => 'bisiklet sürme';

  @override
  String get paHeadingConditionalExercise => 'koşullandırma egzersizi';

  @override
  String get paHeadingDancing => 'dans';

  @override
  String get paHeadingRunning => 'koşu';

  @override
  String get paHeadingSports => 'spor';

  @override
  String get paHeadingWalking => 'yürüyüş';

  @override
  String get paHeadingWaterActivities => 'su aktiviteleri';

  @override
  String get paHeadingWinterActivities => 'kış aktiviteleri';

  @override
  String get paGeneralDesc => 'genel';

  @override
  String get paBicyclingGeneral => 'bisiklet sürme';

  @override
  String get paBicyclingGeneralDesc => 'genel';

  @override
  String get paBicyclingMountainGeneral => 'dağ bisikleti';

  @override
  String get paBicyclingMountainGeneralDesc => 'genel';

  @override
  String get paUnicyclingGeneral => 'tek tekerlekli bisiklet';

  @override
  String get paUnicyclingGeneralDesc => 'genel';

  @override
  String get paBicyclingStationaryGeneral => 'sabit bisiklet';

  @override
  String get paBicyclingStationaryGeneralDesc => 'genel';

  @override
  String get paCalisthenicsGeneral => 'kalistenik';

  @override
  String get paCalisthenicsGeneralDesc => 'hafif veya orta derecede çaba, genel (ör. sırt egzersizleri)';

  @override
  String get paResistanceTraining => 'direnç antrenmanı';

  @override
  String get paResistanceTrainingDesc => 'ağırlık kaldırma, serbest ağırlık, nautilus veya evrensel';

  @override
  String get paRopeSkippingGeneral => 'ip atlama';

  @override
  String get paRopeSkippingGeneralDesc => 'genel';

  @override
  String get paWaterAerobics => 'su egzersizi';

  @override
  String get paWaterAerobicsDesc => 'su aerobiği, su kalistenik';

  @override
  String get paDancingAerobicGeneral => 'aerobik';

  @override
  String get paDancingAerobicGeneralDesc => 'genel';

  @override
  String get paDancingGeneral => 'genel dans';

  @override
  String get paDancingGeneralDesc => 'ör. disko, halk, İrlanda step dansı, hat dansı, polka, contra, country';

  @override
  String get paJoggingGeneral => 'koşu';

  @override
  String get paJoggingGeneralDesc => 'genel';

  @override
  String get paRunningGeneral => 'koşu';

  @override
  String get paRunningGeneralDesc => 'genel';

  @override
  String get paArcheryGeneral => 'okçuluk';

  @override
  String get paArcheryGeneralDesc => 'avcılık dışı';

  @override
  String get paBadmintonGeneral => 'badminton';

  @override
  String get paBadmintonGeneralDesc => 'sosyal tekler ve çiftler, genel';

  @override
  String get paBasketballGeneral => 'basketbol';

  @override
  String get paBasketballGeneralDesc => 'genel';

  @override
  String get paBilliardsGeneral => 'bilardo';

  @override
  String get paBilliardsGeneralDesc => 'genel';

  @override
  String get paBowlingGeneral => 'bowling';

  @override
  String get paBowlingGeneralDesc => 'genel';

  @override
  String get paBoxingBag => 'boks';

  @override
  String get paBoxingBagDesc => 'kum torbası';

  @override
  String get paBoxingGeneral => 'boks';

  @override
  String get paBoxingGeneralDesc => 'ringde, genel';

  @override
  String get paBroomball => 'broomball';

  @override
  String get paBroomballDesc => 'genel';

  @override
  String get paChildrenGame => 'çocuk oyunları';

  @override
  String get paChildrenGameDesc => '(ör. seksek, 4-kare, dodgeball, oyun alanı aletleri, t-ball, tetherball, misket, arcade oyunları), orta derecede çaba';

  @override
  String get paCheerleading => 'amigo';

  @override
  String get paCheerleadingDesc => 'jimnastik hareketleri, rekabetçi';

  @override
  String get paCricket => 'kriket';

  @override
  String get paCricketDesc => 'vuruş, bowling, saha';

  @override
  String get paCroquet => 'kroket';

  @override
  String get paCroquetDesc => 'genel';

  @override
  String get paCurling => 'curling';

  @override
  String get paCurlingDesc => 'genel';

  @override
  String get paDartsWall => 'dart';

  @override
  String get paDartsWallDesc => 'duvar veya çim';

  @override
  String get paAutoRacing => 'otomobil yarışı';

  @override
  String get paAutoRacingDesc => 'açık tekerlek';

  @override
  String get paFencing => 'eskrim';

  @override
  String get paFencingDesc => 'genel';

  @override
  String get paAmericanFootballGeneral => 'futbol';

  @override
  String get paAmericanFootballGeneralDesc => 'dokunmatik, bayrak, genel';

  @override
  String get paCatch => 'futbol veya beyzbol';

  @override
  String get paCatchDesc => 'yakalama oyunu';

  @override
  String get paFrisbee => 'frisbee oyunu';

  @override
  String get paFrisbeeDesc => 'genel';

  @override
  String get paGolfGeneral => 'golf';

  @override
  String get paGolfGeneralDesc => 'genel';

  @override
  String get paGymnasticsGeneral => 'jimnastik';

  @override
  String get paGymnasticsGeneralDesc => 'genel';

  @override
  String get paHackySack => 'hacky sack';

  @override
  String get paHackySackDesc => 'genel';

  @override
  String get paHandballGeneral => 'hentbol';

  @override
  String get paHandballGeneralDesc => 'genel';

  @override
  String get paHangGliding => 'yelken kanat';

  @override
  String get paHangGlidingDesc => 'genel';

  @override
  String get paHockeyField => 'çim hokeyi';

  @override
  String get paHockeyFieldDesc => 'genel';

  @override
  String get paIceHockeyGeneral => 'buz hokeyi';

  @override
  String get paIceHockeyGeneralDesc => 'genel';

  @override
  String get paHorseRidingGeneral => 'at binme';

  @override
  String get paHorseRidingGeneralDesc => 'genel';

  @override
  String get paJaiAlai => 'jai alai';

  @override
  String get paJaiAlaiDesc => 'genel';

  @override
  String get paMartialArtsSlower => 'dövüş sanatları';

  @override
  String get paMartialArtsSlowerDesc => 'farklı tipler, daha yavaş tempo, acemi performansçılar, pratik';

  @override
  String get paMartialArtsModerate => 'dövüş sanatları';

  @override
  String get paMartialArtsModerateDesc => 'farklı tipler, orta tempo (ör. judo, jujitsu, karate, kick boxing, tae kwan do, tai-bo, Muay Thai boks)';

  @override
  String get paJuggling => 'jonglörlük';

  @override
  String get paJugglingDesc => 'genel';

  @override
  String get paKickball => 'kickball';

  @override
  String get paKickballDesc => 'genel';

  @override
  String get paLacrosse => 'lakros';

  @override
  String get paLacrosseDesc => 'genel';

  @override
  String get paLawnBowling => 'çim bowling';

  @override
  String get paLawnBowlingDesc => 'bocce topu, açık hava';

  @override
  String get paMotoCross => 'moto-kros';

  @override
  String get paMotoCrossDesc => 'arazi motor sporları, arazi aracı, genel';

  @override
  String get paOrienteering => 'oryantiring';

  @override
  String get paOrienteeringDesc => 'genel';

  @override
  String get paPaddleball => 'paddleball';

  @override
  String get paPaddleballDesc => 'rahat, genel';

  @override
  String get paPoloHorse => 'polo';

  @override
  String get paPoloHorseDesc => 'at üzerinde';

  @override
  String get paRacquetball => 'raketbol';

  @override
  String get paRacquetballDesc => 'genel';

  @override
  String get paMountainClimbing => 'tırmanma';

  @override
  String get paMountainClimbingDesc => 'kaya veya dağ tırmanışı';

  @override
  String get paRodeoSportGeneralModerate => 'rodeo sporları';

  @override
  String get paRodeoSportGeneralModerateDesc => 'genel, orta derecede çaba';

  @override
  String get paRopeJumpingGeneral => 'ip atlama';

  @override
  String get paRopeJumpingGeneralDesc => 'orta tempo, 100-120 atlama/dakika, genel, 2 ayak atlama, düz atlama';

  @override
  String get paRugbyCompetitive => 'rugby';

  @override
  String get paRugbyCompetitiveDesc => 'birlik, takım, rekabetçi';

  @override
  String get paRugbyNonCompetitive => 'rugby';

  @override
  String get paRugbyNonCompetitiveDesc => 'dokunmatik, rekabetçi olmayan';

  @override
  String get paShuffleboard => 'shuffleboard';

  @override
  String get paShuffleboardDesc => 'genel';

  @override
  String get paSkateboardingGeneral => 'kaykay';

  @override
  String get paSkateboardingGeneralDesc => 'genel, orta derecede çaba';

  @override
  String get paSkatingRoller => 'paten kayma';

  @override
  String get paSkatingRollerDesc => 'genel';

  @override
  String get paRollerbladingLight => 'patenle kayma';

  @override
  String get paRollerbladingLightDesc => 'sıralı paten';

  @override
  String get paSkydiving => 'paraşütle atlama';

  @override
  String get paSkydivingDesc => 'paraşütle atlama, base jumping, bungee jumping';

  @override
  String get paSoccerGeneral => 'futbol';

  @override
  String get paSoccerGeneralDesc => 'rahat, genel';

  @override
  String get paSoftballBaseballGeneral => 'softbol / beyzbol';

  @override
  String get paSoftballBaseballGeneralDesc => 'hızlı veya yavaş atış, genel';

  @override
  String get paSquashGeneral => 'squash';

  @override
  String get paSquashGeneralDesc => 'genel';

  @override
  String get paTableTennisGeneral => 'masa tenisi';

  @override
  String get paTableTennisGeneralDesc => 'masa tenisi, ping pong';

  @override
  String get paTaiChiQiGongGeneral => 'tai chi, qi gong';

  @override
  String get paTaiChiQiGongGeneralDesc => 'genel';

  @override
  String get paTennisGeneral => 'tenis';

  @override
  String get paTennisGeneralDesc => 'genel';

  @override
  String get paTrampolineLight => 'trambolin';

  @override
  String get paTrampolineLightDesc => 'eğlence amaçlı';

  @override
  String get paVolleyballGeneral => 'voleybol';

  @override
  String get paVolleyballGeneralDesc => 'rekabetçi olmayan, 6 - 9 üyeli takım, genel';

  @override
  String get paWrestling => 'güreş';

  @override
  String get paWrestlingDesc => 'genel';

  @override
  String get paWallyball => 'wallyball';

  @override
  String get paWallyballDesc => 'genel';

  @override
  String get paTrackField => 'atletizm';

  @override
  String get paTrackField1Desc => '(ör. gülle, disk, çekiç atma)';

  @override
  String get paTrackField2Desc => '(ör. yüksek atlama, uzun atlama, üçlü atlama, cirit, sırıkla atlama)';

  @override
  String get paTrackField3Desc => '(ör. engelli koşu, engelli yarış)';

  @override
  String get paBackpackingGeneral => 'sırt çantasıyla gezme';

  @override
  String get paBackpackingGeneralDesc => 'genel';

  @override
  String get paClimbingHillsNoLoadGeneral => 'tepe tırmanma, yük yok';

  @override
  String get paClimbingHillsNoLoadGeneralDesc => 'yük yok';

  @override
  String get paHikingCrossCountry => 'yürüyüş';

  @override
  String get paHikingCrossCountryDesc => 'kırsal alan';

  @override
  String get paWalkingForPleasure => 'yürüyüş';

  @override
  String get paWalkingForPleasureDesc => 'zevk için';

  @override
  String get paWalkingTheDog => 'köpeği gezdirmek';

  @override
  String get paWalkingTheDogDesc => 'genel';

  @override
  String get paCanoeingGeneral => 'kano';

  @override
  String get paCanoeingGeneralDesc => 'kürek çekme, zevk için, genel';

  @override
  String get paDivingSpringboardPlatform => 'dalış';

  @override
  String get paDivingSpringboardPlatformDesc => 'trambolin veya platform';

  @override
  String get paKayakingModerate => 'kano';

  @override
  String get paKayakingModerateDesc => 'orta derecede çaba';

  @override
  String get paPaddleBoat => 'pedallı tekne';

  @override
  String get paPaddleBoatDesc => 'genel';

  @override
  String get paSailingGeneral => 'yelken';

  @override
  String get paSailingGeneralDesc => 'tekne ve tahta yelken, rüzgar sörfü, buz yelken, genel';

  @override
  String get paSkiingWaterWakeboarding => 'su kayağı';

  @override
  String get paSkiingWaterWakeboardingDesc => 'su veya wakeboarding';

  @override
  String get paDivingGeneral => 'dalış';

  @override
  String get paDivingGeneralDesc => 'deri dalışı, scuba dalışı, genel';

  @override
  String get paSnorkeling => 'şnorkelle dalış';

  @override
  String get paSnorkelingDesc => 'genel';

  @override
  String get paSurfing => 'sörf';

  @override
  String get paSurfingDesc => 'vücut veya tahta, genel';

  @override
  String get paPaddleBoarding => 'kürek tahtası';

  @override
  String get paPaddleBoardingDesc => 'ayakta';

  @override
  String get paSwimmingGeneral => 'yüzme';

  @override
  String get paSwimmingGeneralDesc => 'su üzerinde durma, orta derecede çaba, genel';

  @override
  String get paWateraerobicsCalisthenics => 'su aerobiği';

  @override
  String get paWateraerobicsCalisthenicsDesc => 'su aerobiği, su kalistenik';

  @override
  String get paWaterPolo => 'su topu';

  @override
  String get paWaterPoloDesc => 'genel';

  @override
  String get paWaterVolleyball => 'su voleybolu';

  @override
  String get paWaterVolleyballDesc => 'genel';

  @override
  String get paIceSkatingGeneral => 'buz pateni';

  @override
  String get paIceSkatingGeneralDesc => 'genel';

  @override
  String get paSkiingGeneral => 'kayak';

  @override
  String get paSkiingGeneralDesc => 'genel';

  @override
  String get paSnowShovingModerate => 'kar küreme';

  @override
  String get paSnowShovingModerateDesc => 'elle, orta derecede çaba';

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
}
