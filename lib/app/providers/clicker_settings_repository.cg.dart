import 'package:beer_ledger/app/providers/app_database.cg.dart';
import 'package:beer_ledger/data/repositories/clicker_settings_repository.dart';
import 'package:beer_ledger/data/repositories/drift_clicker_settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clicker_settings_repository.cg.g.dart';

/// Настройки порции над [appDatabase].
///
/// Экран и запись тапа не ходят в drift сами.
///
/// [Ref.watch], не [Ref.read]: репозиторий привязан к той БД, которую
/// сейчас отдаёт [appDatabase].
@Riverpod(keepAlive: true)
ClickerSettingsRepository clickerSettingsRepository(Ref ref) {
  return DriftClickerSettingsRepository(ref.watch(appDatabaseProvider));
}
