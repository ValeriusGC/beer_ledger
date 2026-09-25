# Промпт 3.5 / шаг 5: `parse` / `known` у `ClickId` и `ClickerId`

**Дата создания:** 2026-09-24 15:26:41 +0300  
**Последнее обновление:** 2026-09-24 16:28:42 +0300  
**Версия:** 3  
**Вид документа:** выполнен

> Не выполнять. Шаг влит в `main`: [#67](https://github.com/ValeriusGC/beer_ledger/issues/67) / [PR #68](https://github.com/ValeriusGC/beer_ledger/pull/68). Следующий промпт — `docs/prompts/iter-3.5/06-home-ui-projection.md`.

---

## Контекст (rules/skills не пересказывать)

Действуют project rules и skills этого репо. Их не цитируй — соблюдай.

Репо: `beer_ledger`  
Режим: Agent  
Skills: не нужны. `/delivery-checklist` не запускай. `/architecture-ui-workflow` не запускай. `/riverpod-codegen` не запускай, кроме двух `build_runner` ниже.

Я техлид. Ты делаешь **шаг 5**, не шаг 4 и не шаг 6. Исходная точка уже на диске — не «как было вчера», а **текущий `main` после [#66](https://github.com/ValeriusGC/beer_ledger/issues/66)**.

Что уже сделано (не повторять):

- дерево `lib/bounded_contexts/portion` и `.../journal` (#62);
- типы `ClickId`, `ClickerId`, `SignedBaseDelta` — обёртки без разбора строки (#64);
- `Click.record` принимает `List<AxisRecordInput>`, не `Clicker`; перевод осей — `axisRecordInputsFrom` в `journal/application` (#66).

**Два коммита шага, не один.**

1. Уже должен быть на `main`, когда ты это читаешь: в коммите **только** `docs/prompts/iter-3.5/05-id-parse.md`. Без Dart. Это не твой коммит и не часть коммита кода. Проверка — G0.
2. Твой коммит — один, на ветке `feat/<номер>-id-parse`, уже **после** issue и `checkout -b`. В нём нет файла промпта.

Пока `git branch --show-current` печатает `main`, тебе нельзя `git add` и `git commit` (ни промпт, ни код). Сначала G0, потом issue, потом ветка, потом правки, потом ворота, потом коммит 2.

Если на диске не то, что в «Карте» — стоп и напиши, что увидел. Не додумывай.

---

## Карта: зачем этот шаг и кто с кем говорит

`ClickId` живёт в журнале: `lib/bounded_contexts/journal/domain/click/click_id.dart`.  
`ClickerId` живёт в порции: `lib/bounded_contexts/portion/domain/clicker/clicker_id.dart`.  
Это разные типы. Компилятор уже не даст подставить одно вместо другого. Это шаг 3.

Дыра, которая осталась: оба типа — `const factory ClickId(String value)` / `ClickerId(String value)`. Пустую строку компилятор принимает. Для портфолио value object, который **нельзя** создать из мусора, обычно имеет два входа:

- **`parse`** — строка, которой мы не доверяем. Возвращает `Result<ClickId>` — в этом репо это `Either<Failure, T>`, **не** `Result<ClickId, Failure>`. Пустая строка → новый `Failure.emptyId()`. Не UUID, не trim, не «похоже на имя».
- **`known`** — строка, которой мы доверяем, потому что она из **нашего** кода: пресет `clicker-beer`, тестовые `'click-1'`, только что порождённый `Uuid().v4()`, id, который мы сами записали в SQLite. Пустую не проверяет. Это не `@visibleForTesting unsafe`: пресетu `beerHalfLiter` нужен **продовый** литерал, видимый в `lib/`.

Почему маппер Drift **не** зовёт `parse`: `clickFromRows` и `clickerFromSettingsRow` возвращают `Click` / `Clicker`, не `Result`. Переписывать их в `Result` — другой шаг, не этот. Строки в БД мы записали сами. Там `ClickId.known(row.id)` и `ClickerId.known(row.clickerId)`.

Почему `SignedBaseDelta.parse` нет: это не строка с границы, это `double` уже в базовой единице. Не выдумывай разбор.

Цепочка тапа **не меняется** (кнопка → `RecordClick` → `axisRecordInputsFrom` → `Click.record(axes:)` → репозиторий). Меняется только **как собирается** `ClickId` / `ClickerId` в тех местах, где сейчас `ClickId('…')`.

На телефоне цифры те же. Главную на UI Projection не переписывать (шаг 6).

---

## Задача (одно предложение)

У `ClickId` и `ClickerId` публичный вход — `parse` и `known`; голый `ClickId('x')` больше не компилируется; пустая строка в `parse` даёт `Failure.emptyId`.

---

## Что не переспрашивать

1. `Result<ClickId>` = `Either<Failure, ClickId>`. Образец: `Click.record` → `Result<Click>`.
2. Одна новая ветка union: `Failure.emptyId()` без полей. И для тапа, и для кликера. Не `invalidName`, не `emptyClickId` + `emptyClickerId`.
3. Пустая = `raw.isEmpty`. Пробел `' '` — **не** пустая, `parse` даёт Right. Формат UUID не проверять.
4. Фабрика `const factory ClickId(String value)` **удаляется**. Остаётся `const factory ClickId.known(String value)`. Иначе `parse` обходят.
5. `@visibleForTesting unsafe` не заводить.
6. `parse` в прод-мапперах и в `RecordClick` не вызывать: там `known`. `parse` — тесты + публичный API на будущее.
7. ADR 001–004 не трогать. `git diff docs/decisions/` пустой.
8. Первый коммит шага (только промпт на `main`) уже сделан человеком. Второй — твой, только код, только на `feat/…`. Промпт в коммит кода не класть.
9. DartDoc: публичный API по-русски, первая строка — что это. Private и generated — без шума.

---

## Порядок Git (G0→G6). Не переставлять

Правки Dart — **только после G3**.

### G0 — посмотреть

```bash
git branch --show-current
git status -sb
```

Ожидание: `main`, чисто (`## main` или `## main...origin/main` и больше ничего). Иначе стоп.

Первый коммит шага — только промпт. Проверь **последний** коммит `main`:

```bash
git log -1 --name-only
```

В списке файлов ровно одна строка: `docs/prompts/iter-3.5/05-id-parse.md`. Есть ещё файлы, нет этого файла, или этот файл в `git status` как неотслеживаемый/изменённый — **стоп**. Не `git add`. Не мешай промпт с кодом. Человек коммитит промпт отдельно.

Проверка, что ты на шаге 5, а не повторяешь 4:

```bash
rg "required List<AxisRecordInput> axes" lib/bounded_contexts/journal/domain/click/click.dart
rg "const factory ClickId\(String value\)" lib/bounded_contexts/journal/domain/click/click_id.dart
```

Первая команда **не** пустая (мост уже разорван). Вторая **не** пустая (ещё старая фабрика). Если `ClickId.known` уже есть, а безымянной фабрики нет — шаг сделан, стоп.

### G1 — issue. Файлы не трогать

Родительский issue не заводи.

```bash
gh issue create \
  --repo ValeriusGC/beer_ledger \
  --milestone "v1.3.5 — lite DDD" \
  --title "refactor: parse и known у ClickId и ClickerId" \
  --body "$(cat <<'EOF'
ClickId и ClickerId: parse → Result, пустая строка — Failure.emptyId; доверенный литерал — known. Не UUID. Не SignedBaseDelta.parse. Не закрывает другие issue.
EOF
)"
```

Число из URL — `<номер>`. Ветка будет `feat/<номер>-id-parse`. После G1 ты на `main`. `git commit` нельзя.

### G2 — ветка до правки файлов

```bash
git checkout -b feat/<номер>-id-parse
git branch --show-current
```

Ожидание: `feat/<номер>-id-parse`. Напечатало `main` — стоп.

### G3 — ворота

```bash
git branch --show-current
```

Не та строка — стоп. Совпала — раздел «Работа».

### G4 — работа на ветке

Не `git switch main`. Не промежуточный коммит.

### G5 — ворота перед коммитом

```bash
git branch --show-current
```

| Вывод | Действие |
| --- | --- |
| `feat/<номер>-id-parse` | G6 |
| `main` | не `git add`, не `git commit`. Если файлы уже грязные: `git checkout -b feat/<номер>-id-parse`, снова G5, потом G6 |
| иное | стоп, напиши имя |

### G6 — второй коммит шага: только код, только feat/

Это **не** первый коммит шага. Первый уже на `main` (только промпт). В индекс **не** класть `docs/prompts/iter-3.5/05-id-parse.md`.

```
Доверенный id — known, недоверенная строка — parse; пустой id — Failure.emptyId.

Ref #<номер>
```

Слов `Closes` / `Fixes` / `Close` нет.

После:

```bash
git branch --show-current
git log -1 --oneline
git status -sb
```

Ветка `feat/…`, один новый коммит, чисто. Коммит на `main` — не push, стоп.

Push и PR — только после отдельной фразы человека.

---

## Работа (после G3)

Прочитай целиком:

- `lib/bounded_contexts/journal/domain/click/click_id.dart`
- `lib/bounded_contexts/portion/domain/clicker/clicker_id.dart`
- `lib/bounded_contexts/portion/domain/clicker/beer_half_liter.dart`
- `lib/bounded_contexts/journal/application/record_click.cg.dart` — строка с `ClickId(const Uuid().v4())`
- `lib/bounded_contexts/journal/infrastructure/click_mapper.dart`
- `lib/bounded_contexts/portion/infrastructure/clicker_settings_mapper.dart`
- `packages/beer_ledger_core/lib/failure/failure.dart`
- `packages/beer_ledger_core/lib/result/result.dart`
- `test/bounded_contexts/portion/domain/clicker/clicker_id_test.dart`

### W1. `Failure.emptyId` в ядре

Файл: `packages/beer_ledger_core/lib/failure/failure.dart`  
Рядом с `unknownUnitId`, **до** `storage`:

```dart
/// Пустой идентификатор тапа или кликера ([ClickId.parse], [ClickerId.parse]).
const factory Failure.emptyId() = EmptyId;
```

Ссылки `[ClickId]` в DartDoc ядра: типы живут в приложении. Напиши без сломанной ссылки, например: «пустой id тапа или кликера после `parse`».

Из каталога `packages/beer_ledger_core`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Коммитим обновлённый `failure.freezed.dart`. Если команда переписала чужое — `git checkout --` и стоп.

В `packages/beer_ledger_core/test/result/result_test.dart`, группа `Failure variants`, добавь тест: `Failure.emptyId()` равен себе. Остальные тесты группы не переписывать.

Исчерпывающих `switch` по `Failure` в приложении нет — новый вариант сам по себе analyze не сломает. Не добавляй ветку в UI и не заводи l10n.

### W2. `ClickId`

Файл: `lib/bounded_contexts/journal/domain/click/click_id.dart`.

Нужны импорты `result.dart`, `failure.dart` (или баррель ядра) и `fpdart` для `Left`/`Right` — как в `click.dart`.

Заменить безымянную фабрику. Оставить `implements ValueObject`, `part 'click_id.freezed.dart'`.

```dart
@freezed
abstract class ClickId with _$ClickId implements ValueObject {
  const ClickId._();

  /// Доверенный идентификатор: пресет, тест, Uuid, строка из нашей SQLite.
  const factory ClickId.known(String value) = _ClickId;

  /// Разбирает недоверенную строку. Пустая → [Failure.emptyId], иначе [known].
  static Result<ClickId> parse(String raw) {
    if (raw.isEmpty) {
      return const Left(Failure.emptyId());
    }
    return Right(ClickId.known(raw));
  }
}
```

Обнови DartDoc класса: колонка TEXT по-прежнему `.value`; вход с границы — `[parse]`; литерал в коде — `[ClickId.known]`.

### W3. `ClickerId`

Тот же рисунок в `clicker_id.dart`: `ClickerId.known`, `ClickerId.parse` → `Result<ClickerId>`, пустая → тот же `Failure.emptyId()`.

### W4. Вызовы: `ClickId('…')` → `ClickId.known('…')`

Не `parse`. Список полный — пройди каждый файл.

**lib**

- `beer_half_liter.dart`: `const ClickerId.known('clicker-beer')` в значении по умолчанию.
- `record_click.cg.dart`: `ClickId.known(const Uuid().v4())`.
- `click_mapper.dart`: `ClickId.known(row.id)`, `ClickerId.known(row.clickerId)`.
- `clicker_settings_mapper.dart`: `ClickerId.known(row.clickerId)`.

**test** (хелперы `_recordClick` / `_click` / литералы):

- `click_record_test.dart` — все `const ClickId('…')` и `const ClickerId('…')`
- `aggregate_for_period_test.dart`
- `clicks_for_today_test.dart`, `today_balance_test.dart`, `undo_last_click_test.dart`, `volume_for_last_7_days_test.dart`
- `click_mapper_test.dart`, `drift_click_repository_test.dart`
- `beer_preset_matrix_test.dart` — `ClickId.known(id)`
- `today_clicks_section_test.dart`
- `clicker_id_test.dart` — `const ClickerId.known('a')`
- `beer_half_liter_test.dart` — литералы `'clicker-beer'` и `'custom'`

Поиск остатка (не `*.freezed.dart`):

```bash
rg "ClickId\(" lib test --glob '!*.freezed.dart'
rg "ClickerId\(" lib test --glob '!*.freezed.dart'
```

Каждое попадание — `.known(`, `.parse(`, или строка фабрики `ClickId.known` / `ClickerId.known`. Голый `ClickId('x')` — брак.

Сигнатуры `watchClicker(ClickerId id)` не менять: тип тот же.

### W5. Тесты parse

Дописать `clicker_id_test.dart` (не ломая проверку «не является ClickId»):

- `ClickerId.parse('')` → `const Left(Failure.emptyId())`
- `ClickerId.parse('a')` → `Right(ClickerId.known('a'))` (или `getOrElse` + `expect` на known)
- `ClickerId.parse(' ')` — Right, не emptyId

Новый файл `test/bounded_contexts/journal/domain/click/click_id_test.dart` — то же для `ClickId`. Плюс: `const ClickId.known('a')` равен себе; `isNot(isA<ClickerId>())` — не `!=`, линт `unrelated_type_equality_checks`.

Не тестируй UUID. Не тестируй `SignedBaseDelta.parse`.

Ожидаемые миллилитры в старых тестах не менять.

### W6. build_runner приложения

Из корня `beer_ledger` (не вместо W1, **после** него):

```bash
dart run build_runner build --delete-conflicting-outputs
```

Нужны новые `click_id.freezed.dart` и `clicker_id.freezed.dart`. Чужой `.g.dart` без правки `@riverpod` — `git checkout --` и стоп.

### W7. Документы приложения

`docs/project-structure.md`, «Следующие шаги»: `parse`/`known` с этого шага уходят; остаётся UI Projection на главной. Шапка: `date '+%Y-%m-%d %H:%M:%S %z'`, версия +1, дату создания не менять.

`docs/architecture.md` — одна фраза в DDD, что id входят через `parse` / `known`. Таблицу ADR не трогать. Шапка так же.

ADR не переписывать.

---

## Проверки до коммита

```bash
cd packages/beer_ledger_core && dart analyze --fatal-warnings && dart test
```

Из корня:

```bash
flutter analyze --fatal-warnings lib
flutter test
```

Упал тест — не меняй ожидаемое число. СТОП: команда и хвост лога.

Потом G5, потом G6.

---

## Вне scope

- UI Projection, новые экраны, «устоял», 0.33 L.
- `SignedBaseDelta.parse`.
- UUID-валидация, trim, `Failure` на пробел.
- `clickFromRows` / `clickerFromSettingsRow` → `Result`.
- `@visibleForTesting unsafe`.
- Перенос `ClickerId` в ядро.
- Схема SQLite.
- Правка ADR.
- Штаб `flutter-senior-prep`.
- Push, PR, второе issue.
- `git commit` на `main`.
- Промпт в коммите кода.

---

## Definition of Done

- [ ] На `main` до ветки уже был коммит **только** с этим файлом промпта (`git log` это показывает).
- [ ] Issue в milestone `v1.3.5 — lite DDD`.
- [ ] `git branch --show-current` = `feat/<номер>-id-parse`, не `main`.
- [ ] Коммит кода после `git checkout -b`, на этой ветке, без файла промпта.
- [ ] `ClickId('x')` и `ClickerId('x')` не компилируются.
- [ ] `ClickId.parse('')` — `Left(Failure.emptyId())`.
- [ ] `beerHalfLiter` собирается через `ClickerId.known`, не через unsafe.
- [ ] `git diff docs/decisions/` пустой.
- [ ] analyze/test ядра и приложения зелёные.
- [ ] Один коммит, `Ref #<номер>`, без `Closes`, без файла промпта.
- [ ] Push не сделан.

---

## Анти-лазейки

1. Не открывай `flutter-senior-prep`.
2. Не `git add` / `git commit` на `main`. Не клади промпт в коммит кода. Не делай «всё одним коммитом».
3. Не оставляй безымянную фабрику «рядом с known».
4. Не вызывай `parse` в маппере «для красоты», сломав возврат `Click`.
5. Не проверяй UUID.
6. Не пиши `SignedBaseDelta.parse`.
7. Не трогай `Click.record(axes:)` и UI Projection.
8. Push/PR — только после отдельной фразы человека.

---

## Формат ответа мне

1. Первая строка — `parse`/`known` на месте, либо стоп и почему (вывод команды).
2. Номер issue и `git branch --show-current`.
3. Сигнатуры `ClickId.parse` / `ClickId.known` одной строкой каждая.
4. `git log --oneline -3` и `git diff --stat`. Один коммит, не на `main`.
5. Хвост `flutter test` / `dart test`.
6. Push не делался.

Без «заодно UI Projection».
