import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

import 'domain_fixtures.dart';

void main() {
  group('Click.record', () {
    test('четыре оси spec, factor=1 — volume 500 мл в базе', () {
      final result = Click.record(
        id: 'click-1',
        clickerId: 'clicker-beer',
        at: DateTime(2026, 7, 28, 18),
        clicker: beerHalfLiterClicker(),
      );

      expect(result.isRight(), isTrue);
      final click = result.getOrElse((_) => throw StateError('expected Right'));

      expect(click.contributions, hasLength(4));
      expect(
        contribution(click, LedgerAxisKind.volume)!.signedBaseDelta,
        500.0,
      );
      expect(
        contribution(click, LedgerAxisKind.energy)!.signedBaseDelta,
        100000.0,
      );
      expect(
        contribution(click, LedgerAxisKind.money)!.signedBaseDelta,
        -15000.0,
      );
      expect(contribution(click, LedgerAxisKind.joy)!.signedBaseDelta, 2.0);
    });

    test('factor=2 удваивает вклад volume', () {
      final result = Click.record(
        id: 'click-2',
        clickerId: 'clicker-beer',
        at: DateTime(2026, 7, 28, 18),
        clicker: beerHalfLiterClicker(),
        factor: 2,
      );

      final click = result.getOrElse((_) => throw StateError('expected Right'));
      expect(
        contribution(click, LedgerAxisKind.volume)!.signedBaseDelta,
        1000.0,
      );
    });

    test('неизвестный enteredInId → Failure.unknownUnitId', () {
      final clicker = beerHalfLiterClicker().copyWith(
        axes: [
          LedgerAxis(
            kind: LedgerAxisKind.volume,
            enteredValue: 1,
            enteredInId: 'volume.unknown',
            sign: AxisSign.plus,
          ),
        ],
      );

      final result = Click.record(
        id: 'click-bad',
        clickerId: clicker.id,
        at: DateTime(2026, 7, 28, 18),
        clicker: clicker,
      );

      expect(result, const Left(Failure.unknownUnitId(id: 'volume.unknown')));
    });

    test(
      'ADR 003: смена конфигурации Clicker не меняет уже записанный Click',
      () {
        final clicker = beerHalfLiterClicker();
        final recorded = Click.record(
          id: 'click-frozen',
          clickerId: clicker.id,
          at: DateTime(2026, 7, 28, 12),
          clicker: clicker,
        ).getOrElse((_) => throw StateError('expected Right'));

        final updatedClicker = clicker.copyWith(
          axes: [
            clicker.axes.first.copyWith(enteredValue: 0.33),
            ...clicker.axes.skip(1),
          ],
        );

        expect(updatedClicker.axes.first.enteredValue, 0.33);
        expect(
          contribution(recorded, LedgerAxisKind.volume)!.signedBaseDelta,
          500.0,
        );
      },
    );

    test('ADR 003: enteredInId на снимке — для отображения через fromBase', () {
      final click = Click.record(
        id: 'click-ui',
        clickerId: 'clicker-beer',
        at: DateTime(2026, 7, 28, 12),
        clicker: beerHalfLiterClicker(),
      ).getOrElse((_) => throw StateError('expected Right'));

      final volume = contribution(click, LedgerAxisKind.volume)!;
      expect(volume.enteredInId, VolumeUnit.liter.id);
      expect(fromBase(volume.signedBaseDelta, VolumeUnit.liter), 0.5);
    });
  });
}
