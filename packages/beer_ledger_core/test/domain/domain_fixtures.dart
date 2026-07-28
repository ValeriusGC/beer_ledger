import 'package:beer_ledger_core/beer_ledger_core.dart';

/// Clicker с четырьмя осями preset «Пиво 0.5 L» (spec v1).
Clicker beerHalfLiterClicker() => Clicker(
  id: 'clicker-beer',
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

AxisContribution? contribution(Click click, LedgerAxisKind kind) {
  for (final item in click.contributions) {
    if (item.kind == kind) return item;
  }
  return null;
}
