import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus { loading, authenticated, unauthenticated, error }

class AuthSessionState {
  const AuthSessionState({
    required this.status,
    this.user,
    this.session,
    this.errorMessage,
  });

  const AuthSessionState.loading() : this(status: AuthStatus.loading);

  const AuthSessionState.unauthenticated()
    : this(status: AuthStatus.unauthenticated);

  const AuthSessionState.authenticated({
    required User user,
    required Session session,
  }) : this(status: AuthStatus.authenticated, user: user, session: session);

  const AuthSessionState.error(String message)
    : this(status: AuthStatus.error, errorMessage: message);

  final AuthStatus status;
  final User? user;
  final Session? session;
  final String? errorMessage;
}
