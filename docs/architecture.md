# Архитектура: beer_ledger (Пивомер)

**Дата создания:** 2026-07-25 17:13:00 +0500  
**Последнее обновление:** 2026-07-28 19:09 +0500  
**Версия:** 3

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
│       │   ├── failure/         # sealed Failure (ADR 002)
│       │   ├── result/          # Result<T> = Either<Failure, T>
│       │   ├── measure/         # MeasureUnit + 6 enum families (ADR 003)
│       │   ├── convert/         # convert, toBase, fromBase, deltaInBase
│       │   ├── domain/          # Click, Clicker, LedgerAxis, AxisContribution
│       │   ├── aggregate/       # aggregateForPeriod, PeriodBalances
│       │   └── preset/          # beerHalfLiter()
│       └── test/
└── test/
```

## Слои

```
┌─────────────┐
│  UI (Flutter)│  Riverpod, Material 3 (planned)
└──────┬──────┘
       │ ref.watch
┌──────▼──────┐
│ Repository  │  persist Click, settings (iter 2)
└──────┬──────┘
       │
┌──────▼──────────────┐
│ beer_ledger_core    │  pure Dart, 110+ VM-тестов
│ measure, convert,   │
│ domain, aggregate,  │
│ preset              │
└─────────────────────┘
```

## Миграция из `fast_2020`

| Источник | Куда | Статус |
|----------|------|--------|
| `lib/calcs/measure_units.dart` | `core/measure/` | ✅ iter 1.1 |
| `lib/calcs/calcs.dart` | `core/domain/` + `core/aggregate/` | ✅ iter 1.1 |
| `lib/domain/clicker.dart`, `click.dart` | `core/domain/` | ✅ iter 1.1 |
| `test/calc_test.dart` | `core/test/` | ✅ заменено новой матрицей |
| `uolles_sys/` | — | **Не переносить** |

## Стек (целевой)

| Слой | Выбор | Статус |
|------|-------|--------|
| Domain | `beer_ledger_core` | ✅ iter 1.1 |
| State | Riverpod 3 | planned (iter 2) |
| Routing | go_router | planned |
| DB | drift **или** isar | ADR pending (iter 2) |
| Charts | fl_chart | planned |
| i18n | flutter gen-l10n | planned |

## Принципы

- **DDD:** домен в `beer_ledger_core`, не в виджетах
- **UI Projection:** dumb widgets, Controller/Factory/Builder по мере роста
- **Offline-first**
- Multi-ledger: один tap → N aggregates (volume, kcal, money, joy)
- История тапов не пересчитывается при смене конфига clicker (ADR 003)

## ADR

| Документ | Тема |
|----------|------|
| [002-domain-style.md](decisions/002-domain-style.md) | Failure, Result, freezed, период `[from, to)` |
| [003-closed-unit-set.md](decisions/003-closed-unit-set.md) | Замкнутый набор единиц; факт в базовой единице |
