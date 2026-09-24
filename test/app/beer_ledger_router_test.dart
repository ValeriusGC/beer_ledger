import 'dart:async';

import 'package:beer_ledger/app/router.dart';
import 'package:beer_ledger/l10n/app_localizations.dart';
import 'package:beer_ledger/bounded_contexts/portion/portion.dart';
import 'package:beer_ledger/bounded_contexts/journal/journal.dart';
import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _ReadyRecordClick extends RecordClick {
  @override
  FutureOr<void> build() {}
}

class _ReadyUndo extends UndoLastClick {
  @override
  FutureOr<void> build() {}
}

void main() {
  testWidgets('со settings кнопка назад возвращает на home', (tester) async {
    final router = GoRouter(routes: beerLedgerRoutes);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayBalanceProvider.overrideWithValue(
            AsyncData(
              PeriodBalances(
                totalsInBase: {
                  LedgerAxisKind.volume: SignedBaseDelta.volume(0),
                  LedgerAxisKind.energy: SignedBaseDelta.energy(0),
                  LedgerAxisKind.money: SignedBaseDelta.money(0),
                  LedgerAxisKind.joy: SignedBaseDelta.joy(0),
                },
              ),
            ),
          ),
          clicksForTodayProvider.overrideWithValue(const AsyncData(<Click>[])),
          recordClickProvider.overrideWith(() => _ReadyRecordClick()),
          undoLastClickProvider.overrideWith(() => _ReadyUndo()),
          currentClickerProvider.overrideWith(
            (ref) => Stream.value(beerHalfLiter()),
          ),
          volumeForLast7DaysProvider.overrideWithValue(
            AsyncData([
              for (var index = 0; index < 7; index++)
                DayVolume(day: DateTime(2026, 9, 15 + index), liters: 0),
            ]),
          ),
        ],
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Portion'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Beer 0.5'), findsOneWidget);
  });
}
