import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kosfinder_vc/features/auth/data/auth_gateway.dart';
import 'package:kosfinder_vc/features/auth/data/auth_repository.dart';
import 'package:kosfinder_vc/features/auth/models/auth_error.dart';

class FakeAuthGateway implements AuthGateway {
  FakeAuthGateway({
    required this.response,
    this.signUpError,
    this.signInError,
    this.signOutError,
    this._session,
    this._user,
  }) : authStateController = StreamController<AuthState>.broadcast();

  final AuthResponse response;
  final Object? signUpError;
  final Object? signInError;
  final Object? signOutError;
  final StreamController<AuthState> authStateController;
  Session? _session;
  User? _user;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    if (signUpError != null) {
      throw signUpError!;
    }
    _session = response.session;
    _user = response.user;
    return response;
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (signInError != null) {
      throw signInError!;
    }
    _session = response.session;
    _user = response.user;
    return response;
  }

  @override
  Future<void> signOut() async {
    if (signOutError != null) {
      throw signOutError!;
    }
    _session = null;
    _user = null;
  }

  @override
  Session? get currentSession => _session;

  @override
  User? get currentUser => _user;

  @override
  Stream<AuthState> get onAuthStateChange => authStateController.stream;
}

User fakeUser() {
  return const User(
    id: 'user-1',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    email: 'owner@example.com',
    createdAt: '2026-11-24T00:00:00Z',
  );
}

Session fakeSession(User user) {
  return Session(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    tokenType: 'bearer',
    user: user,
  );
}

void main() {
  late User user;
  late Session session;

  setUp(() {
    user = fakeUser();
    session = fakeSession(user);
  });

  tearDown(() async {
    // Each test creates its own gateway; controllers are closed in tests that
    // use them directly.
  });

  test('register succeeds with a session', () async {
    final gateway = FakeAuthGateway(
      response: AuthResponse(session: session),
      session: session,
      user: user,
    );
    final repository = AuthRepository.withGateway(gateway);

    await repository.register(
      email: 'owner@example.com',
      password: 'password123',
    );

    expect(repository.currentSession, same(session));
    gateway.authStateController.close();
  });

  test('login succeeds with a session', () async {
    final gateway = FakeAuthGateway(
      response: AuthResponse(session: session),
      session: session,
      user: user,
    );
    final repository = AuthRepository.withGateway(gateway);

    await repository.login(email: 'owner@example.com', password: 'password123');

    expect(repository.currentUser, same(user));
    gateway.authStateController.close();
  });

  test('logout clears the current session', () async {
    final gateway = FakeAuthGateway(
      response: AuthResponse(session: session),
      session: session,
      user: user,
    );
    final repository = AuthRepository.withGateway(gateway);

    await repository.logout();

    expect(repository.currentSession, isNull);
    gateway.authStateController.close();
  });

  test('empty credentials are rejected before calling Supabase', () async {
    final gateway = FakeAuthGateway(response: AuthResponse());
    final repository = AuthRepository.withGateway(gateway);

    try {
      await repository.login(email: '', password: '');
      fail('Expected validation error');
    } on AuthRepositoryException catch (error) {
      expect(error.type, AuthErrorType.validation);
    }
    gateway.authStateController.close();
  });

  test('invalid credentials are mapped safely', () async {
    final gateway = FakeAuthGateway(
      response: AuthResponse(),
      signInError: const AuthException(
        'Invalid login credentials',
        code: 'invalid_credentials',
      ),
    );
    final repository = AuthRepository.withGateway(gateway);

    try {
      await repository.login(
        email: 'owner@example.com',
        password: 'wrong-password',
      );
      fail('Expected invalid credentials error');
    } on AuthRepositoryException catch (error) {
      expect(error.type, AuthErrorType.invalidCredentials);
    }
    gateway.authStateController.close();
  });

  test('duplicate email is mapped safely', () async {
    final gateway = FakeAuthGateway(
      response: AuthResponse(),
      signUpError: const AuthException(
        'User already registered',
        code: 'user_already_exists',
      ),
    );
    final repository = AuthRepository.withGateway(gateway);

    try {
      await repository.register(
        email: 'owner@example.com',
        password: 'password123',
      );
      fail('Expected duplicate email error');
    } on AuthRepositoryException catch (error) {
      expect(error.type, AuthErrorType.emailAlreadyRegistered);
    }
    gateway.authStateController.close();
  });

  test('connection failure is mapped separately', () async {
    final gateway = FakeAuthGateway(
      response: AuthResponse(),
      signInError: const SocketException('offline'),
    );
    final repository = AuthRepository.withGateway(gateway);

    try {
      await repository.login(
        email: 'owner@example.com',
        password: 'password123',
      );
      fail('Expected connection error');
    } on AuthRepositoryException catch (error) {
      expect(error.type, AuthErrorType.connection);
    }
    await gateway.authStateController.close();
  });
}
