# CI и static analysis

**Дата создания:** 2026-07-27 14:56:23 +0500  
**Последнее обновление:** 2026-07-27 14:56:23 +0500  
**Версия:** 1  
**Вид документа:** справочник

> Контракт качества для PR. Workflow: [`.github/workflows/ci.yml`](../.github/workflows/ci.yml).

## Политика

- **0 errors, 0 warnings** — локально и в CI.
- В CI включён `--fatal-warnings`: любой warning = красный pipeline.
- Infos тоже не игнорируем: цель — чистый лог analyzer.

## Monorepo: два контекста

| Пакет | Команды | Что анализируется |
|-------|---------|-------------------|
| **core** | `dart pub get`, `dart analyze --fatal-warnings`, `dart test` | `packages/beer_ledger_core` целиком, включая `test/` |
| **app** | `flutter pub get`, `flutter analyze --fatal-warnings lib` | только `lib/` приложения |

**Почему не `flutter analyze` с корня:** analyzer подхватывает `packages/beer_ledger_core/test/`, но `package:test` — dev_dependency core, не app → ложные errors. Core проверяется отдельным job.

Когда появится `test/widget_test.dart`:

```bash
flutter analyze --fatal-warnings lib test
```

## Локально перед PR

```bash
# core
cd packages/beer_ledger_core
dart pub get && dart analyze --fatal-warnings && dart test

# app (из корня репо)
cd ../..
flutter pub get && flutter analyze --fatal-warnings lib
```

## GitHub Actions

- **Trigger:** push и PR в `main`
- **Jobs:** `core` и `app` параллельно
- **Badge:** в [README](../README.md)

Подробности pipeline — в workflow yaml.

## Связанные документы

- [architecture.md](./architecture.md) — monorepo layout
- [AGENT_INVARIANTS.md](./AGENT_INVARIANTS.md) — инварианты для агентов
