import 'package:beer_ledger/app/flavor.dart';
import 'package:beer_ledger/features/home/home_page.dart';
import 'package:beer_ledger/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Запускает приложение внутри [ProviderScope].
///
/// Scope — единственное место, где живёт состояние провайдеров. Без него
/// не к чему привязать [WidgetRef] в виджетах и [ProviderContainer] в тестах.
void main() {
  runApp(const ProviderScope(child: BeerLedgerApp()));
}

/// Корневой виджет: тема Material 3, локализации и главный экран.
///
/// Провайдеры читаются из [ProviderScope] в [main]; этот виджет их не создаёт
/// и в базу не ходит.
///
/// [onGenerateTitle] нужен потому, что [BuildContext] в [build] ещё не видит
/// [AppLocalizations]: delegates живут внутри [MaterialApp].
/// DEBUG-баннер — только у flavor `dev`: у `prod` его нет даже в debug-run.
class BeerLedgerApp extends StatelessWidget {
  const BeerLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: isDevFlavor,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
