enum AuthErrorType {
  validation,
  invalidCredentials,
  emailAlreadyRegistered,
  connection,
  authentication,
  unknown,
}

class AuthRepositoryException implements Exception {
  const AuthRepositoryException({required this.type, required this.message});

  final AuthErrorType type;
  final String message;

  @override
  String toString() => message;
}
