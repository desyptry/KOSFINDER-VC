import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auth_error.dart';
import 'auth_gateway.dart';

class AuthRepository {
  AuthRepository(SupabaseClient client)
    : this.withGateway(SupabaseAuthGateway(client));

  AuthRepository.withGateway(this._gateway);

  final AuthGateway _gateway;

  Future<void> register({
    required String email,
    required String password,
  }) async {
    _validateCredentials(email, password);

    try {
      final response = await _gateway.signUp(
        email: email.trim(),
        password: password,
      );
      if (response.session == null) {
        throw const AuthRepositoryException(
          type: AuthErrorType.authentication,
          message:
              'Registrasi belum membuat sesi. Pastikan verifikasi email '
              'dinonaktifkan di Supabase.',
        );
      }
    } on AuthRepositoryException {
      rethrow;
    } on AuthException catch (error) {
      throw _mapAuthException(error);
    } catch (error) {
      throw _mapUnexpectedError(error);
    }
  }

  Future<void> login({required String email, required String password}) async {
    _validateCredentials(email, password);

    try {
      final response = await _gateway.signIn(
        email: email.trim(),
        password: password,
      );
      if (response.session == null) {
        throw const AuthRepositoryException(
          type: AuthErrorType.authentication,
          message: 'Login gagal karena sesi tidak tersedia.',
        );
      }
    } on AuthRepositoryException {
      rethrow;
    } on AuthException catch (error) {
      throw _mapAuthException(error);
    } catch (error) {
      throw _mapUnexpectedError(error);
    }
  }

  Future<void> logout() async {
    try {
      await _gateway.signOut();
    } on AuthException catch (error) {
      throw _mapAuthException(error);
    } catch (error) {
      throw _mapUnexpectedError(error);
    }
  }

  Session? get currentSession => _gateway.currentSession;

  User? get currentUser => _gateway.currentUser;

  Stream<AuthState> get onAuthStateChange => _gateway.onAuthStateChange;

  static void _validateCredentials(String email, String password) {
    if (email.trim().isEmpty || password.isEmpty) {
      throw const AuthRepositoryException(
        type: AuthErrorType.validation,
        message: 'Email dan password wajib diisi.',
      );
    }
  }

  static AuthRepositoryException _mapAuthException(AuthException error) {
    final code = error.code?.toLowerCase();
    final message = error.message.toLowerCase();

    if (code == 'user_already_exists' ||
        code == 'email_exists' ||
        message.contains('already registered') ||
        message.contains('already exists')) {
      return const AuthRepositoryException(
        type: AuthErrorType.emailAlreadyRegistered,
        message: 'Email sudah terdaftar.',
      );
    }

    if (code == 'invalid_credentials' ||
        message.contains('invalid login credentials')) {
      return const AuthRepositoryException(
        type: AuthErrorType.invalidCredentials,
        message: 'Email atau password salah.',
      );
    }

    final statusCode = int.tryParse(error.statusCode ?? '');
    if (error is AuthRetryableFetchException ||
        (statusCode != null && statusCode >= 500)) {
      return const AuthRepositoryException(
        type: AuthErrorType.connection,
        message: 'Koneksi ke layanan autentikasi gagal.',
      );
    }

    return const AuthRepositoryException(
      type: AuthErrorType.authentication,
      message: 'Autentikasi gagal. Silakan coba lagi.',
    );
  }

  static AuthRepositoryException _mapUnexpectedError(Object error) {
    if (error is SocketException || error is TimeoutException) {
      return const AuthRepositoryException(
        type: AuthErrorType.connection,
        message: 'Koneksi ke layanan autentikasi gagal.',
      );
    }

    return const AuthRepositoryException(
      type: AuthErrorType.unknown,
      message: 'Terjadi kesalahan. Silakan coba lagi.',
    );
  }
}
