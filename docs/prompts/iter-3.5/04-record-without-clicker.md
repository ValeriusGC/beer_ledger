# Промпт 3.5 / шаг 4: `Click.record` без `Clicker`

**Дата создания:** 2026-09-24 13:41:41 +0300  
**Последнее обновление:** 2026-09-24 14:25:51 +0300  
**Версия:** 3  
**Вид документа:** инструкция

> Шаг 4 итерации 3.5. Value object'ы уже на `main` (#64). Этот шаг рвёт доменный мост, не меняет цифры на телефоне.  
> Открой в Cursor папку `beer_ledger` (File → Open Folder). Штаб `flutter-senior-prep` не открывать и не править.  
> Этот файл — версия 3. Коммитить **как есть**, отдельным коммитом на `main`, до чата модели. Перед этим коммитом промпт не править (ни «налог комментариев на private», ни иные «улучшения»).  
> В чат вставь блок ниже целиком, от «## Контекст» до конца. Каркас — `docs/prompts/chat-task-skeleton.md`; здесь он уже заполнен.

---

## Контекст (rules/skills не пересказывать)

Действуют project rules и skills этого репо. Их не цитируй — соблюдай.

Репо: `beer_ledger`  
Режим: Agent  
Skills по задаче: не нужны. `/delivery-checklist` не запускай. `/architecture-ui-workflow` не запускай. `/riverpod-codegen` не запускай, кроме `build_runner` ниже.

Закон папок — `docs/project-structure.md`. Новых контекстов и корзин типов не создавать.

Перед кодом прочитай:

- `docs/project-structure.md` — раздел «Зависимости»
- `lib/bounded_contexts/journal/domain/click/click.dart` — текущий `Click.record(clicker:)`
- `lib/bounded_contexts/journal/application/record_click.cg.dart`
- `lib/bounded_contexts/journal/journal.dart` — баррель экспортов
- `lib/bounded_contexts/portion/domain/clicker/clicker.dart`
- `lib/bounded_contexts/portion/domain/clicker/ledger_axis.dart`
- `lib/bounded_contexts/portion/domain/clicker/axis_sign.dart` — только чтобы взять `.multiplier`, тип в журнал не тащить
- `packages/beer_ledger_core/lib/convert/convert.dart` — `deltaInBase` / `resolveUnit` остаются в `Click.record`

Решение ниже уже принято. Если файла нет — стоп.

Этот промпт — явная команда завести GitHub issue, ветку и один коммит **кода**. Push и pull request не делать, пока человек не скажет отдельной фразой в этом чате.

---

## Задача (одно предложение)

`Click.record` принимает оси на языке журнала, а не `Clicker`; домен журнала больше не импортирует `clicker.dart`.

---

## Зачем / приоритет

Сейчас агрегат тапа знает живую порцию: `click.dart` импортирует `Clicker` и в `record` сам ходит по `clicker.axes`. Это и есть запрещённый импорт `domain/` соседа. Сценарий записи уже читает порцию через `currentClicker` — перевод осей его работа. На телефоне те же цифры. `Click.record` по-прежнему резолвит единицу и считает `deltaInBase`: инвариант «факт в базовой единице» не уезжает в виджет.

---

## Не переспрашивать

Пять решений закрыты. Не предлагай развилку и не жди второго сообщения.

### 1. Промпт — коммитить версию 3 как есть

Коммит **этого файла** на `main` — отдельный, только промпт, **до** issue и ветки кода. Сообщение без `Ref #`: номера issue шага ещё нет.

Перед этим коммитом файл **не править**. В том числе не добавлять в промпт и не исполнять «каждый private-символ с комментарием». Комментарии уже закрыты правилами репо:

- публичный API — DartDoc на русском, Effective Dart, rule `dart-dartdoc-comments`: первая строка — что это, дальше зачем, типы в `[Скобках]`;
- приватная реализация — **без шума** (quality-bar): `//` только если имя не говорит *почему*; DartDoc на `_recordClick`, `_recordTap` и generated `_$AxisRecordInput` **не писать**.

В этом шаге DartDoc обязателен у трёх публичных мест: тип `AxisRecordInput` (и смысл четырёх полей, если имя поля не исчерпывает: у `signMultiplier` сказать, что это `1` или `-1`, бывший `AxisSign.multiplier`, тип `AxisSign` журнал не знает); обновлённый `Click.record` (оси журнала, не `[Clicker]`); функция `axisRecordInputsFrom`. Существующие `///` в нетронутых файлах не переписывать «ради стиля». Тела циклов не комментировать.

Исполнитель кода этот коммит промпта **не делает заново**. Если `docs/prompts/iter-3.5/04-record-without-clicker.md` нет на текущем `main` или `git status` показывает его изменённым — **стоп**. Не класть промпт в коммит с кодом. Не `git commit --amend` чужого коммита промпта.

### 2. Ветка — `feat/<номер>-record-without-clicker` от `main` после коммита промпта

Порядок жёсткий:

1. `git fetch` / `git status -sb` / `git branch --show-current`. Сейчас `main`, дерево чистое, `HEAD` совпадает с `origin/main` либо `main` содержит коммит промпта и ничего поверх. Иначе стоп.
2. Issue в milestone (команда ниже). Номер, который вернул `gh`, — это `<номер>`.
3. Ветка **только от этого `main`**: `git checkout -b feat/<номер>-record-without-clicker`. Не от `feat/64-…`, не от чужой WIP, не `feat/record-without-clicker` без номера.
4. Правки кода и документов шага — на этой ветке. Один коммит, `Ref #<номер>`, без `Closes`.

Имя ветки с тем же суффиксом, что в заголовке issue: `record-without-clicker`.

### 3. Тесты домена и хелперы импортируют application — да, только в `test/`

`axisRecordInputsFrom` живёт в `journal/application/`. Её вызывают:

- прод: `RecordClick` в том же слое;
- тесты: `click_record_test.dart` и хелперы `_recordClick` / `_recordTap` в `test/`, в том числе `test/bounded_contexts/portion/domain/clicker/beer_preset_matrix_test.dart`.

Импорт в тестах:

```dart
import 'package:beer_ledger/bounded_contexts/journal/application/axis_record_inputs.dart';
```

Прямой путь к файлу, не через баррель `journal.dart` (хелпера там нет, см. п. 4).

Это **не** дыра в архитектуре. Закон слоёв действует на `lib/`: `domain/` не импортирует `application/`. Каталог `test/` слоем не является. Дублировать цикл `for (axis in clicker.axes)` в каждом хелпере нельзя: два источника правды разъедутся с `RecordClick`. Вынести маппинг в `journal/domain/` нельзя: туда вернётся `Clicker`. Копировать функцию в `test/helpers/` нельзя: третья копия.

В `lib/bounded_contexts/journal/domain/` импорта `axis_record_inputs.dart` и любого `application/` **нет**. Проверка: после правок `rg "axis_record_inputs" lib/bounded_contexts/journal/domain` пусто.

Параметр `clicker:` у `aggregateForPeriod`, у карточки, у фейка `watchClicker` — не этот шаг. Меняется только аргумент `Click.record`.

### 4. Баррель: `AxisRecordInput` да, `axisRecordInputsFrom` нет

В `lib/bounded_contexts/journal/journal.dart` добавить одну строку рядом с остальными `domain/click/`:

```dart
export 'domain/click/axis_record_input.dart';
```

`application/axis_record_inputs.dart` в баррель **не** класть. Не экспортировать из `portion.dart`. Не реэкспортировать из `click.dart`. Хелпер — внутренность application плюс прямые импорты из `test/`. Снаружи контекста оси пишут через `Click.record` и баррельный `AxisRecordInput` (тест неизвестного `enteredInId`).

`record_click.cg.dart` уже в барреле — его список экспортов не раздувать хелпером.

### 5. ADR 004 не переписывать; старая фраза про мост остаётся

В ADR 004 написано: мост один — `Click.record`; второй функции перевода не заводим. После этого PR вызов в сценарии будет два шага: `axisRecordInputsFrom(clicker)` затем `Click.record(axes:)`. Буквально одно предложение ADR устареет: `record` больше не читает `Clicker`.

Это **принято**. `docs/decisions/004-portion-and-journal.md` в diff шага **пустой**. Новый ADR не заводить. Не «подчищать формулировку, раз уж всё равно в доках».

Почему так, а не «раз ADR врёт — правим сейчас»:

- ADR 004 фиксирует *какие два контекста* и *что отвергнуто* (шина событий, третий контекст-витрина, общий `lib/domain/`). Это не чертёж сигнатуры. Итерация 3.5 уже один раз переписывала этот ADR из‑за папок; второй раз в том же milestone из‑за маппинга смешает два решения в одной истории.
- Намерение «нет EventBus и нет второго продукта-переводчика» остаётся верным. `axisRecordInputsFrom` — антикоррупционный слой application, не второй доменный перевод и не второй контекст. Заморозка вкладов и резолв единицы по-прежнему только в `Click.record`.
- Живой закон зависимостей — `docs/project-structure.md`. Его этот шаг **обязан** переписать (раздел «Зависимости»). `docs/architecture.md` — одна фраза, если там ещё сказано, что `record` берёт clicker. Строка таблицы ADR «мост `Click.record`» — имя решения, её не менять.
- Шага «поправить ADR 004» в итерации 3.5 нет. Если ревьюер споткнётся — docs-only issue позже, не блокер шагов 4–6.

---

## Git до правок

1. `git status -sb` и `git branch --show-current`. Не `main` или грязное дерево — стоп. Промпт на `main`, см. «Не переспрашивать» §1–§2.
2. Issue в milestone `v1.3.5 — lite DDD` (milestone/7). Родительского issue не заводи.

```bash
gh issue create \
  --repo ValeriusGC/beer_ledger \
  --milestone "v1.3.5 — lite DDD" \
  --title "refactor: Click.record без Clicker" \
  --body "$(cat <<'EOF'
Домен журнала больше не импортирует Clicker. Click.record принимает оси журнала; перевод из порции — в application. Не закрывает другие issue.
EOF
)"
```

3. Ветка только от `main`: `feat/<номер>-record-without-clicker`
4. Один коммит на весь шаг. Сообщение — причина, затем `Ref #<номер>`. Слов `Closes` / `Fixes` / `Close` нет.

---

## Что сделать

### 1. Вход журнала — `AxisRecordInput`

Файл: `lib/bounded_contexts/journal/domain/click/axis_record_input.dart`  
`part 'axis_record_input.freezed.dart'` — как `click_id.dart`, не `*.cg.dart`.  
`implements ValueObject`. DartDoc — «Не переспрашивать» §1.

```dart
@freezed
abstract class AxisRecordInput with _$AxisRecordInput implements ValueObject {
  const factory AxisRecordInput({
    required LedgerAxisKind kind,
    required double enteredValue,
    required String enteredInId,
    required int signMultiplier,
  }) = _AxisRecordInput;
}
```

`signMultiplier` — это сегодня `AxisSign.multiplier` (`1` или `-1`). Тип `AxisSign` в журнал не импортировать. Новую `Failure` на «не 1 и не −1» не заводить.

Экспорт — только `axis_record_input.dart` в `journal.dart`. Хелпер в баррель не класть («Не переспрашивать» §4).

### 2. Новая сигнатура `Click.record`

```dart
static Result<Click> record({
  required ClickId id,
  required ClickerId clickerId,
  required DateTime at,
  required List<AxisRecordInput> axes,
  double factor = 1,
})
```

Параметра `clicker` нет. Цикл тот же: `resolveUnit(axis.enteredInId)` → `Failure.unknownUnitId` или `AxisContribution` через `SignedBaseDelta.fromKind(axis.kind, axis.signMultiplier * deltaInBase(...))`.

`Click.clickerId` остаётся `ClickerId`. Журнальный домен имеет право импортировать **только** `clicker_id.dart` (ссылка на чужой агрегат по id). Файлы `clicker.dart`, `ledger_axis.dart`, `axis_sign.dart`, `beer_half_liter.dart` из `lib/bounded_contexts/journal/domain/` импортировать нельзя.

DartDoc `Click` / `record`: писать про оси журнала, не про параметр `[Clicker]`.

### 3. Перевод в application

Файл: `lib/bounded_contexts/journal/application/axis_record_inputs.dart` — обычный Dart, не `.cg.dart`.

```dart
List<AxisRecordInput> axisRecordInputsFrom(Clicker clicker) {
  return [
    for (final axis in clicker.axes)
      AxisRecordInput(
        kind: axis.kind,
        enteredValue: axis.enteredValue,
        enteredInId: axis.enteredInId,
        signMultiplier: axis.sign.multiplier,
      ),
  ];
}
```

DartDoc: это перевод с языка порции на вход `Click.record`; домен журнала `Clicker` не видит.

`RecordClick.record` после `currentClicker`:

```dart
final recorded = Click.record(
  id: ClickId(const Uuid().v4()),
  clickerId: clicker.id,
  at: ref.refresh(nowProvider),
  axes: axisRecordInputsFrom(clicker),
);
```

Журнальный `application/` импортировать порцию может: это антикоррупционный слой. `infrastructure/` журнала `Clicker` не импортирует (сейчас и не должен).

### 4. Проверка изоляции

Из корня:

```bash
rg "portion/domain/clicker/" lib/bounded_contexts/journal/domain --glob '!**/clicker_id.dart'
rg "axis_record_inputs" lib/bounded_contexts/journal/domain
```

Обе пустые. `click.dart` не содержит `import` `clicker.dart`.

Presentation журнала (`today_clicks_format.dart`, `home_page.dart`) по-прежнему может брать `Clicker` для подписи кнопки. Заодно не чистить.

### 5. Тесты

Ожидаемые числа не менять (`500.0` мл остаются `500.0`).

Хелперы `_recordClick` / `_recordTap`: `axes: axisRecordInputsFrom(...)` — тот же `Clicker`, что раньше уходил в `clicker:`. Не дублировать цикл маппинга. Импорт хелпера — «Не переспрашивать» §3.

`click_record_test.dart`: вызовы с `clicker:` заменить на `axes:`. Тест неизвестного `enteredInId` — список из одного `AxisRecordInput` (тип с барреля `journal.dart`) с `enteredInId: 'volume.unknown'`, без `Clicker.copyWith`.

Новый узкий тест не обязателен, если `click_record_test` покрывает четыре оси, factor=2 и unknown unit.

Фейки и `watchClicker` не трогать, кроме сигнатуры `Click.record`.

### 6. Документы

`docs/project-structure.md`, раздел «Зависимости»: мост больше не «`Click.record` принимает `Clicker`». Написать: домен журнала не импортирует `Clicker`; перевод осей — `axisRecordInputsFrom` в `journal/application`; `Click.record` принимает `List<AxisRecordInput>`; из домена порции журнальный домен импортирует только `ClickerId`. Шапка: дата с `date '+%Y-%m-%d %H:%M:%S %z'`, версия +1, дату создания не менять.

`docs/architecture.md` — одна фраза в том же смысле, если там ещё сказано, что `record` берёт clicker. Таблицу ADR не трогать. Шапка так же.

ADR 001–004 не переписывать (`git diff docs/decisions/` пустой). Новый ADR не заводить. Почему — «Не переспрашивать» §5.

---

## build_runner

Из корня: `dart run build_runner build --delete-conflicting-outputs` из‑за нового `@freezed`. Аннотации `@riverpod` не меняются — если переписался чужой `.g.dart` / `.freezed.dart` не из `axis_record_input` и не из уже меняемых доменных файлов, `git checkout --` этот файл и стоп.

Пакет `beer_ledger_core` не запускать.

---

## Вне scope

- UI Projection, новые экраны, кнопка «устоял», 0.33 L.
- Перенос `ClickerId` в `beer_ledger_core` или обратно в `String`.
- Перенос `AxisSign` в ядро.
- Схема SQLite, `factor`, `enteredValue` на `LedgerAxis`.
- Вынос `deltaInBase` из `Click.record` в виджет или в application.
- `ClickId.parse` / `known` — шаг 5 плана, не этот PR.
- Правка ADR 004 «под новый мост».
- Экспорт `axis_record_inputs.dart` из барреля «для удобства».
- Репозиторий `flutter-senior-prep`.
- Push, pull request, второе issue.
- Коммит промпта в том же коммите, что код.

---

## Definition of Done

- [ ] Issue в milestone `v1.3.5 — lite DDD`, ветка `feat/<номер>-record-without-clicker` от `main` после коммита промпта.
- [ ] `Click.record(clicker: ...)` не компилируется.
- [ ] Оба `rg` выше по `journal/domain` пустые (кроме дозволенного `clicker_id.dart` в первом).
- [ ] `journal.dart` экспортирует `axis_record_input.dart` и не экспортирует `axis_record_inputs.dart`.
- [ ] `git diff docs/decisions/` пустой.
- [ ] `dart analyze --fatal-warnings` и `dart test` в `packages/beer_ledger_core` проходят.
- [ ] Из корня: `flutter analyze --fatal-warnings lib` и `flutter test` проходят.
- [ ] Один коммит с `Ref #<номер>`, без `Closes`. В нём нет повторного коммита промпта.
- [ ] Push не сделан.

---

## Как работать (анти-лазейки)

1. Не открывай `flutter-senior-prep`.
2. Не оставляй перегрузку `record({Clicker clicker})` «для совместимости».
3. Не клади `AxisRecordInput` в portion и не клади `Clicker` в journal/domain.
4. Не называй новый файл `*.cg.dart`.
5. Не клади `axis_record_inputs.dart` в `journal.dart`.
6. Не переписывай ADR 004.
7. Упал тест — не меняй ожидаемое число. Остановись, команда и хвост лога.
8. Push и PR — только после отдельной фразы человека.

---

## Формат ответа

1. Первая строка — мост разорван, либо стоп и почему.
2. Номер issue и имя ветки.
3. Новая сигнатура `Click.record` одной строкой.
4. `git log --oneline -3` и `git diff --stat`. Один коммит.
5. Хвост `flutter test` / `dart test`.
6. Push не делался.

Без предложений «заодно UI Projection» и «заодно поправить ADR».
