import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

/// Сквозной тип ошибки core + app (ADR 002).
///
/// iter 1.1 — domain; iter 2+ — storage и др. в том же union.
@freezed
sealed class Failure with _$Failure {
  /// Единицы измерения из разных семейств или несовместимы.
  const factory Failure.incompatibleUnits({
    required String fromId,
    required String toId,
  }) = IncompatibleUnits;

  /// Невалидный интервал агрегации (напр. [from] >= [to]).
  const factory Failure.invalidPeriod({
    required DateTime from,
    required DateTime to,
  }) = InvalidPeriod;
}
