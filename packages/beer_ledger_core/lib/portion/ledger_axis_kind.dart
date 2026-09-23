import '../measure/measure_family.dart';

/// Вид оси учёта на кнопке-пакете — язык продукта v1.
///
/// Четыре оси preset «Пиво 0.5 L»: объём, калории, деньги, удовольствие.
/// Соответствие семейству единиц: [LedgerAxisKind.volume] → [MeasureFamily.volume],
/// [LedgerAxisKind.energy] → [MeasureFamily.energy],
/// [LedgerAxisKind.money] → [MeasureFamily.money],
/// [LedgerAxisKind.joy] → [MeasureFamily.count].
enum LedgerAxisKind {
  /// Объём выпитого или съеденного.
  volume,

  /// Энергия (ккал) — оценка пользователя, не USDA.
  energy,

  /// Денежная стоимость порции.
  money,

  /// Субъективная оценка (баллы удовольствия).
  joy,
}
