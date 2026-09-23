# beer_ledger_core

**Дата создания:** 2026-07-25 17:13:00 +0500  
**Последнее обновление:** 2026-09-23 20:36:08 +0300  
**Версия:** 4

Pure Dart техническое ядро для [Пивомер](https://github.com/ValeriusGC/beer_ledger): словарь единиц, конвертация, ошибки и маркеры DDD.

Без `import flutter` — только VM unit-тесты. Агрегаты порции и журнала — в приложении `lib/bounded_contexts/`.

## Возможности

- **arch** — маркеры `AggregateRoot`, `Entity`, `ValueObject`
- **measure** — шесть семейств единиц (`VolumeUnit`, `EnergyUnit`, …), ADR 003
- **convert** — `convert`, `toBase`, `fromBase`, `deltaInBase` → `Result`
- **Failure** — sealed ошибки
- **Result** — `Either<Failure, T>`
- **LedgerAxisKind** — четыре оси продукта (общий словарь порции и журнала)

## Пример

```dart
import 'package:beer_ledger_core/beer_ledger_core.dart';

void main() {
  // 500 мл в базе → 0.5 L для UI
  final liters = fromBase(500, VolumeUnit.liter);
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
