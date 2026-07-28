import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:test/test.dart';

void main() {
  group('beerHalfLiter', () {
    test('4 оси spec v1 с дефолтными значениями', () {
      final clicker = beerHalfLiter();

      expect(clicker.id, 'clicker-beer');
      expect(clicker.title, 'Пиво 0.5 L');
      expect(clicker.axes, hasLength(4));

      final volume = clicker.axes.firstWhere(
        (a) => a.kind == LedgerAxisKind.volume,
      );
      expect(volume.enteredValue, 0.5);
      expect(volume.enteredInId, VolumeUnit.liter.id);
      expect(volume.sign, AxisSign.plus);

      final energy = clicker.axes.firstWhere(
        (a) => a.kind == LedgerAxisKind.energy,
      );
      expect(energy.enteredValue, 100);
      expect(energy.enteredInId, EnergyUnit.kilocalorie.id);
      expect(energy.sign, AxisSign.plus);

      final money = clicker.axes.firstWhere(
        (a) => a.kind == LedgerAxisKind.money,
      );
      expect(money.enteredValue, 150);
      expect(money.enteredInId, MoneyUnit.rouble.id);
      expect(money.sign, AxisSign.minus);

      final joy = clicker.axes.firstWhere((a) => a.kind == LedgerAxisKind.joy);
      expect(joy.enteredValue, 2);
      expect(joy.enteredInId, CountUnit.point.id);
      expect(joy.sign, AxisSign.plus);
    });

    test('кастомный id', () {
      expect(beerHalfLiter(id: 'custom').id, 'custom');
    });
  });
}
