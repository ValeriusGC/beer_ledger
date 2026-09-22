import 'package:beer_ledger/data/local/app_database.dart';
import 'package:beer_ledger/data/repositories/drift_clicker_settings_repository.dart';
import 'package:beer_ledger/features/settings/portion_input.dart';
import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftClickerSettingsRepository repository;

  setUp(() {
    db = AppDatabase.inMemory();
    repository = DriftClickerSettingsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('нет строки — один seed, watch отдаёт пресет', () async {
    await db.delete(db.clickerSettings).go();

    final clicker = await repository.watchClicker(beerHalfLiter().id).first;

    expect(clicker.id, beerHalfLiter().id);
    expect(portionEntered(clicker, PortionField.volume), 0.5);
    expect(portionEntered(clicker, PortionField.energy), 100);
    expect(portionEntered(clicker, PortionField.money), 150);
    expect(portionEntered(clicker, PortionField.joy), 2);
    expect(
      clicker.axes.firstWhere((axis) => axis.kind == LedgerAxisKind.money).sign,
      AxisSign.minus,
    );
    final rows = await db.select(db.clickerSettings).get();
    expect(rows, hasLength(1));
  });

  test('save energy 180 не стирает остальные поля', () async {
    final current = await repository.watchClicker(beerHalfLiter().id).first;
    final updated = clickerWithPortion(
      current,
      volume: 0.5,
      energy: 180,
      money: 150,
      joy: 2,
    );

    final saved = await repository.saveClicker(updated);

    expect(saved.isRight(), isTrue);
    final again = await repository.watchClicker(beerHalfLiter().id).first;
    expect(portionEntered(again, PortionField.energy), 180);
    expect(portionEntered(again, PortionField.volume), 0.5);
    expect(portionEntered(again, PortionField.money), 150);
    expect(portionEntered(again, PortionField.joy), 2);
    expect(
      again.axes.firstWhere((axis) => axis.kind == LedgerAxisKind.money).sign,
      AxisSign.minus,
    );
    expect(
      again.axes
          .firstWhere((axis) => axis.kind == LedgerAxisKind.energy)
          .enteredInId,
      EnergyUnit.kilocalorie.id,
    );
  });

  test('закрытая БД — Failure.storage saveClicker', () async {
    final clicker = await repository.watchClicker(beerHalfLiter().id).first;
    await db.close();

    final result = await repository.saveClicker(clicker);

    expect(
      result.fold((failure) => failure, (_) => null),
      isA<StorageFailure>().having(
        (failure) => failure.operation,
        'operation',
        'saveClicker',
      ),
    );
  });
}
