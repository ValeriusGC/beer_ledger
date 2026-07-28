import '../domain/axis_sign.dart';
import '../domain/clicker.dart';
import '../domain/ledger_axis.dart';
import '../domain/ledger_axis_kind.dart';
import '../measure/count_unit.dart';
import '../measure/energy_unit.dart';
import '../measure/money_unit.dart';
import '../measure/volume_unit.dart';

/// Preset v1 «Пиво 0.5 L» — четыре оси по spec v1.
///
/// Один тап: +0.5 L, +100 kcal, −150 ₽, +2 joy (в единицах ввода осей).
/// Агрегация и отображение — через [Click.record] и [aggregateForPeriod].
Clicker beerHalfLiter({String id = 'clicker-beer'}) => Clicker(
  id: id,
  title: 'Пиво 0.5 L',
  axes: [
    LedgerAxis(
      kind: LedgerAxisKind.volume,
      enteredValue: 0.5,
      enteredInId: VolumeUnit.liter.id,
      sign: AxisSign.plus,
    ),
    LedgerAxis(
      kind: LedgerAxisKind.energy,
      enteredValue: 100,
      enteredInId: EnergyUnit.kilocalorie.id,
      sign: AxisSign.plus,
    ),
    LedgerAxis(
      kind: LedgerAxisKind.money,
      enteredValue: 150,
      enteredInId: MoneyUnit.rouble.id,
      sign: AxisSign.minus,
    ),
    LedgerAxis(
      kind: LedgerAxisKind.joy,
      enteredValue: 2,
      enteredInId: CountUnit.point.id,
      sign: AxisSign.plus,
    ),
  ],
);
