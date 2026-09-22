# Реестр: провайдеры и сервисы

**Дата создания:** 2026-07-25 17:13:00 +0500  
**Последнее обновление:** 2026-09-22 11:33:07 +0300  
**Версия:** 6

Перед новым переиспользуемым провайдером или сервисом — проверить таблицу и grep по `lib/`.

| Имя | Путь | Назначение | Когда использовать |
|-----|------|------------|-------------------|
| `appDatabase` | `lib/app/providers/app_database.cg.dart` | Keep-alive файловая SQLite-база. | Нужен executor drift или общий lifecycle БД |
| `clickRepository` | `lib/app/providers/click_repository.cg.dart` | Журнал тапов: `DriftClickRepository` над `appDatabase`. | add / watch / undo из app-слоя; в drift напрямую не ходить |
| `now` | `lib/app/providers/now.cg.dart` | Текущий момент для календарного «сегодня». | Границы дня; в тесте override, не `DateTime.now()` в фиче |
| `clicksForToday` | `lib/app/providers/clicks_for_today.cg.dart` | Поток тапов за локальный день `[now]`. | Экран сегодняшнего журнала; не ходить в `watchClicksForDay` самому |
| `todayBalance` | `lib/app/providers/today_balance.cg.dart` | Суммы за сегодня по осям пресета «Пиво 0.5». | Цифры dashboard; не суммировать тапы в экране |
| `recordClick` | `lib/app/providers/record_click.cg.dart` | Запись одного тапа пресета «Пиво 0.5» в журнал. | Кнопка на home. Не вызывать `addClick` из виджета и не класть запись в `todayBalance` |
| `undoLastClick` | `lib/app/providers/undo_last_click.cg.dart` | Глобальная отмена последнего тапа (ADR 001). | Кнопка undo на home. Не вызывать `undoLastClick` из виджета и не сужать до «только сегодня» |
