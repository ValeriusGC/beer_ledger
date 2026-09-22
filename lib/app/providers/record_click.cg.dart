import 'dart:async';

import 'package:beer_ledger/app/providers/click_repository.cg.dart';
import 'package:beer_ledger/app/providers/now.cg.dart';
import 'package:beer_ledger/data/repositories/click_repository.dart';
import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'record_click.cg.g.dart';

/// Запись одного тапа пресета «Пиво 0.5» в журнал.
///
/// Виджет [ClickRepository] не вызывает. Баланс за сегодня подхватывает тап
/// сам, через уже существующий поток. Момент тапа — [now], те же часы,
/// что и у границ дня.
@riverpod
class RecordClick extends _$RecordClick {
  /// Полезных данных нет: кнопка смотрит только на загрузку и ошибку.
  @override
  FutureOr<void> build() {}

  /// Пишет один [Click] пресета [beerHalfLiter] через [ClickRepository.addClick].
  ///
  /// Пока предыдущий вызов ещё [AsyncValue.isLoading], сразу выходит.
  /// [Click.record] Left и ошибка хранилища становятся [AsyncError] с [Failure].
  Future<void> record() async {
    if (state.isLoading) return;

    state = const AsyncLoading();

    final clicker = beerHalfLiter();
    final recorded = Click.record(
      id: const Uuid().v4(),
      clickerId: clicker.id,
      at: ref.read(nowProvider),
      clicker: clicker,
    );

    final click = recorded.fold<Click?>((failure) {
      state = AsyncError(failure, StackTrace.current);
      return null;
    }, (click) => click);
    if (click == null) return;

    final saved = await ref.read(clickRepositoryProvider).addClick(click);
    saved.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }
}
