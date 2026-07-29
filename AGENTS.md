# AGENTS.md — beer_ledger (Пивомер)

**Дата создания:** 2026-07-25 17:13:00 +0500  
**Последнее обновление:** 2026-07-29 09:30 +0500  
**Версия:** 3

Инструкции для AI-агентов в Cursor. Flutter/Dart pet-project, monorepo.

## Стек

- **Dart SDK:** ^3.12.2 (Flutter app + pure Dart core)
- **Monorepo:** `packages/beer_ledger_core` — domain без `import flutter` (**iter 1.1 ✅**)
- **State:** Riverpod 3 — *planned (iter 2)*
- **Routing:** go_router — *planned*
- **DB:** drift или isar — *ADR pending (iter 2)*
- **Charts:** fl_chart — *planned*
- **Lint:** flutter_lints ^6.0.0
- **Сейчас:** Material 3 shell (`lib/main.dart`), path dep на `beer_ledger_core`; 110 core-тестов

## Архитектура

Стандарты команды: **DDD**, **UI Projection**, **SOLID / YAGNI / KISS / DRY**.

| Документ | Назначение |
|---|---|
| `docs/architecture.md` | Monorepo, слои, миграция из fast_2020, целевой стек |

При сложных UI-задачах подключать `@docs/architecture.md`.

## Реестры общих артефактов

Путь: `docs/registries/`

Перед новым shared-кодом — **обязательно** `/registry-before-create`.

| Реестр | Файл |
|--------|------|
| Виджеты | `docs/registries/widgets.md` |
| Диалоги / modals | `docs/registries/dialogs_and_modals.md` |
| Форматтеры | `docs/registries/formatters.md` |
| Extensions | `docs/registries/extensions.md` |
| Утилиты | `docs/registries/utilities.md` |
| Провайдеры | `docs/registries/providers_and_services.md` |

## Cursor Rules

**Always-on (4):** `quality-bar`, `team-principles`, `dry-and-registries`, `honesty-time-no-fabrication`

**По globs `**/*.dart` / `lib/**`:** `no-reinvent-wheel`, `dart-cg-file-naming`, `riverpod-first-reactivity`, `pre-delivery-analyzer-and-logs-check`, `dart-dartdoc-comments`

**По globs `**/*.md`:** `doc-header-metadata` — шапка **Дата создания / Последнее обновление / Версия**

## MCP

Dart & Flutter MCP: `.cursor/mcp.json`

```json
{ "command": "dart", "args": ["mcp-server"] }
```

Требует Dart ≥ 3.9. Инструменты: analyze, pub.dev search, pubspec deps, run tests, format, runtime errors, widget tree (при запущенном app).

При сбоях roots в Cursor: `"args": ["mcp-server", "--force-roots-fallback"]`

Документация: [docs.flutter.dev/ai/mcp-server](https://docs.flutter.dev/ai/mcp-server)

## Skills

### Проектные (`.cursor/skills/`)

| Skill | Вызов | Когда |
|---|---|---|
| `architecture-ui-workflow` | `/architecture-ui-workflow` | Новый экран/виджет, UI Projection |
| `riverpod-codegen` | `/riverpod-codegen` | @riverpod, @freezed, build_runner |
| `registry-before-create` | `/registry-before-create` | Перед новым shared-кодом |
| `delivery-checklist` | `/delivery-checklist` | Перед сдачей / PR |

### Официальные (`.agents/skills/`)

Источник с 2026-07: **[flutter/agent-plugins](https://github.com/flutter/agent-plugins)** (dart + flutter skills в одном репо).

```bash
npx skills add flutter/agent-plugins --skill '*' --agent universal --yes
npx skills update
```

После добавления зависимостей с bundled skills (iter 2+, напр. Riverpod, drift):

```bash
dart run skills@ get --agent universal
```

Альтернатива npx без Node: `dart run skills@ add <git-url>` — см. [pub.dev/packages/skills](https://pub.dev/packages/skills).

Приоритетные:

- `dart-run-static-analysis`, `dart-fix-runtime-errors`, `dart-add-unit-test`, `dart-use-primary-constructors`
- `flutter-fix-layout-issues`, `flutter-setup-declarative-routing`, `flutter-add-widget-test`

**Осторожно:** `flutter-apply-architecture-best-practices` — сверять с UI Projection проекта; generic layered architecture может конфликтовать.

## Codegen

```bash
dart run build_runner build --delete-conflicting-outputs
```

Файлы с codegen: `*.cg.dart` → `gen/*.g.dart`, `gen/*.freezed.dart`

## Pre-delivery

1. `flutter analyze` — без новых errors в затронутых файлах
2. `/delivery-checklist`
3. Реестры обновлены при новом shared-коде
4. Тесты: `flutter test` (app), `cd packages/beer_ledger_core && dart test` (core)

## Типовые промпты

- «Добавь экран по UI Projection, dumb widgets only»
- «Проверь static + runtime analysis, исправь layout issues»
- «Перед созданием диалога — проверь реестры»
- «Добавь @riverpod провайдер, запусти codegen»
