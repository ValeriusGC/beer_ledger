import 'package:beer_ledger_core/beer_ledger_core.dart';

/// Контракт persistence тапов (ADR 001 §5). Реализация — шаг 28d+.
abstract interface class ClickRepository {
  /// Сохраняет тап и вклады осей в одной транзакции.
  Future<Result<void>> addClick(Click click);

  /// Поток тапов за локальный календарный день `[dayLocal]`.
  Stream<List<Click>> watchClicksForDay(DateTime dayLocal);

  /// Удаляет последний тап по `(at DESC, id DESC)` — undo v1 глобальный.
  Future<Result<void>> undoLastClick();
}
