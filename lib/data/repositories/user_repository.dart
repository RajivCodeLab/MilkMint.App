import '../../models/user_role.dart';
import '../data_sources/local/auth_local_ds.dart';
import '../data_sources/remote/user_remote_ds.dart';

abstract class UserRepository {
  Future<User> getCurrentUser();
  Future<User> updateLanguage(String language);
  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    String? email,
    String? address,
    String? city,
    String? pincode,
  });
}

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  UserRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<User> getCurrentUser() async {
    final data = await _remoteDataSource.getCurrentUser();
    final user = User.fromJson(data);
    await _localDataSource.saveUser(user);
    return user;
  }

  @override
  Future<User> updateLanguage(String language) async {
    final data = await _remoteDataSource.updateLanguage(language);
    final user = User.fromJson(data['user'] ?? data);
    await _localDataSource.saveUser(user);
    return user;
  }

  @override
  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    String? email,
    String? address,
    String? city,
    String? pincode,
  }) async {
    final data = await _remoteDataSource.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      address: address,
      city: city,
      pincode: pincode,
    );
    final user = User.fromJson(data['user'] ?? data);
    await _localDataSource.saveUser(user);
    return user;
  }
}
