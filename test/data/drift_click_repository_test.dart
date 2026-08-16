import 'package:beer_ledger/data/local/app_database.dart';
import 'package:beer_ledger/data/mappers/click_mapper.dart';
import 'package:beer_ledger/data/repositories/drift_click_repository.dart';
import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:flutter_test/flutter_test.dart';

Click _recordClick({
  required String id,
  required DateTime at,
  double factor = 1,
}) {
  return Click.record(
    id: id,
    clickerId: beerHalfLiter().id,
    at: at,
    clicker: beerHalfLiter(),
    factor: factor,
  ).getOrElse((_) => throw StateError('expected Right'));
}

Click _withContributionsSortedByKind(Click click) {
  final contributions = [...click.contributions]
    ..sort((a, b) => a.kind.index.compareTo(b.kind.index));
  return click.copyWith(contributions: contributions);
}

Future<Click?> _readClickFromDb(AppDatabase db, String id) async {
  final row = await (db.select(db.clicks)..where((t) => t.id.equals(id)))
      .getSingleOrNull();
  if (row == null) return null;

  final contributions = await (db.select(
    db.clickContributions,
  )..where((t) => t.clickId.equals(id))).get();

  return clickFromRows(row: row, contributions: contributions);
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.inMemory();
  });

  tearDown(() async {
    await db.close();
  });

  group('DriftClickRepository.addClick', () {
    test('happy path: Click идентичен после read из tables', () async {
      final click = _recordClick(
        id: 'click-persist',
        at: DateTime(2026, 7, 28, 18, 30),
        factor: 2,
      );
      final repository = DriftClickRepository(db);

      final result = await repository.addClick(click);

      expect(result.isRight(), isTrue);
      final restored = await _readClickFromDb(db, click.id);
      expect(restored, isNotNull);
      expect(
        _withContributionsSortedByKind(restored!),
        _withContributionsSortedByKind(click),
      );
    });

    test('duplicate id → Failure.storage', () async {
      final click = _recordClick(
        id: 'click-dup',
        at: DateTime(2026, 7, 28, 12),
      );
      final repository = DriftClickRepository(db);

      expect((await repository.addClick(click)).isRight(), isTrue);

      final duplicate = await repository.addClick(click);

      expect(duplicate.isLeft(), isTrue);
      duplicate.fold(
        (failure) {
          expect(failure, isA<StorageFailure>());
          final storage = failure as StorageFailure;
          expect(storage.operation, 'addClick');
          expect(storage.cause, isNotNull);
        },
        (_) => fail('expected Left(Failure.storage)'),
      );
    });
  });
}
