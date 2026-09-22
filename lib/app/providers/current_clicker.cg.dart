import 'package:beer_ledger/app/providers/clicker_settings_repository.cg.dart';
import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_clicker.cg.g.dart';

/// Текущая порция единственного clicker v1.
///
/// Экран настроек и запись тапа смотрят сюда. В рантайме записи не подставлять
/// [beerHalfLiter] вместо этого потока: пресет даёт только название, единицы и знаки.
@riverpod
Stream<Clicker> currentClicker(Ref ref) {
  return ref
      .watch(clickerSettingsRepositoryProvider)
      .watchClicker(beerHalfLiter().id);
}
