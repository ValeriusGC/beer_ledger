import 'package:fpdart/fpdart.dart';

import '../failure/failure.dart';

/// Результат domain-операции (ADR 002).
///
/// **Left** = [Failure], **Right** = успех.
typedef Result<T> = Either<Failure, T>;
