import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';
import '../models/auth_error.dart';
import '../models/auth_state.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository) {
    _authStateSubscription = _repository.onAuthStateChange.listen(
      _handleAuthState,
      onError: _handleAuthStreamError,
    );
    unawaited(initialize());
  }

  final AuthRepository _repository;
  StreamSubscription<AuthState>? _authStateSubscription;

  AuthSessionState _state = const AuthSessionState.loading();

  AuthSessionState get state => _state;
  bool get isLoading => _state.status == AuthStatus.loading;
  User? get user => _state.user;
  Session? get session => _state.session;

  Future<void> initialize() async {
    final session = _repository.currentSession;
    final user = _repository.currentUser;
    _setSessionState(session, user);
  }

  Future<bool> register({required String email, required String password}) {
    return _runAuthAction(
      () => _repository.register(email: email, password: password),
    );
  }

  Future<bool> login({required String email, required String password}) {
    return _runAuthAction(
      () => _repository.login(email: email, password: password),
    );
  }

  Future<bool> logout() async {
    _state = const AuthSessionState.loading();
    notifyListeners();

    try {
      await _repository.logout();
      _state = const AuthSessionState.unauthenticated();
      notifyListeners();
      return true;
    } on AuthRepositoryException catch (error) {
      _setError(error.message);
      return false;
    }
  }

  Future<bool> _runAuthAction(Future<void> Function() action) async {
    _state = const AuthSessionState.loading();
    notifyListeners();

    try {
      await action();
      final session = _repository.currentSession;
      final user = _repository.currentUser;
      if (session == null || user == null) {
        _setError('Autentikasi gagal karena sesi tidak tersedia.');
        return false;
      }
      _setSessionState(session, user);
      return true;
    } on AuthRepositoryException catch (error) {
      _setError(error.message);
      return false;
    }
  }

  void _handleAuthState(AuthState authState) {
    _setSessionState(authState.session, authState.session?.user);
  }

  void _handleAuthStreamError(Object error, StackTrace stackTrace) {
    _setError('Perubahan sesi tidak dapat dipantau.');
  }

  void _setSessionState(Session? session, User? user) {
    if (session != null && user != null) {
      _state = AuthSessionState.authenticated(user: user, session: session);
    } else {
      _state = const AuthSessionState.unauthenticated();
    }
    notifyListeners();
  }

  void _setError(String message) {
    _state = AuthSessionState.error(message);
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_authStateSubscription?.cancel());
    super.dispose();
  }
}
