import 'package:freezed_annotation/freezed_annotation.dart';

import 'ledger_axis.dart';

part 'clicker.freezed.dart';

/// Кнопка-пакет: название и набор осей учёта.
///
/// Один тап по кнопке порождает [Click] через [Click.record]. История тапов
/// **не** хранится здесь — отдельный [List<Click>] передаётся в агрегацию
/// (PR 5) и в репозиторий (iter 2).
@freezed
abstract class Clicker with _$Clicker {
  const factory Clicker({
    required String id,
    required String title,
    required List<LedgerAxis> axes,
  }) = _Clicker;
}
