import 'package:flutter/material.dart';
import 'package:goz_testi/l10n/app_localizations.dart';

/// Helper class to get localized exercise texts
class ExerciseLocalizations {
  static String getTitle(BuildContext context, String exerciseId) {
    final l10n = AppLocalizations.of(context)!;
    
    // Child exercises
    switch (exerciseId) {
      case 'child_1':
        return l10n.exerciseChild1Title;
      case 'child_2':
        return l10n.exerciseChild2Title;
      case 'child_3':
        return l10n.exerciseChild3Title;
      case 'child_4':
        return l10n.exerciseChild4Title;
      case 'child_5':
        return l10n.exerciseChild5Title;
      case 'child_6':
        return l10n.exerciseChild6Title;
      case 'child_7':
        return l10n.exerciseChild7Title;
      case 'child_8':
        return l10n.exerciseChild8Title;
      case 'child_9':
        return l10n.exerciseChild9Title;
      case 'child_10':
        return l10n.exerciseChild10Title;
      
      // Adult exercises
      case 'adult_1':
        return l10n.exerciseAdult1Title;
      case 'adult_3':
        return l10n.exerciseAdult3Title;
      case 'adult_4':
        return l10n.exerciseAdult4Title;
      case 'adult_5':
        return l10n.exerciseAdult5Title;
      case 'adult_6':
        return l10n.exerciseAdult6Title;
      case 'adult_7':
        return l10n.exerciseAdult7Title;
      case 'adult_8':
        return l10n.exerciseAdult8Title;
      case 'adult_9':
        return l10n.exerciseAdult9Title;
      case 'adult_10':
        return l10n.exerciseAdult10Title;
      case 'adult_11':
        return l10n.exerciseAdult11Title;
      case 'adult_12':
        return l10n.exerciseAdult12Title;
      
      // Office exercises
      case 'office_1':
        return l10n.exerciseOffice1Title;
      case 'office_2':
        return l10n.exerciseOffice2Title;
      case 'office_3':
        return l10n.exerciseOffice3Title;
      case 'office_4':
        return l10n.exerciseOffice4Title;
      case 'office_5':
        return l10n.exerciseOffice5Title;
      case 'office_6':
        return l10n.exerciseOffice6Title;
      case 'office_7':
        return l10n.exerciseOffice7Title;
      case 'office_8':
        return l10n.exerciseOffice8Title;
      case 'office_9':
        return l10n.exerciseOffice9Title;
      case 'office_10':
        return l10n.exerciseOffice10Title;
      
      default:
        return '';
    }
  }
  
  static String getDescription(BuildContext context, String exerciseId) {
    final l10n = AppLocalizations.of(context)!;
    
    // Child exercises
    switch (exerciseId) {
      case 'child_1':
        return l10n.exerciseChild1Desc;
      case 'child_2':
        return l10n.exerciseChild2Desc;
      case 'child_3':
        return l10n.exerciseChild3Desc;
      case 'child_4':
        return l10n.exerciseChild4Desc;
      case 'child_5':
        return l10n.exerciseChild5Desc;
      case 'child_6':
        return l10n.exerciseChild6Desc;
      case 'child_7':
        return l10n.exerciseChild7Desc;
      case 'child_8':
        return l10n.exerciseChild8Desc;
      case 'child_9':
        return l10n.exerciseChild9Desc;
      case 'child_10':
        return l10n.exerciseChild10Desc;
      
      // Adult exercises
      case 'adult_1':
        return l10n.exerciseAdult1Desc;
      case 'adult_3':
        return l10n.exerciseAdult3Desc;
      case 'adult_4':
        return l10n.exerciseAdult4Desc;
      case 'adult_5':
        return l10n.exerciseAdult5Desc;
      case 'adult_6':
        return l10n.exerciseAdult6Desc;
      case 'adult_7':
        return l10n.exerciseAdult7Desc;
      case 'adult_8':
        return l10n.exerciseAdult8Desc;
      case 'adult_9':
        return l10n.exerciseAdult9Desc;
      case 'adult_10':
        return l10n.exerciseAdult10Desc;
      case 'adult_11':
        return l10n.exerciseAdult11Desc;
      case 'adult_12':
        return l10n.exerciseAdult12Desc;
      
      // Office exercises
      case 'office_1':
        return l10n.exerciseOffice1Desc;
      case 'office_2':
        return l10n.exerciseOffice2Desc;
      case 'office_3':
        return l10n.exerciseOffice3Desc;
      case 'office_4':
        return l10n.exerciseOffice4Desc;
      case 'office_5':
        return l10n.exerciseOffice5Desc;
      case 'office_6':
        return l10n.exerciseOffice6Desc;
      case 'office_7':
        return l10n.exerciseOffice7Desc;
      case 'office_8':
        return l10n.exerciseOffice8Desc;
      case 'office_9':
        return l10n.exerciseOffice9Desc;
      case 'office_10':
        return l10n.exerciseOffice10Desc;
      
      default:
        return '';
    }
  }
  
  static String? getBenefit(BuildContext context, String exerciseId) {
    final l10n = AppLocalizations.of(context)!;
    
    // Child exercises
    switch (exerciseId) {
      case 'child_1':
        return l10n.exerciseChild1Benefit;
      case 'child_2':
        return l10n.exerciseChild2Benefit;
      case 'child_3':
        return l10n.exerciseChild3Benefit;
      case 'child_4':
        return l10n.exerciseChild4Benefit;
      case 'child_5':
        return l10n.exerciseChild5Benefit;
      case 'child_6':
        return l10n.exerciseChild6Benefit;
      case 'child_7':
        return l10n.exerciseChild7Benefit;
      case 'child_8':
        return l10n.exerciseChild8Benefit;
      case 'child_9':
        return l10n.exerciseChild9Benefit;
      case 'child_10':
        return l10n.exerciseChild10Benefit;
      
      // Adult exercises
      case 'adult_1':
        return l10n.exerciseAdult1Benefit;
      case 'adult_3':
        return l10n.exerciseAdult3Benefit;
      case 'adult_4':
        return l10n.exerciseAdult4Benefit;
      case 'adult_5':
        return l10n.exerciseAdult5Benefit;
      case 'adult_6':
        return l10n.exerciseAdult6Benefit;
      case 'adult_7':
        return l10n.exerciseAdult7Benefit;
      case 'adult_8':
        return l10n.exerciseAdult8Benefit;
      case 'adult_9':
        return l10n.exerciseAdult9Benefit;
      case 'adult_10':
        return l10n.exerciseAdult10Benefit;
      case 'adult_11':
        return l10n.exerciseAdult11Benefit;
      case 'adult_12':
        return l10n.exerciseAdult12Benefit;
      
      // Office exercises
      case 'office_1':
        return l10n.exerciseOffice1Benefit;
      case 'office_2':
        return l10n.exerciseOffice2Benefit;
      case 'office_3':
        return l10n.exerciseOffice3Benefit;
      case 'office_4':
        return l10n.exerciseOffice4Benefit;
      case 'office_5':
        return l10n.exerciseOffice5Benefit;
      case 'office_6':
        return l10n.exerciseOffice6Benefit;
      case 'office_7':
        return l10n.exerciseOffice7Benefit;
      case 'office_8':
        return l10n.exerciseOffice8Benefit;
      case 'office_9':
        return l10n.exerciseOffice9Benefit;
      case 'office_10':
        return l10n.exerciseOffice10Benefit;
      
      default:
        return null;
    }
  }
}
