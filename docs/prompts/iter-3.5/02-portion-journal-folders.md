# Промпт 3.5 / шаг 2: каталоги порции и журнала

**Дата создания:** 2026-09-23 14:59:44 +0300  
**Последнее обновление:** 2026-09-23 14:59:44 +0300  
**Версия:** 1  
**Вид документа:** инструкция

> Шаг 2 итерации 3.5. Модель только переносит уже существующие файлы ядра. Новых типов нет, поведение то же.  
> Открой в Cursor папку `beer_ledger` (File → Open Folder). Штаб `flutter-senior-prep` не открывать и не править.  
> Этот промпт закоммить отдельно, до чата модели. Иначе проверка чистого дерева ниже — стоп, и это правильно.  
> В чат вставь блок ниже целиком, от «## Контекст» до конца. Каркас — `docs/prompts/chat-task-skeleton.md`; здесь он уже заполнен.

---

## Контекст (rules/skills не пересказывать)

Действуют project rules и skills этого репо. Их не цитируй — соблюдай.

Репо: `beer_ledger`  
Режим: Agent  
Skills по задаче: не нужны. Это перенос файлов, не экран и не провайдер. `/delivery-checklist` не запускай. `/architecture-ui-workflow` не запускай. `/riverpod-codegen` не запускай.

Решение уже принято в `docs/decisions/004-portion-and-journal.md`. Раскладку ниже не обсуждай и не улучшай. Если дерева файлов нет в том виде, как оно перечислено — остановись и напиши, какого пути нет. Не выдумывай другой каталог.

Перед переносом прочитай:

- `docs/decisions/004-portion-and-journal.md` — раздел «Куда лягут файлы потом»
- `docs/architecture.md` — блок Monorepo layout и абзац сразу после таблицы ADR
- `packages/beer_ledger_core/lib/beer_ledger_core.dart`
- `packages/beer_ledger_core/lib/domain/domain.dart`
- `docs/decisions/002-domain-style.md` — только пункт про `*.freezed.dart` в git и команду build_runner

Ветка должна быть `main`, рабочее дерево чистое (`git status -sb` пустой, кроме строки ветки). Иначе стоп. Неперекоммиченный файл этого промпта — тоже стоп: его коммитит человек отдельно, ты перенос не начинаешь. Не переключай ветку сам. Не делай commit, push, pull request и GitHub issue.

---

## Задача (одно предложение)

Разложи `packages/beer_ledger_core/lib/domain/` на `portion/` и `journal/`, поправь импорты и баррель, чтобы публичные имена пакета и тесты ядра остались теми же.

---

## Зачем / приоритет

ADR 004 уже говорит, что порция и журнал — разные языки, а в дереве оба лежат в `domain/`. Этот шаг делает границу видимой. Важнее точный перенос, чем любой попутный рефакторинг. Упавший тест значит, что сломан перенос.

---

## В scope

Файлы порции, `git mv` в `packages/beer_ledger_core/lib/portion/`:

- `lib/domain/clicker.dart` и `clicker.freezed.dart`
- `lib/domain/ledger_axis.dart` и `ledger_axis.freezed.dart`
- `lib/domain/axis_sign.dart`
- `lib/domain/ledger_axis_kind.dart`

Файлы журнала, `git mv` в `packages/beer_ledger_core/lib/journal/`:

- `lib/domain/click.dart` и `click.freezed.dart`
- `lib/domain/axis_contribution.dart` и `axis_contribution.freezed.dart`

`lib/domain/domain.dart` удалить. Каталог `domain/` после этого пустой и в дереве не остаётся.

Новые баррели, только `export` соседних файлов, без логики:

- `lib/portion/portion.dart` экспортирует `axis_sign.dart`, `clicker.dart`, `ledger_axis.dart`, `ledger_axis_kind.dart`
- `lib/journal/journal.dart` экспортирует `axis_contribution.dart`, `click.dart`

В `lib/beer_ledger_core.dart` строку `export 'domain/domain.dart';` заменить на экспорт этих двух баррелей. Остальные export не трогать.

Импорты, которые смотрят в старый `domain/`, переписать на новые пути. Глубина `../measure`, `../convert`, `../failure`, `../result` не меняется: и `portion/`, и `journal/` лежат прямо в `lib/`.

- `lib/journal/click.dart` импортирует `../portion/clicker.dart`. `axis_contribution.dart` остаётся соседом.
- `lib/journal/axis_contribution.dart` импортирует `../portion/ledger_axis_kind.dart`.
- `lib/preset/beer_half_liter.dart` импортирует `axis_sign.dart`, `clicker.dart`, `ledger_axis.dart`, `ledger_axis_kind.dart` из `../portion/`.
- `lib/aggregate/aggregate_for_period.dart` импортирует `../journal/click.dart` и `../portion/ledger_axis_kind.dart`.
- `lib/aggregate/period_balances.dart` импортирует `../portion/ledger_axis_kind.dart`.

Направление зависимостей: файлы в `portion/` не импортируют `journal/`. Журнал может импортировать порцию. `aggregate/` читает оба. `preset/` читает только порцию.

Тесты ядра переносятся так же, тела тестов не меняются:

- `test/domain/clicker_test.dart` → `test/portion/clicker_test.dart`
- `test/domain/click_record_test.dart` → `test/journal/click_record_test.dart`
- `test/domain/domain_fixtures.dart` → `test/fixtures/domain_fixtures.dart`

Импорт фикстур: из `test/portion/` и `test/journal/` — `../fixtures/domain_fixtures.dart`. В `test/aggregate/aggregate_for_period_test.dart` путь `../domain/domain_fixtures.dart` заменить на `../fixtures/domain_fixtures.dart`.

`*.freezed.dart` лежат в git. Перенести их `git mv` вместе с исходником, руками не редактировать. Затем из каталога `packages/beer_ledger_core` выполнить `dart run build_runner build --delete-conflicting-outputs`. Если команда изменила файл, который не входил в перенос (`failure.freezed.dart`, `period_balances.freezed.dart` и любой другой), верни этот файл через `git checkout -- <путь>` и остановись, показав `git diff --stat`.

Документы, и только указанные места:

- `docs/architecture.md`. В дереве Monorepo layout строку `domain/` заменить двумя: `portion/` (Clicker, LedgerAxis, AxisSign, LedgerAxisKind) и `journal/` (Click, AxisContribution, Click.record). В схеме слоёв слово `domain` заменить на `portion, journal`. Таблицу «Миграция из fast_2020» не трогать: это след итерации 1.1. Абзац после таблицы ADR заменить на: каталоги `portion/` и `journal/` в core есть; слоёв `lib/domain/`, `lib/application/`, `lib/presentation/home/` ещё нет. Шапка: дата с машины (`date '+%Y-%m-%d %H:%M:%S %z'`), версия на 1 больше текущей. Дату создания не менять.
- `docs/decisions/001-storage.md`. В уже существующих целях ссылок заменить только сегмент пути: `lib/domain/click.dart` на `lib/journal/click.dart`, `lib/domain/ledger_axis_kind.dart` на `lib/portion/ledger_axis_kind.dart`. Форму ссылки и остальные предложения не менять. Шапка: та же команда даты, версия +1, дату создания не менять.
- `packages/beer_ledger_core/README.md`. В списке возможностей пункт `domain` заменить пунктами `portion` и `journal` с теми же именами типов. Пример кода не менять: публичный вызов `Click.record` тот же. Шапка: дата, версия +1, дату создания не менять.

## Вне scope (явно)

- Любой файл в `lib/` приложения, `test/` приложения, `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/`.
- Каталоги `measure/`, `failure/`, `result/`, `convert/`, `aggregate/`, `preset/` — их не перемещать. Меняются только импорты, перечисленные выше.
- `lib/domain/`, `lib/application/`, `lib/presentation/` приложения. Их нет, и этот шаг их не создаёт.
- Типы `ClickId`, `ClickerId`, типы сумм осей, обёртка множителя. Поля остаются `String` и `double`.
- Текст ADR 002, 003 и 004. ADR 002 по-прежнему описывает дерево итерации 1.1.
- `docs/prompts/iter-3.5/01-adr-portion-journal.md`, `README.md` репозитория, `docs/ci.md`, реестры в `docs/registries/`.
- `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, константа `beerLedgerCoreVersion`.
- Репозиторий `flutter-senior-prep`.
- GitHub issue, ветка, commit, push.

Если `rg "beer_ledger_core/domain"` по `*.dart` найдёт импорт вне пакета — стоп и список файлов. Ожидание: таких импортов нет, приложение берёт пакет через `package:beer_ledger_core/beer_ledger_core.dart`. Не «почини» это переписыванием экранов.

---

## Как переносить

1. Создай каталоги `lib/portion/`, `lib/journal/`, `test/portion/`, `test/journal/`, `test/fixtures/` внутри `packages/beer_ledger_core`.
2. Переноси только `git mv`. Копирование файла с последующим удалением оригинала не использовать: история файла должна идти за ним.
3. Сначала перенос, потом правка импортов, потом баррели, потом `build_runner`, потом документы, потом команды проверки.
4. Тела классов, сигнатуры, значения по умолчанию, комментарии и тексты тестов не переписывать. Если анализатор требует импорт ради уже существующей ссылки в dartdoc — добавь импорт, комментарий оставь.
5. `dart pub get` не запускать: манифест не меняется. Если анализатор говорит, что пакетов нет — стоп, lockfile не трогать.

---

## Definition of Done

Готово только если всё ниже правда. Иначе не писать «готово».

- [ ] `lib/domain/` нет. В `lib/portion/` ровно четыре исходника, два `*.freezed.dart` и `portion.dart`. В `lib/journal/` ровно два исходника, два `*.freezed.dart` и `journal.dart`.
- [ ] `rg "journal/" packages/beer_ledger_core/lib/portion` ничего не находит.
- [ ] `dart analyze --fatal-warnings` и `dart test` из каталога `packages/beer_ledger_core` проходят. Это те же команды, что job `core` в `.github/workflows/ci.yml`.
- [ ] Из корня репозитория `flutter analyze --fatal-warnings lib` проходит. Это job `app`. `flutter test` не запускать: в CI его нет.
- [ ] `git diff` не меняет `lib/` приложения и не меняет тела методов в ядре. Отличия — пути, импорты, баррели, перечисленные документы и, если build_runner переписал их на новом месте, четыре перенесённых `*.freezed.dart`.
- [ ] Commit не сделан.

---

## Как работать (анти-лазейки)

1. Не открывай и не правь `flutter-senior-prep`.
2. Не оставляй `domain/` «для совместимости» и не делай `export` старого пути. Старого пути нет.
3. Не переименовывай `Click`, `Clicker`, `Click.record`, `LedgerAxis`, `LedgerAxisKind`, `AxisSign`, `AxisContribution`.
4. Не переноси `aggregate/` в журнал и `preset/` в порцию. Их очередь не в этом шаге.
5. Не улучшай README примера, CI, ADR 002 и промпт шага 1.
6. Упал тест или analyze — не меняй ожидания теста и не правь формулу. Остановись и покажи команду и хвост лога.
7. Git write (commit, push, ветка, `gh issue`, `gh pr`) — только после отдельной команды человека в чате. Этот промпт такой командой не является.

---

## Формат ответа

1. Первая строка — каталоги разложены, либо стоп и почему.
2. Куда уехал каждый файл из `domain/`.
3. Вывод `git status -sb` и `git diff --stat`.
4. Хвост успешных `dart test` и `flutter analyze`, либо хвост ошибки.
5. Commit не делался.

Без предложений «заодно вынести aggregate» и «заодно ввести ClickId».
