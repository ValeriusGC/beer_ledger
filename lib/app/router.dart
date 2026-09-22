import 'package:beer_ledger/features/home/home_page.dart';
import 'package:beer_ledger/features/settings/settings_page.dart';
import 'package:go_router/go_router.dart';

/// Маршруты приложения: `/` — главный экран, `/settings` — порция.
///
/// Других маршрутов нет: ни shell, ни redirect, ни отдельных deep link.
final List<RouteBase> beerLedgerRoutes = [
  GoRoute(path: '/', builder: (context, state) => const HomePage()),
  GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
];

/// Один роутер на процесс.
///
/// Новый [GoRouter] на каждый rebuild сбрасывал бы стек, и со settings некуда было бы вернуться.
final GoRouter beerLedgerRouter = GoRouter(routes: beerLedgerRoutes);
