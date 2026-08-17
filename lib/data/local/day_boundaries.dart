import 'package:beer_ledger/data/mappers/click_mapper.dart';

/// Полуинтервал локального календарного дня в UTC ms для SQL-фильтра.
///
/// [dayLocal] — календарная дата в локальной TZ (время суток игнорируется).
/// Возвращает `[startUtcMs, endUtcMs)` — границы `[startOfDay, startOfNextDay)`.
({int startUtcMs, int endUtcMs}) localDayUtcRange(DateTime dayLocal) {
  final startOfDay = DateTime(dayLocal.year, dayLocal.month, dayLocal.day);
  final startOfNextDay = startOfDay.add(const Duration(days: 1));
  return (
    startUtcMs: clickAtUtcMs(startOfDay),
    endUtcMs: clickAtUtcMs(startOfNextDay),
  );
}
