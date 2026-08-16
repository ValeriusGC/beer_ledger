import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Тап в SQLite (ADR 001 §2). Data class — [ClickRow], не domain [Click].
@DataClassName('ClickRow')
@TableIndex(
  name: 'idx_clicks_at',
  columns: {IndexedColumn(#atUtcMs, orderBy: OrderingMode.desc)},
)
class Clicks extends Table {
  /// UUID v4 строкой.
  TextColumn get id => text()();

  /// Ссылка на preset/config clicker.
  TextColumn get clickerId => text()();

  /// Момент тапа — UTC, миллисекунды с epoch.
  IntColumn get atUtcMs => integer()();

  /// Множитель тапа.
  RealColumn get factor => real().withDefault(const Constant(1.0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Вклад оси по тапу (ADR 001 §2). Data class — [ClickContributionRow].
@DataClassName('ClickContributionRow')
class ClickContributions extends Table {
  TextColumn get clickId =>
      text().references(Clicks, #id, onDelete: KeyAction.cascade)();

  /// Wire: `volume`, `energy`, `money`, `joy`.
  TextColumn get kind => text()();

  /// Факт в базовой единице × знак (ADR 003).
  RealColumn get signedBaseDelta => real()();

  /// Wire-id единицы ввода для UI.
  TextColumn get enteredInId => text()();

  @override
  Set<Column<Object>> get primaryKey => {clickId, kind};
}

/// Локальная SQLite БД тапов (drift, ADR 001).
@DriftDatabase(tables: [Clicks, ClickContributions])
class AppDatabase extends _$AppDatabase {
  /// Файловая БД приложения.
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// In-memory БД для unit-тестов.
  AppDatabase.inMemory()
    : super(
        NativeDatabase.memory(
          setup: (raw) => raw.execute('PRAGMA foreign_keys = ON'),
        ),
      );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'beer_ledger',
      native: DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
        setup: (raw) => raw.execute('PRAGMA foreign_keys = ON'),
      ),
    );
  }
}
