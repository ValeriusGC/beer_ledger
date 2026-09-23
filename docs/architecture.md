# Архитектура: beer_ledger (Пивомер)

**Дата создания:** 2026-07-25 17:13:00 +0500  
**Последнее обновление:** 2026-09-23 15:09:09 +0300  
**Версия:** 15

Public выжимка. Полная спека — `flutter-senior-prep/project_pivomer/`.

## Monorepo layout

```
beer_ledger/
├── lib/                         # Flutter app
│   ├── main.dart
│   ├── app/                     # providers, flavor, router
│   ├── features/home/           # HomePage; history (planned)
│   ├── features/settings/       # порция clicker, Drift
│   └── data/                    # repositories, drift (ADR 001)
├── packages/
│   └── beer_ledger_core/        # Pure Dart — NO Flutter import
│       ├── lib/
│       │   ├── failure/         # sealed Failure (ADR 002)
│       │   ├── result/          # Result<T> = Either<Failure, T>
│       │   ├── measure/         # MeasureUnit + 6 enum families (ADR 003)
│       │   ├── convert/         # convert, toBase, fromBase, deltaInBase
│       │   ├── portion/         # Clicker, LedgerAxis, AxisSign, LedgerAxisKind
│       │   ├── journal/         # Click, AxisContribution, Click.record
│       │   ├── aggregate/       # aggregateForPeriod, PeriodBalances
│       │   └── preset/          # beerHalfLiter()
│       └── test/
└── test/
```

## Слои

```
┌─────────────┐
│  UI (Flutter)│  HomePage (#44), Riverpod #30–#31, Material 3
└──────┬──────┘
       │ ref.watch
┌──────▼──────┐
│ Repository  │  persist Click (add/watch/undo ✅; Riverpod #30)
└──────┬──────┘
       │
┌──────▼──────────────┐
│ beer_ledger_core    │  pure Dart, 110+ VM-тестов
│ measure, convert,   │
│ portion, journal,   │
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
| State | Riverpod 3 | #30 clicksForToday ✅; #31 todayBalance ✅ |
| Routing | go_router | ✅ `/`, `/settings` |
| DB | drift (SQLite) | ADR 001 ✅; тапы PR #35/#37; порция — `clicker_settings`, schema 2 |
| Charts | fl_chart | ✅ BarChart, объём за 7 дней на home |
| i18n | flutter gen-l10n | ✅ app RU+EN |

## Принципы

- **DDD:** домен в `beer_ledger_core`, не в виджетах
- **UI Projection:** dumb widgets, Controller/Factory/Builder по мере роста
- **Offline-first**
- Multi-ledger: один tap → N aggregates (volume, kcal, money, joy)
- История тапов не пересчитывается при смене конфига clicker (ADR 003)

## ADR

| Документ | Тема |
|----------|------|
| [001-storage.md](decisions/001-storage.md) | drift + SQLite; схема `clicks`; repository contract |
| [002-domain-style.md](decisions/002-domain-style.md) | Failure, Result, freezed, период `[from, to)` |
| [003-closed-unit-set.md](decisions/003-closed-unit-set.md) | Замкнутый набор единиц; факт в базовой единице |
| [004-portion-and-journal.md](decisions/004-portion-and-journal.md) | Два контекста — порция и журнал; мост `Click.record` |

Каталоги `portion/` и `journal/` в core есть; слоёв `lib/domain/`, `lib/application/`, `lib/presentation/home/` ещё нет.
