import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../convert/convert.dart';
import '../failure/failure.dart';
import '../measure/measure_registry.dart';
import '../result/result.dart';
import 'axis_contribution.dart';
import 'clicker.dart';

part 'click.freezed.dart';

/// Одно нажатие кнопки-пакета: момент времени и замороженный вклад по осям.
///
/// [contributions] фиксируются в [record] и **не** пересчитываются при изменении
/// конфигурации [Clicker] — см. ADR 003.
@freezed
abstract class Click with _$Click {
  const factory Click({
    required String id,
    required String clickerId,
    required DateTime at,
    @Default(1.0) double factor,
    required List<AxisContribution> contributions,
  }) = _Click;

  const Click._();

  /// Создаёт тап со снимком вкладов всех осей [clicker].
  ///
  /// На каждой оси: резолв [LedgerAxis.enteredInId] → [resolveUnit]; при
  /// неизвестном id — [Failure.unknownUnitId]. Иначе
  /// `signedBaseDelta = sign.multiplier * deltaInBase(...)`.
  static Result<Click> record({
    required String id,
    required String clickerId,
    required DateTime at,
    required Clicker clicker,
    double factor = 1,
  }) {
    final contributions = <AxisContribution>[];

    for (final axis in clicker.axes) {
      final unit = resolveUnit(axis.enteredInId);
      if (unit == null) {
        return Left(Failure.unknownUnitId(id: axis.enteredInId));
      }

      contributions.add(
        AxisContribution(
          kind: axis.kind,
          signedBaseDelta:
              axis.sign.multiplier *
              deltaInBase(
                enteredValue: axis.enteredValue,
                enteredIn: unit,
                factor: factor,
              ),
          enteredInId: axis.enteredInId,
        ),
      );
    }

    return Right(
      Click(
        id: id,
        clickerId: clickerId,
        at: at,
        factor: factor,
        contributions: contributions,
      ),
    );
  }
}
