import 'package:beer_ledger_core/arch/value_object.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'clicker_id.freezed.dart';

/// Идентификатор кликера (кнопки-пакета) в домене порции и в SQLite.
///
/// Отдельный тип от [ClickId]: компилятор не примет id тапа там, где ждут id
/// кликера. В колонку TEXT уходит [value], не [toString].
@freezed
abstract class ClickerId with _$ClickerId implements ValueObject {
  /// Создаёт обёртку над строкой из хранилища или пресета.
  const factory ClickerId(String value) = _ClickerId;
}
