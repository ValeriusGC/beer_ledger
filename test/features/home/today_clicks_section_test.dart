import 'package:beer_ledger/app/providers/clicks_for_today.cg.dart';
import 'package:beer_ledger/features/home/today_clicks_section.dart';
import 'package:beer_ledger/l10n/app_localizations.dart';
import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Click _click({
  required String id,
  required DateTime at,
  List<AxisContribution> contributions = const [],
}) {
  return Click(
    id: id,
    clickerId: beerHalfLiter().id,
    at: at,
    contributions: contributions,
  );
}

Future<void> _pump(WidgetTester tester, AsyncValue<List<Click>> clicks) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [clicksForTodayProvider.overrideWithValue(clicks)],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: CustomScrollView(slivers: [TodayClicksSection()])),
      ),
    ),
  );
}

void main() {
  testWidgets('пустой сегодня — empty-state, не ошибка', (tester) async {
    await _pump(tester, const AsyncData(<Click>[]));

    expect(find.text('No taps today'), findsOneWidget);
    expect(find.text("Couldn't load today's taps"), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('один тап — время Hm и 0.5 L', (tester) async {
    final at = DateTime(2026, 9, 22, 14, 30);
    await _pump(
      tester,
      AsyncData([
        _click(
          id: 'click-1',
          at: at,
          contributions: [
            AxisContribution(
              kind: LedgerAxisKind.volume,
              signedBaseDelta: 500,
              enteredInId: VolumeUnit.liter.id,
            ),
          ],
        ),
      ]),
    );

    expect(find.byKey(const Key('today-click-click-1')), findsOneWidget);
    expect(find.text('14:30'), findsOneWidget);
    expect(find.text('0.5 L'), findsOneWidget);
  });

  testWidgets('loading — прогресс в секции', (tester) async {
    await _pump(tester, const AsyncLoading());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No taps today'), findsNothing);
    expect(find.byKey(const Key('today-click-click-1')), findsNothing);
  });

  testWidgets('error — текст l10n, без сырого exception', (tester) async {
    await _pump(
      tester,
      AsyncError<List<Click>>(StateError('boom'), StackTrace.empty),
    );

    expect(find.text("Couldn't load today's taps"), findsOneWidget);
    expect(find.textContaining('StateError'), findsNothing);
    expect(find.textContaining('boom'), findsNothing);
    expect(find.text('No taps today'), findsNothing);
  });
}
