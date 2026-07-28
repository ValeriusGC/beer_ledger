# ADR 002: стиль domain-слоя в beer_ledger_core

**Дата создания:** 2026-07-28 13:56:32 +0500  
**Последнее обновление:** 2026-07-28 16:06 +0500  
**Версия:** 4  
**Вид документа:** ADR

**Статус:** Accepted  
**Итерация:** 1.1 (core)

> Pure Dart domain для Пивомера: миграция из `fast_2020`, современный typed errors + fpdart, **без** legacy-инфраструктуры и **без** копирования `ExtendedErrors` из remarked.

Связанные документы: [ADR 003](./003-closed-unit-set.md) · [architecture.md](../architecture.md) · [ci.md](../ci.md)

---

## Контекст

1. **Источник логики** — pet-project `fast_2020`: `MeasureUnit`, calcs, `Click`/`Clicker`, aggregation. Код рабочий, но завязан на `uolles_sys`, `Rez`/`Ex`, Flutter-импорты в calcs, устаревшие паттерны (runtimeType switch, mutable lists в domain).

2. **Целевой пакет** — `packages/beer_ledger_core`: только VM-тесты, **без** `import flutter`, публичный API для app и CI job `core`.

3. **Референс** — production-практики (freezed на entities, typed errors, тесты-first). **Не** parity с `remarked_template` ради parity: `ExtendedErrors` там — transport/UI blob, в Пивомер **не** переносим.

4. **Сквозная система ошибок** — один sealed `Failure` в core; iter 2 добавляет варианты (storage и т.д.) **в том же union**. App мапит `Failure` → пользовательский текст в Controller/Factory, не в виджетах.

---

## Решение

### 1. Модели сущностей — `@freezed`

`Click`, `Clicker`, `LedgerAxis` (и value objects при необходимости) — **immutable** через `freezed`:

- `==`, `hashCode`, `copyWith`, `toString` — из codegen;
- JSON — **не** в iter 1.1.

### 2. Ошибки — `@freezed sealed` `Failure`

Единый тип ошибки monorepo (сначала domain, потом infra):

```dart
// Иллюстрация формы, не финальный API
@freezed
sealed class Failure with _$Failure {
  const factory Failure.incompatibleUnits({required String fromId, required String toId}) =
      IncompatibleUnits;
  const factory Failure.invalidPeriod({required DateTime from, required DateTime to}) =
      InvalidPeriod;
  // iter 2+: Failure.storage(...), ...
}
```

Правила:

- domain **не бросает** exceptions для ожидаемых business rules;
- exhaustive `switch (failure)` в mapper’е UI (iter 2+);
- **не** отдельный `ExtendedErrors` / transport blob.

### 3. Результат операций — `fpdart` + typedef `Result<T>`

```dart
import 'package:fpdart/fpdart.dart';

typedef Result<T> = Either<Failure, T>;
```

**Convention (обязательна):**

| Сторона | Значение |
|---------|----------|
| **Left** | `Failure` |
| **Right** | успех (`T`) |

Public API core и repository (iter 2): сигнатуры **`Result<T>`**, не `Either<…>`.

Цепочки внутри файла: `map`, `flatMap`, `match`, `fold` из fpdart.

- **Не** самописный freezed `Ok`/`Err` — дублирует fpdart;
- **Не** `Rez`/`Ex` из `fast_2020` / `uolles_sys`.

### 4. Единицы измерения — enhanced enum на семейство

Каждое семейство — **enum** со полями `id`, `symbol`, `ratioToBase`, реализующий интерфейс `MeasureUnit`. Замкнутость набора и полнота `switch` обеспечены языком, а не дисциплиной.

| Решение | Причина |
|---------|---------|
| `enum VolumeUnit implements MeasureUnit` (и 5 других семейств) | замкнутый набор — языковая гарантия; `values`, `index`, `==`, канонические экземпляры бесплатны |
| `abstract interface class MeasureUnit` | enum умеет только `implements`; замкнутость держится на уровне семейства — там, где нужна для конвертации |
| `enum MeasureFamily` + `MeasureUnit.family` | совместимость проверяется полем, а не `runtimeType`; `sealed`-иерархия классов потребовала бы `part of` — отвергнуто |
| `static final _byId = {for (final u in values) u.id: u}` | строка-идентификатор существует в одном месте — рядом со своим значением; без `switch` и без отдельных const-строк |
| `static T? tryFromId(String id)` | неизвестный id → `null`; в `fast_2020` фабрика `make` молча возвращала единицу по умолчанию и прятала повреждённые данные |
| `symbol`, не `name` | `name` у enum занято языком (`EnumName.name` — исходный идентификатор значения) |
| `ratioToBase`, `baseUnit`, `defaultUnit` | вместо `convRatio`, `byDefault`, `list` |
| `energy` и `count` — разные семейства | в `fast_2020` калории и счётчики жили в одном наборе, поэтому перевод «порции → ккал» прошёл бы без ошибки |
| cm³ / dm³ и unit-заглушка `∅` не переносятся | дубли миллилитра и литра; ось без единицы выражается отсутствием единицы (`null`) |
| пинты по точным определениям: `473.176473` и `568.26125` мл | в `fast_2020` пинта США была округлена до `470` мл |

Отвергнутая первая редакция PR 2 — класс с приватным конструктором, рукописным `static const values` и `switch` в `tryFromId`. Это идиома Dart **до 2.17**: замкнутость держится на модификаторе `base`, полнота `values` — на внимательности, а `switch` требует отдельных const-строк, потому что `unit.id` не константное выражение. Enhanced enum снимает все три пункта.

Замкнутость набора и правило хранения факта — отдельное решение: **ADR 003**.

### 5. Зависимости и codegen

| Артефакт | Политика |
|----------|----------|
| `fpdart` | **dependency** в `beer_ledger_core` (Result без codegen) |
| `freezed`, `freezed_annotation`, `build_runner` | entities + `Failure` |
| `*.freezed.dart` | **Коммитим в git** |
| CI | без шага `build_runner` (gen в tree) |
| После правки `@freezed` | `dart run build_runner build --delete-conflicting-outputs` |

### 6. Структура пакета (iter 1.1)

```
packages/beer_ledger_core/lib/
├── measure/
├── domain/
├── aggregate/
├── convert/
├── result/            # typedef Result<T> = Either<Failure, T>
├── failure/           # sealed Failure (@freezed)
└── beer_ledger_core.dart
```

### 7. Агрегация периода

`aggregateForPeriod(clicks, axes, from, to)`:

- интервал **`[from, to)`** — local `DateTime`;
- пустой период / 0 clicks → нулевые балансы, **не** ошибка;
- `from >= to` → `Failure.invalidPeriod`.

### 8. Слои и Either

| Слой | Допустимо |
|------|-----------|
| core domain | `Result<T>` |
| repository (iter 2) | `Future<Result<T>>` |
| Controller / Factory | `match` → UiModel / snackbar text |
| Widget | **нет** `Either` / `Result` в `build()` |

### 9. Явно не переносим

| Из fast_2020 / remarked | Причина |
|-------------------------|---------|
| `uolles_sys`, `Rez`, `Ex`, `Micros` | legacy |
| `ExtendedErrors` | transport blob remarked; у нас `Failure` |
| `ImgWrapper`, `ClickerFlags`, template UID | scope v1 |
| `findFactoryOf` / `runtimeType` switch | явные типы |
| `import flutter` в core | граница пакета |

---

## Альтернативы

### A. Самописный freezed `Result` (Ok / Err)

**Плюсы:** семантические имена без Left/Right.  
**Минусы:** дублирует fpdart; maintain `map`/`flatMap`; второй union codegen.  
**Отвергнуто (v2 ADR):** fpdart покрывает API; `Result` = typedef.

### B. `equatable` на entities

**Отвергнуто:** freezed даёт copyWith + equality для entities.

### C. `Either` без typedef в public API

**Минусы:** `Either<Failure, T>` шумнее в сигнатурах.  
**Отвергнуто:** public — `Result<T>`, Either — implementation.

---

## Последствия

**Плюсы**

- Отлаженный fpdart (`flatMap`, `match`) без своего велосипеда;
- Сквозной `Failure`, расширяемый без смены паттерна;
- freezed только там, где нужен codegen (entities + failures);
- Читаемый portfolio narrative: typed errors + FP boundary, не copy-paste remarked.

**Минусы / costs**

- Discipline: Left = failure — зафиксировано в ADR и code review;
- После правки `@freezed` — build_runner локально;
- App iter 2: один mapper `Failure` → user-facing message.

**Follow-up**

- ADR 001 (drift vs isar) — iter 2;
- `Failure.storage` и др. — новые factory в том же sealed class;
- `TaskEither` — опционально в repo, не обязателен в 1.1.

---

## Проверка соблюдения

- [ ] Public API: `Result<T>`, Left = `Failure`, Right = success
- [ ] Entities + `Failure` — `@freezed`, gen в commit
- [ ] Business rules → `Result`, не throw
- [ ] `dart analyze --fatal-warnings` и `dart test` зелёные в job `core`
- [ ] Нет `import flutter`, `uolles_sys`, `ExtendedErrors` в core
