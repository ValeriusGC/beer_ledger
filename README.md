[![CI](https://github.com/ValeriusGC/beer_ledger/actions/workflows/ci.yml/badge.svg)](https://github.com/ValeriusGC/beer_ledger/actions/workflows/ci.yml)

# beer_ledger (Пивомер)

**Дата создания:** 2026-07-25 17:13:00 +0500  
**Последнее обновление:** 2026-07-26 15:51:23 +0500  
**Версия:** 1

Flutter-приложение для учёта привычки **trade-off tap**: один тап фиксирует объём, оценочные калории, деньги и удовольствие.

> Публичный репозиторий для портфолио. Спецификация и roadmap — в приватном штабе `flutter-senior-prep/project_pivomer/`.

## Структура

```
beer_ledger/
├── lib/                        # Flutter UI (Riverpod — по мере разработки)
├── packages/beer_ledger_core/  # Pure Dart: Clicker, Calc, aggregation
└── test/
```

## Запуск

```bash
cd beer_ledger
flutter pub get
flutter run
```

## Тесты core

```bash
cd packages/beer_ledger_core
dart test
```

## Стек (целевой)

- Flutter 3.x, Riverpod, go_router, drift/isar, fl_chart
- Offline-first, Android / iOS / Web

## Статус

**v0** — scaffold создан, домен из `fast_2020` ещё не перенесён.
