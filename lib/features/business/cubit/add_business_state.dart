part of 'add_business_cubit.dart';

@immutable
abstract class AddBusinessState {}

class AddBusinessInitial extends AddBusinessState {}

class AddBusinessLoading extends AddBusinessState {}

class AddBusinessSuccess extends AddBusinessState {
  final String message;

  AddBusinessSuccess({required this.message});
}

class AddBusinessError extends AddBusinessState {
  final String message;

  AddBusinessError({required this.message});
}
