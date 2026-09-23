import 'package:beer_ledger/app/flavor.dart';
import 'package:beer_ledger/app/providers/current_clicker.cg.dart';
import 'package:beer_ledger/app/providers/record_click.cg.dart';
import 'package:beer_ledger/features/home/today_balance_card.dart';
import 'package:beer_ledger/features/home/today_clicks_format.dart';
import 'package:beer_ledger/features/home/today_clicks_section.dart';
import 'package:beer_ledger/features/home/week_volume_chart.dart';
import 'package:beer_ledger/l10n/app_localizations.dart';
import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Порог Material compact: уже окно — колонка, иначе карточка и график в ряд.
const _homeWideWidth = 600.0;

/// Главный экран приложения: баланс, запись тапа, журнал и объём за неделю.
///
/// Shell на [CustomScrollView]. Провайдеры читают дочерние [ConsumerWidget],
/// кроме кнопки записи — она смотрит [recordClickProvider] здесь.
/// Ширина — [MediaQuery.sizeOf]: уже [_homeWideWidth] график под журналом,
/// иначе он стоит рядом с карточкой.
class HomePage extends ConsumerWidget {
  /// Создаёт главный экран с карточкой, кнопкой записи, журналом и графиком.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recordState = ref.watch(recordClickProvider);
    final clickerState = ref.watch(currentClickerProvider);
    // Пока порция ещё грузится, кнопку гасим так же, как при повторном тапе.
    // Иначе нажатие уходит в record() и пропадает молча: раньше пресет был
    // синхронным, и тап всегда писался.
    final tapDisabled = recordState.isLoading || clickerState.isLoading;

    ref.listen(recordClickProvider, (previous, next) {
      if (next.hasError && previous?.hasError != true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.recordClickError)));
      }
      if (previous?.isLoading == true && !next.isLoading && !next.hasError) {
        HapticFeedback.lightImpact();
      }
    });

    final wide = MediaQuery.sizeOf(context).width >= _homeWideWidth;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (isDevFlavor)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: Text(l10n.devBadge)),
            ),
          IconButton(
            tooltip: l10n.homeSettingsTooltip,
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          if (wide)
            const SliverToBoxAdapter(
              child: Row(
                key: Key('home-balance-chart-row'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: TodayBalanceCard()),
                  Expanded(child: WeekVolumeChart()),
                ],
              ),
            )
          else
            const SliverToBoxAdapter(child: TodayBalanceCard()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: tapDisabled
                    ? null
                    : () => ref.read(recordClickProvider.notifier).record(),
                child: Text(
                  l10n.recordBeerTap(
                    formatRecordBeerVolume(
                      clickerState.asData?.value ?? beerHalfLiter(),
                      languageCode: Localizations.localeOf(
                        context,
                      ).languageCode,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const TodayClicksSection(),
          if (!wide) const SliverToBoxAdapter(child: WeekVolumeChart()),
        ],
      ),
    );
  }
}
