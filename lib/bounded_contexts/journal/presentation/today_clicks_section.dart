import 'package:beer_ledger/bounded_contexts/journal/application/clicks_for_today.cg.dart';
import 'package:beer_ledger/bounded_contexts/journal/application/undo_last_click.cg.dart';
import 'package:beer_ledger/bounded_contexts/journal/domain/click/click.dart';
import 'package:beer_ledger/bounded_contexts/journal/presentation/today_clicks_format.dart';
import 'package:beer_ledger/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Журнал тапов за сегодня и кнопка глобального undo.
///
/// Список рисует [clicksForTodayProvider], в Drift не ходит. Порядок строк —
/// как в провайдере. Пустой день — empty-state, не ошибка. Undo зовёт
/// [UndoLastClick], не репозиторий. Виджет — sliver для [CustomScrollView].
class TodayClicksSection extends ConsumerWidget {
  /// Создаёт секцию списка и кнопки undo.
  const TodayClicksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final clicks = ref.watch(clicksForTodayProvider);
    final undoState = ref.watch(undoLastClickProvider);

    ref.listen(undoLastClickProvider, (previous, next) {
      if (next.hasError && previous?.hasError != true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.undoLastTapError)));
      }
    });

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              l10n.todayClicksTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: undoState.isLoading
                    ? null
                    : () => ref.read(undoLastClickProvider.notifier).undo(),
                child: Text(l10n.undoLastTap),
              ),
            ),
          ),
        ),
        clicks.when(
          loading: () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
          error: (Object _, StackTrace _) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(l10n.todayClicksLoadError),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Text(l10n.todayClicksEmpty),
                ),
              );
            }
            return SliverList.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _TodayClickRow(click: items[index], locale: locale);
              },
            );
          },
        ),
      ],
    );
  }
}

class _TodayClickRow extends StatelessWidget {
  const _TodayClickRow({required this.click, required this.locale});

  final Click click;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final time = formatTodayClickTime(click, locale);
    final volume = formatTodayClickVolume(
      click,
      languageCode: locale.languageCode,
    );
    return ListTile(
      key: Key('today-click-${click.id.value}'),
      title: Text(time),
      trailing: volume == null ? null : Text(volume),
    );
  }
}
