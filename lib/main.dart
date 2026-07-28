import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BeerLedgerApp());
}

/// Shell v0 — placeholder until feature screens land.
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
