[![CI](https://github.com/ValeriusGC/beer_ledger/actions/workflows/ci.yml/badge.svg)](https://github.com/ValeriusGC/beer_ledger/actions/workflows/ci.yml)

# beer_ledger (Пивомер)

**Дата создания:** 2026-07-25 17:13:00 +0500  
**Последнее обновление:** 2026-08-25 13:56:43 +0500  
**Версия:** 9

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
flutter run --flavor dev
flutter run --flavor prod
```

В `pubspec.yaml` задан `default-flavor: dev`, поэтому `flutter run` без флага тоже поднимает **dev** (Android и iOS одинаково).

| Flavor | id | Имя на домашнем экране |
|--------|----|------------------------|
| `dev` | `com.beerledger.beer_ledger.dev` | Пивомер DEV |
| `prod` | `com.beerledger.beer_ledger` | Пивомер |

Сборки:

```bash
flutter build apk --flavor dev
flutter build apk --flavor prod
flutter build ios --flavor dev --no-codesign
flutter build ios --flavor prod --no-codesign
```

Dev и prod ставятся на устройство одновременно: разные id. У dev на экране метка DEV; у prod её нет.

## Локализация (RU / EN)

Строки интерфейса живут в `lib/l10n/app_en.arb` (шаблон) и `lib/l10n/app_ru.arb`. Новая фраза:

1. Добавить ключ и `@description` в оба ARB.
2. `flutter gen-l10n` (или `flutter pub get`).
3. В виджете: `AppLocalizations.of(context).yourKey`.

Сгенерированные `lib/l10n/app_localizations*.dart` коммитим вместе с ARB. Доменные строки из `beer_ledger_core` (например, `beerHalfLiter().title`) в ARB не переносятся.

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

- Flutter 3.x, Riverpod (planned), go_router, drift, fl_chart
- Offline-first, Android / iOS / Web

## Статус

**iter 1.1 ✅** — домен в `beer_ledger_core` (measure, convert, `Click`/`Clicker`, `aggregateForPeriod`, preset `beerHalfLiter`).  
**iter 2 (persistence):** ADR 001 drift принят; `addClick` / `watchClicksForDay` — [PR #35](https://github.com/ValeriusGC/beer_ledger/pull/35); `undoLastClick` — [PR #37](https://github.com/ValeriusGC/beer_ledger/pull/37) (closes #29).  
**Следующий шаг:** Riverpod (#30–#31).
