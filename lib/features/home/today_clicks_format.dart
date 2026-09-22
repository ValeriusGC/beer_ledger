import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Время строки журнала: [DateFormat.Hm] по [Click.at] (уже local).
String formatTodayClickTime(Click click, Locale locale) {
  return DateFormat.Hm(locale.toString()).format(click.at);
}

/// Объём тапа в литрах или `null`, если volume-вклада нет.
///
/// База → литры только через [fromBase]. Не падать и не рисовать другие оси.
String? formatTodayClickVolume(Click click, {required String languageCode}) {
  AxisContribution? volume;
  for (final contribution in click.contributions) {
    if (contribution.kind == LedgerAxisKind.volume) {
      volume = contribution;
      break;
    }
  }
  if (volume == null) return null;

  final liters = fromBase(volume.signedBaseDelta, VolumeUnit.liter);
  final amount = NumberFormat.decimalPattern(languageCode)
    ..minimumFractionDigits = 0
    ..maximumFractionDigits = 3;
  return '${amount.format(liters)} ${VolumeUnit.liter.symbol}';
}
