import 'package:beer_ledger/data/local/app_database.dart';
import 'package:beer_ledger/data/local/day_boundaries.dart';
import 'package:beer_ledger/data/mappers/click_mapper.dart';
import 'package:beer_ledger/data/repositories/click_repository.dart';
import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';

/// Drift-реализация [ClickRepository] (ADR 001).
final class DriftClickRepository implements ClickRepository {
  /// [db] — in-memory в тестах, файловая БД в runtime.
  DriftClickRepository(this._db);

  final AppDatabase _db;

  static const _addClickOperation = 'addClick';

  @override
  Future<Result<void>> addClick(Click click) async {
    try {
      await _db.transaction(() async {
        await _db.into(_db.clicks).insert(clickToCompanion(click));
        await _db.batch((batch) {
          batch.insertAll(
            _db.clickContributions,
            contributionsToCompanions(click),
          );
        });
      });
      return const Right(null);
    } on Object catch (error) {
      return Left(Failure.storage(operation: _addClickOperation, cause: error));
    }
  }

  @override
  Stream<List<Click>> watchClicksForDay(DateTime dayLocal) {
    final (:startUtcMs, :endUtcMs) = localDayUtcRange(dayLocal);

    final query = _db.select(_db.clicks)
      ..where(
        (row) =>
            row.atUtcMs.isBiggerOrEqualValue(startUtcMs) &
            row.atUtcMs.isSmallerThanValue(endUtcMs),
      )
      ..orderBy([
        (row) => OrderingTerm.desc(row.atUtcMs),
        (row) => OrderingTerm.desc(row.id),
      ]);

    return query.watch().asyncMap(_clicksFromRows);
  }

  Future<List<Click>> _clicksFromRows(List<ClickRow> rows) async {
    final clicks = <Click>[];
    for (final row in rows) {
      final contributions = await (_db.select(
        _db.clickContributions,
      )..where((t) => t.clickId.equals(row.id))).get();
      clicks.add(clickFromRows(row: row, contributions: contributions));
    }
    return clicks;
  }

  @override
  Future<Result<void>> undoLastClick() async {
    // TODO(#29): DELETE последнего тапа по (at DESC, id DESC).
    throw UnimplementedError('undoLastClick — PR #29');
  }
}
