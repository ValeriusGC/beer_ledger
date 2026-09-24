# Промпт 3.5 / шаг 3: value object'ы id и сумм осей

**Дата создания:** 2026-09-24 07:10:59 +0300  
**Последнее обновление:** 2026-09-24 07:58:10 +0300  
**Версия:** 2  
**Вид документа:** инструкция

> Шаг 3 итерации 3.5. Дерево `lib/bounded_contexts/` уже на `main` (коммит раскладки, issue #62). Этот шаг вводит типы, а не папки.  
> Открой в Cursor папку `beer_ledger` (File → Open Folder). Штаб `flutter-senior-prep` не открывать и не править.  
> Этот промпт закоммить отдельно, до чата модели.  
> В чат вставь блок ниже целиком, от «## Контекст» до конца. Каркас — `docs/prompts/chat-task-skeleton.md`; здесь он уже заполнен.

---

## Контекст (rules/skills не пересказывать)

Действуют project rules и skills этого репо. Их не цитируй — соблюдай.

Репо: `beer_ledger`  
Режим: Agent  
Skills по задаче: не нужны. `/delivery-checklist` не запускай. `/architecture-ui-workflow` не запускай. `/riverpod-codegen` не запускай, кроме обязательного `build_runner` ниже.

Закон папок — `docs/project-structure.md`. Новых корзин `value_objects/`, `entities/` не создавать. Типы кладутся в уже существующие папки агрегатов.

Перед кодом прочитай:

- `docs/project-structure.md` — раздел про агрегат и «следующие шаги»
- `lib/bounded_contexts/portion/domain/clicker/clicker.dart`
- `lib/bounded_contexts/journal/domain/click/click.dart` — `Click.record`
- `lib/bounded_contexts/journal/domain/click/axis_contribution.dart`
- `lib/bounded_contexts/journal/domain/click/period_balances.dart`
- `lib/bounded_contexts/journal/domain/click/aggregate_for_period.dart`
- `lib/bounded_contexts/journal/infrastructure/click_mapper.dart`
- `packages/beer_ledger_core/lib/arch/value_object.dart`
- `packages/beer_ledger_core/lib/convert/convert.dart` — `fromBase` / `deltaInBase` остаются на `double`

Решение ниже уже принято. Не выбирай другой набор типов. Если файл из списка чтения отсутствует — стоп.

Этот промпт — явная команда завести GitHub issue, ветку и коммиты. Push и pull request не делать, пока человек не скажет отдельной фразой в этом чате.

---

## Задача (одно предложение)

Введи `ClickId`, `ClickerId` и `SignedBaseDelta` так, чтобы id тапа нельзя было подставить туда, где ждут id кликера, а миллилитры нельзя было сложить с копейками типом.

---

## Зачем / приоритет

Сейчас оба id — `String`, все суммы — `double`. Компилятор не отличит тап от кликера и объём от денег. На телефоне цифры те же. Схема SQLite не меняется: обёртка живёт в домене, в TEXT/REAL кладётся `.value` / `.signedBase`.

---

## Git до правок

1. `git status -sb` и `git branch --show-current`. Не `main` или грязное дерево — стоп.
2. Issue в milestone `v1.3.5 — lite DDD` (milestone/7). Родительского issue, которое закроет детей, не заводи.

```bash
gh issue create \
  --repo ValeriusGC/beer_ledger \
  --milestone "v1.3.5 — lite DDD" \
  --title "refactor: ClickId, ClickerId и суммы осей как value object" \
  --body "$(cat <<'EOF'
Value object'ы в папках агрегатов: ClickId, ClickerId, SignedBaseDelta. Схема SQLite не меняется. Не закрывает другие issue.
EOF
)"
```

3. Ветка только от `main`: `feat/<номер>-value-objects`
4. Один коммит на всю работу шага: типы, домен, маппер, presentation (только замена полей), тесты, доки. Дробить «сначала типы» нельзя: после смены `Click.id` дерево не собирается, пока не протянуты вызовы. Сообщение — причина, затем строка `Ref #<номер>`. Слов `Closes` / `Fixes` / `Close` нет.

---

## Какие типы завести (закрытый список)

Все новые типы — `@freezed`, `implements ValueObject`, DartDoc на русском по Effective Dart (первая строка — что это, дальше зачем, ссылки `[Type]`). Маркер `ValueObject` уже есть в `packages/beer_ledger_core/lib/arch/value_object.dart`. Пустой `String` и любой `double` не валидировать: это обёртка, не новый инвариант.

Имена файлов как у домена сейчас, не как у Riverpod: исходник `click_id.dart`, `part 'click_id.freezed.dart'`. Суффикс `.cg.dart` не ставить. Он у `@riverpod` (`record_click.cg.dart`). Образец в этом слое — `click.dart` / `click.freezed.dart`.

### 1. `ClickerId`

Файл: `lib/bounded_contexts/portion/domain/clicker/clicker_id.dart`

Одно поле `value` типа `String`. Экспорт в `lib/bounded_contexts/portion/portion.dart`.

`Clicker.id` становится `ClickerId`.  
`beerHalfLiter({ClickerId id = const ClickerId('clicker-beer')})`.  
`ClickerSettingsRepository.watchClicker(ClickerId id)`.  
`Click.clickerId` и `Click.record(... clickerId:)` — тоже `ClickerId`.

### 2. `ClickId`

Файл: `lib/bounded_contexts/journal/domain/click/click_id.dart`

Одно поле `value` типа `String`. Экспорт в `lib/bounded_contexts/journal/journal.dart`.

`Click.id` и `Click.record(... id:)` — `ClickId`.  
`RecordClick.record` пишет `id: ClickId(const Uuid().v4())`.

`ClickId` и `ClickerId` — разные классы. Общего typedef на `String` нет.

### 3. `SignedBaseDelta`

Файл: `lib/bounded_contexts/journal/domain/click/signed_base_delta.dart`  
Экспорт в баррель журнала.

Классические factory-варианты freezed, общее позиционное поле `signedBase`. Другой формы (named-only, отдельные классы без союза) не заводить:

```dart
@freezed
sealed class SignedBaseDelta with _$SignedBaseDelta implements ValueObject {
  const SignedBaseDelta._();
  const factory SignedBaseDelta.volume(double signedBase) = VolumeDelta;
  const factory SignedBaseDelta.energy(double signedBase) = EnergyDelta;
  const factory SignedBaseDelta.money(double signedBase) = MoneyDelta;
  const factory SignedBaseDelta.joy(double signedBase) = JoyDelta;
}
```

Смысл вариантов: volume — миллилитры, energy — калории (как сейчас в `AxisContribution`), money — копейки, joy — баллы.

Геттер `kind` на союзе: `VolumeDelta` → `LedgerAxisKind.volume` и так далее.

Фабрика `SignedBaseDelta.fromKind(LedgerAxisKind kind, double signedBase)` — для маппера Drift и нулей в агрегации.

Сложение **только на варианте**, не на союзе. На `VolumeDelta` — `operator +(VolumeDelta other)`. Аналогично три других. На `SignedBaseDelta` оператора `+` нет: иначе `VolumeDelta + MoneyDelta` снова скомпилируется.

В `aggregateForPeriod` складывать через `switch` по паре вариантов. Смешанная пара — `StateError` (баг программиста, не `Failure`).

`AxisContribution`: поле `signedBaseDelta` (`double`) и поле `kind` убрать. Вместо них одно поле `delta` типа `SignedBaseDelta`. Геттер `LedgerAxisKind get kind => delta.kind` оставить, чтобы сортировка и `contribution(..., kind)` не плодили новый язык.

`PeriodBalances.totalsInBase`: `Map<LedgerAxisKind, SignedBaseDelta>`.  
`totalFor(kind)` возвращает `SignedBaseDelta`, нет ключа — `SignedBaseDelta.fromKind(kind, 0)`.  
Цифру для `fromBase` / `NumberFormat` брать `.signedBase`. Сигнатуры `fromBase` / `deltaInBase` / `convert` не менять.

---

## Граница с базой и UI

Колонки Drift те же TEXT/REAL. В маппере:

- запись: `click.id.value`, `click.clickerId.value`, `contribution.delta.signedBase`, `ledgerAxisKindToWire(contribution.kind)`
- чтение: `ClickId(row.id)`, `ClickerId(row.clickerId)`, `SignedBaseDelta.fromKind(ledgerAxisKindFromWire(row.kind), row.signedBaseDelta)`

`Key('today-click-${click.id}')` в `today_clicks_section.dart` станет `'today-click-${click.id.value}'`. Freezed `toString()` в ключ и в SQL не класть.

Presentation в diff входит. Это замена поля, не UI Projection: не трогать виджеты, колбэки и раскладку экрана. В `today_clicks_format.dart` объём тапа:

```dart
fromBase(volume.delta.signedBase, VolumeUnit.liter)
```

Геттер `kind` на `AxisContribution` остаётся (`=> delta.kind`): циклы `contribution.kind` можно не переписывать. Карточка и график: `balances.totalFor(...).signedBase`.

`equals` в Drift — по `.value`.

Схема, миграции, `schemaVersion` — не трогать.

---

## Что не оборачивать

- `Click.factor` и параметр `factor` у `Click.record` — `double`, всегда 1 в продукте, тип множителя не вводим.
- `LedgerAxis.enteredValue`, `enteredInId`, `Clicker.title`.
- `DayVolume.liters` — это уже литры для графика, не доменная сумма.
- `MeasureUnit` и `convert.dart`.

`Click.record` по-прежнему принимает `Clicker`. Изоляцию доменов не чини — это шаг 4.

---

## Тесты

Существующие тесты поправить по типам, ожидания чисел не менять: `500.0` мл остаются `500.0`, проверять `contribution(...).delta.signedBase` и `balances.totalFor(...).signedBase`.

`expect(clicker.id, 'clicker-beer')` → `expect(clicker.id, const ClickerId('clicker-beer'))`.  
Списки id: `ClickId('click-late')`, не голая строка, либо `.value` с обеих сторон — один стиль на файл.

Фейки `watchClicker(String id)` в тестах — `ClickerId`.

Новые тесты (минимум):

- `test/bounded_contexts/portion/domain/clicker/clicker_id_test.dart`:

```dart
expect(const ClickerId('a'), const ClickerId('a'));
expect(const ClickerId('a'), isNot(isA<ClickId>()));
```

`ClickerId('a') != ClickId('a')` не писать: линт `unrelated_type_equality_checks`. Сравнивать `.value` не надо: обе обёртки могут хранить `'a'`. Разделение id — сигнатура `Click.record(id: ClickId(...), clickerId: ClickerId(...))`; голая строка не компилируется.

- `test/bounded_contexts/journal/domain/click/signed_base_delta_test.dart` — `VolumeDelta(1) + VolumeDelta(2)` даёт `VolumeDelta(3)`; `fromKind(LedgerAxisKind.volume, 500).kind == LedgerAxisKind.volume`.

Тест «два разных варианта нельзя сложить» кодом не пишется: это ошибка компиляции. В DartDoc `SignedBaseDelta` одной фразой сказать, что `+` есть только у одинаковых вариантов.

Тела сценариев (успех тапа, undo, пустой день) не переписывать ради coverage.

---

## Документы

- `docs/project-structure.md`: в дереве агрегатов добавить `clicker_id.dart` и `click_id.dart` / `signed_base_delta.dart`. Раздел «Следующие шаги» — этих трёх типов там больше нет; остаётся UI Projection на главной. Шапка: дата с `date '+%Y-%m-%d %H:%M:%S %z'`, версия +1, дату создания не менять.
- `docs/architecture.md`: одна фраза в принципах DDD, что id и суммы осей — value object'ы в папке агрегата. Шапка так же.
- ADR 001, 002, 003, 004 не переписывать. Новый ADR не заводить: набор типов уже назван в ADR 004.

Реестры — только если в них записан старый путь поля; иначе не трогать.

---

## build_runner

Из корня репозитория: `dart run build_runner build --delete-conflicting-outputs`.  
Из `packages/beer_ledger_core` — не запускать: пакет не меняется, кроме чтения `ValueObject`.

Если команда переписала чужой generated — `git checkout --` этот файл и стоп.

---

## Вне scope

- Каталоги `lib/domain/`, `value_objects/` на весь app или на контекст.
- Смена `Click.record(Clicker)`.
- UI Projection как перепись главной. Правка `today_clicks_format.dart`, карточки и графика — только `.delta.signedBase` / `.value`, см. раздел «Граница с базой и UI».
- Новые экраны, кнопка «устоял», 0.33 L.
- `packages/beer_ledger_core` кроме чтения маркера.
- Репозиторий `flutter-senior-prep` и `deferred-decisions.md` штаба.
- Push, pull request, второе issue.

---

## Definition of Done

- [ ] Issue в milestone `v1.3.5 — lite DDD`, ветка `feat/<номер>-value-objects`.
- [ ] `Click.record(id: 'x', clickerId: 'y', ...)` не компилируется.
- [ ] `VolumeDelta(1) + MoneyDelta(1)` не компилируется.
- [ ] `git diff` не содержит `schemaVersion` и новых `.drift` миграций.
- [ ] `dart analyze --fatal-warnings` и `dart test` в `packages/beer_ledger_core` проходят.
- [ ] Из корня: `flutter analyze --fatal-warnings lib` и `flutter test` проходят.
- [ ] Один коммит с `Ref #<номер>`, без `Closes`.
- [ ] Push не сделан.

---

## Как работать (анти-лазейки)

1. Не открывай `flutter-senior-prep`.
2. Не оставляй `String id` «рядом для удобства» и не добавляй `toString() => value` у id: ключи и SQL берут `.value` явно.
3. Не дроби на коммиты «типы / маппер / тесты»: один коммит, см. Git.
4. Не клади `SignedBaseDelta` в `beer_ledger_core`: суммы — язык журнала, `convert` остаётся про `double`.
5. Не вводи `Factor`, `UnitId`, обёртку `enteredValue`. Не называй VO-файлы `*.cg.dart`.
6. Упал тест — не меняй ожидаемое число. Остановись, команда и хвост лога.
7. Push и PR — только после отдельной фразы человека.

---

## Формат ответа

1. Первая строка — типы введены, либо стоп и почему.
2. Номер issue и имя ветки.
3. Какие три файла типов созданы и какие поля сущностей сменили тип.
4. `git log --oneline -3` и `git diff --stat`. Один коммит на шаге.
5. Хвост `flutter test` / `dart test`.
6. Push не делался.

Без предложений «заодно разорвать Click.record(Clicker)» и «заодно UI Projection».
