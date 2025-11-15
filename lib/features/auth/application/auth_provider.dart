import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/data_sources/local/auth_local_ds.dart';
import '../../../data/data_sources/remote/auth_remote_ds.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../models/user_role.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return AuthService(firebaseAuth);
});

/// Firebase Auth provider
final firebaseAuthProvider = Provider((ref) {
  return firebase_auth.FirebaseAuth.instance;
});

/// Auth local data source provider
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource();
});

/// Auth remote data source provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSource(apiClient);
});

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);

  return AuthRepositoryImpl(
    authService,
    localDataSource,
    remoteDataSource,
  );
});

/// Auth state notifier provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return AuthNotifier(
    repository,
    notificationService: notificationService,
  );
});

/// Current user provider (computed from auth state)
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
});

/// User role provider (computed from current user)
final userRoleProvider = Provider<UserRole?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role;
});

/// Is authenticated provider (computed from auth state)
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    authenticated: (_) => true,
    orElse: () => false,
  );
});

/// Is loading provider (computed from auth state)
final isAuthLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    sendingOtp: () => true,
    verifyingOtp: () => true,
    authenticating: () => true,
    orElse: () => false,
  );
});
