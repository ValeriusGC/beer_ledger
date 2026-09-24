// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_click.cg.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Запись одного тапа текущей порции в журнал.
///
/// Виджет [ClickRepository] не вызывает. Порцию берёт из [currentClicker],
/// не из зашитого пресета. Баланс за сегодня подхватывает тап сам, через
/// уже существующий поток. Момент тапа — свежий [now]: провайдер кэшируется,
/// пока его смотрит экран, поэтому запись его обновляет.

@ProviderFor(RecordClick)
final recordClickProvider = RecordClickProvider._();

/// Запись одного тапа текущей порции в журнал.
///
/// Виджет [ClickRepository] не вызывает. Порцию берёт из [currentClicker],
/// не из зашитого пресета. Баланс за сегодня подхватывает тап сам, через
/// уже существующий поток. Момент тапа — свежий [now]: провайдер кэшируется,
/// пока его смотрит экран, поэтому запись его обновляет.
final class RecordClickProvider
    extends $AsyncNotifierProvider<RecordClick, void> {
  /// Запись одного тапа текущей порции в журнал.
  ///
  /// Виджет [ClickRepository] не вызывает. Порцию берёт из [currentClicker],
  /// не из зашитого пресета. Баланс за сегодня подхватывает тап сам, через
  /// уже существующий поток. Момент тапа — свежий [now]: провайдер кэшируется,
  /// пока его смотрит экран, поэтому запись его обновляет.
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

String _$recordClickHash() => r'6d2fa5ec915d57d3782728f6366d63a6e078c885';

/// Запись одного тапа текущей порции в журнал.
///
/// Виджет [ClickRepository] не вызывает. Порцию берёт из [currentClicker],
/// не из зашитого пресета. Баланс за сегодня подхватывает тап сам, через
/// уже существующий поток. Момент тапа — свежий [now]: провайдер кэшируется,
/// пока его смотрит экран, поэтому запись его обновляет.

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
