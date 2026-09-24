# Архитектура: beer_ledger (Пивомер)

**Дата создания:** 2026-07-25 17:13:00 +0500  
**Последнее обновление:** 2026-09-24 15:45:06 +0300  
**Версия:** 19

Public выжимка. Раскладка папок — закон в `docs/project-structure.md`. Полная спека — `flutter-senior-prep/project_pivomer/`.

## Monorepo layout

```
beer_ledger/
├── lib/
│   ├── core/                    # DI, AppDatabase — не контекст
│   ├── bounded_contexts/
│   │   ├── portion/             # BC порция: domain/clicker + application + infra + presentation
│   │   └── journal/             # BC журнал: domain/click + application + infra + presentation
│   ├── app/                     # роутер, flavor
│   ├── main.dart
│   └── l10n/
├── packages/beer_ledger_core/   # техническое ядро, без Flutter
│   └── lib/ arch, measure, convert, failure, result, LedgerAxisKind
└── test/
```

Целевое дерево с файлами — `docs/project-structure.md`.

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
│ beer_ledger_core    │  словарь + arch; домен контекстов — в lib/bounded_contexts
│ measure, convert    │
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
| Domain | `lib/bounded_contexts/*/domain` + словарь `beer_ledger_core` | iter 3.5 |
| State | Riverpod 3 | #30 clicksForToday ✅; #31 todayBalance ✅ |
| Routing | go_router | ✅ `/`, `/settings` |
| DB | drift (SQLite) | ADR 001 ✅; тапы PR #35/#37; порция — `clicker_settings`, schema 2 |
| Charts | fl_chart | ✅ BarChart, объём за 7 дней на home |
| i18n | flutter gen-l10n | ✅ app RU+EN |

## Принципы

- **DDD:** два bounded context в `lib/bounded_contexts/`; словарь в `beer_ledger_core`; id и суммы осей — value object'ы в папке агрегата; `ClickId` / `ClickerId` входят через `parse` / `known`
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

Раскладка — `docs/project-structure.md`. Общих слоёв на весь `lib/` нет.
