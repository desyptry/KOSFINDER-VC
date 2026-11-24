import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthGateway {
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  });

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Session? get currentSession;

  User? get currentUser;

  Stream<AuthState> get onAuthStateChange;
}

class SupabaseAuthGateway implements AuthGateway {
  SupabaseAuthGateway(this.client);

  final SupabaseClient client;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return client.auth.signUp(email: email, password: password);
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() => client.auth.signOut();

  @override
  Session? get currentSession => client.auth.currentSession;

  @override
  User? get currentUser => client.auth.currentUser;

  @override
  Stream<AuthState> get onAuthStateChange => client.auth.onAuthStateChange;
}
