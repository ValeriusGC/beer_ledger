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
  String get devBadge => 'DEV';

  @override
  String get todayBalanceVolumeLabel => 'Объём';

  @override
  String get todayBalanceEnergyLabel => 'Ккал';

  @override
  String get todayBalanceMoneyLabel => 'Деньги';

  @override
  String get todayBalanceJoyLabel => 'Радость';

  @override
  String get todayBalanceLoadError => 'Не удалось загрузить итог за сегодня';

  @override
  String get recordBeerTap => 'Пиво 0.5';

  @override
  String get recordClickError => 'Не удалось записать тап';

  @override
  String get todayClicksTitle => 'Сегодня';

  @override
  String get todayClicksEmpty => 'Пока нет записей за сегодня';

  @override
  String get todayClicksLoadError => 'Не удалось загрузить записи за сегодня';

  @override
  String get undoLastTap => 'Отменить последний тап';

  @override
  String get undoLastTapError => 'Не удалось отменить тап';
}
