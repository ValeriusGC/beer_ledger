# ADR 001: хранение тапов (clicks) — drift + SQLite

**Дата создания:** 2026-08-02 18:02:59 +0500  
**Последнее обновление:** 2026-08-02 18:02:59 +0500  
**Версия:** 1  
**Вид документа:** ADR

**Статус:** Accepted  
**Итерация:** 2 (persistence)

> Локальное хранение [Click](../../packages/beer_ledger_core/lib/domain/click.dart) в Flutter app через **drift** (SQLite). Domain остаётся в `beer_ledger_core`; repository и мапперы — в `lib/data/`.

Связанные документы: [ADR 002](./002-domain-style.md) · [ADR 003](./003-closed-unit-set.md) · [architecture.md](../architecture.md)

---

## Контекст

1. **iter 1.1 ✅** — domain-модели и агрегация в pure Dart (`beer_ledger_core`). Запись тапа — immutable снимок вкладов по осям (ADR 003 §2); пересчёт при чтении запрещён.

2. **iter 2** — offline-first persistence: тап сохраняется, после cold start данные и баланс на месте. Минимальный контракт repository (#28–#29): `addClick`, `watchClicksForDay`, `undoLastClick`.

3. **Граница слоёв** — SQLite и drift живут **только в app** (`lib/data/`). Core не импортирует Flutter и не знает о БД; repository мапит строки → `Click`.

4. **Агрегация** — `aggregateForPeriod` принимает `List<Click>` из core; интервал **`[from, to)`** в **local** `DateTime` (ADR 002 §7). Repository обязан отдавать тапы, согласованные с этим правилом.

---

## Требования v1

| Требование | Источник |
|------------|----------|
| Persist полного `Click` с `contributions` | ADR 003, domain |
| Поток изменений за локальный день (Riverpod #30) | iter 2 |
| Undo последнего тапа — delete, не edit | spec v1, deferred-decisions §4 |
| Явные миграции при изменении схемы | portfolio, maintainability |
| Ошибки БД → `Failure.storage` в том же union (ADR 002) | iter 2 follow-up |
| Без пересчёта вкладов при чтении | ADR 003 §2 |

**Не в scope ADR:** settings clicker, экспорт, sync, edit-in-place.

---

## Рассмотренные варианты

### A. drift (SQLite, typed ORM)

**Плюсы:** SQL-схема явная и ревьюируемая; миграции через `MigrationStrategy`; `watch()` на query для Riverpod; распространён в senior Flutter-портфолио; маппер `Row → Click` отделяет persistence от domain.

**Минусы:** больше boilerplate, чем у document-DB; вложенные `contributions` — отдельная таблица или JSON (см. ниже).

### B. isar (local NoSQL, embedded objects)

**Плюсы:** `List<AxisContribution>` как embedded list без join; быстрые read/write; `watch()` на filter.

**Минусы:** схема менее прозрачна в PR (codegen вместо SQL); миграции — через версии Isar, слабее narrative «relational + migrations»; привязка к Flutter-экосистеме; для pet-project с 4 осями выигрыш по скорости не нужен.

**Отвергнуто:** для v1 объём данных мал, критичнее явная схема и SQL-миграции под portfolio, чем embedded NoSQL.

### C. In-memory only (prod)

**Плюсы:** нулевая настройка для прототипа.

**Минусы:** cold start теряет данные — нарушает критерий iter 2.

**Отвергнуто:** допустимо только в unit-тестах repository (fake/in-memory drift или mock).

### D. JSON-колонка для `contributions` (внутри drift)

Одна таблица `clicks`, поле `contributions_json TEXT`.

**Плюсы:** один INSERT на тап; проще drift-таблица.

**Минусы:** нет FK на уровне SQL; эволюция формы contribution — парсинг JSON; сложнее отладка в sqlite CLI.

**Отвергнуто:** для v1 с 4 осями нормализованная таблица проще для миграций и ревью.

---

## Решение

### 1. БД — **drift** + SQLite

Пакеты (app, iter 2 PR #28): `drift`, `drift_flutter`, `sqlite3_flutter_libs` (или актуальный набор по docs drift на момент PR).

Файлы: `lib/data/local/app_database.dart`, `lib/data/repositories/click_repository.dart`, мапперы рядом.

### 2. Схема

#### Таблица `clicks`

| Колонка | Тип | Описание |
|---------|-----|----------|
| `id` | `TEXT` PK | UUID v4 строкой |
| `clicker_id` | `TEXT` NOT NULL | ссылка на preset/config clicker |
| `at_utc_ms` | `INTEGER` NOT NULL | момент тапа — **UTC**, миллисекунды с epoch |
| `factor` | `REAL` NOT NULL DEFAULT 1.0 | множитель тапа |

Индекс: `(at_utc_ms DESC)` — для undo и сортировки истории.

#### Таблица `click_contributions`

| Колонка | Тип | Описание |
|---------|-----|----------|
| `click_id` | `TEXT` FK → `clicks.id` ON DELETE CASCADE | |
| `kind` | `TEXT` NOT NULL | wire: `volume`, `energy`, `money`, `joy` ([LedgerAxisKind](../../packages/beer_ledger_core/lib/domain/ledger_axis_kind.dart)) |
| `signed_base_delta` | `REAL` NOT NULL | факт в базовой единице × знак (ADR 003) |
| `entered_in_id` | `TEXT` NOT NULL | wire-id единицы ввода для UI |

PK: `(click_id, kind)` — в v1 одна ось каждого вида на тап.

```sql
-- Иллюстрация v1; drift генерирует DDL из Table-классов
CREATE TABLE clicks (
  id TEXT PRIMARY KEY NOT NULL,
  clicker_id TEXT NOT NULL,
  at_utc_ms INTEGER NOT NULL,
  factor REAL NOT NULL DEFAULT 1.0
);

CREATE INDEX idx_clicks_at ON clicks (at_utc_ms DESC);

CREATE TABLE click_contributions (
  click_id TEXT NOT NULL REFERENCES clicks(id) ON DELETE CASCADE,
  kind TEXT NOT NULL,
  signed_base_delta REAL NOT NULL,
  entered_in_id TEXT NOT NULL,
  PRIMARY KEY (click_id, kind)
);
```

### 3. Время: UTC в БД, local при фильтре

- **Запись:** `Click.at` (может быть local или UTC в Dart) → нормализовать к **UTC instant** → `at_utc_ms`.
- **Чтение:** `DateTime.fromMillisecondsSinceEpoch(at_utc_ms, isUtc: true)` → при необходимости `.toLocal()` для UI.
- **`watchClicksForDay(dayLocal)`:** границы локального дня `[startOfDay, startOfNextDay)` перевести в UTC ms; SQL `WHERE at_utc_ms >= ? AND at_utc_ms < ?`; результат собрать в `Click` с `at` в local (или UTC — единообразно в маппере, главное согласованность с `aggregateForPeriod`).

Правило: **в SQLite только UTC instant**; семантика «день» — timezone устройства на момент запроса.

### 4. Операции repository

| Метод | Поведение |
|-------|-----------|
| `addClick` | INSERT `clicks` + batch INSERT `click_contributions` в одной транзакции |
| `watchClicksForDay` | drift `watch()` на query с UTC-диапазоном; join/map contributions → `List<Click>` |
| `undoLastClick` | DELETE FROM `clicks` WHERE `id` = (SELECT `id` FROM `clicks` ORDER BY `at_utc_ms` DESC, `id` DESC LIMIT 1); CASCADE удалит contributions |

Undo v1 — **глобальный** последний тап (не «последний за сегодня»). Edit-in-place — вне scope (deferred-decisions §4).

### 5. Контракт repository (app)

```dart
// lib/data/repositories/click_repository.dart — иллюстрация, PR #28
abstract interface class ClickRepository {
  Future<Result<void>> addClick(Click click);

  /// [dayLocal] — календарная дата в локальной TZ пользователя.
  Stream<List<Click>> watchClicksForDay(DateTime dayLocal);

  /// Удаляет последний тап по (at DESC, id DESC).
  Future<Result<void>> undoLastClick();
}
```

- Сигнатуры — **`Result<T>`** (ADR 002); repository не бросает необработанные исключения SQLite наружу.
- Реализация: `DriftClickRepository` + `@Riverpod` — PR #28–#30.

### 6. `Failure.storage` (iter 2, PR #28)

Добавить в sealed `Failure` (core, тот же union):

```dart
const factory Failure.storage({
  required String operation,
  Object? cause,
}) = StorageFailure;
```

Mapper UI: generic «Не удалось сохранить» + лог `cause` в debug.

---

## Последствия

**Плюсы**

- Явная SQL-схема и миграции — reviewable PR, portfolio narrative;
- Domain изолирован: тесты core без SQLite;
- Нормализованные contributions — проще эволюция полей без JSON-парсинга;
- `watch()` drift → прямой путь к Riverpod `StreamProvider`.

**Минусы / costs**

- Два слоя маппинга: drift row ↔ `Click`;
- `build_runner` для drift + freezed в monorepo;
- Undo «последний глобально» может удивить, если тапы за разные дни — приемлемо для v1.

**Follow-up**

- PR #28: зависимости drift, `AppDatabase`, `DriftClickRepository`, `Failure.storage`;
- PR #29: `undoLastClick`;
- PR #30–#31: providers + `aggregateForPeriod`;
- iter 2.5+: таблица settings clicker (отдельная миграция).

---

## Проверка соблюдения

- [ ] Persistence только в `lib/data/`, не в `beer_ledger_core`
- [ ] `Click` при чтении совпадает с domain-моделью (contributions не пересчитываются)
- [ ] `at` в БД — UTC ms; фильтр «день» — local boundaries
- [ ] Repository API — `Result<T>`, ошибки БД → `Failure.storage`
- [ ] Миграции drift при изменении схемы — отдельный PR, не silent break
