import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_tr.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('tr'),
    Locale('en'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('pt')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Eye Test'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Smart Tests for Your Eye Health'**
  String get appTagline;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Eye tests and daily exercises'**
  String get splashSubtitle;

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Important Notice'**
  String get disclaimerTitle;

  /// No description provided for @disclaimerContent.
  ///
  /// In en, this message translates to:
  /// **'This app is for informational and entertainment purposes only.\n\n⚠️ This app DOES NOT provide medical diagnosis.\n\n• Results do not replace professional eye examination.\n• If you experience any vision problems, please consult an eye doctor.\n• Test results may be affected by screen size, brightness, and environmental conditions.\n\nBy using this app, you agree to the above conditions.'**
  String get disclaimerContent;

  /// No description provided for @acceptAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Accept and Continue'**
  String get acceptAndContinue;

  /// No description provided for @medicalWarning.
  ///
  /// In en, this message translates to:
  /// **'Medical Warning'**
  String get medicalWarning;

  /// No description provided for @informationalPurpose.
  ///
  /// In en, this message translates to:
  /// **'For Informational Purposes'**
  String get informationalPurpose;

  /// No description provided for @informationalPurposeDesc.
  ///
  /// In en, this message translates to:
  /// **'This app is for educational and awareness purposes only.'**
  String get informationalPurposeDesc;

  /// No description provided for @professionalExamination.
  ///
  /// In en, this message translates to:
  /// **'Professional Examination'**
  String get professionalExamination;

  /// No description provided for @professionalExaminationDesc.
  ///
  /// In en, this message translates to:
  /// **'Visit your eye doctor for regular eye examinations.'**
  String get professionalExaminationDesc;

  /// No description provided for @readAndAccept.
  ///
  /// In en, this message translates to:
  /// **'I have read and accept the above warnings'**
  String get readAndAccept;

  /// No description provided for @scrollDown.
  ///
  /// In en, this message translates to:
  /// **'Scroll down'**
  String get scrollDown;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Eye Health'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tests, exercises, additional info, detailed results'**
  String get homeSubtitle;

  /// No description provided for @freeLabel.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeLabel;

  /// No description provided for @premiumLabel.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumLabel;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @eyeExercises.
  ///
  /// In en, this message translates to:
  /// **'Eye Exercises'**
  String get eyeExercises;

  /// No description provided for @eyeExercisesDesc.
  ///
  /// In en, this message translates to:
  /// **'Relax your eyes with daily eye exercises'**
  String get eyeExercisesDesc;

  /// No description provided for @eyeTests.
  ///
  /// In en, this message translates to:
  /// **'Eye Tests'**
  String get eyeTests;

  /// No description provided for @eyeTestsDesc.
  ///
  /// In en, this message translates to:
  /// **'Evaluate your eye health with 8 different eye tests'**
  String get eyeTestsDesc;

  /// No description provided for @didYouKnow.
  ///
  /// In en, this message translates to:
  /// **'Did You Know?'**
  String get didYouKnow;

  /// No description provided for @didYouKnowDesc.
  ///
  /// In en, this message translates to:
  /// **'Discover interesting facts about eyes'**
  String get didYouKnowDesc;

  /// No description provided for @goPremium.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get goPremium;

  /// No description provided for @goPremiumDesc.
  ///
  /// In en, this message translates to:
  /// **'Access all tests and get detailed reports'**
  String get goPremiumDesc;

  /// No description provided for @testHistory.
  ///
  /// In en, this message translates to:
  /// **'Test History'**
  String get testHistory;

  /// No description provided for @testHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'View all your test results and exercise history'**
  String get testHistoryDesc;

  /// No description provided for @visualAcuityTitle.
  ///
  /// In en, this message translates to:
  /// **'Visual Acuity'**
  String get visualAcuityTitle;

  /// No description provided for @visualAcuityDesc.
  ///
  /// In en, this message translates to:
  /// **'Snellen E Test'**
  String get visualAcuityDesc;

  /// No description provided for @colorVisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Color Blindness'**
  String get colorVisionTitle;

  /// No description provided for @colorVisionDesc.
  ///
  /// In en, this message translates to:
  /// **'Ishihara Test'**
  String get colorVisionDesc;

  /// No description provided for @astigmatismTitle.
  ///
  /// In en, this message translates to:
  /// **'Astigmatism Test'**
  String get astigmatismTitle;

  /// No description provided for @astigmatismDesc.
  ///
  /// In en, this message translates to:
  /// **'Line Diagram'**
  String get astigmatismDesc;

  /// No description provided for @stereopsisTitle.
  ///
  /// In en, this message translates to:
  /// **'Vergence Test'**
  String get stereopsisTitle;

  /// No description provided for @stereopsisDesc.
  ///
  /// In en, this message translates to:
  /// **'Convergence/Divergence Test'**
  String get stereopsisDesc;

  /// No description provided for @nearVisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Near Vision'**
  String get nearVisionTitle;

  /// No description provided for @nearVisionDesc.
  ///
  /// In en, this message translates to:
  /// **'Near Reading Test'**
  String get nearVisionDesc;

  /// No description provided for @macularTitle.
  ///
  /// In en, this message translates to:
  /// **'Macular Test'**
  String get macularTitle;

  /// No description provided for @macularDesc.
  ///
  /// In en, this message translates to:
  /// **'Amsler Grid Test'**
  String get macularDesc;

  /// No description provided for @peripheralVisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Peripheral Vision'**
  String get peripheralVisionTitle;

  /// No description provided for @peripheralVisionDesc.
  ///
  /// In en, this message translates to:
  /// **'Side Vision Test'**
  String get peripheralVisionDesc;

  /// No description provided for @eyeMovementTitle.
  ///
  /// In en, this message translates to:
  /// **'Movement Tracking'**
  String get eyeMovementTitle;

  /// No description provided for @eyeMovementDesc.
  ///
  /// In en, this message translates to:
  /// **'Tracking Test'**
  String get eyeMovementDesc;

  /// No description provided for @contrastTitle.
  ///
  /// In en, this message translates to:
  /// **'Contrast Sensitivity'**
  String get contrastTitle;

  /// No description provided for @contrastDesc.
  ///
  /// In en, this message translates to:
  /// **'Contrast Perception Test'**
  String get contrastDesc;

  /// No description provided for @testInstructions.
  ///
  /// In en, this message translates to:
  /// **'Test Instructions'**
  String get testInstructions;

  /// No description provided for @startTest.
  ///
  /// In en, this message translates to:
  /// **'Start Test'**
  String get startTest;

  /// No description provided for @nextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextQuestion;

  /// No description provided for @finishTest.
  ///
  /// In en, this message translates to:
  /// **'Finish Test'**
  String get finishTest;

  /// No description provided for @skipQuestion.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipQuestion;

  /// No description provided for @cannotSee.
  ///
  /// In en, this message translates to:
  /// **'Cannot See'**
  String get cannotSee;

  /// No description provided for @notSure.
  ///
  /// In en, this message translates to:
  /// **'Not Sure'**
  String get notSure;

  /// No description provided for @visualAcuityInstructions.
  ///
  /// In en, this message translates to:
  /// **'• Hold the phone at eye level.\n• Recommended distance: arm\'s length (40 cm).\n• Select the direction of the letter E.\n• Press \'Cannot See\' if you cannot see it.'**
  String get visualAcuityInstructions;

  /// No description provided for @closeRightEye.
  ///
  /// In en, this message translates to:
  /// **'Please close your right eye'**
  String get closeRightEye;

  /// No description provided for @closeLeftEye.
  ///
  /// In en, this message translates to:
  /// **'Please close your left eye'**
  String get closeLeftEye;

  /// No description provided for @holdAtArmLength.
  ///
  /// In en, this message translates to:
  /// **'Hold the device at arm\'s length'**
  String get holdAtArmLength;

  /// No description provided for @startTestWhenReady.
  ///
  /// In en, this message translates to:
  /// **'You can start the test when you close your eye and hold the device at arm\'s length.'**
  String get startTestWhenReady;

  /// No description provided for @armLengthDistance.
  ///
  /// In en, this message translates to:
  /// **'Arm\'s Length (40 cm)'**
  String get armLengthDistance;

  /// No description provided for @okay.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okay;

  /// No description provided for @markTheLetterYouSee.
  ///
  /// In en, this message translates to:
  /// **'Mark the letter you see'**
  String get markTheLetterYouSee;

  /// No description provided for @colorVisionInstructions.
  ///
  /// In en, this message translates to:
  /// **'• Enter the number you see inside the circle.\n• Leave blank if you cannot see anything.\n• Set screen brightness to maximum.'**
  String get colorVisionInstructions;

  /// No description provided for @enterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter the number'**
  String get enterNumber;

  /// No description provided for @noNumberVisible.
  ///
  /// In en, this message translates to:
  /// **'Cannot See Number'**
  String get noNumberVisible;

  /// No description provided for @whatNumberDoYouSee.
  ///
  /// In en, this message translates to:
  /// **'What number do you see?'**
  String get whatNumberDoYouSee;

  /// No description provided for @astigmatismInstructions.
  ///
  /// In en, this message translates to:
  /// **'• Look at the diagram with one eye.\n• Close your other eye.\n• Do all lines appear equal?'**
  String get astigmatismInstructions;

  /// No description provided for @allLinesEqual.
  ///
  /// In en, this message translates to:
  /// **'All Lines Equal'**
  String get allLinesEqual;

  /// No description provided for @someLinesdarker.
  ///
  /// In en, this message translates to:
  /// **'Some Lines Darker'**
  String get someLinesdarker;

  /// No description provided for @whichEye.
  ///
  /// In en, this message translates to:
  /// **'Which eye are you looking with?'**
  String get whichEye;

  /// No description provided for @leftEye.
  ///
  /// In en, this message translates to:
  /// **'Left Eye'**
  String get leftEye;

  /// No description provided for @rightEye.
  ///
  /// In en, this message translates to:
  /// **'Right Eye'**
  String get rightEye;

  /// No description provided for @rightEyeTest.
  ///
  /// In en, this message translates to:
  /// **'Right Eye Test'**
  String get rightEyeTest;

  /// No description provided for @leftEyeTest.
  ///
  /// In en, this message translates to:
  /// **'Left Eye Test'**
  String get leftEyeTest;

  /// No description provided for @howDoLinesLook.
  ///
  /// In en, this message translates to:
  /// **'How do the lines look?'**
  String get howDoLinesLook;

  /// No description provided for @nearVisionInstructions.
  ///
  /// In en, this message translates to:
  /// **'• Hold the device at reading distance (25-30 cm).\n• Read the text without squinting.'**
  String get nearVisionInstructions;

  /// No description provided for @bookReadingDistance.
  ///
  /// In en, this message translates to:
  /// **'Book Reading Distance (25-30 cm)'**
  String get bookReadingDistance;

  /// No description provided for @canYouReadThis.
  ///
  /// In en, this message translates to:
  /// **'Can you read this text?'**
  String get canYouReadThis;

  /// No description provided for @yesReadable.
  ///
  /// In en, this message translates to:
  /// **'Yes, I can read'**
  String get yesReadable;

  /// No description provided for @noNotReadable.
  ///
  /// In en, this message translates to:
  /// **'No, I cannot read'**
  String get noNotReadable;

  /// No description provided for @macularInstructions.
  ///
  /// In en, this message translates to:
  /// **'• Focus on the center point.\n• Check if lines appear wavy or distorted.'**
  String get macularInstructions;

  /// No description provided for @focusOnCenter.
  ///
  /// In en, this message translates to:
  /// **'Focus on the center point'**
  String get focusOnCenter;

  /// No description provided for @linesAppearStraight.
  ///
  /// In en, this message translates to:
  /// **'Lines appear straight'**
  String get linesAppearStraight;

  /// No description provided for @linesAppearWavy.
  ///
  /// In en, this message translates to:
  /// **'Lines appear wavy/distorted'**
  String get linesAppearWavy;

  /// No description provided for @peripheralInstructions.
  ///
  /// In en, this message translates to:
  /// **'• Keep your eyes on the red dot.\n• Indicate when you see an object appear in your peripheral vision.'**
  String get peripheralInstructions;

  /// No description provided for @keepFocusOnRedDot.
  ///
  /// In en, this message translates to:
  /// **'Keep your focus on the red dot'**
  String get keepFocusOnRedDot;

  /// No description provided for @tapWhenYouSee.
  ///
  /// In en, this message translates to:
  /// **'Tap when you see an object'**
  String get tapWhenYouSee;

  /// No description provided for @eyeMovementInstructions.
  ///
  /// In en, this message translates to:
  /// **'• Follow the moving ball with your eyes.\n• Try not to move your head.'**
  String get eyeMovementInstructions;

  /// No description provided for @followTheBall.
  ///
  /// In en, this message translates to:
  /// **'Follow the ball with your eyes'**
  String get followTheBall;

  /// No description provided for @vergenceInstructions.
  ///
  /// In en, this message translates to:
  /// **'• Focus on the target.\n• Notice if you see double or blurred images.'**
  String get vergenceInstructions;

  /// No description provided for @focusOnTarget.
  ///
  /// In en, this message translates to:
  /// **'Focus on the target'**
  String get focusOnTarget;

  /// No description provided for @seeDouble.
  ///
  /// In en, this message translates to:
  /// **'I see double'**
  String get seeDouble;

  /// No description provided for @seeSingle.
  ///
  /// In en, this message translates to:
  /// **'I see single/clear'**
  String get seeSingle;

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Results'**
  String get resultsTitle;

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// No description provided for @shareResults.
  ///
  /// In en, this message translates to:
  /// **'Share Results'**
  String get shareResults;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @retakeTest.
  ///
  /// In en, this message translates to:
  /// **'Retake Test'**
  String get retakeTest;

  /// No description provided for @nextTest.
  ///
  /// In en, this message translates to:
  /// **'Next Test'**
  String get nextTest;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// No description provided for @seeDoctor.
  ///
  /// In en, this message translates to:
  /// **'Consult an Eye Doctor'**
  String get seeDoctor;

  /// No description provided for @testCompleted.
  ///
  /// In en, this message translates to:
  /// **'Test Completed'**
  String get testCompleted;

  /// No description provided for @exerciseCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get exerciseCompleted;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @belowNormal.
  ///
  /// In en, this message translates to:
  /// **'Below Normal'**
  String get belowNormal;

  /// No description provided for @needsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get needsAttention;

  /// No description provided for @resultExcellent.
  ///
  /// In en, this message translates to:
  /// **'Your results are excellent! Continue to take care of your eye health.'**
  String get resultExcellent;

  /// No description provided for @resultGood.
  ///
  /// In en, this message translates to:
  /// **'Good results. Regular eye check-ups are recommended.'**
  String get resultGood;

  /// No description provided for @resultNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal results. Keep monitoring your eye health.'**
  String get resultNormal;

  /// No description provided for @resultBelowNormal.
  ///
  /// In en, this message translates to:
  /// **'Some areas need attention. Consider consulting an eye specialist.'**
  String get resultBelowNormal;

  /// No description provided for @resultNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'We recommend consulting an eye doctor for a professional examination.'**
  String get resultNeedsAttention;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access all tests and get detailed reports'**
  String get paywallSubtitle;

  /// No description provided for @unlockAllTests.
  ///
  /// In en, this message translates to:
  /// **'Unlock All Tests'**
  String get unlockAllTests;

  /// No description provided for @getDetailedReports.
  ///
  /// In en, this message translates to:
  /// **'Get Detailed Reports'**
  String get getDetailedReports;

  /// No description provided for @trackProgress.
  ///
  /// In en, this message translates to:
  /// **'Track Your Progress'**
  String get trackProgress;

  /// No description provided for @oneTimePurchase.
  ///
  /// In en, this message translates to:
  /// **'One-Time Purchase'**
  String get oneTimePurchase;

  /// No description provided for @lifetimeAccess.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Access'**
  String get lifetimeAccess;

  /// No description provided for @onlyPrice.
  ///
  /// In en, this message translates to:
  /// **'Only {price}'**
  String onlyPrice(String price);

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchase'**
  String get restore;

  /// No description provided for @continueFree.
  ///
  /// In en, this message translates to:
  /// **'Continue Free'**
  String get continueFree;

  /// No description provided for @premiumAdvantages.
  ///
  /// In en, this message translates to:
  /// **'Premium Advantages'**
  String get premiumAdvantages;

  /// No description provided for @unlimitedTests.
  ///
  /// In en, this message translates to:
  /// **'Unlimited tests and exercises'**
  String get unlimitedTests;

  /// No description provided for @detailedAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Detailed vision analysis'**
  String get detailedAnalysis;

  /// No description provided for @historyTracking.
  ///
  /// In en, this message translates to:
  /// **'History tracking'**
  String get historyTracking;

  /// No description provided for @adFreeExperience.
  ///
  /// In en, this message translates to:
  /// **'Ad-free experience'**
  String get adFreeExperience;

  /// No description provided for @watchAdForTest.
  ///
  /// In en, this message translates to:
  /// **'Watch ad, earn +1 test credit. Remaining: {count}'**
  String watchAdForTest(int count);

  /// No description provided for @watchVideo.
  ///
  /// In en, this message translates to:
  /// **'Watch Video'**
  String get watchVideo;

  /// No description provided for @earnExtraTest.
  ///
  /// In en, this message translates to:
  /// **'Earn +1 Test Credit'**
  String get earnExtraTest;

  /// No description provided for @dailyTestLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily Test Limit'**
  String get dailyTestLimit;

  /// No description provided for @dailyTestLimitDesc.
  ///
  /// In en, this message translates to:
  /// **'You have completed 3 tests today. Choose an option to take more tests:'**
  String get dailyTestLimitDesc;

  /// No description provided for @testCreditsRemaining.
  ///
  /// In en, this message translates to:
  /// **'Test credits remaining: {count}'**
  String testCreditsRemaining(int count);

  /// No description provided for @adLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading ad...'**
  String get adLoading;

  /// No description provided for @adFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not show ad. Please try again.'**
  String get adFailed;

  /// No description provided for @adRewardEarned.
  ///
  /// In en, this message translates to:
  /// **'+1 test credit earned!'**
  String get adRewardEarned;

  /// No description provided for @adLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load ad. Please try again later.'**
  String get adLoadFailed;

  /// No description provided for @dailyTestQuotaReached.
  ///
  /// In en, this message translates to:
  /// **'Daily Test Quota Reached'**
  String get dailyTestQuotaReached;

  /// No description provided for @dailyTestQuotaReachedDesc.
  ///
  /// In en, this message translates to:
  /// **'You have used your 3 ad-free tests today. You can watch ads or go Premium to take more tests.'**
  String get dailyTestQuotaReachedDesc;

  /// No description provided for @watchAdOrPremium.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad / Premium'**
  String get watchAdOrPremium;

  /// No description provided for @premiumActivationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not activate Premium. Please try again.'**
  String get premiumActivationFailed;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorOccurred(String error);

  /// No description provided for @noRestoreFound.
  ///
  /// In en, this message translates to:
  /// **'No purchases found to restore.'**
  String get noRestoreFound;

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad'**
  String get watchAd;

  /// No description provided for @earnTestCredit.
  ///
  /// In en, this message translates to:
  /// **'Earn +1 test credit'**
  String get earnTestCredit;

  /// No description provided for @unlimitedTestsAndAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Unlimited tests and detailed analysis'**
  String get unlimitedTestsAndAnalysis;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @premiumFeature1Title.
  ///
  /// In en, this message translates to:
  /// **'Unlimited tests'**
  String get premiumFeature1Title;

  /// No description provided for @premiumFeature1Desc.
  ///
  /// In en, this message translates to:
  /// **'Measure your vision at different times'**
  String get premiumFeature1Desc;

  /// No description provided for @premiumFeature2Title.
  ///
  /// In en, this message translates to:
  /// **'Detailed reports & comparisons'**
  String get premiumFeature2Title;

  /// No description provided for @premiumFeature2Desc.
  ///
  /// In en, this message translates to:
  /// **'See differences with previous results'**
  String get premiumFeature2Desc;

  /// No description provided for @premiumFeature3Title.
  ///
  /// In en, this message translates to:
  /// **'Exercise history & tracking'**
  String get premiumFeature3Title;

  /// No description provided for @premiumFeature3Desc.
  ///
  /// In en, this message translates to:
  /// **'Save your daily exercises and see progress'**
  String get premiumFeature3Desc;

  /// No description provided for @premiumFeature4Title.
  ///
  /// In en, this message translates to:
  /// **'Ad-free, uninterrupted experience'**
  String get premiumFeature4Title;

  /// No description provided for @premiumFeature4Desc.
  ///
  /// In en, this message translates to:
  /// **'Focus more comfortably on tests'**
  String get premiumFeature4Desc;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'🎉 Premium Active!'**
  String get premiumActive;

  /// No description provided for @premiumActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'You can now enjoy all premium features:'**
  String get premiumActiveDesc;

  /// No description provided for @premiumBenefit1.
  ///
  /// In en, this message translates to:
  /// **'✓ Unlimited tests and exercises'**
  String get premiumBenefit1;

  /// No description provided for @premiumBenefit2.
  ///
  /// In en, this message translates to:
  /// **'✓ Detailed vision analysis'**
  String get premiumBenefit2;

  /// No description provided for @premiumBenefit3.
  ///
  /// In en, this message translates to:
  /// **'✓ Your history records'**
  String get premiumBenefit3;

  /// No description provided for @premiumBenefit4.
  ///
  /// In en, this message translates to:
  /// **'✓ Ad-free usage'**
  String get premiumBenefit4;

  /// No description provided for @trackEyeHealth.
  ///
  /// In en, this message translates to:
  /// **'Track Your Eye Health'**
  String get trackEyeHealth;

  /// No description provided for @trackEyeHealthDesc.
  ///
  /// In en, this message translates to:
  /// **'Compare your tests, do daily exercises, use ad-free and uninterrupted'**
  String get trackEyeHealthDesc;

  /// No description provided for @oneTimePayment.
  ///
  /// In en, this message translates to:
  /// **'One-Time Payment'**
  String get oneTimePayment;

  /// No description provided for @lifetimeAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Lifetime access'**
  String get lifetimeAccessDesc;

  /// No description provided for @singlePaymentNote.
  ///
  /// In en, this message translates to:
  /// **'Pay once • Updates included'**
  String get singlePaymentNote;

  /// No description provided for @continueWithPremium.
  ///
  /// In en, this message translates to:
  /// **'Continue with Premium'**
  String get continueWithPremium;

  /// No description provided for @paywallDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This app does not provide medical diagnosis. Tests are for informational and tracking purposes.'**
  String get paywallDisclaimer;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get dailyReminder;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @howWouldYouRateUs.
  ///
  /// In en, this message translates to:
  /// **'How would you rate our app?'**
  String get howWouldYouRateUs;

  /// No description provided for @thankYouForFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get thankYouForFeedback;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorGeneric;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No test history yet'**
  String get noHistory;

  /// No description provided for @startFirstTest.
  ///
  /// In en, this message translates to:
  /// **'Start your first test!'**
  String get startFirstTest;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @confirmClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all test history?'**
  String get confirmClearHistory;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @testTypesByType.
  ///
  /// In en, this message translates to:
  /// **'By Test Types'**
  String get testTypesByType;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @exerciseDaysCompleted.
  ///
  /// In en, this message translates to:
  /// **'Days with exercises'**
  String get exerciseDaysCompleted;

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySunday;

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// No description provided for @exerciseBlinking.
  ///
  /// In en, this message translates to:
  /// **'Blinking'**
  String get exerciseBlinking;

  /// No description provided for @exerciseFocusShift.
  ///
  /// In en, this message translates to:
  /// **'Focus Shifting'**
  String get exerciseFocusShift;

  /// No description provided for @exercisePalming.
  ///
  /// In en, this message translates to:
  /// **'Palming'**
  String get exercisePalming;

  /// No description provided for @exerciseCircularMovement.
  ///
  /// In en, this message translates to:
  /// **'Circular Movement'**
  String get exerciseCircularMovement;

  /// No description provided for @exerciseNearFar.
  ///
  /// In en, this message translates to:
  /// **'Near-Far Focus'**
  String get exerciseNearFar;

  /// No description provided for @exerciseFigureEight.
  ///
  /// In en, this message translates to:
  /// **'Figure Eight'**
  String get exerciseFigureEight;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @repetitions.
  ///
  /// In en, this message translates to:
  /// **'Repetitions'**
  String get repetitions;

  /// No description provided for @selectProfile.
  ///
  /// In en, this message translates to:
  /// **'Select Profile'**
  String get selectProfile;

  /// No description provided for @officeWorker.
  ///
  /// In en, this message translates to:
  /// **'Office Worker'**
  String get officeWorker;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @senior.
  ///
  /// In en, this message translates to:
  /// **'Senior'**
  String get senior;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @testAdTitle.
  ///
  /// In en, this message translates to:
  /// **'TEST AD'**
  String get testAdTitle;

  /// No description provided for @testAdDesc.
  ///
  /// In en, this message translates to:
  /// **'This is a test ad'**
  String get testAdDesc;

  /// No description provided for @closeableIn.
  ///
  /// In en, this message translates to:
  /// **'Closeable in {seconds} seconds'**
  String closeableIn(int seconds);

  /// No description provided for @completeAndGetReward.
  ///
  /// In en, this message translates to:
  /// **'Complete and Get Reward'**
  String get completeAndGetReward;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting... ({seconds})'**
  String waiting(int seconds);

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @soundEffectsDesc.
  ///
  /// In en, this message translates to:
  /// **'Turn button click sounds on/off'**
  String get soundEffectsDesc;

  /// No description provided for @notificationTime.
  ///
  /// In en, this message translates to:
  /// **'Notification Time'**
  String get notificationTime;

  /// No description provided for @brightnessWarning.
  ///
  /// In en, this message translates to:
  /// **'Brightness Warning'**
  String get brightnessWarning;

  /// No description provided for @brightnessWarningDesc.
  ///
  /// In en, this message translates to:
  /// **'Screen brightness warning before test'**
  String get brightnessWarningDesc;

  /// No description provided for @testSection.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get testSection;

  /// No description provided for @dailyTestInfo.
  ///
  /// In en, this message translates to:
  /// **'Daily Test Information'**
  String get dailyTestInfo;

  /// No description provided for @adFreeTestsToday.
  ///
  /// In en, this message translates to:
  /// **'Number of ad-free tests you can take today: {count}'**
  String adFreeTestsToday(int count);

  /// No description provided for @watchAdForExtraTest.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad for Extra Test'**
  String get watchAdForExtraTest;

  /// No description provided for @watchAdForExtraTestDesc.
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad to get +1 test credit'**
  String get watchAdForExtraTestDesc;

  /// No description provided for @premiumUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Premium - Unlimited Tests'**
  String get premiumUnlimited;

  /// No description provided for @premiumUnlimitedDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlimited tests and exercises. Detailed reports. History tracking. Ad-free experience.'**
  String get premiumUnlimitedDesc;

  /// No description provided for @premiumLifetimePrice.
  ///
  /// In en, this message translates to:
  /// **'Premium - Lifetime Access Only {price}'**
  String premiumLifetimePrice(String price);

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @exerciseHistory.
  ///
  /// In en, this message translates to:
  /// **'Exercise History'**
  String get exerciseHistory;

  /// No description provided for @viewAllTestResults.
  ///
  /// In en, this message translates to:
  /// **'View all your test results'**
  String get viewAllTestResults;

  /// No description provided for @viewExerciseHistoryCalendar.
  ///
  /// In en, this message translates to:
  /// **'View your exercise history in calendar'**
  String get viewExerciseHistoryCalendar;

  /// No description provided for @noTestsYet.
  ///
  /// In en, this message translates to:
  /// **'No tests completed yet'**
  String get noTestsYet;

  /// No description provided for @noExercisesYet.
  ///
  /// In en, this message translates to:
  /// **'No exercises completed yet'**
  String get noExercisesYet;

  /// No description provided for @totalTests.
  ///
  /// In en, this message translates to:
  /// **'Total Tests'**
  String get totalTests;

  /// No description provided for @averageScore.
  ///
  /// In en, this message translates to:
  /// **'Average Score'**
  String get averageScore;

  /// No description provided for @lastTestDate.
  ///
  /// In en, this message translates to:
  /// **'Last Test Date'**
  String get lastTestDate;

  /// No description provided for @testType.
  ///
  /// In en, this message translates to:
  /// **'Test Type'**
  String get testType;

  /// No description provided for @testDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get testDate;

  /// No description provided for @testScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get testScore;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @exerciseInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Eye Exercises'**
  String get exerciseInfoTitle;

  /// No description provided for @exerciseInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily exercises to relax and strengthen your eyes'**
  String get exerciseInfoSubtitle;

  /// No description provided for @exerciseInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Regular eye exercises can help reduce eye strain, improve focus, and maintain healthy vision. Choose a profile that matches your lifestyle to get personalized exercise recommendations.'**
  String get exerciseInfoDesc;

  /// No description provided for @startExercises.
  ///
  /// In en, this message translates to:
  /// **'Start Exercises'**
  String get startExercises;

  /// No description provided for @profileDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose a profile to get personalized exercise recommendations'**
  String get profileDesc;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @ofText.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofText;

  /// No description provided for @testInfo.
  ///
  /// In en, this message translates to:
  /// **'Test Information'**
  String get testInfo;

  /// No description provided for @testInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'This test will evaluate your visual acuity. Follow the instructions carefully.'**
  String get testInfoDesc;

  /// No description provided for @questionNumber.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionNumber(int current, int total);

  /// No description provided for @questionsDuringTest.
  ///
  /// In en, this message translates to:
  /// **'{count} questions will be asked during the test.'**
  String questionsDuringTest(int count);

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startButton;

  /// No description provided for @selectDirection.
  ///
  /// In en, this message translates to:
  /// **'Select the direction'**
  String get selectDirection;

  /// No description provided for @selectLetter.
  ///
  /// In en, this message translates to:
  /// **'Select the letter'**
  String get selectLetter;

  /// No description provided for @selectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Select your answer'**
  String get selectAnswer;

  /// No description provided for @resultSummary.
  ///
  /// In en, this message translates to:
  /// **'Result Summary'**
  String get resultSummary;

  /// No description provided for @leftEyeScore.
  ///
  /// In en, this message translates to:
  /// **'Left Eye Score'**
  String get leftEyeScore;

  /// No description provided for @rightEyeScore.
  ///
  /// In en, this message translates to:
  /// **'Right Eye Score'**
  String get rightEyeScore;

  /// No description provided for @overallScore.
  ///
  /// In en, this message translates to:
  /// **'Overall Score'**
  String get overallScore;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String percentage(int value);

  /// No description provided for @exerciseName.
  ///
  /// In en, this message translates to:
  /// **'Exercise Name'**
  String get exerciseName;

  /// No description provided for @exerciseDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get exerciseDescription;

  /// No description provided for @exerciseDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get exerciseDuration;

  /// No description provided for @exerciseRepetitions.
  ///
  /// In en, this message translates to:
  /// **'Repetitions'**
  String get exerciseRepetitions;

  /// No description provided for @startExercise.
  ///
  /// In en, this message translates to:
  /// **'Start Exercise'**
  String get startExercise;

  /// No description provided for @nextExercise.
  ///
  /// In en, this message translates to:
  /// **'Next Exercise'**
  String get nextExercise;

  /// No description provided for @completeExercise.
  ///
  /// In en, this message translates to:
  /// **'Complete Exercise'**
  String get completeExercise;

  /// No description provided for @exerciseProgress.
  ///
  /// In en, this message translates to:
  /// **'Exercise {current} of {total}'**
  String exerciseProgress(int current, int total);

  /// No description provided for @repetitionProgress.
  ///
  /// In en, this message translates to:
  /// **'Repetition {current} of {total}'**
  String repetitionProgress(int current, int total);

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get timeRemaining;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @factTitle.
  ///
  /// In en, this message translates to:
  /// **'Did You Know?'**
  String get factTitle;

  /// No description provided for @factSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Interesting facts about eyes'**
  String get factSubtitle;

  /// No description provided for @swipeToSeeMore.
  ///
  /// In en, this message translates to:
  /// **'Swipe to see more facts'**
  String get swipeToSeeMore;

  /// No description provided for @fact.
  ///
  /// In en, this message translates to:
  /// **'Fact'**
  String get fact;

  /// No description provided for @nextFact.
  ///
  /// In en, this message translates to:
  /// **'Next Fact'**
  String get nextFact;

  /// No description provided for @previousFact.
  ///
  /// In en, this message translates to:
  /// **'Previous Fact'**
  String get previousFact;

  /// No description provided for @testResultsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your test results will appear here as you complete tests'**
  String get testResultsWillAppearHere;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn how your data is protected'**
  String get privacyPolicySubtitle;

  /// No description provided for @privacySection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Data Collection'**
  String get privacySection1Title;

  /// No description provided for @privacySection1Content.
  ///
  /// In en, this message translates to:
  /// **'Our app may collect the following data to provide and improve our services:\n\n• Test results and history (stored on your device)\n• Usage statistics (anonymous)\n• Device information (operating system, model)\n• Application performance data\n\nPersonal identification information (name, email, phone) is not collected.'**
  String get privacySection1Content;

  /// No description provided for @privacySection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Data Usage'**
  String get privacySection2Title;

  /// No description provided for @privacySection2Content.
  ///
  /// In en, this message translates to:
  /// **'Collected data is used for the following purposes:\n\n• Viewing and comparing your test results\n• Improving application performance\n• Debugging and resolving technical issues\n• Enhancing user experience\n\nYour data is not shared with third parties for advertising purposes.'**
  String get privacySection2Content;

  /// No description provided for @privacySection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Data Storage'**
  String get privacySection3Title;

  /// No description provided for @privacySection3Content.
  ///
  /// In en, this message translates to:
  /// **'• Test results and history are stored locally on your device\n• If you delete the app, all your data will be deleted\n• No cloud synchronization is performed\n• Your data is stored securely encrypted'**
  String get privacySection3Content;

  /// No description provided for @privacySection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Third-Party Services'**
  String get privacySection4Title;

  /// No description provided for @privacySection4Content.
  ///
  /// In en, this message translates to:
  /// **'Our app may use the following third-party services:\n\n• Google AdMob: For ad display\n• Google Play Services: For in-app purchases\n• Firebase Analytics: For usage statistics (anonymous)\n\nThese services are subject to their own privacy policies.'**
  String get privacySection4Content;

  /// No description provided for @privacySection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Children\'s Privacy'**
  String get privacySection5Title;

  /// No description provided for @privacySection5Content.
  ///
  /// In en, this message translates to:
  /// **'Our app does not knowingly collect personal information from children under 13. If we discover that we have collected personal information from a child, we will immediately delete that information.'**
  String get privacySection5Content;

  /// No description provided for @privacySection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Your Rights'**
  String get privacySection6Title;

  /// No description provided for @privacySection6Content.
  ///
  /// In en, this message translates to:
  /// **'You have the following rights regarding your data:\n\n• Access to your data\n• Correction of your data\n• Deletion of your data\n• Data portability\n• Right to object\n\nYou can delete your data from the app settings to exercise these rights.'**
  String get privacySection6Content;

  /// No description provided for @privacySection7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Changes'**
  String get privacySection7Title;

  /// No description provided for @privacySection7Content.
  ///
  /// In en, this message translates to:
  /// **'We may update our privacy policy from time to time. In case of significant changes, a notification will be sent within the app. Last update date: {year}'**
  String privacySection7Content(int year);

  /// No description provided for @privacySection8Title.
  ///
  /// In en, this message translates to:
  /// **'8. Contact'**
  String get privacySection8Title;

  /// No description provided for @privacySection8Content.
  ///
  /// In en, this message translates to:
  /// **'If you have questions about our privacy policy, please contact us through the \"About\" section in the app.'**
  String get privacySection8Content;

  /// No description provided for @privacyImportantNote.
  ///
  /// In en, this message translates to:
  /// **'Important Note'**
  String get privacyImportantNote;

  /// No description provided for @privacyDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This privacy policy describes the app\'s data collection and usage practices. By using the app, you agree to this policy.'**
  String get privacyDisclaimer;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceTitle;

  /// No description provided for @termsOfServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Service terms and conditions'**
  String get termsOfServiceSubtitle;

  /// No description provided for @termsSection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Use of Service'**
  String get termsSection1Title;

  /// No description provided for @termsSection1Content.
  ///
  /// In en, this message translates to:
  /// **'This app is for informational and educational purposes. By using the app, you agree that:\n\n• The app is for informational purposes only\n• Test results do not replace professional eye examination\n• You will use the app in compliance with laws\n• You will not misuse the app'**
  String get termsSection1Content;

  /// No description provided for @termsSection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Not Medical Advice'**
  String get termsSection2Title;

  /// No description provided for @termsSection2Content.
  ///
  /// In en, this message translates to:
  /// **'IMPORTANT: This app does not provide medical advice, diagnosis, or treatment.\n\n• Test results are for informational purposes only\n• If you experience any vision problems, please consult an eye doctor\n• Test results may be affected by screen size, brightness, and environmental conditions\n• Do not make medical decisions based on app results'**
  String get termsSection2Content;

  /// No description provided for @termsSection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. User Responsibilities'**
  String get termsSection3Title;

  /// No description provided for @termsSection3Content.
  ///
  /// In en, this message translates to:
  /// **'As a user, you are responsible for:\n\n• Conducting tests under proper conditions\n• Not misinterpreting test results\n• Using the app in compliance with laws\n• Not using the app to harm third parties'**
  String get termsSection3Content;

  /// No description provided for @termsSection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Intellectual Property'**
  String get termsSection4Title;

  /// No description provided for @termsSection4Content.
  ///
  /// In en, this message translates to:
  /// **'• All app content is protected by copyright\n• You may not copy, distribute, or modify the content\n• May not be used for commercial purposes\n• Brand names and logos belong to their owners'**
  String get termsSection4Content;

  /// No description provided for @termsSection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Service Changes'**
  String get termsSection5Title;

  /// No description provided for @termsSection5Content.
  ///
  /// In en, this message translates to:
  /// **'• We reserve the right to change app content and features at any time\n• Notifications will be sent for significant changes\n• We reserve the right to temporarily or permanently suspend the service\n• Keep the app updated to stay informed of changes'**
  String get termsSection5Content;

  /// No description provided for @termsSection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Disclaimer'**
  String get termsSection6Title;

  /// No description provided for @termsSection6Content.
  ///
  /// In en, this message translates to:
  /// **'The app is provided \"as is\". We are not responsible for:\n\n• Accuracy or reliability of test results\n• Any damage arising from app use\n• Data loss or device damage\n• Interruption of third-party services\n• App errors or technical issues'**
  String get termsSection6Content;

  /// No description provided for @termsSection7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Paid Services'**
  String get termsSection7Title;

  /// No description provided for @termsSection7Content.
  ///
  /// In en, this message translates to:
  /// **'• In-app purchases (Premium) are non-refundable\n• Purchases are subject to Google Play Store or App Store policies\n• Refund requests are evaluated according to relevant store policies\n• Premium features may be changed or removed'**
  String get termsSection7Content;

  /// No description provided for @termsSection8Title.
  ///
  /// In en, this message translates to:
  /// **'8. Termination'**
  String get termsSection8Title;

  /// No description provided for @termsSection8Content.
  ///
  /// In en, this message translates to:
  /// **'We may terminate your service in the following cases:\n\n• When you violate the terms\n• When you engage in illegal activities\n• When you harm other users\n• When you misuse the app\n\nYour data may be deleted upon termination.'**
  String get termsSection8Content;

  /// No description provided for @termsSection9Title.
  ///
  /// In en, this message translates to:
  /// **'9. Changes'**
  String get termsSection9Title;

  /// No description provided for @termsSection9Content.
  ///
  /// In en, this message translates to:
  /// **'We may update the terms of service from time to time. Notifications will be sent in the app for significant changes. It is recommended that you check the terms regularly. Last update date: {year}'**
  String termsSection9Content(int year);

  /// No description provided for @termsSection10Title.
  ///
  /// In en, this message translates to:
  /// **'10. Contact and Complaints'**
  String get termsSection10Title;

  /// No description provided for @termsSection10Content.
  ///
  /// In en, this message translates to:
  /// **'If you have questions or complaints about the terms of service, please contact us through the \"About\" section in the app.'**
  String get termsSection10Content;

  /// No description provided for @termsImportantWarning.
  ///
  /// In en, this message translates to:
  /// **'Important Warning'**
  String get termsImportantWarning;

  /// No description provided for @termsDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'By using this app, you agree to the above terms of service. If you do not agree to the terms, please do not use the app.'**
  String get termsDisclaimer;

  /// No description provided for @testAbout.
  ///
  /// In en, this message translates to:
  /// **'About the Test'**
  String get testAbout;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @visualAcuityInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Visual Acuity Test?'**
  String get visualAcuityInfoTitle;

  /// No description provided for @visualAcuityInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Visual acuity test measures how clearly you can see. This test is based on the Snellen letter chart used in standard eye examinations.'**
  String get visualAcuityInfoDesc;

  /// No description provided for @visualAcuityInfoTip.
  ///
  /// In en, this message translates to:
  /// **'A healthy individual should be able to see all letters clearly throughout the test. If letters appear blurry or you are unsure, select the \"I\'m Not Sure\" option.'**
  String get visualAcuityInfoTip;

  /// No description provided for @visualAcuityInfoWarning.
  ///
  /// In en, this message translates to:
  /// **'During the test, each eye will be evaluated separately. You need to complete the test by closing one eye.'**
  String get visualAcuityInfoWarning;

  /// No description provided for @visualAcuityLeftEyeTitle.
  ///
  /// In en, this message translates to:
  /// **'Left Eye Test'**
  String get visualAcuityLeftEyeTitle;

  /// No description provided for @visualAcuityLeftEyeInstruction.
  ///
  /// In en, this message translates to:
  /// **'Please close your RIGHT eye and hold the device at arm\'s length.'**
  String get visualAcuityLeftEyeInstruction;

  /// No description provided for @visualAcuityLeftEyeSubInstruction.
  ///
  /// In en, this message translates to:
  /// **'10 questions will be asked during the test.'**
  String get visualAcuityLeftEyeSubInstruction;

  /// No description provided for @visualAcuityRightEyeTitle.
  ///
  /// In en, this message translates to:
  /// **'Right Eye Test'**
  String get visualAcuityRightEyeTitle;

  /// No description provided for @visualAcuityRightEyeInstruction.
  ///
  /// In en, this message translates to:
  /// **'Please close your LEFT eye and hold the device at arm\'s length.'**
  String get visualAcuityRightEyeInstruction;

  /// No description provided for @visualAcuityRightEyeSubInstruction.
  ///
  /// In en, this message translates to:
  /// **'10 questions will be asked during the test.'**
  String get visualAcuityRightEyeSubInstruction;

  /// No description provided for @visualAcuityDistanceDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Arm\'s Length'**
  String get visualAcuityDistanceDialogTitle;

  /// No description provided for @visualAcuityDistanceDialogContent.
  ///
  /// In en, this message translates to:
  /// **'You can start the test when you close your right eye and bring the device to arm\'s length.'**
  String get visualAcuityDistanceDialogContent;

  /// No description provided for @visualAcuityDistanceDialogContentLeft.
  ///
  /// In en, this message translates to:
  /// **'You can start the test when you close your left eye and bring the device to arm\'s length.'**
  String get visualAcuityDistanceDialogContentLeft;

  /// No description provided for @visualAcuityDistanceDialogContentBoth.
  ///
  /// In en, this message translates to:
  /// **'You can start the test when you keep both eyes open and bring the device to arm\'s length.'**
  String get visualAcuityDistanceDialogContentBoth;

  /// No description provided for @visualAcuityQuestionText.
  ///
  /// In en, this message translates to:
  /// **'Point to the letter you see'**
  String get visualAcuityQuestionText;

  /// No description provided for @colorVisionInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Color Blindness Test?'**
  String get colorVisionInfoTitle;

  /// No description provided for @colorVisionInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'This test evaluates three different types of color blindness:\n\n• Deuteranopia (Green Color Blindness)\n• Protanopia (Red Color Blindness)\n• Tritanopia (Blue Color Blindness)'**
  String get colorVisionInfoDesc;

  /// No description provided for @colorVisionInfoTip.
  ///
  /// In en, this message translates to:
  /// **'A healthy individual should be able to see the numbers inside colored circles clearly. In ring tests, they should be able to distinguish different colors. If you are unsure, select the \"I\'m Not Sure\" option.'**
  String get colorVisionInfoTip;

  /// No description provided for @colorVisionInstruction1.
  ///
  /// In en, this message translates to:
  /// **'Set screen brightness to maximum.'**
  String get colorVisionInstruction1;

  /// No description provided for @colorVisionInstruction2.
  ///
  /// In en, this message translates to:
  /// **'In number plates: Find the number inside the circle.'**
  String get colorVisionInstruction2;

  /// No description provided for @colorVisionInstruction3.
  ///
  /// In en, this message translates to:
  /// **'In ring tests: Evaluate whether you can see different colors.'**
  String get colorVisionInstruction3;

  /// No description provided for @colorVisionPlate.
  ///
  /// In en, this message translates to:
  /// **'Plate {current} / {total}'**
  String colorVisionPlate(int current, int total);

  /// No description provided for @colorVisionWhichNumber.
  ///
  /// In en, this message translates to:
  /// **'Which number do you see?'**
  String get colorVisionWhichNumber;

  /// No description provided for @colorVisionRingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you see a ring of different color inside the circle?'**
  String get colorVisionRingQuestion;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @astigmatismInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Astigmatism Test?'**
  String get astigmatismInfoTitle;

  /// No description provided for @astigmatismInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Astigmatism is a vision disorder caused by the irregular shape of the cornea or lens of the eye. In this case, light cannot focus properly on the eye and images may appear blurry or distorted.'**
  String get astigmatismInfoDesc;

  /// No description provided for @astigmatismInfoTip.
  ///
  /// In en, this message translates to:
  /// **'A healthy individual should be able to see all radial lines with equal clarity. If some lines appear darker, blurry, or different, this may be a sign of astigmatism.'**
  String get astigmatismInfoTip;

  /// No description provided for @astigmatismInstruction1.
  ///
  /// In en, this message translates to:
  /// **'Close one eye'**
  String get astigmatismInstruction1;

  /// No description provided for @astigmatismInstruction2.
  ///
  /// In en, this message translates to:
  /// **'Focus on the dot in the center of the diagram'**
  String get astigmatismInstruction2;

  /// No description provided for @astigmatismInstruction3.
  ///
  /// In en, this message translates to:
  /// **'Evaluate whether all lines are equal'**
  String get astigmatismInstruction3;

  /// No description provided for @astigmatismInstruction4.
  ///
  /// In en, this message translates to:
  /// **'Touch the lines that appear darker'**
  String get astigmatismInstruction4;

  /// No description provided for @astigmatismInstructionInfo.
  ///
  /// In en, this message translates to:
  /// **'Each eye will be tested separately.'**
  String get astigmatismInstructionInfo;

  /// No description provided for @astigmatismSelectDarkerLines.
  ///
  /// In en, this message translates to:
  /// **'Please touch the lines that appear darker'**
  String get astigmatismSelectDarkerLines;

  /// No description provided for @astigmatismBothEyesInstruction.
  ///
  /// In en, this message translates to:
  /// **'Keep both eyes open and look'**
  String get astigmatismBothEyesInstruction;

  /// No description provided for @astigmatismAllLinesEqual.
  ///
  /// In en, this message translates to:
  /// **'All Lines Equal'**
  String get astigmatismAllLinesEqual;

  /// No description provided for @astigmatismSomeLinesDarker.
  ///
  /// In en, this message translates to:
  /// **'Some Lines Darker'**
  String get astigmatismSomeLinesDarker;

  /// No description provided for @astigmatismDiagnosisNormal.
  ///
  /// In en, this message translates to:
  /// **'No signs of astigmatism'**
  String get astigmatismDiagnosisNormal;

  /// No description provided for @astigmatismDiagnosisMild.
  ///
  /// In en, this message translates to:
  /// **'There may be mild astigmatism. Consult an eye doctor.'**
  String get astigmatismDiagnosisMild;

  /// No description provided for @astigmatismDiagnosisModerate.
  ///
  /// In en, this message translates to:
  /// **'There may be astigmatism. Consult an eye doctor.'**
  String get astigmatismDiagnosisModerate;

  /// No description provided for @astigmatismDiagnosisSevere.
  ///
  /// In en, this message translates to:
  /// **'There are clear signs of astigmatism. Consult an eye doctor.'**
  String get astigmatismDiagnosisSevere;

  /// No description provided for @astigmatismLinesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} line selected'**
  String astigmatismLinesSelected(int count);

  /// No description provided for @closeRightEyeInstruction.
  ///
  /// In en, this message translates to:
  /// **'Close your left eye and look with your right eye'**
  String get closeRightEyeInstruction;

  /// No description provided for @closeLeftEyeInstruction.
  ///
  /// In en, this message translates to:
  /// **'Close your right eye and look with your left eye'**
  String get closeLeftEyeInstruction;

  /// No description provided for @bothEyesLabel.
  ///
  /// In en, this message translates to:
  /// **'Both Eyes'**
  String get bothEyesLabel;

  /// No description provided for @nearVisionInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Near Vision Test?'**
  String get nearVisionInfoTitle;

  /// No description provided for @nearVisionInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Near vision test measures how well you can see books, phones, or objects at close range. This test helps evaluate conditions such as presbyopia (age-related near vision problems).'**
  String get nearVisionInfoDesc;

  /// No description provided for @nearVisionInfoTip.
  ///
  /// In en, this message translates to:
  /// **'A healthy individual should be able to read small text at close range clearly. During the test, the text will gradually become smaller.'**
  String get nearVisionInfoTip;

  /// No description provided for @nearVisionDistanceDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Book Reading Distance'**
  String get nearVisionDistanceDialogTitle;

  /// No description provided for @nearVisionDistanceDialogContent.
  ///
  /// In en, this message translates to:
  /// **'You can start the test when you bring the device to book reading distance (25-30 cm).'**
  String get nearVisionDistanceDialogContent;

  /// No description provided for @nearVisionInstruction1.
  ///
  /// In en, this message translates to:
  /// **'Hold the phone at approximately 40 cm distance'**
  String get nearVisionInstruction1;

  /// No description provided for @nearVisionInstruction2.
  ///
  /// In en, this message translates to:
  /// **'Read the word on the screen'**
  String get nearVisionInstruction2;

  /// No description provided for @nearVisionInstruction3.
  ///
  /// In en, this message translates to:
  /// **'Select the word you see from the options'**
  String get nearVisionInstruction3;

  /// No description provided for @nearVisionInstruction4.
  ///
  /// In en, this message translates to:
  /// **'The texts will gradually get smaller'**
  String get nearVisionInstruction4;

  /// No description provided for @nearVisionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Which word do you see?'**
  String get nearVisionQuestion;

  /// No description provided for @nearVisionDiagnosisNormal.
  ///
  /// In en, this message translates to:
  /// **'Your near vision appears normal'**
  String get nearVisionDiagnosisNormal;

  /// No description provided for @nearVisionDiagnosisMild.
  ///
  /// In en, this message translates to:
  /// **'There may be a mild near vision problem'**
  String get nearVisionDiagnosisMild;

  /// No description provided for @nearVisionDiagnosisSevere.
  ///
  /// In en, this message translates to:
  /// **'There is a near vision problem. Consult an eye doctor.'**
  String get nearVisionDiagnosisSevere;

  /// No description provided for @nearVisionWord1.
  ///
  /// In en, this message translates to:
  /// **'BOOK'**
  String get nearVisionWord1;

  /// No description provided for @nearVisionWord2.
  ///
  /// In en, this message translates to:
  /// **'TEXT'**
  String get nearVisionWord2;

  /// No description provided for @nearVisionWord3.
  ///
  /// In en, this message translates to:
  /// **'READ'**
  String get nearVisionWord3;

  /// No description provided for @nearVisionWord4.
  ///
  /// In en, this message translates to:
  /// **'PASSAGE'**
  String get nearVisionWord4;

  /// No description provided for @nearVisionWord5.
  ///
  /// In en, this message translates to:
  /// **'LINE'**
  String get nearVisionWord5;

  /// No description provided for @nearVisionWord6.
  ///
  /// In en, this message translates to:
  /// **'WORD'**
  String get nearVisionWord6;

  /// No description provided for @nearVisionWord7.
  ///
  /// In en, this message translates to:
  /// **'SENTENCE'**
  String get nearVisionWord7;

  /// No description provided for @nearVisionWord8.
  ///
  /// In en, this message translates to:
  /// **'PARAGRAPH'**
  String get nearVisionWord8;

  /// No description provided for @nearVisionWord9.
  ///
  /// In en, this message translates to:
  /// **'LETTER'**
  String get nearVisionWord9;

  /// No description provided for @nearVisionWord10.
  ///
  /// In en, this message translates to:
  /// **'TERM'**
  String get nearVisionWord10;

  /// No description provided for @peripheralVisionInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Peripheral Vision Test?'**
  String get peripheralVisionInfoTitle;

  /// No description provided for @peripheralVisionInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Peripheral vision is the ability to see outside the central field of vision. This test helps detect conditions such as glaucoma and retinal problems.'**
  String get peripheralVisionInfoDesc;

  /// No description provided for @peripheralVisionInfoTip.
  ///
  /// In en, this message translates to:
  /// **'Focus on the center point and try to see the hollow shape at the edges. Do not move your head or eyes.'**
  String get peripheralVisionInfoTip;

  /// No description provided for @peripheralVisionInstruction1.
  ///
  /// In en, this message translates to:
  /// **'Focus on the center point'**
  String get peripheralVisionInstruction1;

  /// No description provided for @peripheralVisionInstruction2.
  ///
  /// In en, this message translates to:
  /// **'Do not move your head or eyes'**
  String get peripheralVisionInstruction2;

  /// No description provided for @peripheralVisionInstruction3.
  ///
  /// In en, this message translates to:
  /// **'Indicate whether you see the shapes on the sides'**
  String get peripheralVisionInstruction3;

  /// No description provided for @peripheralVisionInstruction4.
  ///
  /// In en, this message translates to:
  /// **'Select the empty shape'**
  String get peripheralVisionInstruction4;

  /// No description provided for @peripheralVisionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Look at the center and select the empty shape'**
  String get peripheralVisionQuestion;

  /// No description provided for @eyeMovementInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Eye Movement Test?'**
  String get eyeMovementInfoTitle;

  /// No description provided for @eyeMovementInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Smooth pursuit test measures the eyes\' ability to track moving objects. This test helps evaluate eye muscle coordination and neurological problems.'**
  String get eyeMovementInfoDesc;

  /// No description provided for @eyeMovementInfoTip.
  ///
  /// In en, this message translates to:
  /// **'A healthy individual should be able to track a moving object with their eyes only, without moving their head.'**
  String get eyeMovementInfoTip;

  /// No description provided for @eyeMovementInstruction1.
  ///
  /// In en, this message translates to:
  /// **'Keep both eyes open'**
  String get eyeMovementInstruction1;

  /// No description provided for @eyeMovementInstruction2.
  ///
  /// In en, this message translates to:
  /// **'Track the moving ball with your eyes only'**
  String get eyeMovementInstruction2;

  /// No description provided for @eyeMovementInstruction3.
  ///
  /// In en, this message translates to:
  /// **'Do not move your head'**
  String get eyeMovementInstruction3;

  /// No description provided for @eyeMovementInstruction4.
  ///
  /// In en, this message translates to:
  /// **'Indicate whether you can track the ball'**
  String get eyeMovementInstruction4;

  /// No description provided for @eyeMovementQuestion.
  ///
  /// In en, this message translates to:
  /// **'Could you track the ball?'**
  String get eyeMovementQuestion;

  /// No description provided for @eyeMovementCanFollow.
  ///
  /// In en, this message translates to:
  /// **'Yes, I can follow'**
  String get eyeMovementCanFollow;

  /// No description provided for @eyeMovementCannotFollow.
  ///
  /// In en, this message translates to:
  /// **'No, I cannot follow'**
  String get eyeMovementCannotFollow;

  /// No description provided for @eyeMovementDiagnosisNormal.
  ///
  /// In en, this message translates to:
  /// **'Your eye movement tracking ability appears normal'**
  String get eyeMovementDiagnosisNormal;

  /// No description provided for @eyeMovementDiagnosisMild.
  ///
  /// In en, this message translates to:
  /// **'There may be a mild eye movement problem'**
  String get eyeMovementDiagnosisMild;

  /// No description provided for @eyeMovementDiagnosisLow.
  ///
  /// In en, this message translates to:
  /// **'There is an eye movement problem. Consult an eye doctor.'**
  String get eyeMovementDiagnosisLow;

  /// No description provided for @vergenceInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Vergence Test?'**
  String get vergenceInfoTitle;

  /// No description provided for @vergenceInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Vergence Test measures your eyes\' ability to converge (bring closer) and diverge (move apart). This test detects double vision (diplopia) and eye muscle coordination problems.'**
  String get vergenceInfoDesc;

  /// No description provided for @vergenceInfoTip.
  ///
  /// In en, this message translates to:
  /// **'During the test, you will bring an object closer and move it away. You will indicate whether there is double vision.'**
  String get vergenceInfoTip;

  /// No description provided for @vergenceInfoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Professional Binocular Vision Test'**
  String get vergenceInfoSectionTitle;

  /// No description provided for @vergenceInstruction1.
  ///
  /// In en, this message translates to:
  /// **'Focus on the object on the screen'**
  String get vergenceInstruction1;

  /// No description provided for @vergenceInstruction2.
  ///
  /// In en, this message translates to:
  /// **'Bring the object closer or move it further away'**
  String get vergenceInstruction2;

  /// No description provided for @vergenceInstruction3.
  ///
  /// In en, this message translates to:
  /// **'Indicate if there is double vision (diplopia)'**
  String get vergenceInstruction3;

  /// No description provided for @vergenceInstruction4.
  ///
  /// In en, this message translates to:
  /// **'Keep both eyes open'**
  String get vergenceInstruction4;

  /// No description provided for @vergenceQuestionConverge.
  ///
  /// In en, this message translates to:
  /// **'Bring the object closer (toward your nose)'**
  String get vergenceQuestionConverge;

  /// No description provided for @vergenceQuestionDiverge.
  ///
  /// In en, this message translates to:
  /// **'Move the object further away'**
  String get vergenceQuestionDiverge;

  /// No description provided for @vergenceQuestionFinal.
  ///
  /// In en, this message translates to:
  /// **'Final convergence test'**
  String get vergenceQuestionFinal;

  /// No description provided for @vergenceDiplopiaQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you see the object double?'**
  String get vergenceDiplopiaQuestion;

  /// No description provided for @vergenceDiagnosisNormal.
  ///
  /// In en, this message translates to:
  /// **'Your convergence and divergence abilities appear normal'**
  String get vergenceDiagnosisNormal;

  /// No description provided for @vergenceDiagnosisMild.
  ///
  /// In en, this message translates to:
  /// **'There may be a mild vergence problem - Consult an eye doctor'**
  String get vergenceDiagnosisMild;

  /// No description provided for @vergenceDiagnosisSevere.
  ///
  /// In en, this message translates to:
  /// **'There is a vergence problem - Definitely consult an eye doctor'**
  String get vergenceDiagnosisSevere;

  /// No description provided for @macularInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Macular Test?'**
  String get macularInfoTitle;

  /// No description provided for @macularInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'The Amsler Grid test helps detect macular problems such as macular degeneration (yellow spot disease). This test identifies distortions, warps, or missing areas in the central field of vision.'**
  String get macularInfoDesc;

  /// No description provided for @macularInfoTip.
  ///
  /// In en, this message translates to:
  /// **'A healthy individual should be able to see the grid lines straight and the central point at the intersection clearly. If there are distortions, blurriness, or missing areas in the lines, consult an eye doctor.'**
  String get macularInfoTip;

  /// No description provided for @macularInstruction1.
  ///
  /// In en, this message translates to:
  /// **'Close one eye'**
  String get macularInstruction1;

  /// No description provided for @macularInstruction2.
  ///
  /// In en, this message translates to:
  /// **'Focus on the dot in the center of the grid'**
  String get macularInstruction2;

  /// No description provided for @macularInstruction3.
  ///
  /// In en, this message translates to:
  /// **'Check if all lines are straight and equal'**
  String get macularInstruction3;

  /// No description provided for @macularInstruction4.
  ///
  /// In en, this message translates to:
  /// **'Is there distortion, blurriness, or missing areas?'**
  String get macularInstruction4;

  /// No description provided for @macularStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} / {total}'**
  String macularStep(int current, int total);

  /// No description provided for @macularAllLinesNormal.
  ///
  /// In en, this message translates to:
  /// **'All Lines Normal'**
  String get macularAllLinesNormal;

  /// No description provided for @macularHasIssues.
  ///
  /// In en, this message translates to:
  /// **'Distortion/Blurriness/Missing Areas'**
  String get macularHasIssues;

  /// No description provided for @macularDiagnosisBothNormal.
  ///
  /// In en, this message translates to:
  /// **'Macular appearance is normal in both eyes'**
  String get macularDiagnosisBothNormal;

  /// No description provided for @macularDiagnosisOneEye.
  ///
  /// In en, this message translates to:
  /// **'{eye} eye may show macular abnormalities. Consult an eye doctor.'**
  String macularDiagnosisOneEye(String eye);

  /// No description provided for @macularDiagnosisBothAbnormal.
  ///
  /// In en, this message translates to:
  /// **'Both eyes may show macular abnormalities. Consult an eye doctor urgently.'**
  String get macularDiagnosisBothAbnormal;

  /// No description provided for @contrastInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Contrast Sensitivity Test?'**
  String get contrastInfoTitle;

  /// No description provided for @contrastInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Contrast sensitivity is the ability to distinguish objects of different brightness. This test measures how well you can see low-contrast letters.'**
  String get contrastInfoDesc;

  /// No description provided for @contrastInfoTip.
  ///
  /// In en, this message translates to:
  /// **'A healthy individual should be able to see low-contrast letters as well. During the test, the letters will gradually become less contrasty.'**
  String get contrastInfoTip;

  /// No description provided for @contrastInstruction1.
  ///
  /// In en, this message translates to:
  /// **'Focus on the letter in the center of the screen'**
  String get contrastInstruction1;

  /// No description provided for @contrastInstruction2.
  ///
  /// In en, this message translates to:
  /// **'Set screen brightness to maximum'**
  String get contrastInstruction2;

  /// No description provided for @contrastInstruction3.
  ///
  /// In en, this message translates to:
  /// **'Select the letter you see from the options'**
  String get contrastInstruction3;

  /// No description provided for @contrastInstruction4.
  ///
  /// In en, this message translates to:
  /// **'Letters will gradually become less contrasty'**
  String get contrastInstruction4;

  /// No description provided for @contrastQuestion.
  ///
  /// In en, this message translates to:
  /// **'Which letter do you see?'**
  String get contrastQuestion;

  /// No description provided for @contrastDiagnosisNormal.
  ///
  /// In en, this message translates to:
  /// **'Your contrast sensitivity appears normal'**
  String get contrastDiagnosisNormal;

  /// No description provided for @contrastDiagnosisMild.
  ///
  /// In en, this message translates to:
  /// **'There may be a slight contrast sensitivity deficiency'**
  String get contrastDiagnosisMild;

  /// No description provided for @contrastDiagnosisLow.
  ///
  /// In en, this message translates to:
  /// **'Contrast sensitivity is low. Consult an eye doctor.'**
  String get contrastDiagnosisLow;

  /// No description provided for @peripheralDiagnosisNormal.
  ///
  /// In en, this message translates to:
  /// **'Your peripheral vision appears normal'**
  String get peripheralDiagnosisNormal;

  /// No description provided for @peripheralDiagnosisMild.
  ///
  /// In en, this message translates to:
  /// **'There may be a mild peripheral vision problem'**
  String get peripheralDiagnosisMild;

  /// No description provided for @peripheralDiagnosisLow.
  ///
  /// In en, this message translates to:
  /// **'There is a peripheral vision problem. Consult an eye doctor.'**
  String get peripheralDiagnosisLow;

  /// No description provided for @stereopsisDiagnosisNormal.
  ///
  /// In en, this message translates to:
  /// **'Your visual tracking ability appears normal'**
  String get stereopsisDiagnosisNormal;

  /// No description provided for @stereopsisDiagnosisMild.
  ///
  /// In en, this message translates to:
  /// **'There may be a mild visual tracking problem'**
  String get stereopsisDiagnosisMild;

  /// No description provided for @stereopsisDiagnosisLow.
  ///
  /// In en, this message translates to:
  /// **'There is a visual tracking problem. Consult an eye doctor.'**
  String get stereopsisDiagnosisLow;

  /// No description provided for @stereopsisInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Visual Tracking Test?'**
  String get stereopsisInfoTitle;

  /// No description provided for @stereopsisInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'This test measures your ability to track a moving object and determine which drawing it is under. It evaluates your visual attention, tracking, and concentration skills.'**
  String get stereopsisInfoDesc;

  /// No description provided for @stereopsisInfoTip.
  ///
  /// In en, this message translates to:
  /// **'Carefully track the ball as it moves. When the movement stops, select which drawing it is under.'**
  String get stereopsisInfoTip;

  /// No description provided for @stereopsisInstruction1.
  ///
  /// In en, this message translates to:
  /// **'Carefully track the ball\'s movement'**
  String get stereopsisInstruction1;

  /// No description provided for @stereopsisInstruction2.
  ///
  /// In en, this message translates to:
  /// **'The ball will move under 3 shapes (Hat, Star, Heart)'**
  String get stereopsisInstruction2;

  /// No description provided for @stereopsisInstruction3.
  ///
  /// In en, this message translates to:
  /// **'When the movement stops, select which drawing the ball is under'**
  String get stereopsisInstruction3;

  /// No description provided for @stereopsisInstruction4.
  ///
  /// In en, this message translates to:
  /// **'As the test progresses, the ball will move faster'**
  String get stereopsisInstruction4;

  /// No description provided for @stereopsisQuestion.
  ///
  /// In en, this message translates to:
  /// **'Which drawing is the ball under?'**
  String get stereopsisQuestion;

  /// No description provided for @stereopsisTracking.
  ///
  /// In en, this message translates to:
  /// **'Track the ball...'**
  String get stereopsisTracking;

  /// No description provided for @leftEyeLabel.
  ///
  /// In en, this message translates to:
  /// **'Left Eye'**
  String get leftEyeLabel;

  /// No description provided for @rightEyeLabel.
  ///
  /// In en, this message translates to:
  /// **'Right Eye'**
  String get rightEyeLabel;

  /// No description provided for @exerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Eye Exercises'**
  String get exerciseTitle;

  /// No description provided for @exerciseBenefit1Title.
  ///
  /// In en, this message translates to:
  /// **'Reduces Eye Fatigue'**
  String get exerciseBenefit1Title;

  /// No description provided for @exerciseBenefit1Desc.
  ///
  /// In en, this message translates to:
  /// **'Alleviates eye fatigue caused by screen use'**
  String get exerciseBenefit1Desc;

  /// No description provided for @exerciseBenefit2Title.
  ///
  /// In en, this message translates to:
  /// **'Improves Focus'**
  String get exerciseBenefit2Title;

  /// No description provided for @exerciseBenefit2Desc.
  ///
  /// In en, this message translates to:
  /// **'Strengthens eye muscles to enhance focus ability'**
  String get exerciseBenefit2Desc;

  /// No description provided for @exerciseBenefit3Title.
  ///
  /// In en, this message translates to:
  /// **'Increases Eye Coordination'**
  String get exerciseBenefit3Title;

  /// No description provided for @exerciseBenefit3Desc.
  ///
  /// In en, this message translates to:
  /// **'Improves coordination by regulating eye movements'**
  String get exerciseBenefit3Desc;

  /// No description provided for @exerciseBenefit4Title.
  ///
  /// In en, this message translates to:
  /// **'Protects Eye Health'**
  String get exerciseBenefit4Title;

  /// No description provided for @exerciseBenefit4Desc.
  ///
  /// In en, this message translates to:
  /// **'Protect your eye health with regular exercise'**
  String get exerciseBenefit4Desc;

  /// No description provided for @exerciseBenefit5Title.
  ///
  /// In en, this message translates to:
  /// **'Rests the Eyes'**
  String get exerciseBenefit5Title;

  /// No description provided for @exerciseBenefit5Desc.
  ///
  /// In en, this message translates to:
  /// **'Rest your eyes by adding to your daily routine'**
  String get exerciseBenefit5Desc;

  /// No description provided for @exerciseStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get exerciseStart;

  /// No description provided for @exerciseScrollDown.
  ///
  /// In en, this message translates to:
  /// **'Scroll down'**
  String get exerciseScrollDown;

  /// No description provided for @exerciseProfileSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Profile'**
  String get exerciseProfileSelect;

  /// No description provided for @exerciseProfileSelectDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose the exercise program that suits you'**
  String get exerciseProfileSelectDesc;

  /// No description provided for @exerciseProfileChild.
  ///
  /// In en, this message translates to:
  /// **'Child (Family)'**
  String get exerciseProfileChild;

  /// No description provided for @exerciseProfileChildSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ages 5-12'**
  String get exerciseProfileChildSubtitle;

  /// No description provided for @exerciseProfileAdult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get exerciseProfileAdult;

  /// No description provided for @exerciseProfileAdultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Suitable for all ages.'**
  String get exerciseProfileAdultSubtitle;

  /// No description provided for @exerciseProfileOffice.
  ///
  /// In en, this message translates to:
  /// **'Office Worker'**
  String get exerciseProfileOffice;

  /// No description provided for @exerciseProfileInfo.
  ///
  /// In en, this message translates to:
  /// **'Specially prepared exercise programs for each profile'**
  String get exerciseProfileInfo;

  /// No description provided for @exerciseProfileChildFull.
  ///
  /// In en, this message translates to:
  /// **'Child (Family) - Ages 5-12'**
  String get exerciseProfileChildFull;

  /// No description provided for @exerciseProfileAdultFull.
  ///
  /// In en, this message translates to:
  /// **'Adult (Suitable for all ages.)'**
  String get exerciseProfileAdultFull;

  /// No description provided for @exerciseDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get exerciseDailyReminder;

  /// No description provided for @exerciseDailyReminderDesc.
  ///
  /// In en, this message translates to:
  /// **'Would you like to receive a daily eye exercise reminder once a day?'**
  String get exerciseDailyReminderDesc;

  /// No description provided for @exerciseNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get exerciseNo;

  /// No description provided for @exerciseYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get exerciseYes;

  /// No description provided for @exerciseTodayExercises.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Exercises'**
  String get exerciseTodayExercises;

  /// No description provided for @exerciseSteps.
  ///
  /// In en, this message translates to:
  /// **'{count} steps'**
  String exerciseSteps(int count);

  /// No description provided for @exerciseStartExercises.
  ///
  /// In en, this message translates to:
  /// **'Start Exercises'**
  String get exerciseStartExercises;

  /// No description provided for @exerciseNumber.
  ///
  /// In en, this message translates to:
  /// **'Exercise {current} / {total}'**
  String exerciseNumber(int current, int total);

  /// No description provided for @exerciseComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get exerciseComplete;

  /// No description provided for @exerciseDone.
  ///
  /// In en, this message translates to:
  /// **'Done ({current}/{total})'**
  String exerciseDone(int current, int total);

  /// No description provided for @exerciseReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get exerciseReady;

  /// No description provided for @exerciseStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting'**
  String get exerciseStarting;

  /// No description provided for @exerciseNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get exerciseNext;

  /// No description provided for @exerciseFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get exerciseFinish;

  /// No description provided for @exerciseExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exerciseExit;

  /// No description provided for @exerciseCompletionTitleAdult.
  ///
  /// In en, this message translates to:
  /// **'✔ Today\'s exercises completed'**
  String get exerciseCompletionTitleAdult;

  /// No description provided for @exerciseCompletionTitleChild.
  ///
  /// In en, this message translates to:
  /// **'🎉 Great Job!'**
  String get exerciseCompletionTitleChild;

  /// No description provided for @exerciseCompletionMessageAdult.
  ///
  /// In en, this message translates to:
  /// **'You rested your eyes\nYou refreshed your focus'**
  String get exerciseCompletionMessageAdult;

  /// No description provided for @exerciseCompletionMessageChild.
  ///
  /// In en, this message translates to:
  /// **'You completed today\'s eye exercises 👏'**
  String get exerciseCompletionMessageChild;

  /// No description provided for @exerciseCompletionSubtitleAdult.
  ///
  /// In en, this message translates to:
  /// **'Once a day is enough'**
  String get exerciseCompletionSubtitleAdult;

  /// No description provided for @exerciseCompletionSubtitleChild.
  ///
  /// In en, this message translates to:
  /// **'Your eyes thank you'**
  String get exerciseCompletionSubtitleChild;

  /// No description provided for @exerciseBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get exerciseBackToHome;

  /// No description provided for @exerciseRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat Exercises'**
  String get exerciseRepeat;

  /// No description provided for @exerciseChild1Title.
  ///
  /// In en, this message translates to:
  /// **'Butterfly Eyes'**
  String get exerciseChild1Title;

  /// No description provided for @exerciseChild1Desc.
  ///
  /// In en, this message translates to:
  /// **'Let\'s flap like a butterfly!\nSlowly open and close your eyes. 👁️'**
  String get exerciseChild1Desc;

  /// No description provided for @exerciseChild1Benefit.
  ///
  /// In en, this message translates to:
  /// **'Moisturizes and relaxes the eyes'**
  String get exerciseChild1Benefit;

  /// No description provided for @exerciseChild2Title.
  ///
  /// In en, this message translates to:
  /// **'Near–Far Game'**
  String get exerciseChild2Title;

  /// No description provided for @exerciseChild2Desc.
  ///
  /// In en, this message translates to:
  /// **'Look at your finger. 👆\nNow look at the end of the room. 🌳\nLet\'s do it again!'**
  String get exerciseChild2Desc;

  /// No description provided for @exerciseChild2Benefit.
  ///
  /// In en, this message translates to:
  /// **'Improves focusing ability'**
  String get exerciseChild2Benefit;

  /// No description provided for @exerciseChild3Title.
  ///
  /// In en, this message translates to:
  /// **'Magic Eight'**
  String get exerciseChild3Title;

  /// No description provided for @exerciseChild3Desc.
  ///
  /// In en, this message translates to:
  /// **'Draw an eight in the air with your eyes.\nVery slowly and calmly. ✨'**
  String get exerciseChild3Desc;

  /// No description provided for @exerciseChild3Benefit.
  ///
  /// In en, this message translates to:
  /// **'Strengthens eye coordination'**
  String get exerciseChild3Benefit;

  /// No description provided for @exerciseChild4Title.
  ///
  /// In en, this message translates to:
  /// **'Look Left–Right'**
  String get exerciseChild4Title;

  /// No description provided for @exerciseChild4Desc.
  ///
  /// In en, this message translates to:
  /// **'Keep your head still!\nJust look left and right with your eyes.'**
  String get exerciseChild4Desc;

  /// No description provided for @exerciseChild4Benefit.
  ///
  /// In en, this message translates to:
  /// **'Stretches and strengthens eye muscles'**
  String get exerciseChild4Benefit;

  /// No description provided for @exerciseChild5Title.
  ///
  /// In en, this message translates to:
  /// **'Eye Elevator'**
  String get exerciseChild5Title;

  /// No description provided for @exerciseChild5Desc.
  ///
  /// In en, this message translates to:
  /// **'The elevator is going up. ⬆️\nNow it\'s going down. ⬇️'**
  String get exerciseChild5Desc;

  /// No description provided for @exerciseChild5Benefit.
  ///
  /// In en, this message translates to:
  /// **'Improves vertical eye movements'**
  String get exerciseChild5Benefit;

  /// No description provided for @exerciseChild6Title.
  ///
  /// In en, this message translates to:
  /// **'Drawing Circles'**
  String get exerciseChild6Title;

  /// No description provided for @exerciseChild6Desc.
  ///
  /// In en, this message translates to:
  /// **'Draw a big circle with your eyes.\nNow the other way!'**
  String get exerciseChild6Desc;

  /// No description provided for @exerciseChild6Benefit.
  ///
  /// In en, this message translates to:
  /// **'Relaxes and soothes eye muscles'**
  String get exerciseChild6Benefit;

  /// No description provided for @exerciseChild7Title.
  ///
  /// In en, this message translates to:
  /// **'Turtle Rest'**
  String get exerciseChild7Title;

  /// No description provided for @exerciseChild7Desc.
  ///
  /// In en, this message translates to:
  /// **'Pull in like a turtle.\nClose your eyes and rest.'**
  String get exerciseChild7Desc;

  /// No description provided for @exerciseChild7Benefit.
  ///
  /// In en, this message translates to:
  /// **'Rests the eyes and reduces fatigue'**
  String get exerciseChild7Benefit;

  /// No description provided for @exerciseChild8Title.
  ///
  /// In en, this message translates to:
  /// **'Count Clouds'**
  String get exerciseChild8Title;

  /// No description provided for @exerciseChild8Desc.
  ///
  /// In en, this message translates to:
  /// **'Look at the ceiling.\nCount the clouds and breathe slowly.'**
  String get exerciseChild8Desc;

  /// No description provided for @exerciseChild8Benefit.
  ///
  /// In en, this message translates to:
  /// **'Improves focus on distant objects'**
  String get exerciseChild8Benefit;

  /// No description provided for @exerciseChild9Title.
  ///
  /// In en, this message translates to:
  /// **'Fast & Slow'**
  String get exerciseChild9Title;

  /// No description provided for @exerciseChild9Desc.
  ///
  /// In en, this message translates to:
  /// **'Blink five times fast. ⚡\nBlink five times slow. 🐢'**
  String get exerciseChild9Desc;

  /// No description provided for @exerciseChild9Benefit.
  ///
  /// In en, this message translates to:
  /// **'Regulates blinking reflex'**
  String get exerciseChild9Benefit;

  /// No description provided for @exerciseChild10Title.
  ///
  /// In en, this message translates to:
  /// **'Happy Eyes'**
  String get exerciseChild10Title;

  /// No description provided for @exerciseChild10Desc.
  ///
  /// In en, this message translates to:
  /// **'Close your eyes.\nSmile big. 😄'**
  String get exerciseChild10Desc;

  /// No description provided for @exerciseChild10Benefit.
  ///
  /// In en, this message translates to:
  /// **'Relaxes the eyes and gives a feeling of happiness'**
  String get exerciseChild10Benefit;

  /// No description provided for @exerciseAdult1Title.
  ///
  /// In en, this message translates to:
  /// **'Conscious Blinking'**
  String get exerciseAdult1Title;

  /// No description provided for @exerciseAdult1Desc.
  ///
  /// In en, this message translates to:
  /// **'Slowly close your eyes, wait one second, open. Repeat this five times.'**
  String get exerciseAdult1Desc;

  /// No description provided for @exerciseAdult1Benefit.
  ///
  /// In en, this message translates to:
  /// **'Moisturizes the eyes and prevents dryness'**
  String get exerciseAdult1Benefit;

  /// No description provided for @exerciseAdult3Title.
  ///
  /// In en, this message translates to:
  /// **'Near–Far Focus'**
  String get exerciseAdult3Title;

  /// No description provided for @exerciseAdult3Desc.
  ///
  /// In en, this message translates to:
  /// **'Look at your finger for ten seconds. Now look at a distant point for twenty seconds. Repeat this three times.'**
  String get exerciseAdult3Desc;

  /// No description provided for @exerciseAdult3Benefit.
  ///
  /// In en, this message translates to:
  /// **'Strengthens focus muscles, reduces near vision fatigue'**
  String get exerciseAdult3Benefit;

  /// No description provided for @exerciseAdult4Title.
  ///
  /// In en, this message translates to:
  /// **'Finger Tracking'**
  String get exerciseAdult4Title;

  /// No description provided for @exerciseAdult4Desc.
  ///
  /// In en, this message translates to:
  /// **'Slowly bring your index finger held at arm\'s length closer until it touches your nose. Slowly move it away. Do this ten times.'**
  String get exerciseAdult4Desc;

  /// No description provided for @exerciseAdult4Benefit.
  ///
  /// In en, this message translates to:
  /// **'Improves eye coordination, provides awareness of strabismus'**
  String get exerciseAdult4Benefit;

  /// No description provided for @exerciseAdult5Title.
  ///
  /// In en, this message translates to:
  /// **'Up–Down Scanning'**
  String get exerciseAdult5Title;

  /// No description provided for @exerciseAdult5Desc.
  ///
  /// In en, this message translates to:
  /// **'Just look up and down with your eyes. Repeat this ten times.'**
  String get exerciseAdult5Desc;

  /// No description provided for @exerciseAdult5Benefit.
  ///
  /// In en, this message translates to:
  /// **'Stretches eye muscles, increases vertical movement ability'**
  String get exerciseAdult5Benefit;

  /// No description provided for @exerciseAdult6Title.
  ///
  /// In en, this message translates to:
  /// **'Left–Right Scanning'**
  String get exerciseAdult6Title;

  /// No description provided for @exerciseAdult6Desc.
  ///
  /// In en, this message translates to:
  /// **'Keep your head still. Look left and right with your eyes, repeat this five times each.'**
  String get exerciseAdult6Desc;

  /// No description provided for @exerciseAdult6Benefit.
  ///
  /// In en, this message translates to:
  /// **'Improves horizontal eye movements, can increase reading speed'**
  String get exerciseAdult6Benefit;

  /// No description provided for @exerciseAdult7Title.
  ///
  /// In en, this message translates to:
  /// **'Circular Eye Movement'**
  String get exerciseAdult7Title;

  /// No description provided for @exerciseAdult7Desc.
  ///
  /// In en, this message translates to:
  /// **'Close your eyes. Draw a large circle clockwise, do this five times. Then draw in the opposite direction.'**
  String get exerciseAdult7Desc;

  /// No description provided for @exerciseAdult7Benefit.
  ///
  /// In en, this message translates to:
  /// **'Relaxes eye muscles, increases blood circulation'**
  String get exerciseAdult7Benefit;

  /// No description provided for @exerciseAdult8Title.
  ///
  /// In en, this message translates to:
  /// **'Imaginary Eight'**
  String get exerciseAdult8Title;

  /// No description provided for @exerciseAdult8Desc.
  ///
  /// In en, this message translates to:
  /// **'Close your eyes and slowly draw the infinity symbol.'**
  String get exerciseAdult8Desc;

  /// No description provided for @exerciseAdult8Benefit.
  ///
  /// In en, this message translates to:
  /// **'Improves eye coordination, strengthens eye muscles'**
  String get exerciseAdult8Benefit;

  /// No description provided for @exerciseAdult9Title.
  ///
  /// In en, this message translates to:
  /// **'Peripheral Vision Awareness'**
  String get exerciseAdult9Title;

  /// No description provided for @exerciseAdult9Desc.
  ///
  /// In en, this message translates to:
  /// **'Don\'t move your head.\nNotice the edges with your eyes.'**
  String get exerciseAdult9Desc;

  /// No description provided for @exerciseAdult9Benefit.
  ///
  /// In en, this message translates to:
  /// **'Develops peripheral vision, increases environmental awareness'**
  String get exerciseAdult9Benefit;

  /// No description provided for @exerciseAdult10Title.
  ///
  /// In en, this message translates to:
  /// **'Palming'**
  String get exerciseAdult10Title;

  /// No description provided for @exerciseAdult10Desc.
  ///
  /// In en, this message translates to:
  /// **'Warm your palms by rubbing them together and close your eyes without pressing. Do this for about a minute.'**
  String get exerciseAdult10Desc;

  /// No description provided for @exerciseAdult10Benefit.
  ///
  /// In en, this message translates to:
  /// **'Deeply rests the eyes, reduces eye fatigue'**
  String get exerciseAdult10Benefit;

  /// No description provided for @exerciseAdult11Title.
  ///
  /// In en, this message translates to:
  /// **'Eyes Closed Breathing'**
  String get exerciseAdult11Title;

  /// No description provided for @exerciseAdult11Desc.
  ///
  /// In en, this message translates to:
  /// **'Close your eyes.\nTake three deep breaths.\nTry not to think about anything.'**
  String get exerciseAdult11Desc;

  /// No description provided for @exerciseAdult11Benefit.
  ///
  /// In en, this message translates to:
  /// **'Calms the mind, relaxes eye muscles'**
  String get exerciseAdult11Benefit;

  /// No description provided for @exerciseAdult12Title.
  ///
  /// In en, this message translates to:
  /// **'Neck–Eye Reset'**
  String get exerciseAdult12Title;

  /// No description provided for @exerciseAdult12Desc.
  ///
  /// In en, this message translates to:
  /// **'Drop your shoulders.\nClose your eyes.\nMassage your temples with your index fingers.\nContinue until you feel relaxed.'**
  String get exerciseAdult12Desc;

  /// No description provided for @exerciseAdult12Benefit.
  ///
  /// In en, this message translates to:
  /// **'Relieves headaches, reduces neck and eye tension'**
  String get exerciseAdult12Benefit;

  /// No description provided for @exerciseOffice1Title.
  ///
  /// In en, this message translates to:
  /// **'20-20-20 Rule'**
  String get exerciseOffice1Title;

  /// No description provided for @exerciseOffice1Desc.
  ///
  /// In en, this message translates to:
  /// **'Every 20 minutes\nLook away for 20 seconds'**
  String get exerciseOffice1Desc;

  /// No description provided for @exerciseOffice1Benefit.
  ///
  /// In en, this message translates to:
  /// **'Prevents screen fatigue, relaxes eye muscles'**
  String get exerciseOffice1Benefit;

  /// No description provided for @exerciseOffice2Title.
  ///
  /// In en, this message translates to:
  /// **'Blinking'**
  String get exerciseOffice2Title;

  /// No description provided for @exerciseOffice2Desc.
  ///
  /// In en, this message translates to:
  /// **'Blinking decreases while looking at screen\nBlink consciously'**
  String get exerciseOffice2Desc;

  /// No description provided for @exerciseOffice2Benefit.
  ///
  /// In en, this message translates to:
  /// **'Prevents eye dryness, moisturizes the eyes'**
  String get exerciseOffice2Benefit;

  /// No description provided for @exerciseOffice3Title.
  ///
  /// In en, this message translates to:
  /// **'Eye Exercise'**
  String get exerciseOffice3Title;

  /// No description provided for @exerciseOffice3Desc.
  ///
  /// In en, this message translates to:
  /// **'Move away from screen\nDraw an eight with your eyes'**
  String get exerciseOffice3Desc;

  /// No description provided for @exerciseOffice3Benefit.
  ///
  /// In en, this message translates to:
  /// **'Improves eye coordination, reduces fatigue'**
  String get exerciseOffice3Benefit;

  /// No description provided for @exerciseOffice4Title.
  ///
  /// In en, this message translates to:
  /// **'Horizontal Gaze'**
  String get exerciseOffice4Title;

  /// No description provided for @exerciseOffice4Desc.
  ///
  /// In en, this message translates to:
  /// **'Take your eyes off the screen\nLook left and right'**
  String get exerciseOffice4Desc;

  /// No description provided for @exerciseOffice4Benefit.
  ///
  /// In en, this message translates to:
  /// **'Improves horizontal eye movements'**
  String get exerciseOffice4Benefit;

  /// No description provided for @exerciseOffice5Title.
  ///
  /// In en, this message translates to:
  /// **'Vertical Gaze'**
  String get exerciseOffice5Title;

  /// No description provided for @exerciseOffice5Desc.
  ///
  /// In en, this message translates to:
  /// **'Move your eyes up and down\nReduces screen fatigue'**
  String get exerciseOffice5Desc;

  /// No description provided for @exerciseOffice5Benefit.
  ///
  /// In en, this message translates to:
  /// **'Improves vertical eye movements, reduces screen fatigue'**
  String get exerciseOffice5Benefit;

  /// No description provided for @exerciseOffice6Title.
  ///
  /// In en, this message translates to:
  /// **'Circular Movement'**
  String get exerciseOffice6Title;

  /// No description provided for @exerciseOffice6Desc.
  ///
  /// In en, this message translates to:
  /// **'Draw circles with your eyes\nIncreases blood circulation'**
  String get exerciseOffice6Desc;

  /// No description provided for @exerciseOffice6Benefit.
  ///
  /// In en, this message translates to:
  /// **'Relaxes eye muscles, increases blood circulation'**
  String get exerciseOffice6Benefit;

  /// No description provided for @exerciseOffice7Title.
  ///
  /// In en, this message translates to:
  /// **'Palming'**
  String get exerciseOffice7Title;

  /// No description provided for @exerciseOffice7Desc.
  ///
  /// In en, this message translates to:
  /// **'Close your eyes\nCover with your palms and rest'**
  String get exerciseOffice7Desc;

  /// No description provided for @exerciseOffice7Benefit.
  ///
  /// In en, this message translates to:
  /// **'Deeply rests the eyes'**
  String get exerciseOffice7Benefit;

  /// No description provided for @exerciseOffice8Title.
  ///
  /// In en, this message translates to:
  /// **'Distant Gaze'**
  String get exerciseOffice8Title;

  /// No description provided for @exerciseOffice8Desc.
  ///
  /// In en, this message translates to:
  /// **'Look out the window\nFocus on distant objects'**
  String get exerciseOffice8Desc;

  /// No description provided for @exerciseOffice8Benefit.
  ///
  /// In en, this message translates to:
  /// **'Improves focus on distant objects'**
  String get exerciseOffice8Benefit;

  /// No description provided for @exerciseOffice9Title.
  ///
  /// In en, this message translates to:
  /// **'Fast Blinking'**
  String get exerciseOffice9Title;

  /// No description provided for @exerciseOffice9Desc.
  ///
  /// In en, this message translates to:
  /// **'Moisturize your eyes\nBlink quickly'**
  String get exerciseOffice9Desc;

  /// No description provided for @exerciseOffice9Benefit.
  ///
  /// In en, this message translates to:
  /// **'Quickly moisturizes the eyes'**
  String get exerciseOffice9Benefit;

  /// No description provided for @exerciseOffice10Title.
  ///
  /// In en, this message translates to:
  /// **'Eye Massage'**
  String get exerciseOffice10Title;

  /// No description provided for @exerciseOffice10Desc.
  ///
  /// In en, this message translates to:
  /// **'Close your eyes\nRelax and breathe'**
  String get exerciseOffice10Desc;

  /// No description provided for @exerciseOffice10Benefit.
  ///
  /// In en, this message translates to:
  /// **'Relaxes the eyes and reduces stress'**
  String get exerciseOffice10Benefit;

  /// No description provided for @repetitionText.
  ///
  /// In en, this message translates to:
  /// **'repetitions'**
  String get repetitionText;

  /// No description provided for @secondText.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get secondText;

  /// No description provided for @remainingText.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remainingText;

  /// No description provided for @resultStatusPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect Vision'**
  String get resultStatusPerfect;

  /// No description provided for @resultStatusVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Very Good Vision'**
  String get resultStatusVeryGood;

  /// No description provided for @resultStatusGood.
  ///
  /// In en, this message translates to:
  /// **'Good Vision'**
  String get resultStatusGood;

  /// No description provided for @resultStatusSeeDoctor.
  ///
  /// In en, this message translates to:
  /// **'See an Eye Doctor'**
  String get resultStatusSeeDoctor;

  /// No description provided for @resultStatusNeedGlasses.
  ///
  /// In en, this message translates to:
  /// **'Glasses/Lenses Required'**
  String get resultStatusNeedGlasses;

  /// No description provided for @resultStatusUrgent.
  ///
  /// In en, this message translates to:
  /// **'Schedule Appointment Immediately'**
  String get resultStatusUrgent;

  /// No description provided for @resultStatusColorPassed.
  ///
  /// In en, this message translates to:
  /// **'Test Passed Successfully'**
  String get resultStatusColorPassed;

  /// No description provided for @resultStatusColorSuspicion.
  ///
  /// In en, this message translates to:
  /// **'Color Blindness Suspicion'**
  String get resultStatusColorSuspicion;

  /// No description provided for @resultRecommendationGeneral.
  ///
  /// In en, this message translates to:
  /// **'These results are for informational purposes only. Please consult an eye doctor for a definitive diagnosis.'**
  String get resultRecommendationGeneral;

  /// No description provided for @resultRecommendationColorNormal.
  ///
  /// In en, this message translates to:
  /// **'Your color vision appears normal. Consult your eye doctor for regular checkups.'**
  String get resultRecommendationColorNormal;

  /// No description provided for @resultRecommendationColorSuspicion.
  ///
  /// In en, this message translates to:
  /// **'There is a suspicion of color blindness. Please see your doctor.'**
  String get resultRecommendationColorSuspicion;

  /// No description provided for @resultSubtitleVisualAcuity.
  ///
  /// In en, this message translates to:
  /// **'Visual Acuity Analysis'**
  String get resultSubtitleVisualAcuity;

  /// No description provided for @resultSubtitleColorVision.
  ///
  /// In en, this message translates to:
  /// **'Color Blindness Test Result'**
  String get resultSubtitleColorVision;

  /// No description provided for @resultSubtitleGeneral.
  ///
  /// In en, this message translates to:
  /// **'Test Result'**
  String get resultSubtitleGeneral;

  /// No description provided for @resultImportantWarning.
  ///
  /// In en, this message translates to:
  /// **'Important Warning'**
  String get resultImportantWarning;

  /// No description provided for @resultRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get resultRecommendation;

  /// No description provided for @resultDetailedAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Detailed Analysis'**
  String get resultDetailedAnalysis;

  /// No description provided for @resultViewDetailedAnalysis.
  ///
  /// In en, this message translates to:
  /// **'View Detailed Analysis'**
  String get resultViewDetailedAnalysis;

  /// No description provided for @resultDetailedAnalysisLocked.
  ///
  /// In en, this message translates to:
  /// **'To view detailed analysis'**
  String get resultDetailedAnalysisLocked;

  /// No description provided for @resultWatchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad'**
  String get resultWatchAd;

  /// No description provided for @resultHomeMenu.
  ///
  /// In en, this message translates to:
  /// **'Home Menu'**
  String get resultHomeMenu;

  /// No description provided for @resultComparisonPrevious.
  ///
  /// In en, this message translates to:
  /// **'Comparison with Previous Test'**
  String get resultComparisonPrevious;

  /// No description provided for @resultComparisonText.
  ///
  /// In en, this message translates to:
  /// **'Previous: %{previous} → Now: %{current} ({difference}%)'**
  String resultComparisonText(int previous, int current, String difference);

  /// No description provided for @resultAverageLast7.
  ///
  /// In en, this message translates to:
  /// **'Average of Last 7 Tests'**
  String get resultAverageLast7;

  /// No description provided for @resultDetailedRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Detailed Recommendations'**
  String get resultDetailedRecommendations;

  /// No description provided for @resultDetailedColorPerfect.
  ///
  /// In en, this message translates to:
  /// **'You have excellent color vision. You can maintain this condition with regular checkups.'**
  String get resultDetailedColorPerfect;

  /// No description provided for @resultDetailedColorNormal.
  ///
  /// In en, this message translates to:
  /// **'Your color vision is at a normal level. However, if you have difficulty distinguishing some colors, it is recommended that you consult an eye doctor.'**
  String get resultDetailedColorNormal;

  /// No description provided for @resultDetailedColorDeficiency.
  ///
  /// In en, this message translates to:
  /// **'There may be a deficiency in color vision. Be sure to consult an eye doctor and have a detailed examination.'**
  String get resultDetailedColorDeficiency;

  /// No description provided for @resultDetailedAcuityVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Your visual acuity is at a very good level. You can maintain this condition with regular eye examinations.'**
  String get resultDetailedAcuityVeryGood;

  /// No description provided for @resultDetailedAcuityModerate.
  ///
  /// In en, this message translates to:
  /// **'Your visual acuity is at a moderate level. It is recommended that you consult an eye doctor for a more detailed evaluation.'**
  String get resultDetailedAcuityModerate;

  /// No description provided for @resultDetailedAcuityLow.
  ///
  /// In en, this message translates to:
  /// **'Your visual acuity is at a low level. You need to urgently consult an eye doctor and have an examination.'**
  String get resultDetailedAcuityLow;

  /// No description provided for @resultCorrectAnswers.
  ///
  /// In en, this message translates to:
  /// **'{correct} / {total} Correct'**
  String resultCorrectAnswers(int correct, int total);

  /// No description provided for @resultSnellen.
  ///
  /// In en, this message translates to:
  /// **'Snellen: {value}'**
  String resultSnellen(String value);

  /// No description provided for @detailedAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Detailed Analysis'**
  String get detailedAnalysisTitle;

  /// No description provided for @detailedAnalysisResult.
  ///
  /// In en, this message translates to:
  /// **'Result: %{percentage}'**
  String detailedAnalysisResult(int percentage);

  /// No description provided for @detailedAnalysisCurrentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get detailedAnalysisCurrentStatus;

  /// No description provided for @detailedAnalysisPossibleProblems.
  ///
  /// In en, this message translates to:
  /// **'Possible Problems'**
  String get detailedAnalysisPossibleProblems;

  /// No description provided for @detailedAnalysisPossibleConsequences.
  ///
  /// In en, this message translates to:
  /// **'Possible Consequences and Effects'**
  String get detailedAnalysisPossibleConsequences;

  /// No description provided for @detailedAnalysisTreatmentOptions.
  ///
  /// In en, this message translates to:
  /// **'Treatment and Solution Recommendations'**
  String get detailedAnalysisTreatmentOptions;

  /// No description provided for @detailedAnalysisManagement.
  ///
  /// In en, this message translates to:
  /// **'Management and Support'**
  String get detailedAnalysisManagement;

  /// No description provided for @detailedAnalysisRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get detailedAnalysisRecommendations;

  /// No description provided for @detailedAnalysisWarning.
  ///
  /// In en, this message translates to:
  /// **'Important Warning'**
  String get detailedAnalysisWarning;

  /// No description provided for @detailedAnalysisWarningText.
  ///
  /// In en, this message translates to:
  /// **'These results are for informational purposes only and do not replace a definitive diagnosis. If you are experiencing any vision problems, be sure to consult an eye doctor.'**
  String get detailedAnalysisWarningText;

  /// No description provided for @detailedAnalysisDailyLife.
  ///
  /// In en, this message translates to:
  /// **'Daily Life'**
  String get detailedAnalysisDailyLife;

  /// No description provided for @detailedAnalysisWorkLife.
  ///
  /// In en, this message translates to:
  /// **'Work Life'**
  String get detailedAnalysisWorkLife;

  /// No description provided for @detailedAnalysisHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get detailedAnalysisHealth;

  /// No description provided for @detailedAnalysisEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get detailedAnalysisEducation;

  /// No description provided for @detailedAnalysisVisualAcuityAssessment.
  ///
  /// In en, this message translates to:
  /// **'Visual Acuity Assessment'**
  String get detailedAnalysisVisualAcuityAssessment;

  /// No description provided for @detailedAnalysisVisualAcuityStatus.
  ///
  /// In en, this message translates to:
  /// **'Your visual acuity is at {percentage}%. This value is evaluated in the {severity} category.'**
  String detailedAnalysisVisualAcuityStatus(int percentage, String severity);

  /// No description provided for @detailedAnalysisSeverityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get detailedAnalysisSeverityNormal;

  /// No description provided for @detailedAnalysisSeverityMild.
  ///
  /// In en, this message translates to:
  /// **'Mild Low'**
  String get detailedAnalysisSeverityMild;

  /// No description provided for @detailedAnalysisSeverityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate Low'**
  String get detailedAnalysisSeverityModerate;

  /// No description provided for @detailedAnalysisSeveritySevere.
  ///
  /// In en, this message translates to:
  /// **'Severe Low'**
  String get detailedAnalysisSeveritySevere;

  /// No description provided for @detailedAnalysisMyopia.
  ///
  /// In en, this message translates to:
  /// **'Myopia (Cannot See Far)'**
  String get detailedAnalysisMyopia;

  /// No description provided for @detailedAnalysisMyopiaDesc.
  ///
  /// In en, this message translates to:
  /// **'The condition of not being able to see distant objects clearly. It is usually caused by the eyeball being longer than normal or the cornea being too curved.'**
  String get detailedAnalysisMyopiaDesc;

  /// No description provided for @detailedAnalysisMyopiaSymptom1.
  ///
  /// In en, this message translates to:
  /// **'Blurred vision of distant objects'**
  String get detailedAnalysisMyopiaSymptom1;

  /// No description provided for @detailedAnalysisMyopiaSymptom2.
  ///
  /// In en, this message translates to:
  /// **'Squinting'**
  String get detailedAnalysisMyopiaSymptom2;

  /// No description provided for @detailedAnalysisMyopiaSymptom3.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get detailedAnalysisMyopiaSymptom3;

  /// No description provided for @detailedAnalysisMyopiaSymptom4.
  ///
  /// In en, this message translates to:
  /// **'Eye strain'**
  String get detailedAnalysisMyopiaSymptom4;

  /// No description provided for @detailedAnalysisHypermetropia.
  ///
  /// In en, this message translates to:
  /// **'Hypermetropia (Cannot See Near)'**
  String get detailedAnalysisHypermetropia;

  /// No description provided for @detailedAnalysisHypermetropiaDesc.
  ///
  /// In en, this message translates to:
  /// **'The condition of not being able to see close objects clearly. It is caused by the eyeball being shorter than normal or the cornea being flat.'**
  String get detailedAnalysisHypermetropiaDesc;

  /// No description provided for @detailedAnalysisHypermetropiaSymptom1.
  ///
  /// In en, this message translates to:
  /// **'Blurred vision of close objects'**
  String get detailedAnalysisHypermetropiaSymptom1;

  /// No description provided for @detailedAnalysisHypermetropiaSymptom2.
  ///
  /// In en, this message translates to:
  /// **'Reading difficulty'**
  String get detailedAnalysisHypermetropiaSymptom2;

  /// No description provided for @detailedAnalysisHypermetropiaSymptom3.
  ///
  /// In en, this message translates to:
  /// **'Eye strain'**
  String get detailedAnalysisHypermetropiaSymptom3;

  /// No description provided for @detailedAnalysisHypermetropiaSymptom4.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get detailedAnalysisHypermetropiaSymptom4;

  /// No description provided for @detailedAnalysisPresbyopia.
  ///
  /// In en, this message translates to:
  /// **'Presbyopia (Age-Related Near Vision Problem)'**
  String get detailedAnalysisPresbyopia;

  /// No description provided for @detailedAnalysisPresbyopiaDesc.
  ///
  /// In en, this message translates to:
  /// **'Decrease in near vision ability after age 40. It is caused by the loss of flexibility of the eye lens.'**
  String get detailedAnalysisPresbyopiaDesc;

  /// No description provided for @detailedAnalysisPresbyopiaSymptom1.
  ///
  /// In en, this message translates to:
  /// **'Near reading difficulty'**
  String get detailedAnalysisPresbyopiaSymptom1;

  /// No description provided for @detailedAnalysisPresbyopiaSymptom2.
  ///
  /// In en, this message translates to:
  /// **'Reading with arms extended'**
  String get detailedAnalysisPresbyopiaSymptom2;

  /// No description provided for @detailedAnalysisPresbyopiaSymptom3.
  ///
  /// In en, this message translates to:
  /// **'Need for light'**
  String get detailedAnalysisPresbyopiaSymptom3;

  /// No description provided for @detailedAnalysisDailyLifeConsequence1.
  ///
  /// In en, this message translates to:
  /// **'Difficulty while driving'**
  String get detailedAnalysisDailyLifeConsequence1;

  /// No description provided for @detailedAnalysisDailyLifeConsequence2.
  ///
  /// In en, this message translates to:
  /// **'Reading and writing problems'**
  String get detailedAnalysisDailyLifeConsequence2;

  /// No description provided for @detailedAnalysisDailyLifeConsequence3.
  ///
  /// In en, this message translates to:
  /// **'Fatigue when using screens'**
  String get detailedAnalysisDailyLifeConsequence3;

  /// No description provided for @detailedAnalysisDailyLifeConsequence4.
  ///
  /// In en, this message translates to:
  /// **'Difficulty in social activities'**
  String get detailedAnalysisDailyLifeConsequence4;

  /// No description provided for @detailedAnalysisWorkLifeConsequence1.
  ///
  /// In en, this message translates to:
  /// **'Difficulty using computers'**
  String get detailedAnalysisWorkLifeConsequence1;

  /// No description provided for @detailedAnalysisWorkLifeConsequence2.
  ///
  /// In en, this message translates to:
  /// **'Risk of errors in detailed work'**
  String get detailedAnalysisWorkLifeConsequence2;

  /// No description provided for @detailedAnalysisWorkLifeConsequence3.
  ///
  /// In en, this message translates to:
  /// **'Productivity loss'**
  String get detailedAnalysisWorkLifeConsequence3;

  /// No description provided for @detailedAnalysisWorkLifeConsequence4.
  ///
  /// In en, this message translates to:
  /// **'Eye strain'**
  String get detailedAnalysisWorkLifeConsequence4;

  /// No description provided for @detailedAnalysisHealthConsequence1.
  ///
  /// In en, this message translates to:
  /// **'Chronic headaches'**
  String get detailedAnalysisHealthConsequence1;

  /// No description provided for @detailedAnalysisHealthConsequence2.
  ///
  /// In en, this message translates to:
  /// **'Eye strain'**
  String get detailedAnalysisHealthConsequence2;

  /// No description provided for @detailedAnalysisHealthConsequence3.
  ///
  /// In en, this message translates to:
  /// **'Dry eyes'**
  String get detailedAnalysisHealthConsequence3;

  /// No description provided for @detailedAnalysisHealthConsequence4.
  ///
  /// In en, this message translates to:
  /// **'Risk of strabismus (in children)'**
  String get detailedAnalysisHealthConsequence4;

  /// No description provided for @detailedAnalysisSolutionGlasses.
  ///
  /// In en, this message translates to:
  /// **'Glasses Use'**
  String get detailedAnalysisSolutionGlasses;

  /// No description provided for @detailedAnalysisSolutionGlassesDesc.
  ///
  /// In en, this message translates to:
  /// **'The most common and effective solution. Use the glasses prescribed by your eye doctor regularly.'**
  String get detailedAnalysisSolutionGlassesDesc;

  /// No description provided for @detailedAnalysisSolutionContacts.
  ///
  /// In en, this message translates to:
  /// **'Contact Lenses'**
  String get detailedAnalysisSolutionContacts;

  /// No description provided for @detailedAnalysisSolutionContactsDesc.
  ///
  /// In en, this message translates to:
  /// **'Alternative for those who do not want to wear glasses. Can be used with your eye doctor\'s recommendation.'**
  String get detailedAnalysisSolutionContactsDesc;

  /// No description provided for @detailedAnalysisSolutionLaser.
  ///
  /// In en, this message translates to:
  /// **'Laser Surgery'**
  String get detailedAnalysisSolutionLaser;

  /// No description provided for @detailedAnalysisSolutionLaserDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanent solution for suitable candidates. Your doctor will decide after a detailed examination.'**
  String get detailedAnalysisSolutionLaserDesc;

  /// No description provided for @detailedAnalysisSolutionExercises.
  ///
  /// In en, this message translates to:
  /// **'Eye Exercises'**
  String get detailedAnalysisSolutionExercises;

  /// No description provided for @detailedAnalysisSolutionExercisesDesc.
  ///
  /// In en, this message translates to:
  /// **'In some cases, it can improve vision quality by strengthening eye muscles.'**
  String get detailedAnalysisSolutionExercisesDesc;

  /// No description provided for @detailedAnalysisColorVisionAssessment.
  ///
  /// In en, this message translates to:
  /// **'Color Vision Assessment'**
  String get detailedAnalysisColorVisionAssessment;

  /// No description provided for @detailedAnalysisColorVisionNormal.
  ///
  /// In en, this message translates to:
  /// **'Your color vision is at a normal level. You can distinguish all colors correctly.'**
  String get detailedAnalysisColorVisionNormal;

  /// No description provided for @detailedAnalysisColorVisionDeficiency.
  ///
  /// In en, this message translates to:
  /// **'A deficiency in your color vision has been detected. This condition is evaluated as {severity} level color blindness.'**
  String detailedAnalysisColorVisionDeficiency(String severity);

  /// No description provided for @detailedAnalysisSeverityMildShort.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get detailedAnalysisSeverityMildShort;

  /// No description provided for @detailedAnalysisSeverityModerateShort.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get detailedAnalysisSeverityModerateShort;

  /// No description provided for @detailedAnalysisSeveritySevereShort.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get detailedAnalysisSeveritySevereShort;

  /// No description provided for @detailedAnalysisColorBlindnessTypes.
  ///
  /// In en, this message translates to:
  /// **'Types of Color Blindness'**
  String get detailedAnalysisColorBlindnessTypes;

  /// No description provided for @detailedAnalysisDeuteranopia.
  ///
  /// In en, this message translates to:
  /// **'Deuteranopia (Green Color Blindness)'**
  String get detailedAnalysisDeuteranopia;

  /// No description provided for @detailedAnalysisDeuteranopiaDesc.
  ///
  /// In en, this message translates to:
  /// **'The condition of not being able to distinguish green colors. It is the most common type of color blindness.'**
  String get detailedAnalysisDeuteranopiaDesc;

  /// No description provided for @detailedAnalysisDeuteranopiaSymptom.
  ///
  /// In en, this message translates to:
  /// **'Inability to distinguish green and red tones'**
  String get detailedAnalysisDeuteranopiaSymptom;

  /// No description provided for @detailedAnalysisProtanopia.
  ///
  /// In en, this message translates to:
  /// **'Protanopia (Red Color Blindness)'**
  String get detailedAnalysisProtanopia;

  /// No description provided for @detailedAnalysisProtanopiaDesc.
  ///
  /// In en, this message translates to:
  /// **'The condition of not being able to distinguish red colors. It is the second most common type.'**
  String get detailedAnalysisProtanopiaDesc;

  /// No description provided for @detailedAnalysisProtanopiaSymptom.
  ///
  /// In en, this message translates to:
  /// **'Inability to distinguish red and green tones'**
  String get detailedAnalysisProtanopiaSymptom;

  /// No description provided for @detailedAnalysisTritanopia.
  ///
  /// In en, this message translates to:
  /// **'Tritanopia (Blue-Yellow Color Blindness)'**
  String get detailedAnalysisTritanopia;

  /// No description provided for @detailedAnalysisTritanopiaDesc.
  ///
  /// In en, this message translates to:
  /// **'The condition of not being able to distinguish blue and yellow colors. It is rarer.'**
  String get detailedAnalysisTritanopiaDesc;

  /// No description provided for @detailedAnalysisTritanopiaSymptom.
  ///
  /// In en, this message translates to:
  /// **'Inability to distinguish blue and yellow tones'**
  String get detailedAnalysisTritanopiaSymptom;

  /// No description provided for @detailedAnalysisAchromatopsia.
  ///
  /// In en, this message translates to:
  /// **'Achromatopsia (Complete Color Blindness)'**
  String get detailedAnalysisAchromatopsia;

  /// No description provided for @detailedAnalysisAchromatopsiaDesc.
  ///
  /// In en, this message translates to:
  /// **'The condition of not being able to see all colors. It is very rare, only black and white vision exists.'**
  String get detailedAnalysisAchromatopsiaDesc;

  /// No description provided for @detailedAnalysisAchromatopsiaSymptom.
  ///
  /// In en, this message translates to:
  /// **'Seeing only black, white and gray tones'**
  String get detailedAnalysisAchromatopsiaSymptom;

  /// No description provided for @detailedAnalysisColorDailyLife1.
  ///
  /// In en, this message translates to:
  /// **'Difficulty distinguishing traffic lights'**
  String get detailedAnalysisColorDailyLife1;

  /// No description provided for @detailedAnalysisColorDailyLife2.
  ///
  /// In en, this message translates to:
  /// **'Difficulty choosing colored clothing'**
  String get detailedAnalysisColorDailyLife2;

  /// No description provided for @detailedAnalysisColorDailyLife3.
  ///
  /// In en, this message translates to:
  /// **'Cooking and ripeness checking'**
  String get detailedAnalysisColorDailyLife3;

  /// No description provided for @detailedAnalysisColorDailyLife4.
  ///
  /// In en, this message translates to:
  /// **'Difficulty on nature walks'**
  String get detailedAnalysisColorDailyLife4;

  /// No description provided for @detailedAnalysisColorWorkLife1.
  ///
  /// In en, this message translates to:
  /// **'Difficulty in graphic design and art fields'**
  String get detailedAnalysisColorWorkLife1;

  /// No description provided for @detailedAnalysisColorWorkLife2.
  ///
  /// In en, this message translates to:
  /// **'Risk in electrical and electronic work'**
  String get detailedAnalysisColorWorkLife2;

  /// No description provided for @detailedAnalysisColorWorkLife3.
  ///
  /// In en, this message translates to:
  /// **'Limitations in medical and laboratory work'**
  String get detailedAnalysisColorWorkLife3;

  /// No description provided for @detailedAnalysisColorWorkLife4.
  ///
  /// In en, this message translates to:
  /// **'Restrictions in aviation and maritime professions'**
  String get detailedAnalysisColorWorkLife4;

  /// No description provided for @detailedAnalysisColorEducation1.
  ///
  /// In en, this message translates to:
  /// **'Difficulty understanding color materials'**
  String get detailedAnalysisColorEducation1;

  /// No description provided for @detailedAnalysisColorEducation2.
  ///
  /// In en, this message translates to:
  /// **'Deficiency in visual learning'**
  String get detailedAnalysisColorEducation2;

  /// No description provided for @detailedAnalysisColorEducation3.
  ///
  /// In en, this message translates to:
  /// **'Difficulty in some subjects'**
  String get detailedAnalysisColorEducation3;

  /// No description provided for @detailedAnalysisColorSolutionApps.
  ///
  /// In en, this message translates to:
  /// **'Color Identification Apps'**
  String get detailedAnalysisColorSolutionApps;

  /// No description provided for @detailedAnalysisColorSolutionAppsDesc.
  ///
  /// In en, this message translates to:
  /// **'You can identify colors with smartphone applications.'**
  String get detailedAnalysisColorSolutionAppsDesc;

  /// No description provided for @detailedAnalysisColorSolutionGlasses.
  ///
  /// In en, this message translates to:
  /// **'Special Glasses'**
  String get detailedAnalysisColorSolutionGlasses;

  /// No description provided for @detailedAnalysisColorSolutionGlassesDesc.
  ///
  /// In en, this message translates to:
  /// **'Some special glasses can improve color perception. Consult your eye doctor.'**
  String get detailedAnalysisColorSolutionGlassesDesc;

  /// No description provided for @detailedAnalysisColorSolutionCareer.
  ///
  /// In en, this message translates to:
  /// **'Career Counseling'**
  String get detailedAnalysisColorSolutionCareer;

  /// No description provided for @detailedAnalysisColorSolutionCareerDesc.
  ///
  /// In en, this message translates to:
  /// **'Consider color blindness in career choice.'**
  String get detailedAnalysisColorSolutionCareerDesc;

  /// No description provided for @detailedAnalysisColorImportantNote.
  ///
  /// In en, this message translates to:
  /// **'Important Note'**
  String get detailedAnalysisColorImportantNote;

  /// No description provided for @detailedAnalysisColorImportantNoteText.
  ///
  /// In en, this message translates to:
  /// **'Color blindness is usually hereditary and has no complete cure. However, quality of life can be improved with special glasses and applications.'**
  String get detailedAnalysisColorImportantNoteText;

  /// No description provided for @detailedAnalysisAstigmatismAssessment.
  ///
  /// In en, this message translates to:
  /// **'Astigmatism Assessment'**
  String get detailedAnalysisAstigmatismAssessment;

  /// No description provided for @detailedAnalysisAstigmatismNormal.
  ///
  /// In en, this message translates to:
  /// **'Astigmatism findings are minimal. You are at a normal vision level.'**
  String get detailedAnalysisAstigmatismNormal;

  /// No description provided for @detailedAnalysisAstigmatismDetected.
  ///
  /// In en, this message translates to:
  /// **'Astigmatism has been detected. The image is not clear due to the irregular shape of the cornea or lens.'**
  String get detailedAnalysisAstigmatismDetected;

  /// No description provided for @detailedAnalysisAstigmatismTypes.
  ///
  /// In en, this message translates to:
  /// **'Types of Astigmatism'**
  String get detailedAnalysisAstigmatismTypes;

  /// No description provided for @detailedAnalysisCornealAstigmatism.
  ///
  /// In en, this message translates to:
  /// **'Corneal Astigmatism'**
  String get detailedAnalysisCornealAstigmatism;

  /// No description provided for @detailedAnalysisCornealAstigmatismDesc.
  ///
  /// In en, this message translates to:
  /// **'Caused by the irregular shape of the cornea. It is the most common type.'**
  String get detailedAnalysisCornealAstigmatismDesc;

  /// No description provided for @detailedAnalysisCornealAstigmatismSymptom1.
  ///
  /// In en, this message translates to:
  /// **'Blurred vision at all distances'**
  String get detailedAnalysisCornealAstigmatismSymptom1;

  /// No description provided for @detailedAnalysisCornealAstigmatismSymptom2.
  ///
  /// In en, this message translates to:
  /// **'Lines appearing curved'**
  String get detailedAnalysisCornealAstigmatismSymptom2;

  /// No description provided for @detailedAnalysisCornealAstigmatismSymptom3.
  ///
  /// In en, this message translates to:
  /// **'Eye strain'**
  String get detailedAnalysisCornealAstigmatismSymptom3;

  /// No description provided for @detailedAnalysisLenticularAstigmatism.
  ///
  /// In en, this message translates to:
  /// **'Lenticular Astigmatism'**
  String get detailedAnalysisLenticularAstigmatism;

  /// No description provided for @detailedAnalysisLenticularAstigmatismDesc.
  ///
  /// In en, this message translates to:
  /// **'Caused by the irregular shape of the eye lens.'**
  String get detailedAnalysisLenticularAstigmatismDesc;

  /// No description provided for @detailedAnalysisLenticularAstigmatismSymptom1.
  ///
  /// In en, this message translates to:
  /// **'Near and far vision problems'**
  String get detailedAnalysisLenticularAstigmatismSymptom1;

  /// No description provided for @detailedAnalysisLenticularAstigmatismSymptom2.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get detailedAnalysisLenticularAstigmatismSymptom2;

  /// No description provided for @detailedAnalysisLenticularAstigmatismSymptom3.
  ///
  /// In en, this message translates to:
  /// **'Eye strain'**
  String get detailedAnalysisLenticularAstigmatismSymptom3;

  /// No description provided for @detailedAnalysisAstigmatismConsequences.
  ///
  /// In en, this message translates to:
  /// **'Possible Consequences'**
  String get detailedAnalysisAstigmatismConsequences;

  /// No description provided for @detailedAnalysisAstigmatismVisionQuality.
  ///
  /// In en, this message translates to:
  /// **'Vision Quality'**
  String get detailedAnalysisAstigmatismVisionQuality;

  /// No description provided for @detailedAnalysisAstigmatismVisionQuality1.
  ///
  /// In en, this message translates to:
  /// **'Blurred vision at all distances'**
  String get detailedAnalysisAstigmatismVisionQuality1;

  /// No description provided for @detailedAnalysisAstigmatismVisionQuality2.
  ///
  /// In en, this message translates to:
  /// **'Lines appearing curved'**
  String get detailedAnalysisAstigmatismVisionQuality2;

  /// No description provided for @detailedAnalysisAstigmatismVisionQuality3.
  ///
  /// In en, this message translates to:
  /// **'Seeing light halos'**
  String get detailedAnalysisAstigmatismVisionQuality3;

  /// No description provided for @detailedAnalysisAstigmatismVisionQuality4.
  ///
  /// In en, this message translates to:
  /// **'Difficulty with night vision'**
  String get detailedAnalysisAstigmatismVisionQuality4;

  /// No description provided for @detailedAnalysisAstigmatismDailyLife1.
  ///
  /// In en, this message translates to:
  /// **'Reading difficulty'**
  String get detailedAnalysisAstigmatismDailyLife1;

  /// No description provided for @detailedAnalysisAstigmatismDailyLife2.
  ///
  /// In en, this message translates to:
  /// **'Fatigue when using computers'**
  String get detailedAnalysisAstigmatismDailyLife2;

  /// No description provided for @detailedAnalysisAstigmatismDailyLife3.
  ///
  /// In en, this message translates to:
  /// **'Difficulty while driving'**
  String get detailedAnalysisAstigmatismDailyLife3;

  /// No description provided for @detailedAnalysisAstigmatismDailyLife4.
  ///
  /// In en, this message translates to:
  /// **'Headaches'**
  String get detailedAnalysisAstigmatismDailyLife4;

  /// No description provided for @detailedAnalysisAstigmatismSolutionCylindrical.
  ///
  /// In en, this message translates to:
  /// **'Cylindrical Glasses'**
  String get detailedAnalysisAstigmatismSolutionCylindrical;

  /// No description provided for @detailedAnalysisAstigmatismSolutionCylindricalDesc.
  ///
  /// In en, this message translates to:
  /// **'Glasses specially designed for astigmatism.'**
  String get detailedAnalysisAstigmatismSolutionCylindricalDesc;

  /// No description provided for @detailedAnalysisAstigmatismSolutionToric.
  ///
  /// In en, this message translates to:
  /// **'Toric Contact Lenses'**
  String get detailedAnalysisAstigmatismSolutionToric;

  /// No description provided for @detailedAnalysisAstigmatismSolutionToricDesc.
  ///
  /// In en, this message translates to:
  /// **'Special contact lenses for astigmatism.'**
  String get detailedAnalysisAstigmatismSolutionToricDesc;

  /// No description provided for @detailedAnalysisAstigmatismSolutionLaser.
  ///
  /// In en, this message translates to:
  /// **'Laser Surgery'**
  String get detailedAnalysisAstigmatismSolutionLaser;

  /// No description provided for @detailedAnalysisAstigmatismSolutionLaserDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanent solution for suitable candidates.'**
  String get detailedAnalysisAstigmatismSolutionLaserDesc;

  /// No description provided for @detailedAnalysisGenericTestAssessment.
  ///
  /// In en, this message translates to:
  /// **'{testName} Assessment'**
  String detailedAnalysisGenericTestAssessment(String testName);

  /// No description provided for @detailedAnalysisGenericTestResult.
  ///
  /// In en, this message translates to:
  /// **'{description} Result: %{percentage}'**
  String detailedAnalysisGenericTestResult(String description, int percentage);

  /// No description provided for @detailedAnalysisGenericConsequences.
  ///
  /// In en, this message translates to:
  /// **'Possible Consequences'**
  String get detailedAnalysisGenericConsequences;

  /// No description provided for @detailedAnalysisGenericEffects.
  ///
  /// In en, this message translates to:
  /// **'Effects'**
  String get detailedAnalysisGenericEffects;

  /// No description provided for @detailedAnalysisGenericSolutionDoctor.
  ///
  /// In en, this message translates to:
  /// **'Eye Doctor Examination'**
  String get detailedAnalysisGenericSolutionDoctor;

  /// No description provided for @detailedAnalysisGenericSolutionDoctorDesc.
  ///
  /// In en, this message translates to:
  /// **'Be sure to consult an eye doctor for a detailed examination.'**
  String get detailedAnalysisGenericSolutionDoctorDesc;

  /// No description provided for @detailedAnalysisGenericSolutionCheckups.
  ///
  /// In en, this message translates to:
  /// **'Regular Checkups'**
  String get detailedAnalysisGenericSolutionCheckups;

  /// No description provided for @detailedAnalysisGenericSolutionCheckupsDesc.
  ///
  /// In en, this message translates to:
  /// **'Have regular checkups for your eye health.'**
  String get detailedAnalysisGenericSolutionCheckupsDesc;

  /// No description provided for @detailedAnalysisGenericTestResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Result'**
  String get detailedAnalysisGenericTestResultTitle;

  /// No description provided for @detailedAnalysisGenericTestResultText.
  ///
  /// In en, this message translates to:
  /// **'Your test result: %{percentage}'**
  String detailedAnalysisGenericTestResultText(int percentage);

  /// No description provided for @detailedAnalysisVergenceTest.
  ///
  /// In en, this message translates to:
  /// **'Vergence Test'**
  String get detailedAnalysisVergenceTest;

  /// No description provided for @detailedAnalysisVergenceTestDesc.
  ///
  /// In en, this message translates to:
  /// **'Your convergence and divergence abilities are being evaluated. This test detects double vision (diplopia) and eye muscle coordination problems.'**
  String get detailedAnalysisVergenceTestDesc;

  /// No description provided for @detailedAnalysisVergenceTestConsequence.
  ///
  /// In en, this message translates to:
  /// **'Vergence problems can cause issues such as eye strain, headache, reading difficulty, and double vision.'**
  String get detailedAnalysisVergenceTestConsequence;

  /// No description provided for @detailedAnalysisNearVisionTest.
  ///
  /// In en, this message translates to:
  /// **'Near Vision'**
  String get detailedAnalysisNearVisionTest;

  /// No description provided for @detailedAnalysisNearVisionTestDesc.
  ///
  /// In en, this message translates to:
  /// **'Your near-distance vision ability is being evaluated.'**
  String get detailedAnalysisNearVisionTestDesc;

  /// No description provided for @detailedAnalysisNearVisionTestConsequence.
  ///
  /// In en, this message translates to:
  /// **'Near vision problems can create difficulty in reading, writing, and detailed work.'**
  String get detailedAnalysisNearVisionTestConsequence;

  /// No description provided for @detailedAnalysisMacularTest.
  ///
  /// In en, this message translates to:
  /// **'Macular Test'**
  String get detailedAnalysisMacularTest;

  /// No description provided for @detailedAnalysisMacularTestDesc.
  ///
  /// In en, this message translates to:
  /// **'Your macular (yellow spot) health is being evaluated.'**
  String get detailedAnalysisMacularTestDesc;

  /// No description provided for @detailedAnalysisMacularTestConsequence.
  ///
  /// In en, this message translates to:
  /// **'Macular problems can cause central vision loss.'**
  String get detailedAnalysisMacularTestConsequence;

  /// No description provided for @detailedAnalysisPeripheralVisionTest.
  ///
  /// In en, this message translates to:
  /// **'Peripheral Vision'**
  String get detailedAnalysisPeripheralVisionTest;

  /// No description provided for @detailedAnalysisPeripheralVisionTestDesc.
  ///
  /// In en, this message translates to:
  /// **'Your side vision ability is being evaluated.'**
  String get detailedAnalysisPeripheralVisionTestDesc;

  /// No description provided for @detailedAnalysisPeripheralVisionTestConsequence.
  ///
  /// In en, this message translates to:
  /// **'Peripheral vision problems can cause a decrease in environmental awareness.'**
  String get detailedAnalysisPeripheralVisionTestConsequence;

  /// No description provided for @detailedAnalysisEyeMovementTest.
  ///
  /// In en, this message translates to:
  /// **'Eye Movement'**
  String get detailedAnalysisEyeMovementTest;

  /// No description provided for @detailedAnalysisEyeMovementTestDesc.
  ///
  /// In en, this message translates to:
  /// **'Your eye movement coordination is being evaluated.'**
  String get detailedAnalysisEyeMovementTestDesc;

  /// No description provided for @detailedAnalysisEyeMovementTestConsequence.
  ///
  /// In en, this message translates to:
  /// **'Eye movement problems can cause tracking and focusing difficulties.'**
  String get detailedAnalysisEyeMovementTestConsequence;

  /// No description provided for @fact1Title.
  ///
  /// In en, this message translates to:
  /// **'Eye Blinking'**
  String get fact1Title;

  /// No description provided for @fact1Text.
  ///
  /// In en, this message translates to:
  /// **'When looking at screens, our blink rate decreases by up to 60%.'**
  String get fact1Text;

  /// No description provided for @fact2Title.
  ///
  /// In en, this message translates to:
  /// **'Baby Vision'**
  String get fact2Title;

  /// No description provided for @fact2Text.
  ///
  /// In en, this message translates to:
  /// **'Babies see the world blurry and colorless when they are born.'**
  String get fact2Text;

  /// No description provided for @fact3Title.
  ///
  /// In en, this message translates to:
  /// **'Eye Growth'**
  String get fact3Title;

  /// No description provided for @fact3Text.
  ///
  /// In en, this message translates to:
  /// **'Our eyes do not grow throughout life, but ears and nose continue to grow.'**
  String get fact3Text;

  /// No description provided for @fact4Title.
  ///
  /// In en, this message translates to:
  /// **'Night Vision'**
  String get fact4Title;

  /// No description provided for @fact4Text.
  ///
  /// In en, this message translates to:
  /// **'To see better in the dark, looking slightly to the side of objects is more effective than looking directly at them.'**
  String get fact4Text;

  /// No description provided for @fact5Title.
  ///
  /// In en, this message translates to:
  /// **'Color Blindness'**
  String get fact5Title;

  /// No description provided for @fact5Text.
  ///
  /// In en, this message translates to:
  /// **'Approximately 8% of men and only 0.5% of women are color blind.'**
  String get fact5Text;

  /// No description provided for @fact6Title.
  ///
  /// In en, this message translates to:
  /// **'Color Perception'**
  String get fact6Title;

  /// No description provided for @fact6Text.
  ///
  /// In en, this message translates to:
  /// **'Two people looking at the same color do not see it exactly the same.'**
  String get fact6Text;

  /// No description provided for @fact7Title.
  ///
  /// In en, this message translates to:
  /// **'Purple Color'**
  String get fact7Title;

  /// No description provided for @fact7Text.
  ///
  /// In en, this message translates to:
  /// **'Purple is not a real color in the spectrum; the brain produces it by mixing red and blue.'**
  String get fact7Text;

  /// No description provided for @fact8Title.
  ///
  /// In en, this message translates to:
  /// **'Color Discrimination'**
  String get fact8Title;

  /// No description provided for @fact8Text.
  ///
  /// In en, this message translates to:
  /// **'The human eye can theoretically distinguish 10 million different colors.'**
  String get fact8Text;

  /// No description provided for @fact9Title.
  ///
  /// In en, this message translates to:
  /// **'Eye Movement'**
  String get fact9Title;

  /// No description provided for @fact9Text.
  ///
  /// In en, this message translates to:
  /// **'Our eyes constantly move; if they stay still, the image disappears in a few seconds.'**
  String get fact9Text;

  /// No description provided for @fact10Title.
  ///
  /// In en, this message translates to:
  /// **'Brain and Vision'**
  String get fact10Title;

  /// No description provided for @fact10Text.
  ///
  /// In en, this message translates to:
  /// **'More than 30% of the back part of the brain is directly related to vision.'**
  String get fact10Text;

  /// No description provided for @fact11Title.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get fact11Title;

  /// No description provided for @fact11Text.
  ///
  /// In en, this message translates to:
  /// **'Dark mode reduces energy consumption, not eye strain.'**
  String get fact11Text;

  /// No description provided for @fact12Title.
  ///
  /// In en, this message translates to:
  /// **'Cat Vision'**
  String get fact12Title;

  /// No description provided for @fact12Text.
  ///
  /// In en, this message translates to:
  /// **'Cats can see with 6 times less light than humans.'**
  String get fact12Text;

  /// No description provided for @fact13Title.
  ///
  /// In en, this message translates to:
  /// **'Mantis Shrimp'**
  String get fact13Title;

  /// No description provided for @fact13Text.
  ///
  /// In en, this message translates to:
  /// **'Mantis shrimp have 12-16 different color receptors in their eyes (humans only have 3). They can also see ultraviolet light.'**
  String get fact13Text;

  /// No description provided for @fact14Title.
  ///
  /// In en, this message translates to:
  /// **'Eagle Vision'**
  String get fact14Title;

  /// No description provided for @fact14Text.
  ///
  /// In en, this message translates to:
  /// **'An eagle can clearly spot a small prey from 3-4 kilometers away.'**
  String get fact14Text;

  /// No description provided for @fact15Title.
  ///
  /// In en, this message translates to:
  /// **'Owl Vision'**
  String get fact15Title;

  /// No description provided for @fact15Text.
  ///
  /// In en, this message translates to:
  /// **'Owls\' eyes are tube-shaped and the eyeball cannot move. That\'s why they can rotate their heads 270 degrees.'**
  String get fact15Text;

  /// No description provided for @fact16Title.
  ///
  /// In en, this message translates to:
  /// **'Whale Vision'**
  String get fact16Title;

  /// No description provided for @fact16Text.
  ///
  /// In en, this message translates to:
  /// **'Whales see very well underwater and are not color blind. However, their vision is limited on the water surface.'**
  String get fact16Text;

  /// No description provided for @fact17Title.
  ///
  /// In en, this message translates to:
  /// **'Dog Vision'**
  String get fact17Title;

  /// No description provided for @fact17Text.
  ///
  /// In en, this message translates to:
  /// **'Dogs cannot distinguish red and green. They see the world in yellow, blue, and gray tones.'**
  String get fact17Text;

  /// No description provided for @fact18Title.
  ///
  /// In en, this message translates to:
  /// **'Snake Vision'**
  String get fact18Title;

  /// No description provided for @fact18Text.
  ///
  /// In en, this message translates to:
  /// **'Snakes can detect infrared light and \"see\" temperature differences. This allows them to find prey in the dark.'**
  String get fact18Text;

  /// No description provided for @fact19Title.
  ///
  /// In en, this message translates to:
  /// **'Blind Cave Fish'**
  String get fact19Title;

  /// No description provided for @fact19Text.
  ///
  /// In en, this message translates to:
  /// **'Blind cave fish are born completely blind but their other senses are so developed that they can navigate by \"feeling\" water currents.'**
  String get fact19Text;

  /// No description provided for @fact20Title.
  ///
  /// In en, this message translates to:
  /// **'Chameleon Eyes'**
  String get fact20Title;

  /// No description provided for @fact20Text.
  ///
  /// In en, this message translates to:
  /// **'Chameleons\' eyes can move independently of each other. One eye can track prey while the other scans the environment.'**
  String get fact20Text;

  /// No description provided for @fact21Title.
  ///
  /// In en, this message translates to:
  /// **'Butterfly Vision'**
  String get fact21Title;

  /// No description provided for @fact21Text.
  ///
  /// In en, this message translates to:
  /// **'Butterflies can see ultraviolet light and detect invisible patterns on flowers.'**
  String get fact21Text;

  /// No description provided for @fact22Title.
  ///
  /// In en, this message translates to:
  /// **'Shark Vision'**
  String get fact22Title;

  /// No description provided for @fact22Text.
  ///
  /// In en, this message translates to:
  /// **'Sharks see 10 times better than humans in the dark. They can also distinguish colors underwater.'**
  String get fact22Text;

  /// No description provided for @fact23Title.
  ///
  /// In en, this message translates to:
  /// **'Horse Vision'**
  String get fact23Title;

  /// No description provided for @fact23Text.
  ///
  /// In en, this message translates to:
  /// **'Horses have almost 360-degree vision because their eyes are on the sides of their heads.'**
  String get fact23Text;

  /// No description provided for @fact24Title.
  ///
  /// In en, this message translates to:
  /// **'Dolphin Vision'**
  String get fact24Title;

  /// No description provided for @fact24Text.
  ///
  /// In en, this message translates to:
  /// **'Dolphins can use each eye independently. One eye can watch the water surface while the other watches underwater.'**
  String get fact24Text;

  /// No description provided for @fact25Title.
  ///
  /// In en, this message translates to:
  /// **'Spider Eyes'**
  String get fact25Title;

  /// No description provided for @fact25Text.
  ///
  /// In en, this message translates to:
  /// **'Some spiders have 8 eyes. Each eye serves a different function: some detect movement, others detect details.'**
  String get fact25Text;

  /// No description provided for @fact26Title.
  ///
  /// In en, this message translates to:
  /// **'Blind Mole'**
  String get fact26Title;

  /// No description provided for @fact26Text.
  ///
  /// In en, this message translates to:
  /// **'Blind moles are born completely blind but their sense of smell and touch are so developed that they never get lost in their tunnels.'**
  String get fact26Text;

  /// No description provided for @fact27Title.
  ///
  /// In en, this message translates to:
  /// **'Parrot Vision'**
  String get fact27Title;

  /// No description provided for @fact27Text.
  ///
  /// In en, this message translates to:
  /// **'Parrots can see ultraviolet light, allowing them to find ripe fruits more easily.'**
  String get fact27Text;

  /// No description provided for @fact28Title.
  ///
  /// In en, this message translates to:
  /// **'Shark Retina'**
  String get fact28Title;

  /// No description provided for @fact28Text.
  ///
  /// In en, this message translates to:
  /// **'Sharks have special cells in their retina, allowing them to see their prey even at very low light levels.'**
  String get fact28Text;

  /// No description provided for @fact29Title.
  ///
  /// In en, this message translates to:
  /// **'Nocturnal Animals'**
  String get fact29Title;

  /// No description provided for @fact29Text.
  ///
  /// In en, this message translates to:
  /// **'Nocturnal animals have a special layer called tapetum lucidum in their eyes. This layer reflects light to enhance vision.'**
  String get fact29Text;

  /// No description provided for @fact30Title.
  ///
  /// In en, this message translates to:
  /// **'Bat Vision'**
  String get fact30Title;

  /// No description provided for @fact30Text.
  ///
  /// In en, this message translates to:
  /// **'Bats are not blind! Although their vision is weak, they use echolocation to navigate in the dark.'**
  String get fact30Text;

  /// No description provided for @factPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get factPrevious;

  /// No description provided for @factNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get factNext;

  /// No description provided for @factComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get factComplete;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'pt',
        'tr'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
