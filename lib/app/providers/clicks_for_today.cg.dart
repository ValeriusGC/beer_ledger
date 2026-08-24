import 'package:beer_ledger/app/providers/click_repository.cg.dart';
import 'package:beer_ledger/app/providers/now.cg.dart';
import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clicks_for_today.cg.g.dart';

/// Живой список тапов за сегодняшний локальный день.
///
/// «Сегодня» — календарный день [now]. Экран только рисует этот поток,
/// в базу сам не ходит.
@riverpod
Stream<List<Click>> clicksForToday(Ref ref) {
  return ref
      .watch(clickRepositoryProvider)
      .watchClicksForDay(ref.watch(nowProvider));
}
