import 'package:beer_ledger_core/arch/value_object.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'click_id.freezed.dart';

/// Идентификатор одного тапа в домене журнала и в SQLite.
///
/// Отдельный тип от [ClickerId]: компилятор не примет id кликера там, где ждут
/// id тапа. В колонку TEXT уходит [value], не [toString].
@freezed
abstract class ClickId with _$ClickId implements ValueObject {
  /// Создаёт обёртку над строкой из хранилища или [Uuid].
  const factory ClickId(String value) = _ClickId;
}
