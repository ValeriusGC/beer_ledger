// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_click.cg.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Запись одного тапа пресета «Пиво 0.5» в журнал.
///
/// Виджет [ClickRepository] не вызывает. Баланс за сегодня подхватывает тап
/// сам, через уже существующий поток. Момент тапа — [now], те же часы,
/// что и у границ дня.

@ProviderFor(RecordClick)
final recordClickProvider = RecordClickProvider._();

/// Запись одного тапа пресета «Пиво 0.5» в журнал.
///
/// Виджет [ClickRepository] не вызывает. Баланс за сегодня подхватывает тап
/// сам, через уже существующий поток. Момент тапа — [now], те же часы,
/// что и у границ дня.
final class RecordClickProvider
    extends $AsyncNotifierProvider<RecordClick, void> {
  /// Запись одного тапа пресета «Пиво 0.5» в журнал.
  ///
  /// Виджет [ClickRepository] не вызывает. Баланс за сегодня подхватывает тап
  /// сам, через уже существующий поток. Момент тапа — [now], те же часы,
  /// что и у границ дня.
  RecordClickProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recordClickProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordClickHash();

  @$internal
  @override
  RecordClick create() => RecordClick();
}

String _$recordClickHash() => r'266f8c41687c07969ce8bcf3f27cbfb4d87ab1ea';

/// Запись одного тапа пресета «Пиво 0.5» в журнал.
///
/// Виджет [ClickRepository] не вызывает. Баланс за сегодня подхватывает тап
/// сам, через уже существующий поток. Момент тапа — [now], те же часы,
/// что и у границ дня.

abstract class _$RecordClick extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
