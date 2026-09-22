import 'package:beer_ledger/app/providers/today_balance.cg.dart';
import 'package:beer_ledger/features/home/today_balance_format.dart';
import 'package:beer_ledger/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Карточка четырёх итогов за сегодня.
///
/// Сама читает [todayBalanceProvider]. Суммы не считает и в репозиторий не
/// ходит: базовые единицы в подписи переводит [formatTodayBalanceLines].
/// Пустые итоги рисуются нулями.
class TodayBalanceCard extends ConsumerWidget {
  /// Создаёт карточку, которая подписывается на баланс за сегодня.
  const TodayBalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ref
        .watch(todayBalanceProvider)
        .when(
          loading: () => const CircularProgressIndicator(),
          error: (Object _, StackTrace _) => Text(l10n.todayBalanceLoadError),
          data: (balances) {
            final lines = formatTodayBalanceLines(
              balances,
              languageCode: Localizations.localeOf(context).languageCode,
            );
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BalanceAxis(
                      label: l10n.todayBalanceVolumeLabel,
                      value: lines.volume,
                      valueKey: const Key('today-balance-volume'),
                    ),
                    const SizedBox(height: 12),
                    _BalanceAxis(
                      label: l10n.todayBalanceEnergyLabel,
                      value: lines.energy,
                      valueKey: const Key('today-balance-energy'),
                    ),
                    const SizedBox(height: 12),
                    _BalanceAxis(
                      label: l10n.todayBalanceMoneyLabel,
                      value: lines.money,
                      valueKey: const Key('today-balance-money'),
                    ),
                    const SizedBox(height: 12),
                    _BalanceAxis(
                      label: l10n.todayBalanceJoyLabel,
                      value: lines.joy,
                      valueKey: const Key('today-balance-joy'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }
}

class _BalanceAxis extends StatelessWidget {
  const _BalanceAxis({
    required this.label,
    required this.value,
    required this.valueKey,
  });

  final String label;
  final String value;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodyMedium),
        Text(value, key: valueKey, style: textTheme.titleLarge),
      ],
    );
  }
}
