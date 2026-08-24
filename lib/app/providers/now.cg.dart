import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'now.cg.g.dart';

/// Текущий момент для границ календарного «сегодня».
///
/// Журнал берёт из этого [DateTime] только локальную дату: часы и минуты
/// на фильтр дня не влияют.
@riverpod
DateTime now(Ref ref) => DateTime.now();
