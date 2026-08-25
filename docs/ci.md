# CI и static analysis

**Дата создания:** 2026-07-27 14:56:23 +0500  
**Последнее обновление:** 2026-08-25 16:04:55 +0500  
**Версия:** 4  
**Вид документа:** справочник

> Контракт качества для PR. Workflow: [`.github/workflows/ci.yml`](../.github/workflows/ci.yml).  
> Ручная сборка dev APK: [`.github/workflows/dev-apk.yml`](../.github/workflows/dev-apk.yml).

## Политика

- **0 errors, 0 warnings** — локально и в CI.
- В CI включён `--fatal-warnings`: любой warning = красный pipeline.
- Infos тоже не игнорируем: цель — чистый лог analyzer.

## Monorepo: три контекста

| Пакет | Команды | Что анализируется / собирается |
|-------|---------|--------------------------------|
| **core** | `dart pub get`, `dart analyze --fatal-warnings`, `dart test` | `packages/beer_ledger_core` целиком, включая `test/` |
| **app** | `flutter pub get`, `flutter analyze --fatal-warnings lib` | только `lib/` приложения |
| **apk** | `flutter pub get`, `flutter build apk --flavor dev` | Android APK flavor `dev`; файл не в git |

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

- **CI** ([`ci.yml`](../.github/workflows/ci.yml)): trigger — push и PR в `main`. Jobs `core` и `app` параллельно. Badge — в [README](../README.md).
- **Dev APK** ([`dev-apk.yml`](../.github/workflows/dev-apk.yml)): только вручную (`workflow_dispatch`), **не** на push/PR.

  Запуск:

  1. Actions → **Dev APK** → **Run workflow**
  2. Поле **branch** — какую ветку собрать:
     - `main` — релизная линия после merge
     - `feat/…` — проверить PR-ветку **до** merge (код берётся с указанной ветки)
  3. Run → Artifacts → `beer-ledger-dev-<ветка>-<N>.apk` (слэши в имени ветки → `-`)

  Кнопка **Dev APK** видна только если `dev-apk.yml` уже в `main`. Сам workflow-файл всегда из `main`; собираемый код — с ветки из поля **branch**.

Подробности — комментарий в начале [`dev-apk.yml`](../.github/workflows/dev-apk.yml) и [README § Сборка dev APK](../README.md).

## Связанные документы

- [architecture.md](./architecture.md) — monorepo layout
- [AGENT_INVARIANTS.md](./AGENT_INVARIANTS.md) — инварианты для агентов
