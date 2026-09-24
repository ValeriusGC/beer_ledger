import 'package:beer_ledger/bounded_contexts/journal/domain/click/signed_base_delta.dart';
import 'package:beer_ledger_core/ledger_axis_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('VolumeDelta складывается в том же варианте', () {
    expect(VolumeDelta(1) + VolumeDelta(2), VolumeDelta(3));
  });

  test('fromKind возвращает вариант с нужным kind', () {
    expect(
      SignedBaseDelta.fromKind(LedgerAxisKind.volume, 500).kind,
      LedgerAxisKind.volume,
    );
  });
}
