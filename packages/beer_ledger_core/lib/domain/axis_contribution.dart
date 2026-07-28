import 'package:freezed_annotation/freezed_annotation.dart';

import 'ledger_axis_kind.dart';

part 'axis_contribution.freezed.dart';

/// Замороженный вклад одной оси в момент тапа (ADR 003 §2).
///
/// [signedBaseDelta] уже включает знак оси и [Click.factor] — готов к
/// суммированию в [aggregateForPeriod] (PR 5). [enteredInId] нужен только для
/// отображения («0.5 L»); пересчёт факта из него **запрещён**.
@freezed
abstract class AxisContribution with _$AxisContribution {
  const factory AxisContribution({
    required LedgerAxisKind kind,
    required double signedBaseDelta,
    required String enteredInId,
  }) = _AxisContribution;
}
