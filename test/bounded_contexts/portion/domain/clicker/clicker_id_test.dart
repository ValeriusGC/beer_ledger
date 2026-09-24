import 'package:beer_ledger/bounded_contexts/journal/domain/click/click_id.dart';
import 'package:beer_ledger/bounded_contexts/portion/domain/clicker/clicker_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ClickerId равен себе и не является ClickId', () {
    expect(const ClickerId('a'), const ClickerId('a'));
    expect(const ClickerId('a'), isNot(isA<ClickId>()));
  });
}
