import 'package:beer_ledger/app/providers/clicks_for_today.cg.dart';
import 'package:beer_ledger/app/providers/now.cg.dart';
import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'today_balance.cg.g.dart';

/// Четыре цифры за сегодня: объём, ккал, деньги, радость.
///
/// Сумма — [aggregateForPeriod], не отдельная формула. Тапы — [clicksForToday],
/// оси — [beerHalfLiter]. Экран только рисует.
@riverpod
Future<PeriodBalances> todayBalance(Ref ref) {
  // Без async: иначе загрузка списка станет ошибкой, а не ожиданием.
  final clicks = ref.watch(clicksForTodayProvider).requireValue;
  final now = ref.watch(nowProvider);
  final from = DateTime(now.year, now.month, now.day);
  final to = from.add(const Duration(days: 1));

  final balances = aggregateForPeriod(
    clicks: clicks,
    kinds: beerHalfLiter().axes.map((axis) => axis.kind).toList(),
    from: from,
    to: to,
  ).getOrElse((failure) => throw StateError('aggregateForPeriod: $failure'));

  return Future.value(balances);
}
