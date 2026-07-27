# Архитектура: beer_ledger (Пивомер)

**Дата создания:** 2026-07-25 17:13:00 +0500  
**Последнее обновление:** 2026-07-26 15:51:23 +0500  
**Версия:** 1

Public выжимка. Полная спека — `flutter-senior-prep/project_pivomer/`.

## Monorepo layout

```
beer_ledger/
├── lib/                         # Flutter app
│   ├── main.dart
│   ├── app/                     # router, theme (planned)
│   ├── features/                # home, settings, history (planned)
│   └── data/                    # repositories, drift/isar (planned)
├── packages/
│   └── beer_ledger_core/        # Pure Dart — NO Flutter import
│       ├── lib/
│       │   ├── measure/         # MeasureUnit, convRatio (from fast_2020)
│       │   ├── domain/          # Clicker, Click, Calc
│       │   └── aggregate/       # sum by period, signs
│       └── test/
└── test/
```

## Слои

```
┌─────────────┐
│  UI (Flutter)│  Riverpod, Material 3
└──────┬──────┘
       │ ref.watch
┌──────▼──────┐
│ Repository  │  persist Click, settings
└──────┬──────┘
       │
┌──────▼──────────────┐
│ beer_ledger_core    │  pure Dart, unit-tested
│ aggregate, convert  │
└─────────────────────┘
```

## Миграция из `fast_2020`

| Источник | Куда | Действие |
|----------|------|----------|
| `lib/calcs/measure_units.dart` | `core/measure/` | Переписать под Dart 3 |
| `lib/calcs/calcs.dart` | `core/domain/` + `aggregate/` | Упростить |
| `lib/domain/clicker.dart`, `click.dart` | `core/domain/` | Упростить IDs |
| `test/calc_test.dart` | `core/test/` | Мигрировать |
| `uolles_sys/` | — | **Не переносить** |

## Стек (целевой)

| Слой | Выбор | Статус |
|------|-------|--------|
| State | Riverpod 3 | planned |
| Routing | go_router | planned |
| DB | drift **или** isar | ADR pending |
| Charts | fl_chart | planned |
| i18n | flutter gen-l10n | planned |

## Принципы

- **DDD:** домен в `beer_ledger_core`, не в виджетах
- **UI Projection:** dumb widgets, Controller/Factory/Builder по мере роста
- **Offline-first**
- Multi-ledger: один tap → N aggregates (volume, kcal, money, joy)
