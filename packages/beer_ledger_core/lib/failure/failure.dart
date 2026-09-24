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

  /// Неизвестный wire-id единицы измерения при записи тапа.
  const factory Failure.unknownUnitId({required String id}) = UnknownUnitId;

  /// Пустой id тапа или кликера после `parse`.
  const factory Failure.emptyId() = EmptyId;

  /// Ошибка persistence: операция repository/БД не выполнена (ADR 001 §6).
  ///
  /// [operation] — имя операции для лога и mapper UI (напр. `addClick`).
  /// [cause] — исходное исключение SQLite/drift; в mapper не показывается пользователю.
  const factory Failure.storage({required String operation, Object? cause}) =
      StorageFailure;
}
