import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kosfinder_vc/app/kos_finder_app.dart';
import 'package:kosfinder_vc/features/auth/data/auth_gateway.dart';
import 'package:kosfinder_vc/features/auth/data/auth_repository.dart';
import 'package:kosfinder_vc/features/auth/presentation/auth_login_screen.dart';
import 'package:kosfinder_vc/features/auth/presentation/auth_register_screen.dart';
import 'package:kosfinder_vc/features/auth/presentation/owner_home_screen.dart';
import 'package:kosfinder_vc/features/auth/providers/auth_provider.dart';

class FakeAuthGateway implements AuthGateway {
  FakeAuthGateway({
    required this.user,
    required this.session,
    this.signInError,
    this.signUpError,
  }) : controller = StreamController<AuthState>.broadcast();

  User? user;
  Session? session;
  final Object? signInError;
  final Object? signUpError;
  final StreamController<AuthState> controller;

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (signInError != null) {
      throw signInError!;
    }
    return AuthResponse(user: user, session: session);
  }

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    if (signUpError != null) {
      throw signUpError!;
    }
    return AuthResponse(user: user, session: session);
  }

  @override
  Future<void> signOut() async {
    user = null;
    session = null;
  }

  @override
  Session? get currentSession => session;

  @override
  User? get currentUser => user;

  @override
  Stream<AuthState> get onAuthStateChange => controller.stream;
}

User testUser() {
  return const User(
    id: 'owner-1',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    email: 'owner@example.com',
    createdAt: '2026-11-24T00:00:00Z',
  );
}

Session testSession(User user) {
  return Session(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    tokenType: 'bearer',
    user: user,
  );
}

Widget testAuthApp({required AuthRepository repository, required Widget home}) {
  return ChangeNotifierProvider(
    create: (_) => AuthProvider(repository),
    child: MaterialApp(home: home),
  );
}

void main() {
  late FakeAuthGateway gateway;
  late AuthRepository repository;

  setUp(() {
    final user = testUser();
    gateway = FakeAuthGateway(user: user, session: testSession(user));
    repository = AuthRepository.withGateway(gateway);
  });

  tearDown(() {
    gateway.controller.close();
  });

  testWidgets('login and register pages can be displayed', (tester) async {
    await tester.pumpWidget(
      testAuthApp(repository: repository, home: const AuthLoginScreen()),
    );
    await tester.pump();

    expect(find.text('Masuk Pemilik'), findsOneWidget);
    expect(find.byKey(const Key('auth-email')), findsOneWidget);
    expect(find.byKey(const Key('auth-password')), findsOneWidget);

    await tester.pumpWidget(
      testAuthApp(repository: repository, home: const AuthRegisterScreen()),
    );
    await tester.pump();

    expect(find.text('Daftar Pemilik'), findsOneWidget);
    expect(find.byKey(const Key('auth-submit-Daftar')), findsOneWidget);
  });

  testWidgets('empty login fields show validation', (tester) async {
    await tester.pumpWidget(
      testAuthApp(repository: repository, home: const AuthLoginScreen()),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('auth-submit-Masuk')));
    await tester.pump();

    expect(find.text('Email dan password wajib diisi.'), findsNWidgets(2));
    expect(gateway.currentSession, isNotNull);
  });

  testWidgets('authentication error is displayed', (tester) async {
    gateway = FakeAuthGateway(
      user: null,
      session: null,
      signInError: const AuthException(
        'Invalid login credentials',
        code: 'invalid_credentials',
      ),
    );
    repository = AuthRepository.withGateway(gateway);

    await tester.pumpWidget(
      testAuthApp(repository: repository, home: const AuthLoginScreen()),
    );
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('auth-email')),
      'owner@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('auth-password')),
      'wrong-password',
    );
    await tester.tap(find.byKey(const Key('auth-submit-Masuk')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth-error')), findsOneWidget);
    expect(find.text('Email atau password salah.'), findsOneWidget);
    expect(find.text('Kelola Kos'), findsNothing);
  });

  testWidgets('successful login opens owner landing page', (tester) async {
    await tester.pumpWidget(
      testAuthApp(repository: repository, home: const AuthLoginScreen()),
    );
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('auth-email')),
      'owner@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('auth-password')),
      'password123',
    );
    await tester.tap(find.byKey(const Key('auth-submit-Masuk')));
    await tester.pumpAndSettle();

    expect(find.text('Kelola Kos'), findsNWidgets(2));
    expect(find.text('owner@example.com'), findsOneWidget);
  });

  testWidgets('logout returns to public page', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(repository),
        child: MaterialApp(
          initialRoute: '/owner',
          routes: {
            '/': (_) => const Text('Daftar Kos'),
            '/owner': (_) => const OwnerHomeScreen(),
          },
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('logout-button')));
    await tester.pumpAndSettle();

    expect(find.text('Daftar Kos'), findsOneWidget);
    expect(find.text('Kelola Kos'), findsNothing);
  });

  testWidgets('owner access button opens login when unauthenticated', (
    tester,
  ) async {
    gateway = FakeAuthGateway(user: null, session: null);
    repository = AuthRepository.withGateway(gateway);

    await tester.pumpWidget(KosFinderApp(authRepository: repository));
    await tester.pump();

    await tester.tap(find.byKey(const Key('owner-access-button')));
    await tester.pumpAndSettle();

    expect(find.text('Masuk Pemilik'), findsOneWidget);
    expect(find.byKey(const Key('auth-submit-Masuk')), findsOneWidget);
  });
}
