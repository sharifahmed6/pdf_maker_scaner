import '../../domain/entities/user_entity.dart';

abstract class SupabaseAuthDataSource {
  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> signUpWithEmail(String name, String email, String password);
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> signInWithApple();
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<UserEntity?> restoreSession();
}

class SupabaseAuthDataSourceImpl implements SupabaseAuthDataSource {
  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> signUpWithEmail(String name, String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> signInWithApple() async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    throw UnimplementedError();
  }

  @override
  Future<void> resetPassword(String email) async {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity?> restoreSession() async {
    return null;
  }
}
