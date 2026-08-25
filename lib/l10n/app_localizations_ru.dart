// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Пивомер';

  @override
  String get placeholderHeadline => 'Заглушка домашнего экрана';

  @override
  String coreVersion(String version) {
    return 'core $version';
  }

  @override
  String get placeholderNextStep => 'Главный экран ещё впереди';
}
