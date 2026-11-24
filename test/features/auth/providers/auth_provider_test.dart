import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kosfinder_vc/features/auth/data/auth_gateway.dart';
import 'package:kosfinder_vc/features/auth/data/auth_repository.dart';
import 'package:kosfinder_vc/features/auth/models/auth_state.dart';
import 'package:kosfinder_vc/features/auth/providers/auth_provider.dart';

class ProviderAuthGateway implements AuthGateway {
  ProviderAuthGateway({required this.session, required this.user})
    : controller = StreamController<AuthState>.broadcast(
        onCancel: () {
          cancelCount++;
        },
      );

  final Session? session;
  final User? user;
  final StreamController<AuthState> controller;
  static int cancelCount = 0;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return AuthResponse(session: session);
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return AuthResponse(session: session);
  }

  @override
  Future<void> signOut() async {}

  @override
  Session? get currentSession => session;

  @override
  User? get currentUser => user;

  @override
  Stream<AuthState> get onAuthStateChange => controller.stream;
}

User providerUser() {
  return const User(
    id: 'user-1',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    email: 'owner@example.com',
    createdAt: '2026-11-24T00:00:00Z',
  );
}

Session providerSession(User user) {
  return Session(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    tokenType: 'bearer',
    user: user,
  );
}

void main() {
  setUp(() {
    ProviderAuthGateway.cancelCount = 0;
  });

  test(
    'provider initializes authenticated state from current session',
    () async {
      final user = providerUser();
      final gateway = ProviderAuthGateway(
        user: user,
        session: providerSession(user),
      );
      final provider = AuthProvider(AuthRepository.withGateway(gateway));

      await provider.initialize();

      expect(provider.state.status, AuthStatus.authenticated);
      expect(provider.user, same(user));
      provider.dispose();
      await gateway.controller.close();
    },
  );

  test('provider updates state after logout', () async {
    final user = providerUser();
    final gateway = ProviderAuthGateway(
      user: user,
      session: providerSession(user),
    );
    final provider = AuthProvider(AuthRepository.withGateway(gateway));

    await provider.logout();

    expect(provider.state.status, AuthStatus.unauthenticated);
    provider.dispose();
    await gateway.controller.close();
  });

  test('provider follows authentication stream changes', () async {
    final user = providerUser();
    final session = providerSession(user);
    final gateway = ProviderAuthGateway(user: user, session: session);
    final provider = AuthProvider(AuthRepository.withGateway(gateway));

    gateway.controller.add(AuthState(AuthChangeEvent.signedIn, session));
    await Future<void>.delayed(Duration.zero);
    expect(provider.state.status, AuthStatus.authenticated);

    gateway.controller.add(const AuthState(AuthChangeEvent.signedOut, null));
    await Future<void>.delayed(Duration.zero);
    expect(provider.state.status, AuthStatus.unauthenticated);

    provider.dispose();
    await gateway.controller.close();
  });

  test('provider disposes authentication subscription', () async {
    final gateway = ProviderAuthGateway(user: null, session: null);
    final provider = AuthProvider(AuthRepository.withGateway(gateway));

    provider.dispose();
    await Future<void>.delayed(Duration.zero);

    expect(ProviderAuthGateway.cancelCount, 1);
    await gateway.controller.close();
  });

  test('provider exposes session error after failed login', () async {
    final gateway = ProviderAuthGateway(user: null, session: null);
    final provider = AuthProvider(AuthRepository.withGateway(gateway));

    final success = await provider.login(email: '', password: '');

    expect(success, isFalse);
    expect(provider.state.status, AuthStatus.error);
    expect(provider.state.errorMessage, 'Email dan password wajib diisi.');
    provider.dispose();
    await gateway.controller.close();
  });
}
