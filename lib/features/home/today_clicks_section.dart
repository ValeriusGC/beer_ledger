import 'package:beer_ledger/app/providers/clicks_for_today.cg.dart';
import 'package:beer_ledger/features/home/today_clicks_format.dart';
import 'package:beer_ledger/l10n/app_localizations.dart';
import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Журнал тапов за сегодня: рисует [clicksForTodayProvider], в Drift не ходит.
///
/// Порядок строк — как в провайдере, без повторной сортировки. Пустой день —
/// empty-state, не ошибка. Виджет — sliver, его кладут в [CustomScrollView].
class TodayClicksSection extends ConsumerWidget {
  /// Создаёт секцию списка, которая сама подписывается на тапы за сегодня.
  const TodayClicksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final clicks = ref.watch(clicksForTodayProvider);

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
      key: Key('today-click-${click.id}'),
      title: Text(time),
      trailing: volume == null ? null : Text(volume),
    );
  }
}
