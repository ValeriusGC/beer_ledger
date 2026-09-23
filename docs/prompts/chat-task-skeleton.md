# Скелет промпта на чат / задачу

**Дата создания:** 2026-08-16 17:53:47 +0500  
**Последнее обновление:** 2026-08-16 18:13:44 +0500  
**Версия:** 2  
**Вид документа:** инструкция

> Копируй в начало чата и заполняй `{{…}}`.  
> **Не дублирует** project rules и skills — **усиливает** конкретную задачу: scope, DoD, анти-лазейки.

Связанные артефакты: `AGENTS.md` · `docs/AGENT_INVARIANTS.md` · `.cursor/rules/` · `.cursor/skills/`

---

## Как пользоваться

1. Открой **нужный репо** в Cursor (`beer_ledger` для кода, `flutter-senior-prep` для штаба/доков).
2. Скопируй блок **«Шаблон»** ниже в чат.
3. Замени `{{…}}` — минимум четыре поля: репо, задача, вне scope, DoD.
4. Для Flutter-кода в конце работы — `/delivery-checklist`.

---

## Шаблон (копировать отсюда)

```markdown
## Контекст (rules/skills не пересказывать)

Действуют project rules и skills этого репо. Их не цитируй — соблюдай.

Репо: `{{beer_ledger | flutter-senior-prep (штаб)}}`
Режим: `{{Agent | Ask}}`
Skills по задаче: `{{/architecture-ui-workflow, /delivery-checklist, … | не нужны}}`

---

## Задача (одно предложение)

{{Что должно измениться после выполнения.}}

---

## Зачем / приоритет

{{Почему сейчас. Что важнее: минимальный diff, ADR, скорость, обучение.}}

---

## В scope

- {{файл / модуль / итерация}}
- {{артефакт: код, ADR, journal, тест}}

## Вне scope (явно)

- {{что НЕ трогать}}
- {{что в parking lot / iter N+1}}

---

## Definition of Done (проверяемо)

Готово = всё ниже. Иначе не писать «готово».

- [ ] {{команда: dart test / flutter analyze / …}}
- [ ] {{поведение или артефакт}}
- [ ] {{док: metadata-шапка, ADR — если нужен}}
- [ ] Реестры обновлены (если новый shared-код в beer_ledger)

Перед сдачей Flutter-кода: `/delivery-checklist`.

---

## Тестирование

1. **Узкий scope (unit under test).** Тест проверяет один слой/модуль. Всё вне scope — mock, stub или fake: l10n, провайдеры, соседние репозитории, навигация, платформа. Не тянуть в тест лишние зависимости «чтобы собралось».
2. **SUT vs mock.** То, что тестируешь напрямую — **не** мокать (напр. in-memory drift при тесте `DriftClickRepository`). Мокать слой **ниже** SUT только если SUT выше (controller → fake `ClickRepository`, не наоборот).
3. **Застрял на обвязке** — сначала grep/`test/` по проекту: есть ли тест с такой же связкой (drift, Riverpod, freezed, `ProviderContainer`). Копировать проверенный паттерн, не изобретать setup с нуля.
4. **Ценность, не coverage ради галочки.** Минимум: happy path **+** осмысленные edge cases (пустой ввод, граница периода, ошибка storage, невалидные данные). Один `expect(true, isTrue)` — дефект, не тест.
5. **Skill:** `dart-add-unit-test` — механика; критерии качества — этот блок.

{{Дополнительно по задаче: какие edge cases обязательны для этого PR}}

---

## Как работать (анти-лазейки)

1. **Неизвестное** — «не проверено» + проверка (файл, команда, docs). Гипотезу не выдавать за инструкцию.
2. **Блокер** — остановиться, спросить. Не додумывать API, IDE, схему БД.
3. **Scope** — не расширять задачу. Лишнее — в «вне scope», не в diff.
4. **Git** — commit/push только по моей явной команде.
5. **Утверждения** — только с опорой на прочитанный файл или вывод команды.

---

## Формат ответа

1. Первая строка — результат или статус (сделано / заблокирован / нужно уточнение).
2. Что изменилось и почему — кратко.
3. Что проверено (команды, файлы).
4. Что осталось / что нужно от меня.

Без воды, без «можно ещё», без хвальбы.

---

## Эскалация (остановиться и спросить)

- {{вариант A vs B без выбора}}
- {{нужен ADR или смена scope}}
- {{поведение Cursor / MCP / multi-root — сначала проверить, потом совет}}
```

---

## Минимум за 30 секунд

| Поле | Пример |
|------|--------|
| Репо | `beer_ledger`, Agent |
| Задача | «ADR drift vs isar для iter 2» |
| Вне scope | «не писать repository, не трогать UI» |
| DoD | «ADR в docs/decisions/, 2 варианта, analyze чистый» |

---

## Пример: ADR storage (beer_ledger)

```markdown
Репо: beer_ledger, Agent. Rules/skills — как в проекте.

Задача: написать ADR — выбор drift vs isar для clicks (iter 2).

В scope: docs/decisions/001-storage.md; ссылка из architecture.md, если есть место.
Вне scope: код repository, миграции, Riverpod, правки в штабе.

DoD:
- [ ] ADR: контекст, 2+ варианта, решение, последствия
- [ ] Факты про drift/isar — только docs/pub.dev
- [ ] Шапка metadata по doc-header-metadata

Анти-лазейки: не «рекомендую drift» без сравнения; не трогать lib/; git — жду команды.
```

---

## Пример: journal (штаб)

```markdown
Репо: flutter-senior-prep (штаб), Agent.

Задача: запись в project_pivomer/journal.md — milestone v1.1 закрыт, следующий iter 2.

В scope: project_pivomer/journal.md.
Вне scope: beer_ledger, roadmap, код.

DoD:
- [ ] Новая секция с датой; шапка metadata, версия +1
- [ ] «Дальше» совпадает с roadmap.md (сверить файл)

Анти-лазейки: дата с машины; roadmap не менять без запроса.
```

---

## Что уже покрыто rules (не дублировать в промпте)

| Тема | Где |
|------|-----|
| Честность, без догадок | `honesty-time-no-fabrication.mdc`, `AGENT_INVARIANTS.md` |
| Планка качества, YAGNI | `quality-bar.mdc` |
| Git commit/push | `git-sovereignty.mdc` |
| DDD, UI Projection | `team-principles.mdc`, `/architecture-ui-workflow` |
| Реестры, DRY | `dry-and-registries.mdc`, `/registry-before-create` |
| Финальная сдача кода | `/delivery-checklist` |
| Карточки Anki (штаб) | `verified-sources-only.mdc` |
| Механика unit-тестов | skill `dart-add-unit-test` |

Промпт добавляет **контекст задачи**, **границы**, **DoD** и **политику тестирования** (узкий scope, edge cases).

---

## Cursor: какой репо открывать

| Задача | Открыть в Cursor |
|--------|------------------|
| Код, тесты, MCP, skills | `beer_ledger` — **File → Open Folder** |
| journal, roadmap, glossary, карточки | `flutter-senior-prep` |
| Оба репо видеть рядом | `senior-prep.code-workspace` — tooling Пивомера **не** подтягивается; для кода всё равно Open Folder на `beer_ledger` |
