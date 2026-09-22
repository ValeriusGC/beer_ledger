import 'package:beer_ledger/app/providers/app_database.cg.dart';
import 'package:beer_ledger/app/providers/now.cg.dart';
import 'package:beer_ledger/app/providers/record_click.cg.dart';
import 'package:beer_ledger/app/providers/today_balance.cg.dart';
import 'package:beer_ledger/data/local/app_database.dart';
import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Порции пресета «Пиво 0.5»: 500 мл, 100000 cal, −15000 коп, 2 joy.
void _expectPortions(PeriodBalances balances, int count) {
  expect(balances.totalFor(LedgerAxisKind.volume), 500.0 * count);
  expect(balances.totalFor(LedgerAxisKind.energy), 100000.0 * count);
  expect(balances.totalFor(LedgerAxisKind.money), -15000.0 * count);
  expect(balances.totalFor(LedgerAxisKind.joy), 2.0 * count);
}

/// In-memory БД и замороженные часы.
///
/// Без override [appDatabase] откроет файл, [now] — реальный [DateTime.now].
ProviderContainer _container({required AppDatabase db, required DateTime now}) {
  return ProviderContainer.test(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      nowProvider.overrideWithValue(now),
    ],
  );
}

/// Ждём emit drift `watch()` после записи. Без этого баланс ещё прежний.
Future<void> _flushWatch() => pumpEventQueue();

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 8, 24, 12);

  setUp(() {
    db = AppDatabase.inMemory();
  });

  tearDown(() async {
    await db.close();
  });

  group('RecordClick', () {
    test('record → баланс одной порции пресета', () async {
      final container = _container(db: db, now: now);
      container.listen(recordClickProvider, (_, _) {});

      await container.read(recordClickProvider.notifier).record();
      await _flushWatch();

      final balances = await container
          .listen(todayBalanceProvider.future, (_, _) {})
          .read();
      _expectPortions(balances, 1);
    });

    test('второй record → две порции', () async {
      final container = _container(db: db, now: now);
      container.listen(recordClickProvider, (_, _) {});
      final notifier = container.read(recordClickProvider.notifier);

      await notifier.record();
      await notifier.record();
      await _flushWatch();

      final balances = await container
          .listen(todayBalanceProvider.future, (_, _) {})
          .read();
      _expectPortions(balances, 2);
    });

    test('пока loading второй record не пишет второй тап', () async {
      final container = _container(db: db, now: now);
      container.listen(recordClickProvider, (_, _) {});
      final notifier = container.read(recordClickProvider.notifier);

      final first = notifier.record();
      expect(container.read(recordClickProvider).isLoading, isTrue);
      final second = notifier.record();
      await Future.wait([first, second]);
      await _flushWatch();

      final balances = await container
          .listen(todayBalanceProvider.future, (_, _) {})
          .read();
      _expectPortions(balances, 1);
    });
  });
}
