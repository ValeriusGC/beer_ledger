# Реестр: форматтеры

**Дата создания:** 2026-07-25 17:13:00 +0500  
**Последнее обновление:** 2026-09-23 20:36:08 +0300  
**Версия:** 3

Перед новым форматтером дат, строк, масок — проверить таблицу и grep по `lib/`.

| Имя | Путь | Назначение | Когда использовать |
|-----|------|------------|-------------------|
| `formatTodayClickTime` | `lib/bounded_contexts/journal/presentation/today_clicks_format.dart` | Время тапа в журнале: часы, минуты, секунды. | Строка списка за сегодня |
| `formatTodayClickVolume` | `lib/bounded_contexts/journal/presentation/today_clicks_format.dart` | Объём тапа в литрах из базовых единиц. | Строка списка за сегодня |
| `formatRecordBeerVolume` | `lib/bounded_contexts/journal/presentation/today_clicks_format.dart` | Текущий объём порции для подписи кнопки тапа. | Кнопка на home, не зашитый «0.5» |
