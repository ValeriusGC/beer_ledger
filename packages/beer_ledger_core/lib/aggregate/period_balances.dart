import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/ledger_axis_kind.dart';

part 'period_balances.freezed.dart';

/// Суммы по осям за период — в **базовых** единицах семейства.
///
/// Значения уже подписаны ([AxisContribution.signedBaseDelta] суммировался
/// при агрегации): объём в мл, энергия в cal, деньги в kop, joy в count.
/// Конвертация для UI («1.5 L», «−450 ₽») — в слое приложения через
/// [fromBase].
@freezed
abstract class PeriodBalances with _$PeriodBalances {
  const factory PeriodBalances({
    required Map<LedgerAxisKind, double> totalsInBase,
  }) = _PeriodBalances;

  const PeriodBalances._();

  /// Сумма по [kind]; отсутствующий ключ → `0.0`.
  double totalFor(LedgerAxisKind kind) => totalsInBase[kind] ?? 0.0;
}
