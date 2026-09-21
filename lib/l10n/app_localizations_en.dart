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
  String get devBadge => 'DEV';

  @override
  String get todayBalanceVolumeLabel => 'Volume';

  @override
  String get todayBalanceEnergyLabel => 'Calories';

  @override
  String get todayBalanceMoneyLabel => 'Money';

  @override
  String get todayBalanceJoyLabel => 'Joy';

  @override
  String get todayBalanceLoadError => 'Couldn\'t load today\'s totals';
}
