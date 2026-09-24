import 'dart:io';

import 'package:beer_ledger/core/persistence/app_database.dart';
import 'package:beer_ledger/bounded_contexts/portion/portion.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.inMemory();
  });

  tearDown(() async {
    await db.close();
  });

  test('fresh db — schema 2 и seed пресета', () async {
    expect(db.schemaVersion, 2);
    final row = await db.select(db.clickerSettings).getSingle();
    final preset = beerHalfLiter();
    expect(row.clickerId, preset.id.value);
    expect(row.volumeEntered, 0.5);
    expect(row.energyEntered, 100);
    expect(row.moneyEntered, 150);
    expect(row.joyEntered, 2);
  });

  // v1→v2 без drift schema dump: сырой sqlite с user_version = 1, таблицами
  // тапов schema 1 и одной строкой клика. AppDatabase должен вызвать onUpgrade.
  // Клик остаётся, появляется seed. Если upgrade так не бежит — тест красный,
  // не expect(true).
  test('onUpgrade с user_version 1 сохраняет клик и сеет порцию', () async {
    await db.close();
    final file = File(
      '${Directory.systemTemp.path}/beer_ledger_v1_${DateTime.now().microsecondsSinceEpoch}.sqlite',
    );
    final raw = sqlite3.open(file.path);
    raw.userVersion = 1;
    raw.execute(
      'CREATE TABLE "clicks" ('
      '"id" TEXT NOT NULL, "clicker_id" TEXT NOT NULL, '
      '"at_utc_ms" INTEGER NOT NULL, "factor" REAL NOT NULL DEFAULT 1.0, '
      'PRIMARY KEY ("id"))',
    );
    raw.execute('CREATE INDEX idx_clicks_at ON clicks (at_utc_ms DESC)');
    raw.execute(
      'CREATE TABLE "click_contributions" ('
      '"click_id" TEXT NOT NULL REFERENCES clicks (id) ON DELETE CASCADE, '
      '"kind" TEXT NOT NULL, "signed_base_delta" REAL NOT NULL, '
      '"entered_in_id" TEXT NOT NULL, PRIMARY KEY ("click_id", "kind"))',
    );
    raw.execute(
      "INSERT INTO clicks (id, clicker_id, at_utc_ms, factor) "
      "VALUES ('click-old', 'clicker-beer', 1000, 1.0)",
    );
    raw.execute(
      'INSERT INTO click_contributions '
      '(click_id, kind, signed_base_delta, entered_in_id) '
      "VALUES ('click-old', 'energy', 100000, 'energy.kcal')",
    );
    raw.close();

    final upgraded = AppDatabase(NativeDatabase(file));
    addTearDown(() async {
      await upgraded.close();
      if (file.existsSync()) file.deleteSync();
    });

    final version = await upgraded
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.read<int>('user_version'), 2);

    final clicks = await upgraded.select(upgraded.clicks).get();
    expect(clicks, hasLength(1));
    expect(clicks.single.id, 'click-old');

    final energy = await upgraded
        .customSelect(
          'SELECT signed_base_delta FROM click_contributions '
          "WHERE click_id = 'click-old' AND kind = 'energy'",
        )
        .getSingle();
    expect(energy.read<double>('signed_base_delta'), 100000);

    final settings = await upgraded
        .select(upgraded.clickerSettings)
        .getSingle();
    expect(settings.clickerId, beerHalfLiter().id.value);
    expect(settings.volumeEntered, 0.5);
    expect(settings.energyEntered, 100);
    expect(settings.moneyEntered, 150);
    expect(settings.joyEntered, 2);
  });

  test('customSelect runs without error', () async {
    final row = await db.customSelect('SELECT 1 AS x').getSingle();
    expect(row.read<int>('x'), 1);
  });
}
