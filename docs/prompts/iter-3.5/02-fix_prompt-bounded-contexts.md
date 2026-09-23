# Промпт 3.5 / шаг 2: fix — дерево bounded_contexts

**Дата создания:** 2026-09-23 19:16:22 +0300  
**Последнее обновление:** 2026-09-23 19:16:22 +0300  
**Версия:** 1  
**Вид документа:** инструкция

> Заменяет `docs/prompts/iter-3.5/02-portion-journal-folders.md`. Тот файл не выполнять.  
> Открой в Cursor папку `beer_ledger` (File → Open Folder). Штаб `flutter-senior-prep` не открывать и не править.  
> Этот промпт и `docs/project-structure.md` закоммить отдельно, до чата модели.  
> В чат вставь блок ниже целиком, от «## Контекст» до конца. Каркас — `docs/prompts/chat-task-skeleton.md`; здесь он уже заполнен.

---

## Контекст (rules/skills не пересказывать)

Действуют project rules и skills этого репо. Их не цитируй — соблюдай.

Репо: `beer_ledger`  
Режим: Agent  
Skills по задаче: не нужны. `/delivery-checklist` не запускай. `/architecture-ui-workflow` не запускай. `/riverpod-codegen` не запускай, кроме обязательного `build_runner` ниже.

Закон папок — `docs/project-structure.md`. Другое дерево не предлагай. Если файл из таблицы «откуда» отсутствует — стоп, список отсутствующих путей, ничего не двигай.

Перед работой прочитай:

- `docs/project-structure.md`
- `docs/decisions/004-portion-and-journal.md` — разделы «Решение» и «Куда лягут файлы»
- `docs/architecture.md`
- `docs/decisions/002-domain-style.md` — только пункт: `*.freezed.dart` в git; после правки `@freezed` — `dart run build_runner build --delete-conflicting-outputs`

Этот промпт — явная команда завести GitHub issue, ветку и коммиты. Push и pull request не делать, пока человек не скажет отдельной фразой в этом чате.

---

## Задача (одно предложение)

Переложи уже существующие файлы в дерево из `docs/project-structure.md`: два bounded context в `lib/bounded_contexts/`, слои внутри каждого, агрегат — папка в `domain/`.

---

## Зачем / приоритет

Первый промпт шага 2 клал порцию и журнал только в ядро. Открывший `lib/` контекстов не видел. Сейчас в ядре уже есть `portion/` и `journal/`, а приложение всё ещё в `lib/features/` и `lib/data/`. Это промежуточное дерево считать ошибкой и разобрать. Поведение на телефоне то же. Важнее точный перенос по таблице, чем любой попутный рефакторинг.

---

## Git до правок

1. `git status -sb` и `git branch --show-current`. Нечистое дерево или не `main` — стоп. Не переключай ветку «чтобы починить».
2. Создай issue в milestone `v1.3.5 — lite DDD` (это milestone/7). Родительского issue, которое потом закроет детей, не заводи.

```bash
gh issue create \
  --repo ValeriusGC/beer_ledger \
  --milestone "v1.3.5 — lite DDD" \
  --title "refactor: раскладка lib/bounded_contexts" \
  --body "$(cat <<'EOF'
Раскладка по docs/project-structure.md: порция и журнал — bounded_contexts в lib, слои внутри, агрегат — папка в domain.

Не закрывает другие issue.

EOF
)"
```

3. Запомни номер. Ветка только от `main`:

```bash
git checkout -b feat/<номер>-bounded-contexts
```

4. Каждый коммит — сообщение о причине и отдельной строкой `Ref #<номер>`. Слов `Closes`, `Fixes`, `Close` в коммите нет. Issue закрывает pull request позже, не этот чат.

---

## В scope

Только перенос, импорты, баррели, три маркера DDD, правка путей в перечисленных документах, `flutter test` в job `app` CI. Имена классов, сигнатуры, тела методов, значения по умолчанию не менять — кроме `implements` маркеров на четырёх типах ниже.

### Откуда → куда

Корень приложения — пакет `beer_ledger`. Корень ядра — `packages/beer_ledger_core`. Пути ниже от этих корней. Перенос только `git mv`.

**Агрегат порции** (из корня репозитория)

| Откуда | Куда |
|--------|------|
| `packages/beer_ledger_core/lib/portion/clicker.dart` и `clicker.freezed.dart` | `lib/bounded_contexts/portion/domain/clicker/` |
| `packages/beer_ledger_core/lib/portion/ledger_axis.dart` и `ledger_axis.freezed.dart` | туда же |
| `packages/beer_ledger_core/lib/portion/axis_sign.dart` | туда же |
| `packages/beer_ledger_core/lib/preset/beer_half_liter.dart` | туда же |

**Контракт порции (уже в приложении)**

| Откуда | Куда |
|--------|------|
| `lib/data/repositories/clicker_settings_repository.dart` | `lib/bounded_contexts/portion/domain/clicker/clicker_settings_repository.dart` |

**Агрегат журнала**

| Откуда | Куда |
|--------|------|
| `packages/beer_ledger_core/lib/journal/click.dart` и `click.freezed.dart` | `lib/bounded_contexts/journal/domain/click/` |
| `packages/beer_ledger_core/lib/journal/axis_contribution.dart` и `axis_contribution.freezed.dart` | туда же |
| `packages/beer_ledger_core/lib/aggregate/aggregate_for_period.dart` | туда же |
| `packages/beer_ledger_core/lib/aggregate/period_balances.dart` и `period_balances.freezed.dart` | туда же |
| `lib/data/repositories/click_repository.dart` | `lib/bounded_contexts/journal/domain/click/click_repository.dart` |

**Общий словарь осей**

| Откуда | Куда |
|--------|------|
| `packages/beer_ledger_core/lib/portion/ledger_axis_kind.dart` | `packages/beer_ledger_core/lib/ledger_axis_kind.dart` |

Не в контекст: оба языка называют одни четыре оси.

**Маркеры DDD — новые файлы**, не перенос. Только пустой маркер и DartDoc на русском по Effective Dart (первая строка — что это, дальше зачем, ссылки `[Type]`):

| Файл | Содержимое |
|------|------------|
| `packages/beer_ledger_core/lib/arch/aggregate_root.dart` | `abstract class AggregateRoot {}` |
| `packages/beer_ledger_core/lib/arch/entity.dart` | `abstract class Entity {}` |
| `packages/beer_ledger_core/lib/arch/value_object.dart` | `abstract class ValueObject {}` |

К типам после переноса, не меняя полей:

- `Clicker` и `Click` — `implements AggregateRoot`
- `LedgerAxis` — `implements Entity`
- `AxisContribution` — `implements ValueObject`

`AxisSign` и `LedgerAxisKind` остаются enum без маркера.

**Application порции**

| Откуда | Куда |
|--------|------|
| `lib/app/providers/current_clicker.cg.dart` | `lib/bounded_contexts/portion/application/` |

**Infrastructure порции**

| Откуда | Куда |
|--------|------|
| `lib/data/repositories/drift_clicker_settings_repository.dart` | `lib/bounded_contexts/portion/infrastructure/` |
| `lib/data/mappers/clicker_settings_mapper.dart` | туда же |

**Presentation порции**

| Откуда | Куда |
|--------|------|
| `lib/features/settings/settings_page.dart` | `lib/bounded_contexts/portion/presentation/` |
| `lib/features/settings/portion_input.dart` | туда же |

**Application журнала**

| Откуда | Куда |
|--------|------|
| `lib/app/providers/record_click.cg.dart` | `lib/bounded_contexts/journal/application/` |
| `lib/app/providers/undo_last_click.cg.dart` | туда же |
| `lib/app/providers/clicks_for_today.cg.dart` | туда же |
| `lib/app/providers/today_balance.cg.dart` | туда же |
| `lib/app/providers/volume_for_last_7_days.cg.dart` | туда же |

**Infrastructure журнала**

| Откуда | Куда |
|--------|------|
| `lib/data/repositories/drift_click_repository.dart` | `lib/bounded_contexts/journal/infrastructure/` |
| `lib/data/mappers/click_mapper.dart` | туда же |
| `lib/data/mappers/ledger_axis_kind_wire.dart` | туда же |
| `lib/data/local/day_boundaries.dart` | туда же |

**Presentation журнала**

| Откуда | Куда |
|--------|------|
| `lib/features/home/home_page.dart` | `lib/bounded_contexts/journal/presentation/` |
| `lib/features/home/today_balance_card.dart` | туда же |
| `lib/features/home/today_balance_format.dart` | туда же |
| `lib/features/home/today_clicks_section.dart` | туда же |
| `lib/features/home/today_clicks_format.dart` | туда же |
| `lib/features/home/week_volume_chart.dart` | туда же |

**Ядро приложения, не контекст**

| Откуда | Куда |
|--------|------|
| `lib/data/local/app_database.dart` | `lib/core/persistence/app_database.dart` |
| `lib/app/providers/app_database.cg.dart` | `lib/core/di/` |
| `lib/app/providers/now.cg.dart` | `lib/core/di/` |
| `lib/app/providers/click_repository.cg.dart` | `lib/core/di/` |
| `lib/app/providers/clicker_settings_repository.cg.dart` | `lib/core/di/` |

`lib/app/router.dart` и `lib/app/flavor.dart` не двигать. `lib/main.dart` и `lib/l10n/` не двигать.

**Удалить после переноса, если пусто**

- `packages/beer_ledger_core/lib/portion/` включая `portion.dart`
- `packages/beer_ledger_core/lib/journal/` включая `journal.dart`
- `packages/beer_ledger_core/lib/aggregate/` включая `aggregate.dart`
- `packages/beer_ledger_core/lib/preset/` включая `preset.dart`
- `lib/data/`
- `lib/features/`
- `lib/app/providers/`

**Баррели** — новые, только `export`, DartDoc одной фразой что за контекст:

- `lib/bounded_contexts/portion/portion.dart` — domain clicker + application + presentation, которые этому контексту нужны снаружи (роутер импортирует presentation отсюда или напрямую из `settings_page.dart`; выбери один путь и везде его)
- `lib/bounded_contexts/journal/journal.dart` — аналогично для журнала
- `packages/beer_ledger_core/lib/arch/arch.dart` — три маркера

В `packages/beer_ledger_core/lib/beer_ledger_core.dart` убрать export `portion`, `journal`, `aggregate`, `preset`. Добавить `arch/arch.dart` и `ledger_axis_kind.dart`. Остальные export не трогать.

**Тесты — тот же перенос**

| Откуда | Куда |
|--------|------|
| `packages/beer_ledger_core/test/portion/clicker_test.dart` | `test/bounded_contexts/portion/domain/clicker/clicker_test.dart` |
| `packages/beer_ledger_core/test/preset/beer_half_liter_test.dart` | `test/bounded_contexts/portion/domain/clicker/` |
| `packages/beer_ledger_core/test/preset/beer_preset_matrix_test.dart` | туда же |
| `packages/beer_ledger_core/test/journal/click_record_test.dart` | `test/bounded_contexts/journal/domain/click/` |
| `packages/beer_ledger_core/test/aggregate/aggregate_for_period_test.dart` | туда же |
| `packages/beer_ledger_core/test/fixtures/domain_fixtures.dart` | `test/helpers/domain_fixtures.dart` |
| `test/features/settings/*` | `test/bounded_contexts/portion/presentation/` |
| `test/data/drift_clicker_settings_repository_test.dart` | `test/bounded_contexts/portion/infrastructure/` |
| `test/features/home/*` | `test/bounded_contexts/journal/presentation/` |
| `test/app/providers/record_click_test.dart` | `test/bounded_contexts/journal/application/` |
| `test/app/providers/undo_last_click_test.dart` | туда же |
| `test/app/providers/clicks_for_today_test.dart` | туда же |
| `test/app/providers/today_balance_test.dart` | туда же |
| `test/app/providers/volume_for_last_7_days_test.dart` | туда же |
| `test/data/drift_click_repository_test.dart` | `test/bounded_contexts/journal/infrastructure/` |
| `test/data/click_mapper_test.dart` | туда же |
| `test/data/app_database_test.dart` | `test/core/persistence/` |
| `test/app/beer_ledger_router_test.dart` | `test/app/` (уже там — не двигать) |
| `test/l10n/app_localizations_smoke_test.dart` | не двигать |

Тесты `packages/beer_ledger_core/test/measure/`, `convert/`, `result/`, `beer_ledger_core_test.dart` не двигать.

Импорты в тестах: типы `Click`, `Clicker` и соседние — `package:beer_ledger/...`, не `package:beer_ledger_core/...`. Словарь единиц, `Failure`, `Result`, `LedgerAxisKind` — по-прежнему `package:beer_ledger_core/...`.

**Документы, только пути**

- `docs/architecture.md` — блок Monorepo layout уже целевой; убери оговорку «пока код не перенесён», если после переноса `lib/features` и `lib/data` нет. Шапка: дата с машины, версия +1, дату создания не менять.
- `docs/decisions/001-storage.md` — в ссылках заменить сегмент `lib/domain/` или `lib/journal/` ядра на новый путь `lib/bounded_contexts/journal/domain/click/click.dart` и `packages/beer_ledger_core/lib/ledger_axis_kind.dart`. Шапка: дата, версия +1.
- `packages/beer_ledger_core/README.md` — возможности: нет пунктов domain/portion/journal; есть arch, measure, convert, Failure, Result, LedgerAxisKind. Пример с `Click.record` переписать на импорт `package:beer_ledger/...` или убрать вызов Click, оставив convert/measure. Шапка: дата, версия +1.
- Реестры в `docs/registries/`, если в них записан старый путь файла — обновить путь, не описание заново.

**CI**

В `.github/workflows/ci.yml` job `app` после `flutter analyze --fatal-warnings lib` добавить:

```yaml
      - run: flutter test
```

Иначе тесты домена, уехавшие из пакета core, в CI не бегут. Job `core` не трогать: `dart test` остаётся для measure/convert/result.

**build_runner**

1. Из `packages/beer_ledger_core`: `dart run build_runner build --delete-conflicting-outputs`. Если изменился файл не из переноса (`failure.freezed.dart` и любой другой чужой) — `git checkout --` этот файл и стоп.
2. Из корня репозитория: та же команда для `@riverpod` после переезда `.cg.dart`. Чужие generated не в этом шаге — стоп.

**Комментарии**

Новые публичные файлы (маркеры, баррели) — DartDoc по rule `dart-dartdoc-comments`: русский, первая строка говорит что это, дальше зачем, типы в `[Скобках]`. Существующие `///` не переписывать «ради стиля». Тела методов не комментировать.

---

## Вне scope (явно)

- Типы `ClickId`, `ClickerId`, суммы осей, обёртка множителя.
- Смена сигнатуры `Click.record`: параметр `Clicker` остаётся. Это единственный импорт домена порции из домена журнала. Не «чини изоляцию» в этом шаге.
- Переписывание виджетов на UI Projection.
- Папки `lib/core/network/`, `lib/core/theme/`, `lib/core/arch/` (arch живёт в пакете).
- Общие `lib/domain/`, `lib/application/`, `lib/presentation/`, `lib/features/`.
- Репозиторий `flutter-senior-prep`.
- Текст ADR 002, 003. ADR 004 не переписывать: раскладка уже в нём и в `project-structure.md`.
- `README.md` репозитория, `docs/ci.md` кроме если единственная строка про analyze без test врёт — тогда одна фраза, что job `app` гоняет `flutter test`.
- `pubspec.yaml` / lock, кроме случая когда анализатор требует и это не лечится импортом — тогда стоп.
- Push, pull request, `gh pr create`.
- Второе GitHub issue.

`Click.record` после переноса импортирует `Clicker` по новому пути `package:beer_ledger/bounded_contexts/portion/domain/clicker/clicker.dart` (или через баррель порции). Это ожидаемо.

---

## Как переносить

1. Создай каталоги назначения. Пустых слоёв нет: в каждый слой из дерева что-то переезжает.
2. Только `git mv`. Не копируй и не удаляй оригинал отдельно.
3. Порядок: каталоги → `git mv` → импорты → баррели и export ядра → маркеры + `implements` → build_runner → документы и CI → тесты и analyze.
4. Не переименовывай классы `Click`, `Clicker`, `Click.record`, `ClickRepository`, `ClickerSettingsRepository`.
5. Не запускай `dart pub get` / `flutter pub get`, пока анализатор не скажет, что пакетов нет. Lockfile не трогать.

Проверка изоляции после импортов (не считая моста `click.dart` → `clicker.dart`):

```bash
rg "bounded_contexts/portion" lib/bounded_contexts/journal --glob '!**/click.dart'
rg "bounded_contexts/journal" lib/bounded_contexts/portion
```

Второе должно быть пусто. Первое — пусто, если исключить `click.dart`. Любой другой файл журнала, импортирующий порцию — стоп и список.

---

## Definition of Done

Готово только если всё ниже правда. Иначе не писать «готово».

- [ ] Issue создан в milestone `v1.3.5 — lite DDD`, ветка `feat/<номер>-bounded-contexts`.
- [ ] Нет `lib/features/`, `lib/data/`, `lib/app/providers/`, `packages/beer_ledger_core/lib/portion/`, `.../journal/`, `.../aggregate/`, `.../preset/`.
- [ ] Есть дерево как в `docs/project-structure.md` (без `network/` и `theme/`).
- [ ] `dart analyze --fatal-warnings` и `dart test` в `packages/beer_ledger_core` проходят.
- [ ] Из корня: `flutter analyze --fatal-warnings lib` и `flutter test` проходят.
- [ ] Коммиты содержат `Ref #<номер>` и не содержат `Closes`.
- [ ] Push не сделан.

---

## Как работать (анти-лазейки)

1. Не открывай `flutter-senior-prep`.
2. Не оставляй `lib/features` «на всякий случай» и не делай re-export старых путей.
3. Не клади `Click` обратно в `beer_ledger_core`.
4. Не создавай `lib/bounded_contexts/showcase/` и не переименовывай `journal/presentation` в `home`.
5. Упал тест — не меняй ожидание. Остановись, команда и хвост лога.
6. Push и PR — только после отдельной фразы человека в этом чате.

---

## Формат ответа

1. Первая строка — дерево разложено, либо стоп и почему.
2. Номер issue и имя ветки.
3. Таблица: каждый исходный каталог → куда уехал.
4. `git status -sb` и `git log --oneline -5`.
5. Хвост `dart test`, `flutter analyze`, `flutter test`.
6. Push не делался.

Без предложений «заодно ввести ClickId» и «заодно переписать главную на UI Projection».
