import 'package:beer_ledger/data/local/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.inMemory();
  });

  tearDown(() async {
    await db.close();
  });

  test('schemaVersion is 1', () {
    expect(db.schemaVersion, 1);
  });

  test('customSelect runs without error', () async {
    final row = await db.customSelect('SELECT 1 AS x').getSingle();
    expect(row.read<int>('x'), 1);
  });
}
