import 'dart:async';

import 'package:beer_ledger/app/providers/record_click.cg.dart';
import 'package:beer_ledger/app/providers/today_balance.cg.dart';
import 'package:beer_ledger/features/home/home_page.dart';
import 'package:beer_ledger/l10n/app_localizations.dart';
import 'package:beer_ledger_core/beer_ledger_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

PeriodBalances _emptyBalances() {
  return PeriodBalances(
    totalsInBase: {
      LedgerAxisKind.volume: 0,
      LedgerAxisKind.energy: 0,
      LedgerAxisKind.money: 0,
      LedgerAxisKind.joy: 0,
    },
  );
}

/// [build] завершён — кнопка активна.
class _ReadyRecordClick extends RecordClick {
  @override
  FutureOr<void> build() {}
}

/// [build] не завершается — кнопка в loading.
class _LoadingRecordClick extends RecordClick {
  @override
  FutureOr<void> build() => Completer<void>().future;
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required RecordClick recordClick,
}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        todayBalanceProvider.overrideWithValue(AsyncData(_emptyBalances())),
        recordClickProvider.overrideWith(() => recordClick),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomePage(),
      ),
    ),
  );
}

void main() {
  testWidgets('подпись кнопки — Beer 0.5 на en', (tester) async {
    await _pumpHome(tester, recordClick: _ReadyRecordClick());

    expect(find.text('Beer 0.5'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('isLoading — кнопка disabled', (tester) async {
    await _pumpHome(tester, recordClick: _LoadingRecordClick());

    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });
}
