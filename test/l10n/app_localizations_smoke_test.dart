import 'package:beer_ledger/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Минимальный [MaterialApp] с delegates — без Riverpod и drift.
Widget _l10nHarness(Locale locale) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => Text(AppLocalizations.of(context).appTitle),
    ),
  );
}

void main() {
  testWidgets('appTitle на en — Beer Ledger, не Пивомер', (tester) async {
    await tester.pumpWidget(_l10nHarness(const Locale('en')));

    expect(find.text('Beer Ledger'), findsOneWidget);
    expect(find.text('Пивомер'), findsNothing);
  });

  testWidgets('appTitle на ru — Пивомер, не Beer Ledger', (tester) async {
    await tester.pumpWidget(_l10nHarness(const Locale('ru')));

    expect(find.text('Пивомер'), findsOneWidget);
    expect(find.text('Beer Ledger'), findsNothing);
  });
}
