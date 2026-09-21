import 'package:beer_ledger/app/flavor.dart';
import 'package:beer_ledger/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Главный экран приложения: баланс за сегодня и блоки итерации 3.
///
/// Shell на [CustomScrollView]: сюда по задачам v1.3 добавляются карточка,
/// кнопка записи, список и график. Провайдеры читают дочерние [ConsumerWidget],
/// не этот виджет.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          // Карточка баланса — следующий шов (today_balance_card.dart).
          const SliverToBoxAdapter(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}
