import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await authRepository.restoreSession();
      result.fold(
        (failure) => emit(AuthUnauthenticated()),
        (user) {
          if (user != null) {
            emit(AuthAuthenticated(user));
          } else {
            emit(AuthUnauthenticated());
          }
        },
      );
    });

    on<AuthSignOut>((event, emit) async {
      emit(AuthLoading());
      await authRepository.signOut();
      emit(AuthUnauthenticated());
    });
    
    // Additional handlers to be implemented when UI connects
  }
}
