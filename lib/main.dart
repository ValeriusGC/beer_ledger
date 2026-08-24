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

/// Корневой виджет: тема Material 3 и заглушка домашнего экрана.
///
/// Feature-экраны ещё не подключены. Провайдеры читаются из [ProviderScope]
/// в [main]; этот виджет их не создаёт и в базу не ходит.
class BeerLedgerApp extends StatelessWidget {
  const BeerLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Пивомер',
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
/// провайдеры.
class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Пивомер')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Beer Ledger — iter 1.1 core ✅'),
            const SizedBox(height: 8),
            Text('core $beerLedgerCoreVersion'),
            const SizedBox(height: 8),
            Text(beerHalfLiter().title),
            const SizedBox(height: 24),
            const Text('Следующий шаг: iter 2 — persistence + Riverpod'),
          ],
        ),
      ),
    );
  }
}
