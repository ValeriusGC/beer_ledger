/// Bounded context «порция»: живой clicker «что будет при нажатии сейчас».
///
/// Снаружи контекста отсюда берут presentation и сценарий текущей порции.
/// Журнал этот баррель не импортирует, кроме моста [Click.record].
library;

export 'application/current_clicker.cg.dart';
export 'domain/clicker/axis_sign.dart';
export 'domain/clicker/beer_half_liter.dart';
export 'domain/clicker/clicker.dart';
export 'domain/clicker/clicker_settings_repository.dart';
export 'domain/clicker/ledger_axis.dart';
export 'presentation/portion_input.dart';
export 'presentation/settings_page.dart';
