# beer_ledger_core

**Дата создания:** 2026-07-25 17:13:00 +0500  
**Последнее обновление:** 2026-07-28 19:09 +0500  
**Версия:** 2

Pure Dart domain layer для [Пивомер](https://github.com/ValeriusGC/beer_ledger): multi-ledger учёт одного тапа по нескольким осям (объём, калории, деньги, удовольствие).

Без `import flutter` — только VM unit-тесты.

## Возможности

- **measure** — шесть семейств единиц (`VolumeUnit`, `EnergyUnit`, …), ADR 003
- **convert** — `convert`, `toBase`, `fromBase`, `deltaInBase` → `Result`
- **domain** — `@freezed` `Click`, `Clicker`, `LedgerAxis`; `Click.record` замораживает вклад
- **aggregate** — `aggregateForPeriod` за полуинтервал `[from, to)`
- **preset** — `beerHalfLiter()` — clicker v1 «Пиво 0.5 L»

## Пример

```dart
import 'package:beer_ledger_core/beer_ledger_core.dart';

void main() {
  final clicker = beerHalfLiter();
  final dayStart = DateTime(2026, 7, 28);
  final dayEnd = DateTime(2026, 7, 29);

  final click = Click.record(
    id: 'c1',
    clickerId: clicker.id,
    at: DateTime(2026, 7, 28, 12),
    clicker: clicker,
  ).getOrElse((_) => throw StateError('expected Right'));

  final balances = aggregateForPeriod(
    clicks: [click],
    kinds: clicker.axes.map((a) => a.kind).toList(),
    from: dayStart,
    to: dayEnd,
  ).getOrElse((_) => throw StateError('expected Right'));

  // 500 мл в базе → 0.5 L для UI
  final liters = fromBase(
    balances.totalFor(LedgerAxisKind.volume),
    VolumeUnit.liter,
  );
}
```

## Разработка

```bash
dart pub get
dart analyze --fatal-warnings
dart test
```

После правки `@freezed`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

ADR и layout — [../../docs/architecture.md](../../docs/architecture.md).
