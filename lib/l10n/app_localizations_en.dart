// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Beer Ledger';

  @override
  String get placeholderHeadline => 'Placeholder home screen';

  @override
  String coreVersion(String version) {
    return 'core $version';
  }

  @override
  String get placeholderNextStep => 'Home screen is next';
}
