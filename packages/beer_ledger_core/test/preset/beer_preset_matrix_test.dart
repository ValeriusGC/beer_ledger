import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:test/test.dart';

List<LedgerAxisKind> _kinds(Clicker clicker) =>
    clicker.axes.map((a) => a.kind).toList();

(DateTime from, DateTime to) _dayPeriod(int year, int month, int day) {
  final from = DateTime(year, month, day);
  return (from, DateTime(year, month, day + 1));
}

Click _recordTap({
  required Clicker clicker,
  required String id,
  required DateTime at,
}) {
  return Click.record(
    id: id,
    clickerId: clicker.id,
    at: at,
    clicker: clicker,
  ).getOrElse((_) => throw StateError('expected Right'));
}

PeriodBalances _aggregateDay({
  required List<Click> clicks,
  required Clicker clicker,
  required DateTime from,
  required DateTime to,
}) {
  return aggregateForPeriod(
    clicks: clicks,
    kinds: _kinds(clicker),
    from: from,
    to: to,
  ).getOrElse((_) => throw StateError('expected Right'));
}

void main() {
  group('beer preset matrix', () {
    final clicker = beerHalfLiter();

    test('0 тапов — нули в base и display', () {
      final (from, to) = _dayPeriod(2026, 7, 28);
      final balances = _aggregateDay(
        clicks: [],
        clicker: clicker,
        from: from,
        to: to,
      );

      expect(balances.totalFor(LedgerAxisKind.volume), 0.0);
      expect(
        fromBase(balances.totalFor(LedgerAxisKind.volume), VolumeUnit.liter),
        0.0,
      );
      expect(
        fromBase(
          balances.totalFor(LedgerAxisKind.energy),
          EnergyUnit.kilocalorie,
        ),
        0.0,
      );
      expect(
        fromBase(balances.totalFor(LedgerAxisKind.money), MoneyUnit.rouble),
        0.0,
      );
      expect(
        fromBase(balances.totalFor(LedgerAxisKind.joy), CountUnit.point),
        0.0,
      );
    });

    test('1 тап — одна порция base + display', () {
      final (from, to) = _dayPeriod(2026, 7, 28);
      final balances = _aggregateDay(
        clicks: [
          _recordTap(clicker: clicker, id: 'c1', at: DateTime(2026, 7, 28, 12)),
        ],
        clicker: clicker,
        from: from,
        to: to,
      );

      expect(balances.totalFor(LedgerAxisKind.volume), 500.0);
      expect(
        fromBase(balances.totalFor(LedgerAxisKind.volume), VolumeUnit.liter),
        0.5,
      );
      expect(
        fromBase(
          balances.totalFor(LedgerAxisKind.energy),
          EnergyUnit.kilocalorie,
        ),
        100.0,
      );
      expect(
        fromBase(balances.totalFor(LedgerAxisKind.money), MoneyUnit.rouble),
        -150.0,
      );
      expect(
        fromBase(balances.totalFor(LedgerAxisKind.joy), CountUnit.point),
        2.0,
      );
    });

    test('3 тапа — spec dashboard base + display', () {
      final (from, to) = _dayPeriod(2026, 7, 28);
      final balances = _aggregateDay(
        clicks: [
          _recordTap(clicker: clicker, id: 'c1', at: DateTime(2026, 7, 28, 10)),
          _recordTap(clicker: clicker, id: 'c2', at: DateTime(2026, 7, 28, 14)),
          _recordTap(clicker: clicker, id: 'c3', at: DateTime(2026, 7, 28, 20)),
        ],
        clicker: clicker,
        from: from,
        to: to,
      );

      expect(balances.totalFor(LedgerAxisKind.volume), 1500.0);
      expect(balances.totalFor(LedgerAxisKind.energy), 300000.0);
      expect(balances.totalFor(LedgerAxisKind.money), -45000.0);
      expect(balances.totalFor(LedgerAxisKind.joy), 6.0);

      expect(
        fromBase(balances.totalFor(LedgerAxisKind.volume), VolumeUnit.liter),
        1.5,
      );
      expect(
        fromBase(
          balances.totalFor(LedgerAxisKind.energy),
          EnergyUnit.kilocalorie,
        ),
        300.0,
      );
      expect(
        fromBase(balances.totalFor(LedgerAxisKind.money), MoneyUnit.rouble),
        -450.0,
      );
      expect(
        fromBase(balances.totalFor(LedgerAxisKind.joy), CountUnit.point),
        6.0,
      );
    });

    test('знаки на агрегате: money < 0, остальные > 0', () {
      final (from, to) = _dayPeriod(2026, 7, 28);
      final balances = _aggregateDay(
        clicks: [
          _recordTap(clicker: clicker, id: 'c1', at: DateTime(2026, 7, 28, 12)),
        ],
        clicker: clicker,
        from: from,
        to: to,
      );

      expect(balances.totalFor(LedgerAxisKind.volume), greaterThan(0));
      expect(balances.totalFor(LedgerAxisKind.energy), greaterThan(0));
      expect(balances.totalFor(LedgerAxisKind.joy), greaterThan(0));
      expect(balances.totalFor(LedgerAxisKind.money), lessThan(0));
    });

    test('undo последнего — totals как у 2 тапов', () {
      final (from, to) = _dayPeriod(2026, 7, 28);
      final clicks = [
        _recordTap(clicker: clicker, id: 'c1', at: DateTime(2026, 7, 28, 10)),
        _recordTap(clicker: clicker, id: 'c2', at: DateTime(2026, 7, 28, 14)),
        _recordTap(clicker: clicker, id: 'c3', at: DateTime(2026, 7, 28, 20)),
      ];
      clicks.removeLast();

      final balances = _aggregateDay(
        clicks: clicks,
        clicker: clicker,
        from: from,
        to: to,
      );

      expect(balances.totalFor(LedgerAxisKind.volume), 1000.0);
      expect(
        fromBase(balances.totalFor(LedgerAxisKind.volume), VolumeUnit.liter),
        1.0,
      );
      expect(
        fromBase(
          balances.totalFor(LedgerAxisKind.energy),
          EnergyUnit.kilocalorie,
        ),
        200.0,
      );
      expect(
        fromBase(balances.totalFor(LedgerAxisKind.money), MoneyUnit.rouble),
        -300.0,
      );
      expect(
        fromBase(balances.totalFor(LedgerAxisKind.joy), CountUnit.point),
        4.0,
      );
    });

    test('полночь — в дневной период попадает только сегодняшний тап', () {
      final (from, to) = _dayPeriod(2026, 7, 28);
      final balances = _aggregateDay(
        clicks: [
          _recordTap(
            clicker: clicker,
            id: 'c-yesterday',
            at: DateTime(2026, 7, 27, 23, 59),
          ),
          _recordTap(
            clicker: clicker,
            id: 'c-today',
            at: DateTime(2026, 7, 28, 10),
          ),
        ],
        clicker: clicker,
        from: from,
        to: to,
      );

      expect(balances.totalFor(LedgerAxisKind.volume), 500.0);
      expect(
        fromBase(balances.totalFor(LedgerAxisKind.volume), VolumeUnit.liter),
        0.5,
      );
    });

    test('N=5 тапов — volume 2500 мл', () {
      final (from, to) = _dayPeriod(2026, 7, 28);
      final clicks = List.generate(
        5,
        (i) => _recordTap(
          clicker: clicker,
          id: 'c$i',
          at: DateTime(2026, 7, 28, 8 + i),
        ),
      );

      final balances = _aggregateDay(
        clicks: clicks,
        clicker: clicker,
        from: from,
        to: to,
      );

      expect(balances.totalFor(LedgerAxisKind.volume), 2500.0);
      expect(
        fromBase(balances.totalFor(LedgerAxisKind.volume), VolumeUnit.liter),
        2.5,
      );
    });
  });
}
