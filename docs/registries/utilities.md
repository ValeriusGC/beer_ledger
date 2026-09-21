# Реестр: утилиты

**Дата создания:** 2026-07-25 17:13:00 +0500  
**Последнее обновление:** 2026-09-21 18:53:17 +0300  
**Версия:** 2

Перед новой чистой функцией или helper — проверить таблицу и grep по `lib/`.

| Имя | Путь | Назначение | Когда использовать |
|-----|------|------------|-------------------|
| `beer_ledger_core` | `packages/beer_ledger_core/` | Pure Dart domain (Clicker, Click, Calc) | Логика без Flutter |
| `isDevFlavor` | `lib/app/flavor.dart` | `true` для сборки `--flavor dev` | DEV-бейдж и debug banner |
| `beerLedgerCoreVersion` | `packages/beer_ledger_core/lib/src/beer_ledger_core_base.dart` | Версия core placeholder | Отладка scaffold |
