import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('Failure variants', () {
    test('incompatibleUnits holds ids', () {
      const failure = Failure.incompatibleUnits(fromId: 'kg', toId: 'liter');
      expect(
        failure,
        const Failure.incompatibleUnits(fromId: 'kg', toId: 'liter'),
      );
    });

    test('invalidPeriod holds bounds', () {
      final from = DateTime(2026, 7, 28, 10);
      final to = DateTime(2026, 7, 28, 9);
      final failure = Failure.invalidPeriod(from: from, to: to);
      expect(failure, Failure.invalidPeriod(from: from, to: to));
    });
  });

  group('Result — Left is Failure, Right is success', () {
    test('Right propagates through flatMap', () {
      const Result<int> source = Right(2);

      final Result<int> next = source.flatMap((n) => Right(n * 3));

      expect(next, const Right(2 * 3));
    });

    test('Left short-circuits flatMap without running callback', () {
      final failure = Failure.invalidPeriod(
        from: DateTime(2026, 7, 28, 12),
        to: DateTime(2026, 7, 28, 11),
      );
      final Result<int> source = Left(failure);

      var callbackRan = false;
      final Result<int> next = source.flatMap((n) {
        callbackRan = true;
        return Right(n * 3);
      });

      expect(callbackRan, isFalse);
      expect(next.isLeft(), isTrue);
      next.fold(
        (f) => expect(f, failure),
        (_) => fail('expected Left(Failure)'),
      );
    });

    test('match distinguishes Left and Right', () {
      const success = Right<String, int>(7);
      final failure = Failure.incompatibleUnits(fromId: 'a', toId: 'b');
      final err = Left<Failure, int>(failure);

      expect(
        success.match((l) => 'err:$l', (r) => 'ok:$r'),
        'ok:7',
      );
      expect(
        err.match((l) => l.runtimeType, (r) => 'ok:$r'),
        IncompatibleUnits,
      );
    });
  });
}
