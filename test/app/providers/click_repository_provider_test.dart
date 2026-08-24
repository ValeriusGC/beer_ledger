/// Этот файл целиком — временный smoke wiring.
///
/// Не журнал и не «тапы за сегодня». Удалить файл, когда появятся тесты
/// `clicksForToday` на [ProviderContainer] + in-memory: они покроют тот же
/// контракт (репозиторий берёт БД из [appDatabase]).
library;

import 'package:beer_ledger/app/providers/app_database.cg.dart';
import 'package:beer_ledger/app/providers/click_repository.cg.dart';
import 'package:beer_ledger/data/local/app_database.dart';
import 'package:beer_ledger/data/repositories/drift_click_repository.dart';
import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Click _recordClick({required String id, required DateTime at}) {
  return Click.record(
    id: id,
    clickerId: beerHalfLiter().id,
    at: at,
    clicker: beerHalfLiter(),
  ).getOrElse((_) => throw StateError('expected Right'));
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.inMemory();
  });

  tearDown(() async {
    // Ниже overrideWithValue: create() провайдера не вызывается, onDispose
    // не регистрируется — контейнер эту БД сам не закроет.
    await db.close();
  });

  test(
    'override appDatabase → clickRepository пишет в ту же in-memory БД',
    () async {
      // Подменяем БД, не репозиторий: clickRepository должен взять db
      // через watch(appDatabase). Иначе unit-тест открыл бы файловую SQLite.
      final container = ProviderContainer.test(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );

      expect(identical(container.read(appDatabaseProvider), db), isTrue);

      final repository = container.read(clickRepositoryProvider);
      expect(repository, isA<DriftClickRepository>());

      // addClick здесь не про журнал: только что запись пошла в db,
      // а не в случайный файловый executor.
      final result = await repository.addClick(
        _recordClick(id: 'via-provider', at: DateTime(2026, 8, 24, 12)),
      );
      expect(result.isRight(), isTrue);
    },
  );
}
