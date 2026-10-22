enum AppAuthException {
  sessionExpired('Session has expired. Log in again.'),
  userNotFound('User not found'),
  userAlreadyExists('User already exists'),
  invalidCredentials('Invalid credentials'),
  networkError('Network error'),
  unknownError('Unknown error'),
  overEmailSendRateLimit('Over email send rate limit');

  final String errorMessage;
  const AppAuthException(this.errorMessage);
}

enum AppAuthState { idle, userLoggedIn, userLoggedOut, userSignedUp }
