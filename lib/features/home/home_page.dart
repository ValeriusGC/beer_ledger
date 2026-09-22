import 'package:beer_ledger/app/flavor.dart';
import 'package:beer_ledger/app/providers/record_click.cg.dart';
import 'package:beer_ledger/features/home/today_balance_card.dart';
import 'package:beer_ledger/features/home/today_clicks_section.dart';
import 'package:beer_ledger/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Главный экран приложения: баланс, запись тапа и журнал за сегодня.
///
/// Shell на [CustomScrollView]. Провайдеры читают дочерние [ConsumerWidget],
/// кроме кнопки записи — она смотрит [recordClickProvider] здесь.
class HomePage extends ConsumerWidget {
  /// Создаёт главный экран с карточкой, кнопкой записи и журналом за сегодня.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recordState = ref.watch(recordClickProvider);

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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (isDevFlavor)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: Text(l10n.devBadge)),
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: TodayBalanceCard()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: recordState.isLoading
                    ? null
                    : () => ref.read(recordClickProvider.notifier).record(),
                child: Text(l10n.recordBeerTap),
              ),
            ),
          ),
          const TodayClicksSection(),
        ],
      ),
    );
  }
}
