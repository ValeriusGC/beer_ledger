import 'package:fpdart/fpdart.dart';

import '../domain/click.dart';
import '../domain/ledger_axis_kind.dart';
import '../failure/failure.dart';
import '../result/result.dart';
import 'period_balances.dart';

/// Суммирует [AxisContribution.signedBaseDelta] всех [clicks] в полуинтервале
/// `[from, to)`.
///
/// [kinds] — оси dashboard'а: для каждого kind в списке в результате будет
/// ключ (даже если вкладов не было). Обычно:
/// `clicker.axes.map((a) => a.kind).toList()`.
///
/// В roadmap параметр назван «axes»; для суммирования достаточно kind'ов —
/// конфигурация оси ([LedgerAxis]) в расчёт не входит, снимок уже в [Click].
///
/// Интервал полуоткрытый (ADR 002 §7): `click.at >= from && click.at < to`.
/// Пустой список тапов или ни один tap вне периода → нули по [kinds], не ошибка.
/// `from >= to` → [Failure.invalidPeriod].
///
/// Вклад с kind, которого нет в [kinds], всё равно попадает в map (ключ
/// создаётся при первом вкладе).
Result<PeriodBalances> aggregateForPeriod({
  required List<Click> clicks,
  required List<LedgerAxisKind> kinds,
  required DateTime from,
  required DateTime to,
}) {
  if (!from.isBefore(to)) {
    return Left(Failure.invalidPeriod(from: from, to: to));
  }

  final totals = {for (final kind in kinds) kind: 0.0};

  for (final click in clicks) {
    if (_isBefore(click.at, from) || !_isBefore(click.at, to)) {
      continue;
    }

    for (final contribution in click.contributions) {
      final kind = contribution.kind;
      totals[kind] = (totals[kind] ?? 0) + contribution.signedBaseDelta;
    }
  }

  return Right(PeriodBalances(totalsInBase: totals));
}

/// `a < b` по календарному сравнению (local [DateTime], iter 1.1).
bool _isBefore(DateTime a, DateTime b) => a.compareTo(b) < 0;
