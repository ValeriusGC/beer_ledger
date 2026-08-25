import 'package:beer_ledger/l10n/app_localizations.dart';
import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Запускает приложение внутри [ProviderScope].
///
/// Scope — единственное место, где живёт состояние провайдеров. Без него
/// не к чему привязать [WidgetRef] в виджетах и [ProviderContainer] в тестах.
void main() {
  runApp(const ProviderScope(child: BeerLedgerApp()));
}

/// Корневой виджет: тема Material 3, локализации и заглушка домашнего экрана.
///
/// Feature-экраны ещё не подключены. Провайдеры читаются из [ProviderScope]
/// в [main]; этот виджет их не создаёт и в базу не ходит.
///
/// [onGenerateTitle] нужен потому, что [BuildContext] в [build] ещё не видит
/// [AppLocalizations]: delegates живут внутри [MaterialApp].
class BeerLedgerApp extends StatelessWidget {
  const BeerLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const HomePlaceholderPage(),
    );
  }
}

/// Заглушка домашнего экрана, пока нет feature-слоя.
///
/// Намеренно [StatelessWidget], не [ConsumerWidget]: экран ещё не читает
/// провайдеры. Подписи — из [AppLocalizations]; title у [beerHalfLiter]
/// остаётся доменным литералом core.
class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.placeholderHeadline),
            const SizedBox(height: 8),
            Text(l10n.coreVersion(beerLedgerCoreVersion)),
            const SizedBox(height: 8),
            Text(beerHalfLiter().title),
            const SizedBox(height: 24),
            Text(l10n.placeholderNextStep),
          ],
        ),
      ),
    );
  }
}
