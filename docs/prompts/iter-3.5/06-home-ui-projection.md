# Промпт 3.5 / шаг 6: главная по UI Projection

**Дата создания:** 2026-09-24 16:28:42 +0300  
**Последнее обновление:** 2026-09-24 16:45:04 +0300  
**Версия:** 3  
**Вид документа:** инструкция

> Человек: открой в Cursor папку `beer_ledger`. Штаб `flutter-senior-prep` не открывать.  
> Промпт **не** коммитить на `main` отдельно. Он уходит в ту же ветку и тот же PR, что код. Сквош при вливе — человек.  
> В чат — от «## Контекст» до конца.

---

## Контекст (rules/skills не пересказывать)

Действуют project rules и skills этого репо. Их не цитируй — соблюдай.

Репо: `beer_ledger`  
Режим: Agent  
Skills: не запускай `/architecture-ui-workflow`, `/delivery-checklist`, `/riverpod-codegen` (кроме `build_runner` ниже). Цепочка UI Projection уже расписана здесь. Не создавай `lib/ui/screens/` — этого пути в репо нет.

Я техлид. Ты делаешь **шаг 6**, последний в итерации 3.5. Исходная точка — текущий `main` после [#68](https://github.com/ValeriusGC/beer_ledger/pull/68): `parse`/`known` уже есть, `Click.record` уже без `Clicker`.

Этот промпт — **явная команда** завести issue, ветку, коммит(ы), `git push` и pull request. На `main` ты ничего не коммитишь.

Промпт и код — **один PR**. Этот файл кладёшь в коммит на feat-ветке вместе с работой. Отдельный коммит промпта на `main` не делай. Несколько коммитов на ветке допустимы: человек сольёт squash.

Порядок, который нельзя переставить: **issue → ветка с номером этого issue → работа (включая этот промпт) → `dart format .` → чистый статус → коммит(ы) с `Ref #<номер>` → push → PR с `Closes #<номер>`**. В коммите слов `Closes` / `Fixes` / `Close` нет. Они живут **только в теле PR**.

Если на диске не то, что в «Карте» — стоп и напиши, что увидел.

---

## Карта: что сейчас на главной и куда это деть

Главная сейчас — `lib/bounded_contexts/journal/presentation/home_page.dart`. После шага файл **переезжает** в `lib/bounded_contexts/journal/presentation/home/home_page.dart`. Роутер по-прежнему берёт `HomePage` из барреля `journal.dart`. Настройки — другой контекст, `/settings`, этот шаг их не трогает.

Сейчас на главной четыре куска:

| Что видит человек | Файл сейчас | Кто умный |
| --- | --- | --- |
| Карточка четырёх итогов | `today_balance_card.dart` | сама `watch(todayBalanceProvider)`, сама зовёт `formatTodayBalanceLines`, сама `when` loading/error/data |
| Кнопка тапа | кусок `home_page.dart` | `watch(recordClickProvider)` + `currentClickerProvider`; `tapDisabled`; подпись через `formatRecordBeerVolume`; fallback `beerHalfLiter()` |
| Список тапов и undo | `today_clicks_section.dart` | `watch(clicksForTodayProvider)` + `undoLastClickProvider`; `if (items.isEmpty)`; строка зовёт `formatTodayClickTime` / `formatTodayClickVolume` из `Click` |
| График за 7 дней | `week_volume_chart.dart` | сам `watch(volumeForLast7DaysProvider)` — **в цепочку не берём** |

Витрина — не третий контекст. Всё новое кладётся в `lib/bounded_contexts/journal/presentation/home/`. Закон папок — `docs/project-structure.md`.

Цепочка этого репо (не MVVM рядом):

```
факты application/domain
        → Factory (решения: пустой день? кнопка активна?)
        → Projection (данные без строк UI)
        → Builder (l10n + formatToday* )
        → UiModel (готовые строки)
        → dumb Widget (рисует UiModel, зовёт callback)
```

Controller — тонкая обёртка handler'ов `record` / `undo`. Навигация в настройки (`context.push('/settings')`) и бейдж `isDevFlavor` — оболочка AppBar, не Factory.

Ширина окна `>= 600` (`_homeWideWidth`, ключ `home-balance-chart-row`) — **layout**, не учёт. Остаётся в `HomePage` через `MediaQuery`. В Factory ширину не тащи.

График уже только рисует готовые литры. Продукт не менять: файл не переписывать под Factory, провайдер тот же.

`fromBase` / сложение осей в виджете **запрещены**. Суммы считает `todayBalance` / `aggregateForPeriod`. Подписи — существующие `today_balance_format.dart` и `today_clicks_format.dart`, их **вызывает Builder**, не `build` карточки.

На телефоне те же кнопки и те же цифры. Новых ARB-строк нет, если все тексты уже в l10n.

---

## Задача (одно предложение)

Главная собирается по UI Projection: решения в Factory, строки в Builder, виджеты карточки/списка/кнопки не смотрят домен и не форматируют сами.

---

## Что не переспрашивать

1. Не третий контекст «витрина». Не `lib/ui/screens/`. Не `lib/features/`.
2. Настройки (`portion/presentation`) не переписывать.
3. `WeekVolumeChart` не втягивать в Factory.
4. Не выносить `deltaInBase` / `Click.record`. Не трогать SQLite.
5. Ключи тестов не переименовывать: `today-balance-volume|energy|money|joy`, `today-click-<id>`, `home-balance-chart-row`.
6. ADR 001–004 не трогать.
7. Все коммиты шага — на `feat/…`, в одном PR, с `Ref #<номер>`. Промпт в этом же PR. `Closes #<номер>` — **только тело PR**, не коммит.
8. После правок — `dart format .` из корня, потом analyze/test, потом смотри `git status`: лишнего нет.
9. DartDoc публичного API по-русски. Private без шума.
10. `HomePage` живёт в `presentation/home/home_page.dart`. Старый путь удалить.
11. `TodayBalanceCard` и `TodayClicksSection` — dumb: UiModel **только конструктором**. Rule `riverpod-first-reactivity` на них не действует. `HomePage` и `WeekVolumeChart` по-прежнему `ref.watch`.
12. Оба `ref.listen` (запись и undo) — только в `HomePage`. В секции списка listen нет.

---

## Порядок Git (G0→G9). Не переставлять

Правки Dart — **только после G3**.

### G0 — посмотреть, ничего не менять

```bash
git branch --show-current
git status -sb
```

Ожидание:

- ветка `main`;
- кроме **этого** файла промпта (`docs/prompts/iter-3.5/06-home-ui-projection.md`) дерево чистое. Неотслеживаемый или изменённый только он — нормально, его закоммитишь уже на feat. Чужие грязные файлы — **стоп**.

Не `main` — стоп. Не `git commit` на `main`.

Проверка, что шаг 6 ещё не сделан:

```bash
ls lib/bounded_contexts/journal/presentation/home 2>/dev/null || true
rg "HomeProjectionFactory" lib || true
```

Каталог `home/` с Factory уже есть — стоп, шаг сделан.

### G1 — issue. Файлы не трогать

Родительский issue не заводи. Milestone точно `v1.3.5 — lite DDD`.

```bash
gh issue create \
  --repo ValeriusGC/beer_ledger \
  --milestone "v1.3.5 — lite DDD" \
  --title "refactor: главная по UI Projection" \
  --body "$(cat <<'EOF'
Главная журнала: Factory → Projection → Builder → UiModel → dumb widgets. Настройки и график как продукт не переписываем. Не закрывает другие issue.
EOF
)"
```

Число из URL — `<номер>`. Пример: `issues/70` → ветка `feat/70-home-ui-projection`. После G1 ты на `main`. `git commit` нельзя.

### G2 — ветка до любой правки

```bash
git checkout -b feat/<номер>-home-ui-projection
git branch --show-current
```

Ожидание: `feat/<номер>-home-ui-projection`. Напечатало `main` — стоп.

Не имя без номера. Не ветка от `feat/67-…`.

### G3 — ворота

```bash
git branch --show-current
```

Не та строка — стоп. Совпала — раздел «Работа».

### G4 — работа на ветке

Не `git switch main`. Не промежуточный коммит «пока набросал».

### G5 — подтереть за собой, до коммита

Из **корня** `beer_ledger`:

```bash
dart format .
```

Потом:

```bash
git branch --show-current
git status -sb
```

Ветка всё ещё `feat/…`. В статусе только файлы этого шага **включая** `docs/prompts/iter-3.5/06-home-ui-projection.md`. Если build_runner или форматтер тронули чужой generated — `git checkout --` этот файл. Не оставляй неотслеживаемый мусор, `print`, закомментированный код, лишний тест «я ещё проверю value».

Промпт в индекс **клади**: он часть того же PR, не отдельный ритуал на `main`.

### G6 — ворота перед коммитом

```bash
git branch --show-current
```

| Вывод | Действие |
| --- | --- |
| `feat/<номер>-home-ui-projection` | G7 |
| `main` | **не** `git add`, **не** `git commit`. Если файлы уже грязные: `git checkout -b feat/<номер>-home-ui-projection`, снова G5, потом G6 |
| иное | стоп, напиши имя |

### G7 — коммит(ы) на feat/, не на main

Один коммит на всё (промпт + код) достаточно. Несколько тоже ок: человек сквошнет PR.

```
Собрать главную по UI Projection: решения в Factory, строки в Builder.

Ref #<номер>
```

Слов `Closes` / `Fixes` / `Close` в сообщении коммита **нет**.

После:

```bash
git log -1 --format='%s'
git status -sb
```

Чисто. Сообщение без `Closes`. Ветка `feat/…`. Коммит на `main` — **не** push, стоп.

### G8 — push

```bash
git push -u origin HEAD
```

Не `--force`. Не push в `main`.

### G9 — pull request, Close только здесь

```bash
gh pr create \
  --repo ValeriusGC/beer_ledger \
  --base main \
  --head feat/<номер>-home-ui-projection \
  --title "refactor: главная по UI Projection" \
  --body "$(cat <<EOF
Closes #<номер>

Главная журнала собрана по UI Projection. Настройки и график как продукт не менялись.
EOF
)"
```

Подставь число из G1. Первая строка тела — `Closes #<номер>` (GitHub закрывает issue при merge; слово `Closes` в **коммите** по-прежнему нельзя).

Milestone PR не создаём отдельно. Родительский issue не заводи.

---

## Работа (после G3)

Прочитай целиком:

- `docs/project-structure.md`
- `lib/bounded_contexts/journal/presentation/home_page.dart`
- `today_balance_card.dart`, `today_clicks_section.dart`
- `today_balance_format.dart`, `today_clicks_format.dart`
- `week_volume_chart.dart` — чтобы **не** переписывать
- `lib/bounded_contexts/journal/application/today_balance.cg.dart`
- `clicks_for_today.cg.dart`, `record_click.cg.dart`, `undo_last_click.cg.dart`
- `lib/bounded_contexts/portion/application/current_clicker.cg.dart`
- тесты: `today_balance_card_test.dart`, `today_clicks_section_test.dart`, `record_beer_tap_button_test.dart`, `home_breakpoints_test.dart`

### W1. Типы Projection — чистый Dart

Каталог: `lib/bounded_contexts/journal/presentation/home/`

`home_projection.dart` — `@freezed`, `part '*.freezed.dart'` (не `.cg.dart`).

Имена типов такие, не короче:

1. **HomeBalanceProjection** — sealed: `loading` / `error` / `ready(PeriodBalances)`. Не строки.
2. **HomeJournalProjection** — sealed: `loading` / `error` / `empty` / `items(List<Click>)`. Пустой список на входе Factory → `empty`, не `items([])`.
3. **HomeProjection** — поля:
   - `bool tapEnabled` — сейчас это `!(record.isLoading || clicker.isLoading)`;
   - `Clicker buttonClicker` — `currentClicker.asData?.value ?? beerHalfLiter()` (тот же fallback, что в `home_page.dart`);
   - баланс;
   - журнал;
   - `bool undoEnabled` — не `undoState.isLoading`.

`PeriodBalances` и `Click` здесь законны: это слой Projection, ещё не виджет.

### W2. Factory

`home_projection_factory.dart` — обычный Dart, без Flutter.

```dart
static HomeProjection from({
  required AsyncValue<PeriodBalances> balance,
  required AsyncValue<List<Click>> clicks,
  required AsyncValue<void> record,
  required AsyncValue<Clicker> clicker,
  required AsyncValue<void> undo,
})
```

`AsyncValue` — из `flutter_riverpod` / `riverpod`; Factory всё же живёт в presentation, импорт Riverpod здесь ок. Развижки `isLoading` / `hasError` / `value` — **только здесь**, не в виджете.

Правила:

- `tapEnabled == false`, пока record или clicker в loading (как сейчас).
- `buttonClicker`: есть data у clicker — она; иначе `beerHalfLiter()`.
- баланс: loading → `loading`; hasError → `error`; иначе `ready` (в том числе нули за пустой день — это не error).
- журнал: loading / error так же; `data` и список пуст → `empty`; иначе `items`.
- `undoEnabled == !undo.isLoading`.

Никакого `fromBase`, никакого l10n.

### W3. Провайдер Projection

Файл `home_projection.cg.dart`: `@riverpod`, `part '*.cg.g.dart'`.

Смотрит уже существующие:

- `todayBalanceProvider`
- `clicksForTodayProvider`
- `recordClickProvider`
- `currentClickerProvider`
- `undoLastClickProvider`

Возвращает `HomeProjectionFactory.from(...)`. Новых запросов в репозиторий нет.

### W4. UiModel + Builder

`home_ui_model.dart` — данные **для виджета**: строки, флаги, не `Click` и не `PeriodBalances`.

- баланс: loading / error(текст) / lines (`TodayBalanceLines` уже есть в `today_balance_format.dart`);
- журнал: loading / error(текст) / empty(текст) / rows: `{id, time, volume?}` — `id` нужен для `Key('today-click-$id')`;
- `tapEnabled`, `tapLabel`, `undoEnabled`, `undoLabel`.

Builder `home_ui_model_builder.dart`:

```dart
static HomeUiModel build({
  required HomeProjection projection,
  required AppLocalizations l10n,
  required Locale locale,
})
```

Здесь и только здесь:

- `formatTodayBalanceLines`
- `formatTodayClickTime` / `formatTodayClickVolume`
- `formatRecordBeerVolume` + `l10n.recordBeerTap(...)`
- тексты ошибок/empty из **существующих** ключей: `todayBalanceLoadError`, `todayClicksLoadError`, `todayClicksEmpty`, `undoLastTap`

Новых строк в ARB нет.

### W5. Controller

`home_controller.cg.dart`: `@riverpod class`, `build` пустой или `void`. Методы:

- `Future<void> record() => ref.read(recordClickProvider.notifier).record();`
- `Future<void> undo() => ref.read(undoLastClickProvider.notifier).undo();`

Не ходи в `ClickRepository`. Не форматируй.

### W6. Виджеты

`home_page.dart` **переезжает** в `lib/bounded_contexts/journal/presentation/home/home_page.dart`. Файл `presentation/home_page.dart` удалить, не оставлять реэкспорт. В `journal.dart` одна правка: `export 'presentation/home/home_page.dart';` вместо старого пути. Класс по-прежнему `HomePage`. Роутер не трогать: он импортирует баррель.

Factory в баррель **не** экспортировать. Тесты Factory импортируют файл напрямую. `HomePage` из барреля остаётся.

**`HomePage`** — единственный оркестратор, `ConsumerWidget`. Он:

- `watch(homeProjectionProvider)`;
- вызывает Builder с `AppLocalizations` и locale;
- layout wide/narrow как сейчас;
- AppBar: title, dev-badge, settings `context.push('/settings')` — как сейчас;
- **оба** `ref.listen`: `recordClickProvider` (snackbar ошибки записи + haptic успеха) и `undoLastClickProvider` (snackbar `l10n.undoLastTapError` при новой ошибке). Тексты snackbar — существующие l10n, как сейчас. Из секции списка listen **убрать**;
- кнопка: `onPressed: ui.tapEnabled ? () => ref.read(homeControllerProvider.notifier).record() : null`, текст `ui.tapLabel`;
- `TodayClicksSection(..., onUndo: () => ref.read(homeControllerProvider.notifier).undo())`;
- вставляет карточку, секцию, график.

В `build` **нет** `beerHalfLiter()`, **нет** `formatRecordBeerVolume`, **нет** `items.isEmpty` по `List<Click>`.

**`TodayBalanceCard`** — `StatelessWidget`, без `ConsumerWidget` и без `ref`. На вход конструктором — кусок UiModel (loading / error / lines). Не `watch(todayBalanceProvider)`. Spinner / текст ошибки / четыре `_BalanceAxis` с теми же ключами.

**`TodayClicksSection`** — sliver, `StatelessWidget`, без `ref`. На вход конструктором — журнал UiModel + `undoEnabled` + `VoidCallback onUndo`. Не `watch`, не `listen`, не `Click`. Строка списка — `ListTile` с тем же `Key('today-click-$id')`.

Rule `riverpod-first-reactivity` («не через конструктор») **на эти два виджета не действует**. Им UiModel передают параметрами. `HomePage` и `WeekVolumeChart` по-прежнему берут данные через `ref.watch`.

**`WeekVolumeChart`** — не менять сигнатуру и провайдер.

### W7. Тесты

**Unit** (без `WidgetTester`): `test/bounded_contexts/journal/presentation/home/home_projection_factory_test.dart`

Минимум:

- clicker loading → `tapEnabled == false`;
- clicks `AsyncData([])` → журнал `empty`, не items;
- balance `AsyncData` с нулями → `ready`, не error;
- balance `AsyncLoading` → `loading`.

**Карточка:** больше не override `todayBalanceProvider`, если карточка его не читает. Передавай UiModel. Ожидания `'1.5 L (1500 ml)'` и ключи — те же. Loading / error — те же l10n-тексты.

**Секция:** передавай rows / empty / loading. Кнопка undo disabled при `undoEnabled: false`. Ключи строк те же.

**`record_beer_tap_button_test` и `home_breakpoints_test`:** по-прежнему качают `HomePage`. Их override application-провайдеров **оставить**: Factory их читает. Если провайдер переименовался — поправь override, не поведение кнопки и не breakpoint 600.

Новые golden не нужны.

### W8. build_runner

Из корня:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Из-за нового `@riverpod` и `@freezed`. Чужой `.g.dart` без правки аннотации — `git checkout --` и стоп. `beer_ledger_core` не запускать.

### W9. Документы приложения

`docs/project-structure.md`: в дереве `journal/presentation/` виден `home/` (Factory, Builder, HomePage). «Следующие шаги» — итерация 3.5 этим шагом закрывается, дальше итерация 4 (не расписывать её здесь). Шапка: `date '+%Y-%m-%d %H:%M:%S %z'`, версия +1, дату создания не менять.

`docs/architecture.md`: в принципах UI Projection — главная собрана по цепочке, не «по мере роста». Таблицу ADR не трогать. Шапка так же.

ADR не переписывать.

---

## Проверки до G5

```bash
cd packages/beer_ledger_core && dart analyze --fatal-warnings && dart test
```

Из корня:

```bash
dart format .
flutter analyze --fatal-warnings lib
flutter test
```

Упал тест — не меняй ожидаемую подпись (`1.5 L`, `+300 kcal`). СТОП: команда и хвост лога.

Потом G5→G9.

---

## Вне scope

- Экран настроек, график как продукт, «устоял», 0.33 L.
- Третий bounded context.
- `lib/ui/screens/`, MVVM как второе имя.
- Смена `Click.record`, SQLite, l10n ARB (без новой строки).
- Штаб `flutter-senior-prep`.
- `Closes` в коммите.
- Коммит на `main`.
- `--force` push.
- Отдельный коммит промпта на `main`.
- Закрытие milestone.

---

## Definition of Done

- [ ] Issue в milestone `v1.3.5 — lite DDD`.
- [ ] Ветка `feat/<номер>-home-ui-projection`, не `main`.
- [ ] В PR есть и этот промпт, и код. На `main` промпт отдельно не коммитился.
- [ ] `HomePage` в `presentation/home/home_page.dart`, старого `presentation/home_page.dart` нет.
- [ ] `TodayBalanceCard` / `TodayClicksSection` не импортируют провайдеры и не вызывают `ref.listen`.
- [ ] Оба listen (record и undo) только в `HomePage`.
- [ ] `rg "formatTodayBalanceLines" lib/bounded_contexts/journal/presentation` — вызов из Builder, не из `today_balance_card.dart`.
- [ ] `WeekVolumeChart` без Factory.
- [ ] Ключи тестов на месте, `flutter test` зелёный.
- [ ] `dart format .` сделан, `git status` после коммита чистый.
- [ ] Коммит(ы) с `Ref #<номер>`, без `Closes`.
- [ ] PR открыт, в теле `Closes #<номер>`.
- [ ] Штаб не тронут.

---

## Анти-лазейки

1. Не открывай `flutter-senior-prep`.
2. Не `git commit` на `main`. Не `Closes` в коммите.
3. Не клади Factory в `portion/` и не делай контекст «home».
4. Не переписывай график и settings «для единообразия».
5. Не считай миллилитры в `build`.
6. Не оставляй `home_page.dart` в `presentation/` рядом с `home/`.
7. Не оставляй `ref.listen` в `TodayClicksSection`.
8. Не оставляй грязный `git status` после коммита.
9. Не force-push.
10. Не закрывай milestone.

---

## Формат ответа мне

1. Первая строка — главная на UI Projection, либо стоп и вывод команды.
2. Номер issue, ветка, URL pull request.
3. `git log -1 --format='%s'` — должно быть `Ref #`, не `Closes`.
4. `git status -sb` — чисто, не `main`.
5. Хвост `flutter test`.
6. В теле PR есть `Closes #<номер>`.

Без «заодно тёмная тема» и без предложений переписать график.
