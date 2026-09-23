import 'package:beer_ledger/l10n/app_localizations.dart';
import 'package:beer_ledger/bounded_contexts/journal/journal.dart';
import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

PeriodBalances _balances({
  double volume = 0,
  double energy = 0,
  double money = 0,
  double joy = 0,
}) {
  return PeriodBalances(
    totalsInBase: {
      LedgerAxisKind.volume: volume,
      LedgerAxisKind.energy: energy,
      LedgerAxisKind.money: money,
      LedgerAxisKind.joy: joy,
    },
  );
}

Future<void> _pump(WidgetTester tester, AsyncValue<PeriodBalances> balance) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [todayBalanceProvider.overrideWithValue(balance)],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TodayBalanceCard(),
      ),
    ),
  );
}

String _value(WidgetTester tester, String key) {
  return tester.widget<Text>(find.byKey(Key(key))).data!;
}

void main() {
  testWidgets('1500 мл, 300000 cal, −45000 коп и joy 6', (tester) async {
    await _pump(
      tester,
      AsyncData(_balances(volume: 1500, energy: 300000, money: -45000, joy: 6)),
    );

    expect(_value(tester, 'today-balance-volume'), '1.5 L (1500 ml)');
    expect(_value(tester, 'today-balance-energy'), '+300 kcal');
    expect(_value(tester, 'today-balance-money'), '-450 ₽');
    expect(_value(tester, 'today-balance-joy'), '+6 pt');
  });

  testWidgets('пустой день — нули, не ошибка и не загрузка', (tester) async {
    await _pump(tester, AsyncData(_balances()));

    expect(_value(tester, 'today-balance-volume'), '0 L (0 ml)');
    expect(_value(tester, 'today-balance-energy'), '0 kcal');
    expect(_value(tester, 'today-balance-money'), '0 ₽');
    expect(_value(tester, 'today-balance-joy'), '0 pt');
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text("Couldn't load today's totals"), findsNothing);
  });

  testWidgets('loading — индикатор, значений нет', (tester) async {
    await _pump(tester, const AsyncLoading());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(const Key('today-balance-volume')), findsNothing);
    expect(find.byKey(const Key('today-balance-energy')), findsNothing);
    expect(find.byKey(const Key('today-balance-money')), findsNothing);
    expect(find.byKey(const Key('today-balance-joy')), findsNothing);
  });

  testWidgets('error — текст l10n, без StateError и Failure', (tester) async {
    await _pump(
      tester,
      AsyncError<PeriodBalances>(StateError('boom'), StackTrace.empty),
    );

    expect(find.text("Couldn't load today's totals"), findsOneWidget);
    expect(find.textContaining('StateError'), findsNothing);
    expect(find.textContaining('boom'), findsNothing);
    expect(find.textContaining('Failure'), findsNothing);
    expect(find.byKey(const Key('today-balance-volume')), findsNothing);
  });
}
