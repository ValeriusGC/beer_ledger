[![CI](https://github.com/ValeriusGC/beer_ledger/actions/workflows/ci.yml/badge.svg)](https://github.com/ValeriusGC/beer_ledger/actions/workflows/ci.yml)

# beer_ledger (Пивомер)

**Дата создания:** 2026-07-25 17:13:00 +0500  
**Последнее обновление:** 2026-07-28 19:09 +0500  
**Версия:** 4

Flutter-приложение для учёта привычки **trade-off tap**: один тап фиксирует объём, оценочные калории, деньги и удовольствие.

## Структура

```
beer_ledger/
├── lib/                        # Flutter UI (shell; iter 2+ — features)
├── packages/beer_ledger_core/  # Pure Dart: measure, domain, aggregate, preset
└── test/
```

Детали слоёв и миграция — [docs/architecture.md](docs/architecture.md).

## Запуск

```bash
cd beer_ledger
flutter pub get
flutter run
```

## Тесты core

```bash
cd packages/beer_ledger_core
dart analyze --fatal-warnings
dart test
```

Сейчас **110** unit-тестов на VM (без `import flutter` в core).

## CI

Политика analyze и команды перед PR — [docs/ci.md](docs/ci.md).

## Стек (целевой)

- Flutter 3.x, Riverpod, go_router, drift/isar, fl_chart
- Offline-first, Android / iOS / Web

## Статус

**iter 1.1 ✅** — домен в `beer_ledger_core` (measure, convert, `Click`/`Clicker`, `aggregateForPeriod`, preset `beerHalfLiter`).  
**Следующий шаг:** iter 2 — persistence + Riverpod (ADR drift vs isar).
