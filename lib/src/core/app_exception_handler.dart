import 'package:ido_prime/src/core/app_enums.dart';
import 'package:ido_prime/src/core/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppExceptionHandler {
  static AppAuthException handleAuthException(Object exception) {
    logError('Error handling auth exception: $exception');
    return switch (exception) {
      AuthApiException exception => switch (exception.code) {
        'over_email_send_rate_limit' => AppAuthException.overEmailSendRateLimit,
        _ => AppAuthException.unknownError,
      },
      _ => AppAuthException.unknownError,
    };
  }
}
