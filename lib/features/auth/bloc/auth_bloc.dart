import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/local_storage_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LocalStorageRepository _repository;
  final _uuid = const Uuid();

  AuthBloc(this._repository) : super(AuthInitial()) {
    on<CheckAuthRequested>(_onCheckAuthRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthRequested(
    CheckAuthRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await Future.delayed(const Duration(seconds: 2));
      final user = await _repository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _repository.login(event.email, event.password);
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const AuthError('Invalid email or password'));
      }
    } catch (e) {
      emit(const AuthError('An error occurred during login'));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // DUPLICATE EMAIL CHECK: Pehle check kar rahe hain ke email pehle se exist karti hai ya nahi
      final isEmailTaken = await _repository.isEmailRegistered(event.email);
      if (isEmailTaken) {
        emit(const AuthError('This email is already registered!'));
        return;
      }

      final user = User(
        id: _uuid.v4(),
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
        gender: event.gender,
      );

      await _repository.saveUser(user);

      // Auto login after registration
      final loggedInUser = await _repository.login(event.email, event.password);
      if (loggedInUser != null) {
        emit(Authenticated(loggedInUser));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _repository.logout();
    emit(Unauthenticated());
  }
}
