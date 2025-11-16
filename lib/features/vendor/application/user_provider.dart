import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../data/data_sources/remote/user_remote_ds.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../models/user_role.dart';
import '../../../features/auth/application/auth_provider.dart';

/// User remote data source provider
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserRemoteDataSource(apiClient);
});

/// User repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  return UserRepositoryImpl(remoteDataSource, localDataSource);
});

/// User provider notifier
class UserNotifier extends StateNotifier<AsyncValue<User?>> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> refreshUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> updateLanguage(String language) async {
    try {
      final user = await _repository.updateLanguage(language);
      state = AsyncValue.data(user);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    String? email,
    String? address,
    String? city,
    String? pincode,
  }) async {
    try {
      final user = await _repository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        address: address,
        city: city,
        pincode: pincode,
      );
      state = AsyncValue.data(user);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
      rethrow;
    }
  }
}

/// User provider
final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<User?>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserNotifier(repository);
});
