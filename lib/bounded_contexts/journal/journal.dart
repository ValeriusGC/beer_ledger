/// Bounded context «журнал»: факты тапов «что уже случилось».
///
/// Снаружи контекста отсюда берут главную и сценарии записи, отмены, сегодня
/// и семи дней. Порцию не экспортирует.
library;

export 'application/clicks_for_today.cg.dart';
export 'application/record_click.cg.dart';
export 'application/today_balance.cg.dart';
export 'application/undo_last_click.cg.dart';
export 'application/volume_for_last_7_days.cg.dart';
export 'domain/click/aggregate_for_period.dart';
export 'domain/click/axis_contribution.dart';
export 'domain/click/click.dart';
export 'domain/click/click_repository.dart';
export 'domain/click/period_balances.dart';
export 'presentation/home_page.dart';
export 'presentation/today_balance_card.dart';
export 'presentation/today_balance_format.dart';
export 'presentation/today_clicks_format.dart';
export 'presentation/today_clicks_section.dart';
export 'presentation/week_volume_chart.dart';
