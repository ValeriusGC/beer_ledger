import 'package:flutter/services.dart';

/// `true`, когда сборка запущена с `--flavor dev`.
bool get isDevFlavor => appFlavor == 'dev';
