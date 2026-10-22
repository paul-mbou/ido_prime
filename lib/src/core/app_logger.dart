import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

void logDebug(String message) {
  if (kDebugMode) {
    Logger().d(message);
  }
}

void logError(String message) {
  if (kDebugMode) {
    Logger().e(message);
  }
}

void logWarning(String message) {
  if (kDebugMode) {
    Logger().w(message);
  }
}

void logInfo(String message) {
  if (kDebugMode) {
    Logger().i(message);
  }
}

void logTrace(String message) {
  if (kDebugMode) {
    Logger().t(message);
  }
}
