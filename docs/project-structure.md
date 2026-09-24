# Структура каталогов

**Дата создания:** 2026-09-23 19:16:22 +0300  
**Последнее обновление:** 2026-09-24 11:27:12 +0300  
**Версия:** 2  
**Вид документа:** справочник

> Закон раскладки Пивомера. Другое дерево не предлагать и не «улучшать».  
> Решение: [ADR 004](decisions/004-portion-and-journal.md). Обзор: [architecture.md](architecture.md).

Открывший `lib/` должен сразу видеть два ограниченных контекста. Слои живут внутри контекста, не вокруг него. Агрегат — папка в `domain/`: корень, сущности и value object'ы лежат рядом, без общих корзин `entities/` и `value_objects/`.

## Почему так

Контекст — граница языка, не слой. Слой-first (`lib/domain`, `lib/data`, `lib/presentation` на всё приложение) прячет порцию и журнал. Контексты только в `packages/beer_ledger_core` прячут их от того, кто открыл приложение.

Техническое ядро — не контекст. Единицы измерения, `Failure`, `Result` и маркеры DDD не отвечают ни на «что будет при нажатии», ни на «что уже случилось».

## Дерево

```
lib/
├── core/                                 # композиция приложения, не бизнес-контекст
│   ├── di/                               # now, провайдеры базы и репозиториев
│   └── persistence/                      # AppDatabase — одна SQLite на оба контекста
├── bounded_contexts/
│   ├── portion/                          # Bounded Context: порция
│   │   ├── domain/
│   │   │   └── clicker/                  # Aggregate
│   │   │       ├── clicker.dart          # Aggregate Root
│   │   │       ├── clicker_id.dart       # Value Object
│   │   │       ├── ledger_axis.dart      # Entity
│   │   │       ├── axis_sign.dart        # Value Object (enum)
│   │   │       ├── beer_half_liter.dart  # пресет корня
│   │   │       └── clicker_settings_repository.dart  # контракт
│   │   ├── application/                  # прочитать текущую порцию
│   │   ├── infrastructure/               # Drift-реализация порции
│   │   └── presentation/                 # экран настроек
│   └── journal/                          # Bounded Context: журнал
│       ├── domain/
│       │   └── click/                    # Aggregate
│       │       ├── click.dart            # Aggregate Root, Click.record
│       │       ├── click_id.dart         # Value Object
│       │       ├── signed_base_delta.dart# Value Object (sealed union)
│       │       ├── axis_contribution.dart# Value Object
│       │       ├── aggregate_for_period.dart
│       │       ├── period_balances.dart
│       │       └── click_repository.dart # контракт
│       ├── application/                  # записать, отменить, сегодня, семь дней
│       ├── infrastructure/               # Drift-реализация журнала
│       └── presentation/                 # главная: карточка, список, график
├── app/                                  # оболочка: роутер, flavor
├── main.dart
└── l10n/

packages/beer_ledger_core/lib/            # техническое ядро (на картинке — lib/core/arch + словарь)
├── arch/                                 # AggregateRoot, Entity, ValueObject
├── measure/
├── convert/
├── failure/
├── result/
└── ledger_axis_kind.dart                 # четыре оси продукта, общий словарь
```

Пакет `beer_ledger_core` — это техническое ядро с картинки: без `import flutter`, тесты на VM. В `lib/core/` приложения только то, чему нужен Flutter или Drift: DI и `AppDatabase`. Сетевого клиента и темы в v1 нет — папок `network/` и `theme/` не заводить.

## Что куда класть

| Что | Где | Не класть |
|-----|-----|-----------|
| Ограниченный контекст | `lib/bounded_contexts/<имя>/` | корень `lib/`, пакет core |
| Слой | внутри своего контекста: `domain/`, `application/`, `infrastructure/`, `presentation/` | общие `lib/domain`, `lib/data`, `lib/features`, `lib/presentation` |
| Агрегат | `domain/<имя_корня>/` | `domain/entities`, `domain/value_objects` |
| Корень агрегата | файл с именем корня в папке агрегата | рядом с чужим корнем |
| Сущность и value object | в папке своего агрегата | общая корзина типов |
| Контракт репозитория | в папке агрегата, который хранит | `infrastructure/` |
| Реализация Drift | `infrastructure/` того же контекста | `domain/` |
| Сценарий (use case) | `application/` того же контекста | `lib/app/providers` |
| Экран | `presentation/` того же контекста | `lib/features` |
| Единицы, Failure, Result, маркеры DDD | `packages/beer_ledger_core` | внутрь контекста |
| `LedgerAxisKind` | `beer_ledger_core` — оба языка называют одни оси | третий контекст |
| `AppDatabase` | `lib/core/persistence/` | внутрь одного контекста как «его база» |

Имена папок без суффиксов `_context` и `_aggregate`. Роль видна по родителям: `bounded_contexts/portion`, `domain/clicker`. Файлы без суффиксов `Entity` / `ValueObject`: роль видна по месту и по маркеру в типе.

## Зависимости

```
presentation → application → domain ← infrastructure
```

Контекст не импортирует `domain/` и `infrastructure/` соседа. Мост порция → журнал — `Click.record` в агрегате `click`. Пока запись принимает `Clicker`, это единственное дозволенное чтение домена порции из домена журнала. Снимать его будет отдельный шаг: сценарий записи переведёт оси сам.

`beer_ledger_core` не импортирует `lib/`.

## Чего в дереве нет

- `lib/features/`
- `lib/data/`
- `lib/domain/` и `lib/application/` на весь app
- `lib/presentation/` на весь app
- `packages/beer_ledger_core/lib/portion/` и `.../journal/`
- третьего контекста «витрина»
- контекста «деньги» и контекста «единицы измерения»

## Следующие шаги кода (не это дерево)

Главная на UI Projection остаётся в `journal/presentation/`.
