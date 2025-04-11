part of 'login_cubit.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final Map<String, dynamic> userData;

  LoginSuccess({required this.userData});
}

class LoginError extends LoginState {
  final String message;

  LoginError({required this.message});
}
