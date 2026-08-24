# Реестр: провайдеры и сервисы

**Дата создания:** 2026-07-25 17:13:00 +0500  
**Последнее обновление:** 2026-08-24 15:19:24 +0500  
**Версия:** 2

Перед новым переиспользуемым провайдером или сервисом — проверить таблицу и grep по `lib/`.

| Имя | Путь | Назначение | Когда использовать |
|-----|------|------------|-------------------|
| `appDatabase` | `lib/app/providers/app_database.cg.dart` | Keep-alive файловая SQLite-база. В тесте override на `AppDatabase.inMemory()`. | Нужен executor drift или общий lifecycle БД |
| `clickRepository` | `lib/app/providers/click_repository.cg.dart` | Журнал тапов: `DriftClickRepository` над `appDatabase`. | add / watch / undo из app-слоя; в drift напрямую не ходить |
